// design-sync: validates that every utility class named in the authored docs
// (conventions.md, design-language.md) resolves in the shipped CSS closure,
// and that every icon named in design-language.md is vendored. Exits non-zero
// listing offenders. Run after building ds-bundle.
import { readFileSync, readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const css =
  readFileSync(join(repo, "ds-bundle/_ds_bundle.css"), "utf8") +
  readFileSync(join(repo, "ds-bundle/tokens/theme.css"), "utf8") +
  readFileSync(join(repo, "ds-bundle/styles.css"), "utf8");

const docs = ["conventions.md", "design-language.md"]
  .map((f) => readFileSync(join(repo, ".design-sync", f), "utf8"))
  .join("\n");

// Candidate classes: backticked single tokens, plus class="..." attribute contents.
const candidates = new Set();
const addAlternation = (tick, sep) => {
  const parts = tick.split(sep);
  const stem = parts[0].slice(0, parts[0].lastIndexOf("-") + 1);
  candidates.add(parts[0]);
  for (const p of parts.slice(1)) candidates.add(stem + p);
};
for (let [, tick] of docs.matchAll(/`([^`\s]+)`/g)) {
  // Expand doc shorthands: a-{x,y} braces, a|b pipes, alpha a/b slashes.
  const brace = tick.match(/^([\w-]*)\{([\w,-]+)\}([\w-]*)$/);
  if (brace) for (const p of brace[2].split(",")) candidates.add(brace[1] + p + brace[3]);
  else if (tick.includes("|")) addAlternation(tick, "|");
  else if (/^[\w-]+\/[a-z-]+$/.test(tick)) addAlternation(tick, "/");
  else candidates.add(tick);
}
for (const [, attr] of docs.matchAll(/class="([^"]+)"/g)) for (const c of attr.split(/\s+/)) candidates.add(c);

const skip = (c) =>
  c.includes("*") || c.includes("(") || c.includes("<") || c.includes("/design") ||
  c.includes("[") || c.startsWith("-") || c.endsWith(":") || // arbitrary-value/variant notation, prose fragments
  c.startsWith("--") || c.startsWith("Ui::") || c.startsWith("render") || c.startsWith("lucide") ||
  /\.(md|css|erb|rb)$/.test(c) || c.includes("::") || /^[A-Z«\d]/.test(c) ||
  ["…", "body", "html", "dark", "link", "lg", "sm", "size=:sm", "variant=:default", "currentColor"].includes(c) ||
  c.startsWith("size=") || c.startsWith("variant=") || c.startsWith("stroke=") || c.startsWith("class=");

const esc = (c) => c.replace(/([:./])/g, "\\$1");
const missing = [];
for (const c of [...candidates].filter((c) => !skip(c))) {
  if (!css.includes(`.${esc(c)}`)) missing.push(c);
}

// Icons named in design-language.md's icon paragraph must exist on disk.
const vendored = new Set(readdirSync(join(repo, "app/assets/icons/lucide")).map((f) => f.replace(/\.svg$/, "")));
const iconBlock = docs.match(/vendored set:\n([\s\S]*?)\n\n/);
const badIcons = iconBlock
  ? iconBlock[1].split(/[,\s]+/).map((s) => s.replace(/\.$/, "")).filter((s) => s && !vendored.has(s))
  : ["icon block not found"];

if (missing.length || badIcons.length) {
  if (missing.length) console.error("classes not in shipped CSS:", missing.join(", "));
  if (badIcons.length) console.error("icons not vendored:", badIcons.join(", "));
  process.exit(1);
}
console.log(`ok: ${[...candidates].filter((c) => !skip(c)).length} classes + ${vendored.size} icons verified`);
