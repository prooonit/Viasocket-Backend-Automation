const fs = require("fs");
const path = require("path");
const axios = require("axios");

const REPORTS_ROOT = path.join(__dirname, "../reportsJson");
const WEBHOOK_URL = "https://flow.sokt.io/func/scriDNWooIDY";

function collectJsonFiles(dir) {
  let results = [];
  if (!fs.existsSync(dir)) return results;
  for (const item of fs.readdirSync(dir)) {
    const fullPath = path.join(dir, item);
    if (fs.statSync(fullPath).isDirectory()) {
      results = results.concat(collectJsonFiles(fullPath));
    } else if (item.endsWith(".json")) {
      results.push(fullPath);
    }
  }
  return results;
}

const files = collectJsonFiles(REPORTS_ROOT);
console.log(`Found ${files.length} report files`);

async function sendAllReports() {
  for (const filePath of files) {
    const report = JSON.parse(fs.readFileSync(filePath, "utf8"));
    const stats = report.run.stats;
    const timings = report.run.timings;
    const reportName = path.parse(filePath).name;

    const payload = {
      reportName,
      collection: report.collection.info.name,
      totalRequests: stats.requests.total,
      totalAssertions: stats.assertions.total,
      failedAssertions: stats.assertions.failed,
      failures: report.run.failures.length,
      avgResponseTimeMs: timings.responseAverage,
      minResponseMs: timings.responseMin,
      maxResponseMs: timings.responseMax,
      success: report.run.failures.length === 0
    };

    try {
      await axios.post(WEBHOOK_URL, payload);
      console.log(`Sent report: ${reportName}`);
    } catch (err) {
      console.error(`Failed to send ${reportName}:`, err.message);
    }
  }

  console.log("ALL REPORTS SENT SUCCESSFULLY");
}

sendAllReports();
