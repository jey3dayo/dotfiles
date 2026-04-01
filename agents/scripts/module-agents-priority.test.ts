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
const flakeUrl = `git+file://${repoRoot}`;
const user = process.env.USER ?? "t00114";
const bundledCodeReviewer = fs.readFileSync(
  path.join(repoRoot, "agents", "src", "agents", "code-reviewer.md"),
  "utf8",
);

const evalHomeFileSource = (targetPath: string) =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--raw",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
       in
         homeConfig.config.home.file.${JSON.stringify(targetPath)}.source`,
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

const evalKeepTargets = () =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--json",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
         names = builtins.attrNames homeConfig.config.home.file;
       in
         builtins.filter (n: builtins.match ".*(\\\\.claude/skills|\\\\.codex/rules)/\\\\.keep$" n != null) names`,
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

const buildActivationScript = () => {
  const result = spawnSync(
    nixBin,
    [
      "build",
      `.#homeConfigurations.${user}.activationPackage`,
      "--impure",
      "--no-link",
      "--print-out-paths",
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

  if (result.status !== 0) {
    return result;
  }

  const activatePath = path.join(result.stdout.trim(), "activate");
  return {
    ...result,
    activateScript: fs.readFileSync(activatePath, "utf8"),
  };
};

describe("agents/nix/module.nix", () => {
  it("preserves bundled code-reviewer agent when an external source ships the same ID", () => {
    for (const targetPath of [
      ".claude/agents/code-reviewer.md",
      ".codex/agents/code-reviewer.md",
    ]) {
      const result = evalHomeFileSource(targetPath);

      expect(result.status).toBe(0);
      expect(fs.readFileSync(result.stdout.trim(), "utf8")).toBe(bundledCodeReviewer);
    }
  }, 15_000);

  it("materializes keep files for target directories instead of symlinking them from home.file", () => {
    const keepResult = evalKeepTargets();
    expect(keepResult.status).toBe(0);
    expect(JSON.parse(keepResult.stdout)).toEqual([]);

    const buildResult = buildActivationScript();
    expect(buildResult.status).toBe(0);
    expect(buildResult.activateScript).toContain("agent-skills-materialized-keep");
    expect(buildResult.activateScript).toContain('$HOME/.claude/skills/.keep');
    expect(buildResult.activateScript).toContain('$HOME/.codex/rules/.keep');
    expect(buildResult.activateScript).toContain("install -m 600 /dev/null");
  }, 30_000);
});
