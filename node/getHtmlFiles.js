const fs = require("fs");
const path = require("path");

function getHtmlFiles(dirPath) {
  let files = [];

  const items = fs.readdirSync(dirPath);

  for (const item of items) {
    const fullPath = path.join(dirPath, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      files = files.concat(getHtmlFiles(fullPath));
    } else if (item.endsWith(".html")) {
      files.push(fullPath);
    }
  }

  return files;
}

module.exports = getHtmlFiles;
