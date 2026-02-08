#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.resolve(__dirname, "../..");
const targetDir = path.join(repoRoot, "agents", "skills-internal");

if (!fs.existsSync(targetDir) || !fs.statSync(targetDir).isDirectory()) {
  console.error(`skills-internal not found: ${targetDir}`);
  process.exit(1);
}

const markdownFiles = [];

const walk = (dir) => {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(fullPath);
      continue;
    }
    if (entry.isFile() && fullPath.endsWith(".md")) {
      markdownFiles.push(fullPath);
    }
  }
};

walk(targetDir);

const fenceOpen = /^\s*(`{3,}|~{3,})/;
const boldOnly = /^(\s*)\*\*([^*][\s\S]*?)\*\*\s*$/;

let totalFiles = 0;
let totalReplacements = 0;

for (const filePath of markdownFiles) {
  const original = fs.readFileSync(filePath, "utf8");
  const eol = original.includes("\r\n") ? "\r\n" : "\n";
  const lines = original.split(eol);
  let inFence = false;
  let fenceChar = "";
  let fenceLen = 0;
  let fileReplacements = 0;

  const updated = lines.map((line) => {
    const fenceMatch = line.match(fenceOpen);
    if (fenceMatch) {
      const marker = fenceMatch[1];
      const char = marker[0];
      const len = marker.length;
      if (!inFence) {
        inFence = true;
        fenceChar = char;
        fenceLen = len;
      } else if (char === fenceChar && len >= fenceLen) {
        inFence = false;
        fenceChar = "";
        fenceLen = 0;
      }
      return line;
    }

    if (inFence) {
      return line;
    }

    const boldMatch = line.match(boldOnly);
    if (!boldMatch) {
      return line;
    }

    const indent = boldMatch[1];
    if (boldMatch[2].includes("**")) {
      return line;
    }
    const text = boldMatch[2].trim();
    fileReplacements += 1;
    return `${indent}### ${text}`;
  });

  if (fileReplacements > 0) {
    fs.writeFileSync(filePath, updated.join(eol), "utf8");
    totalFiles += 1;
    totalReplacements += fileReplacements;
  }
}

if (totalReplacements === 0) {
  console.log("No bold-only headings found.");
  process.exit(0);
}

console.log(
  `Replaced ${totalReplacements} bold-only headings across ${totalFiles} files in skills-internal.`,
);
