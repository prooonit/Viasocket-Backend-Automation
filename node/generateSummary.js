/**
 * Aggregates every module's Newman JSON reports under modules/<name>/reportsJson/*.json
 * into a single self-contained HTML dashboard at ./summary-report.html.
 *
 * Usage:  node node/generateSummary.js
 *   OR:   REPORTS_ROOT=<path> OUT=<file.html> node node/generateSummary.js
 */
const fs = require("fs");
const path = require("path");

const ROOT = process.env.REPORTS_ROOT
  ? path.resolve(process.env.REPORTS_ROOT)
  : path.join(__dirname, "..", "modules");
const OUT = process.env.OUT
  ? path.resolve(process.env.OUT)
  : path.join(__dirname, "..", "summary-report.html");

// ---------- collect ----------
function listReportsPerModule(root) {
  const out = {};
  if (!fs.existsSync(root)) return out;
  for (const modName of fs.readdirSync(root)) {
    const modPath = path.join(root, modName);
    if (!fs.statSync(modPath).isDirectory()) continue;
    const jsonDir = path.join(modPath, "reportsJson");
    if (!fs.existsSync(jsonDir)) continue;
    const files = fs.readdirSync(jsonDir)
      .filter((f) => f.endsWith(".json"))
      .map((f) => path.join(jsonDir, f));
    if (files.length) out[modName] = files;
  }
  return out;
}

function extractUrl(u) {
  if (!u) return "";
  if (typeof u === "string") return u;
  if (typeof u.raw === "string" && u.raw) return u.raw;
  const proto = u.protocol ? u.protocol + "://" : "";
  const host  = Array.isArray(u.host) ? u.host.join(".") : (u.host || "");
  const port  = u.port ? ":" + u.port : "";
  const path  = Array.isArray(u.path) ? "/" + u.path.join("/") : (u.path || "");
  const query = Array.isArray(u.query) && u.query.length
    ? "?" + u.query.filter((q) => q && q.key).map((q) => `${q.key}=${q.value == null ? "" : q.value}`).join("&")
    : "";
  return proto + host + port + path + query;
}

function decodeResponseBody(response) {
  if (!response) return "";
  const s = response.stream;
  try {
    if (!s) return "";
    if (typeof s === "string") return s;
    if (Buffer.isBuffer(s)) return s.toString("utf8");
    if (s.type === "Buffer" && Array.isArray(s.data)) return Buffer.from(s.data).toString("utf8");
    if (Array.isArray(s)) return Buffer.from(s).toString("utf8");
    if (s.data && Array.isArray(s.data)) return Buffer.from(s.data).toString("utf8");
  } catch (_) { /* ignore */ }
  return "";
}

function prettyBody(text) {
  if (!text) return "";
  try { return JSON.stringify(JSON.parse(text), null, 2); } catch (_) { return text; }
}

function summarizeReport(filePath) {
  const raw = JSON.parse(fs.readFileSync(filePath, "utf8"));
  const stats = raw.run.stats;
  const timings = raw.run.timings || {};
  const iterations = (raw.run.executions || []).map((exec) => {
    const iter = (exec.cursor && exec.cursor.iteration) != null ? exec.cursor.iteration : 0;
    const req = exec.request || {};
    const url = extractUrl(req.url);
    const method = req.method || "";
    const status = exec.response ? exec.response.code : null;
    const statusText = exec.response ? (exec.response.status || "") : "";
    const time = exec.response ? exec.response.responseTime : null;
    const body = prettyBody(decodeResponseBody(exec.response));
    const assertions = (exec.assertions || []).map((a) => ({
      name: a.assertion,
      failed: !!a.error,
      error: a.error ? (a.error.message || a.error.name) : null,
    }));
    return { iter, method, url, status, statusText, time, assertions, body };
  });
  return {
    reportName: path.parse(filePath).name,
    collection: raw.collection && raw.collection.info ? raw.collection.info.name : "",
    requests: stats.requests || { total: 0, failed: 0 },
    assertions: stats.assertions || { total: 0, failed: 0 },
    failures: (raw.run.failures || []).length,
    timings,
    iterations,
  };
}

function esc(s) {
  return String(s == null ? "" : s)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}

// ---------- aggregate ----------
const perModule = {};
const modulesFound = listReportsPerModule(ROOT);
for (const [modName, files] of Object.entries(modulesFound)) {
  const reports = files.map(summarizeReport);
  const agg = reports.reduce((acc, r) => {
    acc.requestsTotal    += r.requests.total    || 0;
    acc.requestsFailed   += r.requests.failed   || 0;
    acc.assertionsTotal  += r.assertions.total  || 0;
    acc.assertionsFailed += r.assertions.failed || 0;
    acc.failures         += r.failures          || 0;
    return acc;
  }, { requestsTotal: 0, requestsFailed: 0, assertionsTotal: 0, assertionsFailed: 0, failures: 0 });
  perModule[modName] = { reports, agg };
}

// grand totals
const grand = Object.values(perModule).reduce((acc, m) => {
  acc.requestsTotal    += m.agg.requestsTotal;
  acc.requestsFailed   += m.agg.requestsFailed;
  acc.assertionsTotal  += m.agg.assertionsTotal;
  acc.assertionsFailed += m.agg.assertionsFailed;
  acc.failures         += m.agg.failures;
  return acc;
}, { requestsTotal: 0, requestsFailed: 0, assertionsTotal: 0, assertionsFailed: 0, failures: 0 });

// ---------- render ----------
const modNames = Object.keys(perModule).sort();

function statusBadge(status) {
  if (status == null) return `<span class="badge err">ERR</span>`;
  const cls = status >= 200 && status < 300 ? "ok" : (status >= 400 && status < 500 ? "warn" : "err");
  return `<span class="badge ${cls}">${status}</span>`;
}

function renderIterations(iters) {
  if (!iters.length) return `<div class="muted">no executions</div>`;
  return `
    <table class="iter">
      <thead><tr><th>#</th><th>Method</th><th>URL</th><th>Status</th><th>Time</th><th>Assertions</th></tr></thead>
      <tbody>
      ${iters.map((it) => {
        const passed = it.assertions.filter((a) => !a.failed).length;
        const failed = it.assertions.filter((a) =>  a.failed);
        const failedTxt = failed.length
          ? `<div class="fail-list">${failed.map((f) => `&#10007; ${esc(f.name)}`).join("<br>")}</div>`
          : "";
        const hasBody = it.body && it.body.length;
        const bodyBlock = hasBody
          ? `<details class="resp"><summary>Response ${it.status != null ? "(" + it.status + (it.statusText ? " " + it.statusText : "") + ")" : ""}</summary><pre>${esc(it.body)}</pre></details>`
          : (failed.length ? `<div class="muted">No response body captured</div>` : "");
        return `<tr>
          <td>${it.iter + 1}</td>
          <td>${esc(it.method)}</td>
          <td class="url">${esc(it.url)}</td>
          <td>${statusBadge(it.status)}</td>
          <td>${it.time == null ? "-" : it.time + "ms"}</td>
          <td>
            <span class="badge ok">${passed} passed</span>
            ${failed.length ? `<span class="badge err">${failed.length} failed</span>` : ""}
            ${failedTxt}
            ${bodyBlock}
          </td>
        </tr>`;
      }).join("")}
      </tbody>
    </table>`;
}

function renderModule(name) {
  const { reports, agg } = perModule[name];
  const ok = agg.assertionsFailed === 0;
  return `
    <details class="mod" ${ok ? "" : "open"}>
      <summary>
        <span class="mod-name">${esc(name)}</span>
        <span class="mod-stats">
          <span class="badge ${ok ? "ok" : "err"}">${ok ? "PASS" : "FAIL"}</span>
          <span class="badge">${agg.requestsTotal} req</span>
          <span class="badge">${agg.assertionsTotal - agg.assertionsFailed}/${agg.assertionsTotal} assertions</span>
          ${agg.assertionsFailed ? `<span class="badge err">${agg.assertionsFailed} failed</span>` : ""}
        </span>
      </summary>
      <div class="mod-body">
        ${reports.map((r) => `
          <div class="ep">
            <div class="ep-head">
              <span class="ep-name">${esc(r.reportName)}</span>
              <span>
                <span class="badge">${r.requests.total} req</span>
                <span class="badge">${r.assertions.total - r.assertions.failed}/${r.assertions.total}</span>
                ${r.assertions.failed ? `<span class="badge err">${r.assertions.failed} failed</span>` : `<span class="badge ok">OK</span>`}
                ${r.timings.responseAverage != null ? `<span class="badge">avg ${Math.round(r.timings.responseAverage)}ms</span>` : ""}
              </span>
            </div>
            ${renderIterations(r.iterations)}
          </div>
        `).join("")}
      </div>
    </details>`;
}

const overallOk = grand.assertionsFailed === 0;
const html = `<!doctype html>
<html><head>
<meta charset="utf-8">
<title>ViaSocket API Automation - Summary Report</title>
<style>
  :root { --ok:#16a34a; --err:#dc2626; --warn:#d97706; --bg:#0b1220; --fg:#e5e7eb; --mut:#94a3b8; --card:#111827; --line:#1f2937; }
  * { box-sizing: border-box; }
  body { margin: 0; font-family: -apple-system, "Segoe UI", Roboto, Ubuntu, sans-serif; background: var(--bg); color: var(--fg); }
  header { padding: 28px 32px; background: linear-gradient(90deg, #0f172a, #1e293b); border-bottom: 1px solid var(--line); }
  header h1 { margin: 0 0 4px; font-size: 22px; }
  header .sub { color: var(--mut); font-size: 13px; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; padding: 20px 32px; }
  .stat { background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; }
  .stat .label { color: var(--mut); font-size: 11px; text-transform: uppercase; letter-spacing: .5px; }
  .stat .value { font-size: 22px; font-weight: 600; margin-top: 4px; }
  .stat.ok  .value { color: var(--ok); }
  .stat.err .value { color: var(--err); }
  main { padding: 0 32px 32px; }
  details.mod { background: var(--card); border: 1px solid var(--line); border-radius: 10px; margin-bottom: 12px; overflow: hidden; }
  details.mod summary { padding: 14px 18px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; gap: 12px; list-style: none; }
  details.mod summary::-webkit-details-marker { display: none; }
  details.mod .mod-name { font-weight: 600; font-size: 15px; }
  details.mod .mod-stats { display: flex; gap: 6px; flex-wrap: wrap; }
  details.mod[open] summary { border-bottom: 1px solid var(--line); }
  .mod-body { padding: 12px 18px 18px; }
  .ep { border-top: 1px dashed var(--line); padding: 12px 0; }
  .ep:first-child { border-top: 0; }
  .ep-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; gap: 12px; flex-wrap: wrap; }
  .ep-name { font-weight: 600; color: #cbd5e1; }
  table.iter { width: 100%; border-collapse: collapse; font-size: 13px; }
  table.iter th, table.iter td { padding: 6px 8px; text-align: left; border-bottom: 1px solid var(--line); vertical-align: top; }
  table.iter th { color: var(--mut); font-weight: 500; text-transform: uppercase; font-size: 11px; letter-spacing: .5px; }
  table.iter td.url { color: #93c5fd; word-break: break-all; max-width: 480px; }
  .badge { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 11px; background: #1e293b; color: #cbd5e1; margin-right: 4px; }
  .badge.ok  { background: rgba(22,163,74,.15); color: #4ade80; }
  .badge.err { background: rgba(220,38,38,.15); color: #f87171; }
  .badge.warn{ background: rgba(217,119,6,.15); color: #fbbf24; }
  .muted { color: var(--mut); font-size: 12px; }
  .fail-list { margin-top: 4px; font-size: 12px; color: #fca5a5; }
  details.resp { margin-top: 6px; background: #0f172a; border: 1px solid var(--line); border-radius: 6px; }
  details.resp summary { padding: 4px 8px; cursor: pointer; font-size: 11px; color: #93c5fd; }
  details.resp pre { margin: 0; padding: 8px 10px; border-top: 1px solid var(--line); font-size: 12px; color: #e2e8f0; white-space: pre-wrap; word-break: break-word; max-height: 320px; overflow: auto; }
  footer { padding: 20px 32px; color: var(--mut); font-size: 12px; border-top: 1px solid var(--line); }
</style>
</head><body>
<header>
  <h1>ViaSocket API Automation - Summary</h1>
  <div class="sub">Generated ${new Date().toLocaleString()} - source: <code>${esc(ROOT)}</code></div>
</header>

<section class="grid">
  <div class="stat ${overallOk ? "ok" : "err"}"><div class="label">Overall</div><div class="value">${overallOk ? "PASS" : "FAIL"}</div></div>
  <div class="stat"><div class="label">Modules</div><div class="value">${modNames.length}</div></div>
  <div class="stat"><div class="label">Requests</div><div class="value">${grand.requestsTotal}</div></div>
  <div class="stat"><div class="label">Assertions</div><div class="value">${grand.assertionsTotal - grand.assertionsFailed} / ${grand.assertionsTotal}</div></div>
  <div class="stat ${grand.assertionsFailed ? "err" : "ok"}"><div class="label">Failed</div><div class="value">${grand.assertionsFailed}</div></div>
</section>

<main>
  ${modNames.length ? modNames.map(renderModule).join("") : `<div class="muted">No reports found under ${esc(ROOT)}. Run <code>.\\runAll.ps1</code> first.</div>`}
</main>

<footer>Report source: <code>${esc(ROOT)}</code> - Output: <code>${esc(OUT)}</code></footer>
</body></html>`;

fs.writeFileSync(OUT, html, "utf8");
console.log(`Summary report written -> ${OUT}`);
console.log(`Modules: ${modNames.length}, Requests: ${grand.requestsTotal}, Assertions: ${grand.assertionsTotal - grand.assertionsFailed}/${grand.assertionsTotal}, Failed: ${grand.assertionsFailed}`);
