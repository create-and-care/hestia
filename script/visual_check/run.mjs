// Driven by `bin/rails visual:check` (see app/services/visual_check/runner.rb),
// never invoked by hand. Reads a manifest written by the Rails side (route
// list already resolved, dynamic segments filled from seed data), drives a
// headless Chrome instance across it, and writes tmp/visual/results.json for
// the Ruby side to turn into report.md / routes.txt. Screenshots (capture
// mode only) are written directly to tmp/visual/shots/.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import puppeteer from "puppeteer";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MEASURE_JS = fs.readFileSync(path.join(__dirname, "measure.js"), "utf8");

// Component state pairs worth checking for perceptible separation. Hand
// curated, not derived from every "*-hover" token in the stylesheet: several
// hover-only tokens (--button-bg-ghost-hover, --button-bg-outline-hover) have
// no non-transparent default counterpart — their resting state is
// `background: transparent`, so pairing them against anything would just be
// comparing "the page behind it" to itself and produce noise, not signal.
const TOKEN_PAIRS = [
  ["--surface", "--surface-hover"],
  ["--surface-inset", "--surface-inset-hover"],
  ["--container", "--container-hover"],
  ["--container-inset", "--container-inset-hover"],
  ["--item-active", "--surface-hover"],
  ["--button-bg-primary", "--button-bg-primary-hover"],
  ["--button-bg-secondary", "--button-bg-secondary-hover"],
  ["--button-bg-secondary-strong", "--button-bg-secondary-strong-hover"],
  ["--button-bg-destructive", "--button-bg-destructive-hover"],
  ["--tab-item-hover", "--tab-item-active"],
  ["--bg-inverse", "--bg-inverse-hover"]
];
const TOKEN_DELTA_MIN = 4.0;

const manifestPath = process.argv[2];
if (!manifestPath) {
  console.error("usage: node run.mjs <manifest.json>");
  process.exit(2);
}
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const { baseUrl, mode, outDir, viewports, themes } = manifest;
const shotsDir = path.join(outDir, "shots");
if (mode === "capture") fs.mkdirSync(shotsDir, { recursive: true });

const results = { violations: [], tokenViolations: [], runtimeSkips: [], spacingHistograms: {}, screenshots: [], warnings: [] };

function slugFor(route) {
  return `${route.controller.replace(/\//g, "-")}-${route.action}`;
}

async function settle(page) {
  await page.evaluate(() => document.fonts.ready);
  await page.evaluate(
    () => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))
  );
  await new Promise((resolve) => setTimeout(resolve, 200));
}

async function login(page, auth) {
  await page.goto(`${baseUrl}/session/new`, { waitUntil: "networkidle0" });
  await page.type("#email_address", auth.email);
  await page.type("#password", auth.password);
  await Promise.all([
    page.waitForNavigation({ waitUntil: "networkidle0" }),
    page.click("button[type=submit]")
  ]);
}

// Evaluated rather than added as a <script> tag: the app now sends a real
// Content-Security-Policy in every environment, and `script-src 'self'` is
// exactly as unimpressed by Puppeteer's injected inline script as it would be
// by anyone else's. page.evaluate goes through the debugger protocol instead
// of the document, so it defines window.__visualCheck without a hole having to
// be cut in the policy the check is supposed to be measuring the app under.
async function injectMeasure(page) {
  await page.evaluate(MEASURE_JS);
}

async function measureRoute(page, { pass, theme, viewport, route }) {
  let response;
  try {
    response = await page.goto(`${baseUrl}${route.url}`, { waitUntil: "networkidle0", timeout: 30000 });
  } catch (err) {
    results.runtimeSkips.push({ pass: pass.key, route: route.name, url: route.url, reason: `navigation failed: ${err.message}` });
    return;
  }

  const status = response ? response.status() : 200;
  const contentType = response ? response.headers()["content-type"] || "" : "text/html";
  if (status >= 400) {
    results.runtimeSkips.push({ pass: pass.key, route: route.name, url: route.url, reason: `HTTP ${status}` });
    return;
  }
  if (!contentType.includes("text/html")) {
    results.runtimeSkips.push({ pass: pass.key, route: route.name, url: route.url, reason: `non-HTML response (${contentType})` });
    return;
  }

  await settle(page);
  await injectMeasure(page);
  const { violations, spacingHistogram } = await page.evaluate(() => window.__visualCheck.run());

  const histKey = `${pass.key}/${slugFor(route)}@${viewport}-${theme}`;
  results.spacingHistograms[histKey] = spacingHistogram;

  violations.forEach((v) => {
    results.violations.push({ pass: pass.key, route: route.name, url: route.url, viewport, theme, ...v });
  });

  if (mode === "capture") {
    const suffix = pass.key === "empty" ? "-empty" : "";
    const filename = `${slugFor(route)}@${viewport}-${theme}${suffix}.png`;
    await page.screenshot({ path: path.join(shotsDir, filename), fullPage: true });
    results.screenshots.push({ pass: pass.key, route: route.name, viewport, theme, file: `shots/${filename}` });
  }
}

async function measureTokenPairs(page, theme) {
  await injectMeasure(page);
  const pairResults = await page.evaluate((pairs) => {
    return pairs.map(([a, b]) => {
      const rgbA = window.__visualCheck.resolveToken(a);
      const rgbB = window.__visualCheck.resolveToken(b);
      const hexA = window.__visualCheck.toHex(rgbA);
      const hexB = window.__visualCheck.toHex(rgbB);
      return { a, b, hexA, hexB, deltaE: window.__visualCheck.deltaE76(hexA, hexB) };
    });
  }, TOKEN_PAIRS);

  pairResults.forEach((r) => {
    results.tokenViolations.push({
      theme,
      pair: [r.a, r.b],
      hexA: r.hexA,
      hexB: r.hexB,
      deltaE: Number(r.deltaE.toFixed(2)),
      passed: r.deltaE >= TOKEN_DELTA_MIN
    });
  });
}

async function run() {
  const browser = await puppeteer.launch({ headless: true, args: ["--force-color-profile=srgb"] });

  for (const pass of manifest.passes) {
    const context = await browser.createBrowserContext();

    if (pass.auth) {
      const loginPage = await context.newPage();
      await login(loginPage, pass.auth);
      await loginPage.close();
    }

    for (const theme of themes) {
      const page = await context.newPage();
      await page.evaluateOnNewDocument((t) => localStorage.setItem("theme", t), theme);

      // Token pairs are global CSS, independent of route — probed once per
      // (pass, theme) on the first viewport rather than once per route, or
      // this would report the same handful of findings dozens of times over.
      let tokenProbeDone = false;

      for (const viewport of viewports) {
        await page.setViewport({ width: viewport, height: 900 });

        if (!tokenProbeDone && pass.routes.length > 0) {
          try {
            await page.goto(`${baseUrl}${pass.routes[0].url}`, { waitUntil: "networkidle0" });
            await measureTokenPairs(page, theme);
            tokenProbeDone = true;
          } catch {
            // First route failed to load — token probe will just be skipped
            // for this pass/theme; the route itself still gets its own
            // runtimeSkip entry when it's measured properly below.
          }
        }

        for (const route of pass.routes) {
          await measureRoute(page, { pass, theme, viewport, route });
        }
      }
      await page.close();
    }
    await context.close();
  }

  await browser.close();
  fs.writeFileSync(path.join(outDir, "results.json"), JSON.stringify(results, null, 2));

  // Counted on distinct (rule, element) pairs, not on per-screen findings:
  // the old count rose with the number of routes, so it fired on a rule that
  // was working and stayed quiet on one that was not.
  const absurdThreshold = 60;
  const byRule = {};
  results.violations.forEach((v) => {
    (byRule[v.rule] = byRule[v.rule] || new Set()).add(v.signature || v.selector);
  });
  const absurd = Object.entries(byRule)
    .map(([rule, set]) => [ rule, set.size ])
    .filter(([, count]) => count > absurdThreshold);
  if (absurd.length > 0) {
    results.warnings.push(
      ...absurd.map(([rule, count]) => `${rule}: ${count} distinct elements across all screens — that is a lot for one rule. Check "Récurrences inter-écrans" below before assuming it is ${count} separate bugs, then ask whether the rule's scope is right.`)
    );
    fs.writeFileSync(path.join(outDir, "results.json"), JSON.stringify(results, null, 2));
    console.error("SUSPICIOUS RULE OUTPUT (likely a broken rule, not a broken app):");
    absurd.forEach(([rule, count]) => console.error(`  ${rule}: ${count} violations`));
  }

  // The headline is the number of *distinct* (rule, element) pairs, not the
  // number of occurrences. Chrome shared by the whole app — the sidebar, the
  // notification bell — is measured once per screen, so occurrences scale with
  // the route count and say nothing about how much work there is. Reporting
  // the occurrence count first is what made "3 212 violations" read as a queue
  // of 3 212 things to fix when it was 163.
  const distinct = new Set(results.violations.map((v) => `${v.rule}:${v.signature || v.selector}`)).size;
  const occurrences = results.violations.reduce((sum, v) => sum + (v.count || 1), 0);

  console.log(
    `visual_check: ${distinct} distinct findings (${occurrences} occurrences across ${results.screenshots.length || "all"} screens), ` +
      `${results.runtimeSkips.length} runtime skips, ${results.screenshots.length} screenshots`
  );
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
