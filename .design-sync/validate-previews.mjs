// design-sync: verifies every class in the rendered markup patterns
// (.design-sync/out/previews/*.html) resolves in the shipped CSS closure.
// This backs the guidelines' claim "all classes resolve against styles.css".
import { readFileSync, readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const css =
  readFileSync(join(repo, "ds-bundle/_ds_bundle.css"), "utf8") +
  readFileSync(join(repo, "ds-bundle/tokens/theme.css"), "utf8");

const unescapeHtml = (s) =>
  s.replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, "&");

// CSS-escape a class name the way Tailwind's minifier emits it.
const esc = (c) => c.replace(/([^a-zA-Z0-9_-])/g, "\\$1");

const previewsDir = join(repo, ".design-sync/out/previews");
const missing = new Map();
let checked = 0;
for (const f of readdirSync(previewsDir)) {
  if (!f.endsWith(".html")) continue;
  const html = readFileSync(join(previewsDir, f), "utf8");
  for (const [, attr] of html.matchAll(/class="([^"]*)"/g)) {
    for (const c of unescapeHtml(attr).split(/\s+/).filter(Boolean)) {
      checked++;
      if (!css.includes(`.${esc(c)}`)) {
        if (!missing.has(c)) missing.set(c, new Set());
        missing.get(c).add(f.replace(/\.html$/, ""));
      }
    }
  }
}

if (missing.size) {
  for (const [c, files] of missing) console.error(`${c} → ${[...files].join(",")}`);
  process.exit(1);
}
console.log(`ok: ${checked} class usages across previews all resolve`);
