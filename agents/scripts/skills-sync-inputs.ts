#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

import { syncFlakeInputsFromSources } from "./skills-sync-inputs-lib.ts";

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

const updatedFlakeContent = syncFlakeInputsFromSources(sourceContent, flakeContent);
fs.writeFileSync(flakeFile, updatedFlakeContent, "utf8");

console.log("Updated flake.nix inputs from agent-skills-sources.nix");
