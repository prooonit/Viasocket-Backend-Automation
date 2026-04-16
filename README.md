# ViaSocket Backend Automation

Automated API test suite for the ViaSocket backend, built with **Newman** (the command-line runner for Postman collections). Runs tests, checks responses, and generates HTML + JSON reports.

---

## Prerequisites

Install these once on your machine before anything else:

1. **Node.js** (v16+) → https://nodejs.org/en/download  
   *(This also installs `npm` and `npx` automatically)*

2. Verify the install worked by opening a terminal and running:
   ```
   node -v
   npx -v
   ```

---

## Setup (First Time Only)

1. Clone or download this project folder.

2. Open a terminal **inside this folder** and run:
   ```
   npm install
   ```
   This installs `newman` and `newman-reporter-html`.

3. Open `environment/env.json` and update the values for your account:

   | Key | What it is |
   |---|---|
   | `proxy_auth_token` | Your ViaSocket auth token |
   | `BASE_URL` | API base URL (default: `https://dev-api.viasocket.com`) |
   | `org_id` | Your organization ID |
   | `user_id` | Your user ID |
   | `project_id` | A project ID to test against |

---

## How to Run Tests

Open a PowerShell terminal inside the project folder and run:

```powershell
# Run ALL tests (org + projects)
.\run.ps1

# Run only Org API tests
.\run.ps1 -Suite org

# Run only Project API tests
.\run.ps1 -Suite projects
```

> **First time on Windows?** If PowerShell blocks the script, run this once:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

---

## Where Are the Reports?

After running tests, reports are saved in two formats:

| Format | Location | Use for |
|---|---|---|
| HTML | `reports/` | Human-readable, open in browser |
| JSON | `reportsJson/` | Sending to webhook / dashboard |

Open any `.html` file in your browser to see a full pass/fail breakdown.

---

## Sending Reports to the Webhook

After running the JSON tests, you can push a summary to the configured webhook:

```bash
cd node
npm install
node sendReports.js
```

This reads all JSON reports from `reportsJson/` and POSTs a summary to the webhook URL in `sendReports.js`.

---

## Project Structure

```
├── run.ps1                    ← START HERE — master run script
├── collection/
│   └── viacollection.json     ← All API requests + test assertions (Postman collection)
├── environment/
│   └── env.json               ← Config: base URL, auth token, IDs
├── data/
│   ├── org/                   ← Test cases for Org APIs
│   ├── projects/              ← Test cases for Project APIs
│   ├── scripts/               ← Test cases for Script APIs
│   └── users/                 ← Test cases for User APIs
├── reports/                   ← HTML reports (generated after run)
├── reportsJson/               ← JSON reports (generated after run)
└── node/
    └── sendReports.js         ← Sends report summaries to webhook
```

---

## How Test Cases Work

Each file in `data/` is a list of test scenarios. Newman runs the API **once per row**.

Example — `data/org/create-org.json`:
```json
[
  { "nameOrg": "TestOrg_ValidName",  "expectedStatus": 200 },
  { "nameOrg": "AnotherOrg",         "expectedStatus": 200 },
  { "nameOrg": "",                   "expectedStatus": 400 }
]
```

Row 3 tests what happens when you send an empty name — the test expects a `400` error back.  
If the server returns `200` instead, the test **fails** and shows up red in the report.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `npx: command not found` | Install Node.js from nodejs.org |
| `newman: not found` | Run `npm install` in the project root |
| All tests fail with 401 | Update `proxy_auth_token` in `environment/env.json` |
| HTML report not opening | Make sure tests have been run at least once |
