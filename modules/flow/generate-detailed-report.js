/**
 * Generates modules/flow-extended/reports/DETAILED_REPORT.md
 *
 * A case is FAIL if:
 * - any Newman assertion failed, OR
 * - data expectedStatus is set and differs from actual HTTP status
 */
const fs = require("fs");
const path = require("path");

const moduleRoot = __dirname;
const dir = path.join(moduleRoot, "reportsJson");
const dataDir = path.join(moduleRoot, "data");
const outFile = path.join(moduleRoot, "reports", "DETAILED_REPORT.md");

const dataMap = {
  "01-create-step.json": "create-step.data.json",
  "02-update-step.json": "update-step.data.json",
  "03-change-status.json": "change-status.data.json",
  "04-reorder-step.json": "reorder-step.data.json",
  "05-duplicate-step.json": "duplicate-step.data.json",
  "06-trigger.json": "trigger.data.json",
  "07-trigger-preprocess.json": "trigger-preprocess.data.json",
  "08-delete-preprocess.json": "delete-preprocess.data.json",
  "09-draft-trigger.json": "draft-trigger.data.json",
  "10-memory-auth.json": "memory-auth.data.json",
  "11-title-description.json": "title-description.data.json",
  "12-hire-an-expert.json": "hire-an-expert.data.json",
  "13-delete-step.json": "delete-step.data.json",
  "14-add-multiple-actions.json": "add-multiple-actions.data.json",
};

function readBody(res) {
  try {
    if (res.stream && res.stream.data) return Buffer.from(res.stream.data).toString("utf8");
  } catch (e) {}
  return "";
}

function apiMessageFrom(body) {
  try {
    const j = JSON.parse(body);
    return j.message || j.error || "";
  } catch (e) {
    return (body || "").slice(0, 120).replace(/\n/g, " ");
  }
}

const files = fs.existsSync(dir)
  ? fs.readdirSync(dir).filter((f) => f.endsWith(".json") && dataMap[f]).sort()
  : [];

let totalAssertions = 0;
let failedAssertions = 0;
let totalRequests = 0;
let casePass = 0;
let caseFail = 0;
const suiteRows = [];
const bodyLines = [];

for (const file of files) {
  const report = JSON.parse(fs.readFileSync(path.join(dir, file), "utf8"));
  const stats = report.run.stats;
  const executions = report.run.executions || [];
  totalAssertions += stats.assertions.total;
  failedAssertions += stats.assertions.failed;
  totalRequests += stats.requests.total;

  let cases = [];
  try {
    cases = JSON.parse(fs.readFileSync(path.join(dataDir, dataMap[file]), "utf8"));
  } catch (e) {
    cases = [];
  }

  const limit = cases.length > 0 ? Math.min(cases.length, executions.length) : executions.length;
  let suiteCaseFails = 0;
  const caseBlocks = [];

  for (let i = 0; i < limit; i++) {
    const ex = executions[i];
    const caseMeta = cases[i] || {};
    const caseName = caseMeta.case || (ex.item && ex.item.name) || ("execution-" + (i + 1));
    const res = ex.response || {};
    const actualCode = res.code != null ? Number(res.code) : null;
    const expected =
      caseMeta.expectedStatus !== undefined && caseMeta.expectedStatus !== null && caseMeta.expectedStatus !== ""
        ? Number(caseMeta.expectedStatus)
        : null;

    const assertions = (ex.assertions || []).map((a) => ({
      name: a.assertion,
      passed: !a.error,
      error: a.error ? (a.error.message || String(a.error)).split("\n")[0] : null,
    }));
    const failedAsserts = assertions.filter((a) => !a.passed);
    const statusMismatch = expected != null && actualCode != null && expected !== actualCode;
    const mark = failedAsserts.length || statusMismatch ? "FAIL" : "PASS";

    if (mark === "FAIL") {
      suiteCaseFails++;
      caseFail++;
    } else {
      casePass++;
    }

    const body = readBody(res);
    const apiMessage = apiMessageFrom(body);
    const block = [];
    block.push("### Case " + (i + 1) + ": `" + caseName + "` — **" + mark + "**");
    block.push("");
    block.push("| Field | Value |");
    block.push("|---|---|");
    block.push("| Method | " + ((ex.request && ex.request.method) || "") + " |");
    block.push("| Expected Status | " + (expected != null ? expected : "") + " |");
    block.push("| Actual Status | " + (actualCode != null ? actualCode : "") + " " + (res.status || "") + " |");
    block.push("| Response Time | " + (res.responseTime != null ? res.responseTime + " ms" : "") + " |");
    block.push("| API Message | " + String(apiMessage).slice(0, 200) + " |");
    block.push("");
    block.push("**Assertions**");
    block.push("");
    if (statusMismatch) {
      block.push("- FAIL — Expected status matches actual → `expected " + expected + " but got " + actualCode + "`");
    } else if (expected != null) {
      block.push("- PASS — Expected status matches actual");
    }
    assertions.forEach((a) => {
      if (a.passed) block.push("- PASS — " + a.name);
      else block.push("- FAIL — " + a.name + " → `" + a.error + "`");
    });
    block.push("");
    if (body) {
      block.push("<details><summary>Response body</summary>");
      block.push("");
      block.push("```json");
      block.push(body.slice(0, 500) + (body.length > 500 ? "..." : ""));
      block.push("```");
      block.push("");
      block.push("</details>");
      block.push("");
    }
    caseBlocks.push(block.join("\n"));
  }

  const suiteFail = suiteCaseFails > 0 || stats.assertions.failed > 0;
  suiteRows.push({
    file: file.replace(".json", ""),
    req: stats.requests.total,
    assert: stats.assertions.total,
    fail: stats.assertions.failed,
    caseFails: suiteCaseFails,
    result: suiteFail ? "FAIL" : "PASS",
  });

  bodyLines.push("---");
  bodyLines.push("");
  bodyLines.push("## " + file.replace(".json", "") + (suiteFail ? " — FAIL" : " — PASS"));
  bodyLines.push("");
  bodyLines.push("| Requests | Assertions | Failed | Case status mismatches |");
  bodyLines.push("|---|---|---|---|");
  bodyLines.push(
    "| " + stats.requests.total + " | " + stats.assertions.total + " | " + stats.assertions.failed + " | " + suiteCaseFails + " |"
  );
  bodyLines.push("");
  bodyLines.push(caseBlocks.join("\n"));
}

const passRate =
  totalAssertions === 0 ? "0.0" : ((100 * (totalAssertions - failedAssertions)) / totalAssertions).toFixed(1);
const caseTotal = casePass + caseFail;
const casePassRate = caseTotal === 0 ? "0.0" : ((100 * casePass) / caseTotal).toFixed(1);

const md = [
  "# Flow Extended API — Detailed Test Report",
  "",
  "Generated: " + new Date().toISOString(),
  "",
  "Module: `modules/flow-extended`",
  "",
  "## Overall Summary",
  "",
  "| Metric | Value |",
  "|---|---|",
  "| Total Requests | " + totalRequests + " |",
  "| Total Assertions | " + totalAssertions + " |",
  "| Failed Assertions | " + failedAssertions + " |",
  "| Assertion Pass Rate | " + passRate + "% |",
  "| Data Cases PASS | " + casePass + " |",
  "| Data Cases FAIL | " + caseFail + " |",
  "| Case Pass Rate | " + casePassRate + "% |",
  "",
  "## Suite Scoreboard",
  "",
  "| Suite | Requests | Assertions | Failed | Case mismatches | Result |",
  "|---|---|---|---|---|---|",
  ...suiteRows.map(
    (r) =>
      "| " + r.file + " | " + r.req + " | " + r.assert + " | " + r.fail + " | " + r.caseFails + " | **" + r.result + "** |"
  ),
  "",
  ...bodyLines,
].join("\n");

fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, md);
console.log("Wrote " + outFile);
console.log("Assertion pass rate: " + passRate + "%");
console.log("Case pass rate: " + casePassRate + "% (" + caseFail + " failed of " + caseTotal + ")");
