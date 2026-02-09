const fs = require("fs");
const path = require("path");
const axios = require("axios");

const REPORTS_DIR = path.join(__dirname, "../reportsJson/projects");
const WEBHOOK_URL = "https://flow.sokt.io/func/scriDNWooIDY";

// 1️⃣ Read all JSON files
const files = fs.readdirSync(REPORTS_DIR).filter(f => f.endsWith(".json"));

console.log(`📂 Found ${files.length} report files`);

async function sendAllReports() {
  for (const file of files) {
    const filePath = path.join(REPORTS_DIR, file);
    const report = JSON.parse(fs.readFileSync(filePath, "utf8"));

    const stats = report.run.stats;
    const timings = report.run.timings;

    // ✅ REMOVE .json EXTENSION
    const reportName = path.parse(file).name;

    const payload = {
      reportName, // 👈 clean name now
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
      console.log(`✅ Sent report: ${reportName}`);
    } catch (err) {
      console.error(`❌ Failed to send ${reportName}:`, err.message);
    }
  }

  console.log("🚀 ALL REPORTS SENT SUCCESSFULLY");
}

sendAllReports();
