/**
 * Sends a single notification to the deploy webhook after a successful
 * Netlify deployment. Called once per full-suite run.
 *
 * Env vars:
 *   REPORT_URL  - production URL to include in the payload
 *                 (default: https://viasocket-apis-automation-reports.netlify.app)
 */
const axios = require("axios");

const DEPLOY_WEBHOOK_URL = "https://flow.sokt.io/func/scriyZ6jVhX9";
const REPORT_URL =
  process.env.REPORT_URL ||
  "https://viasocket-apis-automation-reports.netlify.app";

(async () => {
  const payload = {
    reportUrl: REPORT_URL,
    deployedAt: new Date().toISOString(),
    source: "backend-api-automation",
  };

  try {
    await axios.post(DEPLOY_WEBHOOK_URL, payload);
    console.log(`Deploy notification sent -> ${DEPLOY_WEBHOOK_URL}`);
    console.log(`Payload: ${JSON.stringify(payload)}`);
  } catch (err) {
    console.error(
      `Failed to send deploy notification: ${err.message}`
    );
    process.exit(1);
  }
})();
