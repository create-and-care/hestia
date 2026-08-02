// Injected into the page via page.addScriptTag() and invoked through
// page.evaluate(() => window.__visualCheck.run()). Runs entirely inside the
// browser because it needs getComputedStyle to resolve custom properties,
// color-mix(), and inheritance the same way the browser actually renders
// them — reimplementing that in Node would just be a worse CSS engine.
(function () {
  const TOUCH_MIN = 36;
  const CONTRAST_MIN_NORMAL = 4.5;
  const CONTRAST_MIN_LARGE = 3.0;
  const SPACING_STEP = 4;
  const SPACING_TOLERANCE = 0.5;
  const FONT_WEIGHT_MAX = 600;
  const FONT_SIZE_MIN = 13;

  function isVisible(el) {
    if (!el || el.nodeType !== 1) return false;
    if (typeof el.checkVisibility === "function") {
      if (!el.checkVisibility({ checkVisibilityCSS: true })) return false;
    } else {
      const cs = getComputedStyle(el);
      if (cs.display === "none" || cs.visibility === "hidden") return false;
    }
    // .sr-only content (and its descendants) is deliberately clipped to
    // ~1px for sighted users while staying in the accessibility tree —
    // that's the whole point of the technique, not an overflow/touch-target
    // bug. A naive bounding-box check treats it as "visible" and its own
    // unwrapped text as "overflowing" its 1px box, which is noise, not a
    // real finding — so it's excluded here rather than per-rule.
    if (el.closest(".sr-only")) return false;
    const rect = el.getBoundingClientRect();
    return rect.width > 0 && rect.height > 0;
  }

  function cssPath(el, depth) {
    depth = depth || 3;
    const parts = [];
    let node = el;
    while (node && node.nodeType === 1 && depth-- > 0) {
      let part = node.tagName.toLowerCase();
      if (node.id) {
        parts.unshift(`${part}#${node.id}`);
        break;
      }
      const cls = (node.getAttribute("class") || "").trim().split(/\s+/).filter(Boolean).slice(0, 3).join(".");
      if (cls) part += `.${cls}`;
      parts.unshift(part);
      node = node.parentElement;
    }
    return parts.join(" > ");
  }

  // Class-list-only signature (no nth-of-type), so N visually-identical rows
  // (e.g. a list of shopping items sharing one class) collapse into a single
  // reported violation instead of flooding the report with duplicates.
  function groupKey(el) {
    const cls = (el.getAttribute("class") || "").trim().split(/\s+/).filter(Boolean).sort().join(".");
    return `${el.tagName.toLowerCase()}.${cls}`;
  }

  function parseColor(str) {
    const m = str.match(/rgba?\(([^)]+)\)/);
    if (!m) return { r: 255, g: 255, b: 255, a: 0 };
    const parts = m[1].split(",").map((s) => parseFloat(s));
    return { r: parts[0] || 0, g: parts[1] || 0, b: parts[2] || 0, a: parts.length > 3 ? parts[3] : 1 };
  }

  function compositeOver(fg, bg) {
    const a = fg.a + bg.a * (1 - fg.a);
    if (a === 0) return { r: 255, g: 255, b: 255, a: 0 };
    return {
      r: (fg.r * fg.a + bg.r * bg.a * (1 - fg.a)) / a,
      g: (fg.g * fg.a + bg.g * bg.a * (1 - fg.a)) / a,
      b: (fg.b * fg.a + bg.b * bg.a * (1 - fg.a)) / a,
      a
    };
  }

  // Walks from <html> down to el, alpha-compositing every ancestor's
  // background over a white base, so translucent tokens (color-mix overlays,
  // shadow tints) resolve to the actual rendered color instead of being
  // read as "transparent" and silently skipped.
  function effectiveBackground(el) {
    const chain = [];
    let node = el;
    while (node) {
      chain.push(node);
      node = node.parentElement;
    }
    let result = { r: 255, g: 255, b: 255, a: 1 };
    for (let i = chain.length - 1; i >= 0; i--) {
      const bg = parseColor(getComputedStyle(chain[i]).backgroundColor);
      if (bg.a > 0) result = compositeOver(bg, result);
    }
    return result;
  }

  function luminance(c) {
    const [rs, gs, bs] = [c.r, c.g, c.b].map((v) => {
      v /= 255;
      return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  function contrastRatio(fg, bg) {
    const l1 = luminance(fg);
    const l2 = luminance(bg);
    const [lighter, darker] = l1 > l2 ? [l1, l2] : [l2, l1];
    return (lighter + 0.05) / (darker + 0.05);
  }

  function toHex(c) {
    const h = (n) => Math.round(Math.max(0, Math.min(255, n))).toString(16).padStart(2, "0");
    return `#${h(c.r)}${h(c.g)}${h(c.b)}`;
  }

  // Elements that render their own direct visible text — the unit both the
  // contrast rule and the font weight/size rule operate on. Built once via a
  // TreeWalker over text nodes rather than checking every element, so a
  // wrapper <div> with no text of its own (but a font-weight it never uses)
  // doesn't get flagged.
  function collectTextElements(root) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode(node) {
        if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
        const parent = node.parentElement;
        if (!parent || !isVisible(parent)) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });
    const parents = new Set();
    let n;
    while ((n = walker.nextNode())) parents.add(n.parentElement);
    return Array.from(parents);
  }

  function pushDeduped(bucket, key, entry) {
    const existing = bucket.get(key);
    if (existing) {
      existing.count += 1;
    } else {
      entry.count = 1;
      bucket.set(key, entry);
    }
  }

  function checkTouchTargets(root) {
    const bucket = new Map();
    root.querySelectorAll("a, button, input, select, [role=button], [onclick]").forEach((el) => {
      if (!isVisible(el)) return;
      if (el.tagName === "A" && el.closest("p")) return; // in-flow text link, not a tap target
      const rect = el.getBoundingClientRect();
      const minDim = Math.min(rect.width, rect.height);
      if (minDim < TOUCH_MIN) {
        pushDeduped(bucket, `touch:${groupKey(el)}:${minDim.toFixed(0)}`, {
          rule: "touch_target",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `${minDim.toFixed(1)}px (need >= ${TOUCH_MIN}px)`
        });
      }
    });
    return Array.from(bucket.values());
  }

  function checkOverflow(root) {
    const violations = [];
    const doc = document.documentElement;
    if (doc.scrollWidth > doc.clientWidth) {
      violations.push({
        rule: "overflow_page",
        selector: "html",
        signature: "html",
        value: `scrollWidth=${doc.scrollWidth} clientWidth=${doc.clientWidth} (overflow=${doc.scrollWidth - doc.clientWidth}px)`
      });
    }

    function walk(el) {
      if (!isVisible(el)) return;
      const cs = getComputedStyle(el);
      const overflowAmt = el.scrollWidth - el.clientWidth;
      // "auto"/"scroll" scroll instead of visibly overflowing; "hidden"/"clip"
      // clip instead — none of the four ever spill into neighboring layout,
      // so none is the "Débordement horizontal" this rule exists to catch.
      // Without this, e.g. a `truncate` (overflow-x: hidden) element's
      // unwrapped text measures as "overflowing" its own clipped box, which
      // is the technique working as intended, not a bug.
      const clipsOrScrolls = [ "auto", "scroll", "hidden", "clip" ].includes(cs.overflowX);
      if (overflowAmt > 2 && !clipsOrScrolls) {
        violations.push({ rule: "overflow_container", selector: cssPath(el), signature: groupKey(el), value: `${overflowAmt.toFixed(1)}px` });
        return; // don't descend — children of an overflowing container trivially overflow too
      }
      Array.from(el.children).forEach(walk);
    }
    walk(root);
    return violations;
  }

  function checkContrast(textElements) {
    const bucket = new Map();
    textElements.forEach((el) => {
      const cs = getComputedStyle(el);
      const fg = parseColor(cs.color);
      if (fg.a === 0) return;
      const bg = effectiveBackground(el);
      const fontSize = parseFloat(cs.fontSize);
      const fontWeight = parseInt(cs.fontWeight, 10);
      const isLarge = fontSize >= 24 || (fontSize >= 19 && fontWeight >= 600);
      const min = isLarge ? CONTRAST_MIN_LARGE : CONTRAST_MIN_NORMAL;
      const ratio = contrastRatio(fg, bg);
      if (ratio < min) {
        pushDeduped(bucket, `contrast:${groupKey(el)}:${toHex(fg)}:${toHex(bg)}`, {
          rule: "contrast",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `${ratio.toFixed(2)}:1 (need >= ${min}:1) — text ${toHex(fg)} on ${toHex(bg)}, ${fontSize.toFixed(0)}px/${fontWeight}`
        });
      }
    });
    return Array.from(bucket.values());
  }

  function checkSpacing(root) {
    const bucket = new Map();
    const histogram = {};
    const PROPS = ["marginTop", "marginBottom", "paddingTop", "paddingBottom"];
    root.querySelectorAll("*").forEach((el) => {
      if (!isVisible(el)) return;
      const cs = getComputedStyle(el);
      PROPS.forEach((prop) => {
        const val = parseFloat(cs[prop]);
        if (!val) return;
        const rounded = Math.round(val * 10) / 10;
        histogram[rounded] = (histogram[rounded] || 0) + 1;
        const remainder = val % SPACING_STEP;
        const offScale = Math.min(remainder, SPACING_STEP - remainder) > SPACING_TOLERANCE;
        if (offScale) {
          pushDeduped(bucket, `spacing:${groupKey(el)}:${prop}:${rounded}`, {
            rule: "spacing_scale",
            selector: cssPath(el),
            signature: `${groupKey(el)}:${prop}`,
            value: `${prop.replace(/([A-Z])/g, "-$1").toLowerCase()}: ${rounded}px (not a multiple of ${SPACING_STEP}px)`
          });
        }
      });
    });
    return { violations: Array.from(bucket.values()), histogram };
  }

  function checkTypeScale(textElements) {
    const bucket = new Map();
    textElements.forEach((el) => {
      const cs = getComputedStyle(el);
      const weight = parseInt(cs.fontWeight, 10);
      const size = parseFloat(cs.fontSize);
      if (weight > FONT_WEIGHT_MAX) {
        pushDeduped(bucket, `weight:${groupKey(el)}:${weight}`, {
          rule: "font_weight",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `font-weight: ${weight} (cap is ${FONT_WEIGHT_MAX})`
        });
      }
      if (size < FONT_SIZE_MIN) {
        pushDeduped(bucket, `size:${groupKey(el)}:${size}`, {
          rule: "font_size",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `font-size: ${size.toFixed(1)}px (floor is ${FONT_SIZE_MIN}px)`
        });
      }
    });
    return Array.from(bucket.values());
  }

  window.__visualCheck = {
    run() {
      const root = document.body;
      const textElements = collectTextElements(root);
      const spacing = checkSpacing(root);
      const violations = [
        ...checkTouchTargets(root),
        ...checkOverflow(root),
        ...checkContrast(textElements),
        ...spacing.violations,
        ...checkTypeScale(textElements)
      ];
      return { violations, spacingHistogram: spacing.histogram };
    },

    // Rule 4 — resolves a named CSS custom property to its rendered color by
    // painting a throwaway probe element with it, so color-mix()/var() chains
    // get resolved exactly as the browser would resolve them for real UI,
    // instead of being pattern-matched as CSS text.
    resolveToken(name) {
      const probe = document.createElement("div");
      probe.style.position = "absolute";
      probe.style.visibility = "hidden";
      probe.style.backgroundColor = `var(${name})`;
      document.body.appendChild(probe);
      const rgb = parseColor(getComputedStyle(probe).backgroundColor);
      probe.remove();
      return rgb;
    },

    deltaE76(hexA, hexB) {
      function lab(hex) {
        const r = parseInt(hex.slice(1, 3), 16) / 255;
        const g = parseInt(hex.slice(3, 5), 16) / 255;
        const b = parseInt(hex.slice(5, 7), 16) / 255;
        const lin = (c) => (c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
        const [rl, gl, bl] = [lin(r), lin(g), lin(b)];
        const x = rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375;
        const y = rl * 0.2126729 + gl * 0.7151522 + bl * 0.072175;
        const z = rl * 0.0193339 + gl * 0.119192 + bl * 0.9503041;
        const [xn, yn, zn] = [0.95047, 1.0, 1.08883];
        const f = (t) => (t > Math.pow(6 / 29, 3) ? Math.pow(t, 1 / 3) : t / (3 * Math.pow(6 / 29, 2)) + 4 / 29);
        const [fx, fy, fz] = [f(x / xn), f(y / yn), f(z / zn)];
        return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
      }
      const [l1, a1, b1] = lab(hexA);
      const [l2, a2, b2] = lab(hexB);
      return Math.sqrt((l1 - l2) ** 2 + (a1 - a2) ** 2 + (b1 - b2) ** 2);
    },

    toHex,
    parseColor
  };
})();
