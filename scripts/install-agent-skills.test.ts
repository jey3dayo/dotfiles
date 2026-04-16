#!/usr/bin/env bun

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

import { describe, expect, it } from "bun:test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const scriptPath = path.join(repoRoot, "scripts", "install-agent-skills.ps1");

describe("install-agent-skills.ps1", () => {
  it("handles homeLinks metadata from external sources", () => {
    const script = fs.readFileSync(scriptPath, "utf8");

    expect(script).toContain("homeLinks");
    expect(script).toContain("HomeLinks");
    expect(script).toContain('foreach ($homeLink in $externalSource.HomeLinks)');
    expect(script).toContain('Join-Path $HOME $homeLink.Destination');
    expect(script).toContain("selection\\.enable");
    expect(script).toContain('Where-Object { $_.Selected }');
    expect(script).toContain("Assert-UniqueExternalHomeLinks");
    expect(script).toContain("Duplicate homeLinks destination detected");
  });
});
