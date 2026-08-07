// Injected into the page via page.evaluate() (see injectMeasure in run.mjs —
// not addScriptTag, which the app's CSP refuses) and invoked through
// page.evaluate(() => window.__visualCheck.run()). Runs entirely inside the
// browser because it needs getComputedStyle to resolve custom properties,
// color-mix(), and inheritance the same way the browser actually renders
// them — reimplementing that in Node would just be a worse CSS engine.
(function () {
  const TOUCH_MIN = 36;
  const TOUCH_MIN_COMPACT = 24; // WCAG 2.5.8 AA — see touchFloorFor below
  const CONTRAST_MIN_NORMAL = 4.5;
  const CONTRAST_MIN_LARGE = 3.0;
  const SPACING_STEP = 4;
  const SPACING_TOLERANCE = 0.5;
  const FONT_WEIGHT_MAX = 600;
  const FONT_SIZE_MIN = 13;

  // ── Scope of each rule ───────────────────────────────────────────────────
  // The rules below all encode "this is body UI" assumptions. Three classes of
  // element break those assumptions without being defects, and were producing
  // roughly two thirds of the report's volume — enough noise to hide the real
  // findings under it, which is the only way a measurement tool fails.

  // A counter pill, a keycap, a status dot: elements whose whole job is to be
  // small and which carry no prose. The 4px spacing grid and the 13px reading
  // floor are both about *text people read*, and neither says anything useful
  // here. Recognised by size rather than by class, so it needs no maintenance
  // as components are added.
  // Height rather than area: a keycap is wider than it is tall and its width
  // follows the glyph, so an area bound would let "⌘K" through and stop at
  // "⌥⌘K". Height is what actually says "this is a chip, not a line of body
  // text". The character bound is what keeps a real badge — one with a word in
  // it — inside the rules, since that one *is* text a person reads.
  const MICRO_MAX_HEIGHT = 24;
  const MICRO_MAX_CHARS = 3;

  function isMicroElement(el) {
    if (el.getBoundingClientRect().height > MICRO_MAX_HEIGHT) return false;

    return (el.textContent || "").trim().length <= MICRO_MAX_CHARS;
  }

  // A link inside running text is not a tap target — you read it, you don't
  // aim at it. The rule already knew this for <p>; a breadcrumb trail is the
  // same case, and it alone accounted for 582 of the 994 touch-target findings,
  // being rendered by 101 views.
  //
  // Deliberately *not* "any <a> inside a <ul>/<ol>": a list of links is the
  // standard shape of a navigation menu, where every item genuinely is a tap
  // target. Only a <nav> that names itself a breadcrumb qualifies, plus the
  // prose containers where a link cannot be anything but inline.
  // Matched on data-breadcrumb rather than on the aria-label, which is
  // translated — see Ui::BreadcrumbComponent.
  const TEXT_FLOW_ANCESTORS = "p, dd, blockquote, figcaption, nav[data-breadcrumb]";

  function isInTextFlow(el) {
    return el.tagName === "A" && el.closest(TEXT_FLOW_ANCESTORS) !== null;
  }

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

  // A checkbox is 16px square in every browser, and nobody aims at the box —
  // they tap the label, which activates the control. So the target is the
  // union of the two, and measuring the input alone reports a defect that
  // does not exist for anyone actually using the form.
  function effectiveTargetRect(el) {
    const rect = el.getBoundingClientRect();
    const labels = el.labels ? Array.from(el.labels) : [];
    if (labels.length === 0) return rect;

    return labels.reduce((acc, label) => {
      const l = label.getBoundingClientRect();
      const top = Math.min(acc.top, l.top);
      const left = Math.min(acc.left, l.left);
      return {
        top, left,
        width: Math.max(acc.left + acc.width, l.left + l.width) - left,
        height: Math.max(acc.top + acc.height, l.top + l.height) - top
      };
    }, rect);
  }

  // 36px is the design system's own bar, stricter than WCAG 2.5.8 AA (24px)
  // and looser than 2.5.5 AAA (44px). Some controls genuinely cannot meet it —
  // a chip in a filter row, the up/down pair in a list's reorder gutter, where
  // 36px each would double the row. Those carry data-touch-target="compact"
  // and are held to the AA floor instead.
  //
  // The exception lives in the markup rather than in a list here on purpose:
  // it is then visible in review, at the call site, to whoever is choosing to
  // take it.
  function touchFloorFor(el) {
    return el.closest('[data-touch-target="compact"]') ? TOUCH_MIN_COMPACT : TOUCH_MIN;
  }

  function checkTouchTargets(root) {
    const bucket = new Map();
    root.querySelectorAll("a, button, input, select, [role=button], [onclick]").forEach((el) => {
      if (!isVisible(el)) return;
      if (isInTextFlow(el)) return; // read, not aimed at
      const rect = effectiveTargetRect(el);
      const minDim = Math.min(rect.width, rect.height);
      const floor = touchFloorFor(el);
      if (minDim < floor) {
        pushDeduped(bucket, `touch:${groupKey(el)}:${minDim.toFixed(0)}`, {
          rule: "touch_target",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `${minDim.toFixed(1)}px (need >= ${floor}px)`
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

    // Every overflowing element is collected, then only the deepest in each
    // chain is reported.
    //
    // The rule used to stop at the first offender on the way down, which is
    // right for a nested clip but wrong for the case that matters: when a page
    // scrolls sideways, <body> overflows too, and stopping there reported
    // `html > body` on six screens and named the actual culprit on none of
    // them. An ancestor overflowing because its child does is exactly as
    // uninformative as a child overflowing because its ancestor does.
    const offenders = [];

    function walk(el) {
      if (!isVisible(el)) return;
      const cs = getComputedStyle(el);
      // "auto"/"scroll" scroll instead of visibly overflowing; "hidden"/"clip"
      // clip instead — none of the four ever spill into neighboring layout,
      // so none is the "Débordement horizontal" this rule exists to catch.
      // Without this, e.g. a `truncate` (overflow-x: hidden) element's
      // unwrapped text measures as "overflowing" its own clipped box, which
      // is the technique working as intended, not a bug.
      const clipsOrScrolls = [ "auto", "scroll", "hidden", "clip" ].includes(cs.overflowX);
      const overflowAmt = el.scrollWidth - el.clientWidth;
      if (overflowAmt > 2 && !clipsOrScrolls) offenders.push({ el, overflowAmt });

      if (clipsOrScrolls) return; // whatever is inside is contained; stop here
      Array.from(el.children).forEach(walk);
    }
    walk(root);

    const offending = new Set(offenders.map((o) => o.el));
    offenders
      .filter(({ el }) => !Array.from(offending).some((other) => other !== el && el.contains(other)))
      .forEach(({ el, overflowAmt }) => {
        violations.push({
          rule: "overflow_container",
          selector: cssPath(el),
          signature: groupKey(el),
          value: `${overflowAmt.toFixed(1)}px`
        });
      });

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
      // A 2px inset on a keycap is not a grid violation; it is what makes it a
      // keycap. The ⌘K hint alone was 1 120 of the 1 264 spacing findings.
      if (isMicroElement(el)) return;
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
      // The reading floor is about text people read. A count badge showing "3"
      // is a glyph, and it was 436 of the 444 font-size findings.
      if (size < FONT_SIZE_MIN && !isMicroElement(el)) {
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
