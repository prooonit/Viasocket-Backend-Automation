/**
 * One-time (or repeatable) restructure:
 *   modules/<module>/{collection,data,reports,reportsJson,run.ps1}
 *
 * Splits viacollection.json top-level folders into per-module collections.
 * Moves existing data + flow-extended assets into modules/.
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");

function readJson(filePath) {
  let raw = fs.readFileSync(filePath, "utf8");
  if (raw.charCodeAt(0) === 0xfeff) raw = raw.slice(1);
  return JSON.parse(raw);
}

function writeJson(filePath, obj) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2));
}

function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const from = path.join(src, entry.name);
    const to = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(from, to);
    else fs.copyFileSync(from, to);
  }
}

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

const MODULE_MAP = {
  org: { folderNames: ["org"], dataSrc: "data/org" },
  projects: { folderNames: ["Projects"], dataSrc: "data/projects" },
  users: { folderNames: ["Users"], dataSrc: "data/users" },
  scripts: { folderNames: ["Scripts"], dataSrc: "data/scripts" },
  functions: { folderNames: ["Functions"], dataSrc: "data/functions" },
  flow: { folderNames: ["flow"], dataSrc: "data/flow" },
  template: { folderNames: ["Template"], dataSrc: "data/template" },
};

const viaPath = path.join(ROOT, "collection", "viacollection.json");
const via = readJson(viaPath);
const viaByName = {};
for (const item of via.item || []) {
  viaByName[item.name] = item;
}

const modulesRoot = path.join(ROOT, "modules");
ensureDir(modulesRoot);

for (const [mod, cfg] of Object.entries(MODULE_MAP)) {
  const modDir = path.join(modulesRoot, mod);
  ensureDir(path.join(modDir, "collection"));
  ensureDir(path.join(modDir, "data"));
  ensureDir(path.join(modDir, "reports"));
  ensureDir(path.join(modDir, "reportsJson"));

  const items = [];
  for (const name of cfg.folderNames) {
    if (viaByName[name]) items.push(viaByName[name]);
    else console.warn(`[warn] folder not found in viacollection: ${name}`);
  }

  // Flatten: if top-level is a folder containing requests, use its children as collection items
  // so --folder "Create Project" still works. Keep as nested folder for Newman folder matching.
  const collection = {
    info: {
      _postman_id: via.info?._postman_id || undefined,
      name: `viasocket-${mod}`,
      description: `ViaSocket ${mod} API collection (split from viacollection).`,
      schema: via.info?.schema || "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    },
    item: items,
  };
  if (via.event) collection.event = via.event;
  if (via.auth) collection.auth = via.auth;
  if (via.variable) collection.variable = via.variable;

  writeJson(path.join(modDir, "collection", `${mod}.postman_collection.json`), collection);
  copyDir(path.join(ROOT, cfg.dataSrc), path.join(modDir, "data"));

  // Copy existing reports if present
  copyDir(path.join(ROOT, "reports", mod), path.join(modDir, "reports"));
  copyDir(path.join(ROOT, "reportsJson", mod), path.join(modDir, "reportsJson"));

  console.log(`[ok] modules/${mod}`);
}

// flow-extended: already has its own collection
{
  const mod = "flow-extended";
  const modDir = path.join(modulesRoot, mod);
  ensureDir(path.join(modDir, "collection"));
  ensureDir(path.join(modDir, "data"));
  ensureDir(path.join(modDir, "reports"));
  ensureDir(path.join(modDir, "reportsJson"));

  const srcCol = path.join(ROOT, "collection", "flow-extended-apis.postman_collection.json");
  if (fs.existsSync(srcCol)) {
    fs.copyFileSync(srcCol, path.join(modDir, "collection", "flow-extended.postman_collection.json"));
  }
  copyDir(path.join(ROOT, "data", "flow-extended"), path.join(modDir, "data"));
  copyDir(path.join(ROOT, "reports", "flow-extended"), path.join(modDir, "reports"));
  copyDir(path.join(ROOT, "reportsJson", "flow-extended"), path.join(modDir, "reportsJson"));
  console.log(`[ok] modules/${mod}`);
}

// Keep shared environment at root (already there). Archive note file.
ensureDir(path.join(ROOT, "shared"));
const envSrc = path.join(ROOT, "environment", "env.json");
if (fs.existsSync(envSrc)) {
  ensureDir(path.join(ROOT, "shared", "environment"));
  fs.copyFileSync(envSrc, path.join(ROOT, "shared", "environment", "env.json"));
  console.log("[ok] shared/environment/env.json");
}

console.log("\nRestructure complete. Next: write per-module run.ps1 scripts.");
