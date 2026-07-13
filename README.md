# ViaSocket Backend Automation

Automated API test suite for the ViaSocket backend, built with **Newman**.  
Each backend module owns its own **collection**, **data**, and **reports**.

---

## Prerequisites

1. **Node.js** (v16+) → https://nodejs.org  
2. From repo root: `npm install`

---

## Setup

Edit shared env (preferred):

`shared/environment/env.json`

| Key | Purpose |
|---|---|
| `proxy_auth_token` | ViaSocket auth token |
| `BASE_URL` | API base URL |
| `org_id` / `project_id` / `scriptId` | Test context IDs |

(`environment/env.json` is kept in sync for older scripts.)

---

## Project structure

```
Viasocket-Backend-Automation/
├── modules/
│   ├── org/
│   │   ├── collection/          # org.postman_collection.json
│   │   ├── data/                # iteration data files
│   │   ├── reports/             # HTML + DETAILED_REPORT (if any)
│   │   ├── reportsJson/         # Newman JSON reports
│   │   └── run.ps1              # run this module only
│   ├── projects/
│   ├── users/
│   ├── scripts/
│   ├── functions/
│   ├── flow/
│   ├── flow-extended/
│   └── template/
├── shared/
│   ├── environment/env.json
│   └── Resolve-Newman.ps1
├── run.ps1                      # .\run.ps1 -Suite org|projects|...|all
├── runAll.ps1                   # runs every module
└── package.json
```

Legacy root folders (`collection/`, `data/`, `reports/`) are superseded by `modules/`.  
Root `runscript*.ps1` files are thin wrappers to `modules/*/run.ps1`.

---

## How to run

```powershell
# One module
.\modules\org\run.ps1
.\modules\flow-extended\run.ps1

# Via master entry
.\run.ps1 -Suite org
.\run.ps1 -Suite flow-extended
.\run.ps1 -Suite all

# Or
.\runAll.ps1
```

---

## Reports

| Format | Location |
|---|---|
| HTML | `modules/<module>/reports/*.html` |
| JSON | `modules/<module>/reportsJson/*.json` |
| Markdown (flow-extended) | `modules/flow-extended/reports/DETAILED_REPORT.md` |

---

## Adding a new module

1. Create `modules/<name>/{collection,data,reports,reportsJson}/`
2. Add `<name>.postman_collection.json` under `collection/`
3. Add data files under `data/`
4. Copy an existing `run.ps1` and point paths at the new collection/data
5. Register the module in `runAll.ps1` and `run.ps1`

---

## Webhook summaries

```powershell
cd node
npm install
node sendReports.js
```

Scans `modules/*/reportsJson/**/*.json` by default.
