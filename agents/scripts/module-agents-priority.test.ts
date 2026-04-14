#!/usr/bin/env bun

import * as fs from "node:fs";
import * as path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "bun:test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..", "..");
const nixBin = "/nix/var/nix/profiles/default/bin/nix";
const bundledCodeReviewer = fs.readFileSync(
  path.join(repoRoot, "agents", "src", "agents", "code-reviewer.md"),
  "utf8",
);

const evalMergedAgent = (externalAgentsPath: string) =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--impure",
      "--json",
      "--expr",
      `let
         pkgs = import <nixpkgs> {};
         agentLib = import ${JSON.stringify(path.join(repoRoot, "agents", "nix", "lib.nix"))} {
           inherit pkgs;
           nixlib = pkgs.lib;
         };
         distributionResult = agentLib.scanDistribution ${JSON.stringify(path.join(repoRoot, "agents", "src"))};
         sources = {
           ext = {
             path = ${JSON.stringify(path.join(repoRoot, "agents", "src", "skills"))};
             agentsPath = builtins.path {
               path = ${JSON.stringify(externalAgentsPath)};
               name = "external-agents";
             };
           };
         };
         externalAgents = agentLib.discoverExternalAssets {
           inherit sources;
           assetType = "agents";
           enabledSources = ["ext"];
         };
         mergedAgents = externalAgents // distributionResult.agents;
       in
         {
           path = mergedAgents."code-reviewer".path;
           source = mergedAgents."code-reviewer".source;
         }`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

describe("agents/nix/module.nix", () => {
  it("preserves bundled code-reviewer agent when an external source ships the same ID", () => {
    const tempRoot = fs.mkdtempSync(path.join(fs.realpathSync.native(process.env.TMPDIR ?? "/tmp"), "ext-agents-"));

    try {
      const externalAgentsPath = path.join(tempRoot, "agents");
      fs.mkdirSync(externalAgentsPath, { recursive: true });
      fs.writeFileSync(path.join(externalAgentsPath, "code-reviewer.md"), "external override\n", "utf8");

      const result = evalMergedAgent(externalAgentsPath);

      expect(result.status).toBe(0);
      expect(result.stderr).toBe("");

      const evaluated = JSON.parse(result.stdout) as { path: string; source: string };

      expect(evaluated.source).toBe("distribution");
      expect(fs.readFileSync(evaluated.path, "utf8")).toBe(bundledCodeReviewer);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
