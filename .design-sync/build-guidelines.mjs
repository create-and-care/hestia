// design-sync: generates ds-bundle/guidelines/ and ds-bundle/README.md from
// .design-sync/out/ (produced by extract.rb) plus the preview ERB sources.
// Mechanical transform — never edit the output. Run after extract.rb.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const out = join(repo, ".design-sync/out");
const entries = JSON.parse(readFileSync(join(out, "registry.json"), "utf8"));

const catSlug = (category) =>
  category
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

const compact = (html) =>
  html
    .split("\n")
    .map((l) => l.trimEnd())
    .filter((l, i, a) => l !== "" || a[i - 1] !== "")
    .join("\n")
    .trim();

const section = (e) => {
  const parts = [`## ${e.name} (\`${e.slug}\`)`, "", e.description];
  if (e.component_class) parts.push("", `Rails component: \`${e.component_class}\` — engineers render it as \`render ${e.component_class}.new(...)\`.`);
  if (e.usage) parts.push("", "**Quand utiliser :** " + e.usage.split("\n").join("\n- ").replace(":\n- ", ":\n\n- "));
  if (e.related?.length) parts.push("", `Related: ${e.related.map((r) => `\`${r}\``).join(", ")}`);

  if (e.props?.length) {
    parts.push("", "**Props** (from `#initialize`):", "");
    parts.push("| Name | Required |", "| --- | --- |");
    for (const p of e.props) parts.push(`| \`${p.name}\` | ${p.required ? "yes" : "no"} |`);
  }
  for (const [name, values] of Object.entries(e.enums ?? {}))
    parts.push("", `**${name}:** ${values.map((v) => `\`${v}\``).join(" · ")}`);
  const slots = Object.entries(e.slots ?? {});
  if (slots.length)
    parts.push("", `**Slots:** ${slots.map(([n, kind]) => `\`with_${n}\` (${kind})`).join(" · ")}`);

  const erbPath = join(repo, `app/views/design_system/previews/_${e.slug}.html.erb`);
  if (existsSync(erbPath))
    parts.push("", "**Canonical usage (ERB, from the docs site):**", "", "```erb", readFileSync(erbPath, "utf8").trim(), "```");

  const htmlPath = join(out, "previews", `${e.slug}.html`);
  if (existsSync(htmlPath))
    parts.push(
      "",
      "**Rendered markup pattern** (real output of the above — mirror these classes exactly when recreating this component):",
      "",
      "```html",
      compact(readFileSync(htmlPath, "utf8")),
      "```"
    );
  return parts.join("\n");
};

// One guideline file per registry category, sections in registry order.
const byCat = new Map();
for (const e of entries) {
  if (!byCat.has(e.category)) byCat.set(e.category, []);
  byCat.get(e.category).push(e);
}

const guidelinesDir = join(repo, "ds-bundle/guidelines/components");
mkdirSync(guidelinesDir, { recursive: true });
const files = [];
for (const [category, list] of byCat) {
  const slug = catSlug(category);
  const body = [
    `# ${category}`,
    "",
    `${list.length} components. Each section gives the component's purpose, its Rails API`,
    "(what engineers ship), and its **rendered markup pattern** — the exact HTML + classes",
    "to reproduce it in a design. All classes resolve against `styles.css`.",
    "",
    list.map(section).join("\n\n---\n\n")
  ].join("\n");
  writeFileSync(join(guidelinesDir, `${slug}.md`), body);
  files.push({ category, slug, count: list.length, components: list });
}

// Authored design-language guideline travels with the generated ones.
const dlPath = join(repo, ".design-sync/design-language.md");
if (existsSync(dlPath)) writeFileSync(join(repo, "ds-bundle/guidelines/design-language.md"), readFileSync(dlPath, "utf8"));

// README body — index of everything; conventions header is prepended if present.
const headerPath = join(repo, ".design-sync/conventions.md");
const header = existsSync(headerPath) ? readFileSync(headerPath, "utf8").trim() + "\n\n---\n\n" : "";

const index = files
  .map(
    (f) =>
      `### ${f.category} — \`guidelines/components/${f.slug}.md\`\n\n` +
      f.components.map((c) => `- **${c.name}** (\`${c.slug}\`) — ${c.description}`).join("\n")
  )
  .join("\n\n");

const body = `# Hestia Design System

Hestia is a Rails app; this library is its **design language and component catalog**, synced
from the app's own docs site (\`/design-system\`). Components are server-rendered Rails
ViewComponents (\`Ui::*Component\`) — there is no JS component bundle. Designs are built from
the **markup patterns** in \`guidelines/components/*.md\`: real rendered HTML whose classes all
resolve against \`styles.css\`.

- \`tokens/tokens.md\` — every design token with its value (palette, semantic, fonts, radii, shadows).
- \`guidelines/design-language.md\` — how to compose Hestia UI: color roles, type scale, surfaces, dark mode.
- \`guidelines/components/*.md\` — per-category component reference: purpose, Rails API, props/slots, canonical usage, rendered markup.

## Component index (${entries.length} components)

${index}
`;

writeFileSync(join(repo, "ds-bundle/README.md"), header + body);
console.log(`wrote ${files.length} guideline files + README.md (${entries.length} components)`);
