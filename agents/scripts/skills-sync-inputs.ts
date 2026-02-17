#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const repoRoot = path.resolve(__dirname, "../..");
const sourcesFile = path.join(repoRoot, "nix", "agent-skills-sources.nix");
const flakeFile = path.join(repoRoot, "flake.nix");

if (!fs.existsSync(sourcesFile)) {
  console.error(`Missing file: ${sourcesFile}`);
  process.exit(1);
}
if (!fs.existsSync(flakeFile)) {
  console.error(`Missing file: ${flakeFile}`);
  process.exit(1);
}

const sourceContent = fs.readFileSync(sourcesFile, "utf8");
const flakeContent = fs.readFileSync(flakeFile, "utf8");

const countChar = (str, char) => {
  let count = 0;
  for (const ch of str) {
    if (ch === char) count += 1;
  }
  return count;
};

const stripComments = (line) => line.replace(/#.*/, ""); // コメントのみ削除、文字列リテラルは保持

const extractSources = (content) => {
  const lines = content.split(/\r?\n/);
  let depth = 0;
  const sources = [];
  let current = null;
  for (let i = 0; i < lines.length; i += 1) {
    const raw = lines[i];
    const sanitized = stripComments(raw);
    if (depth === 1 && !current) {
      const match = sanitized.match(/^\s*([A-Za-z0-9_-]+)\s*=\s*\{\s*$/);
      if (match) {
        current = { name: match[1], url: null, flake: null };
      }
    } else if (current) {
      const urlMatch = sanitized.match(/^\s*url\s*=\s*"([^"]+)"\s*;/);
      if (urlMatch) current.url = urlMatch[1];
      const flakeMatch = sanitized.match(/^\s*flake\s*=\s*(true|false)\s*;/);
      if (flakeMatch) current.flake = flakeMatch[1] === "true";
    }

    depth += countChar(sanitized, "{") - countChar(sanitized, "}");

    if (current && depth === 1) {
      sources.push(current);
      current = null;
    }
  }
  return sources;
};

const sources = extractSources(sourceContent).filter((s) => s.url);

const agentBlockHeader = [
  "    # Agent-skills external sources (flake = false: raw git repos)",
  "    # NOTE: These must be manually kept in sync with nix/agent-skills-sources.nix",
  "    #       Flake spec requires literal inputs - dynamic generation not allowed",
  "    #       agent-skills-sources.nix remains the SSoT for baseDir and selection metadata",
];
const agentBlockFooter = ["    # END Agent-skills external sources"]; 

const buildAgentEntries = () => {
  const lines = [];
  const sorted = sources.slice().sort((a, b) => a.name.localeCompare(b.name));
  for (const source of sorted) {
    const flakeValue = source.flake === true ? "true" : "false";
    lines.push(`    ${source.name} = {`);
    lines.push(`      url = "${source.url}";`);
    lines.push(`      flake = ${flakeValue};`);
    lines.push("    };");
  }
  return lines;
};

const ensureInputsBlock = (lines) => {
  let inputsStart = -1;
  let inputsEnd = -1;
  let depth = 0;
  for (let i = 0; i < lines.length; i += 1) {
    const sanitized = stripComments(lines[i]);
    if (inputsStart === -1 && /^\s*inputs\s*=\s*\{\s*$/.test(sanitized)) {
      inputsStart = i;
      depth = 1;
      continue;
    }
    if (inputsStart !== -1) {
      depth += countChar(sanitized, "{") - countChar(sanitized, "}");
      if (depth === 0) {
        inputsEnd = i;
        break;
      }
    }
  }
  if (inputsStart === -1 || inputsEnd === -1) {
    throw new Error("Failed to locate inputs block in flake.nix");
  }
  return { inputsStart, inputsEnd };
};

const lines = flakeContent.split(/\r?\n/);
const { inputsStart, inputsEnd } = ensureInputsBlock(lines);

const startMarkerIndex = lines.findIndex((line) =>
  line.includes("# Agent-skills external sources")
);
const endMarkerIndex = lines.findIndex((line) =>
  line.includes("# END Agent-skills external sources")
);

const newBlock = [
  ...agentBlockHeader,
  ...buildAgentEntries(),
  ...agentBlockFooter,
];

let updatedLines = lines.slice();

if (startMarkerIndex !== -1) {
  const endIndex = endMarkerIndex !== -1 ? endMarkerIndex : inputsEnd - 1;
  updatedLines.splice(startMarkerIndex, endIndex - startMarkerIndex + 1, ...newBlock);
} else {
  // Insert before the closing brace of inputs
  updatedLines.splice(inputsEnd, 0, ...newBlock);
}

const eol = flakeContent.includes("\r\n") ? "\r\n" : "\n";
fs.writeFileSync(flakeFile, updatedLines.join(eol), "utf8");
console.log("Updated flake.nix inputs from agent-skills-sources.nix");
