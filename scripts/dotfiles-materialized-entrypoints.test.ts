#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const nixBin = "/nix/var/nix/profiles/default/bin/nix";
const flakeUrl = `git+file://${repoRoot}`;
const user = process.env.USER ?? "j138";

const runNix = (args: string[]) =>
  spawnSync(nixBin, args, {
    cwd: repoRoot,
    encoding: "utf8",
    env: {
      ...process.env,
      NIX_CONFIG: "experimental-features = nix-command flakes",
    },
  });

const evalDotfilesMaterializationState = () =>
  runNix([
    "eval",
    "--json",
    "--impure",
    "--expr",
    `let
       flake = builtins.getFlake "${flakeUrl}";
       homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
     in
       {
         aicManagedByHomeFile = builtins.hasAttr ".aicommits" homeConfig.config.home.file;
         ocoManagedByHomeFile = builtins.hasAttr ".opencommit" homeConfig.config.home.file;
       }`,
  ]);

const buildActivationScript = () => {
  const result = runNix([
    "build",
    `.#homeConfigurations.${user}.activationPackage`,
    "--impure",
    "--no-link",
    "--print-out-paths",
  ]);

  if (result.status !== 0) {
    return result;
  }

  const activatePath = path.join(result.stdout.trim(), "activate");
  return {
    ...result,
    activatePath,
    activateScript: fs.readFileSync(activatePath, "utf8"),
  };
};

describe("nix/dotfiles-module.nix", () => {
  it("materializes oco and aic config files instead of managing them as symlinks", () => {
    const evalResult = evalDotfilesMaterializationState();
    expect(evalResult.status).toBe(0);

    const state = JSON.parse(evalResult.stdout) as {
      aicManagedByHomeFile: boolean;
      ocoManagedByHomeFile: boolean;
    };

    expect(state.aicManagedByHomeFile).toBe(false);
    expect(state.ocoManagedByHomeFile).toBe(false);

    const buildResult = buildActivationScript();
    expect(buildResult.status).toBe(0);
    expect(buildResult.activateScript).toContain("dotfiles-materialized-entrypoints");
    expect(buildResult.activateScript).toContain(".aicommits");
    expect(buildResult.activateScript).toContain(".opencommit");
    expect(buildResult.activateScript).toMatch(/diffutils-[^/]+\/bin\/cmp/);
    expect(buildResult.activateScript).not.toMatch(/coreutils-[^/]+\/bin\/cmp/);
    expect(buildResult.activateScript).toContain("install -m 600");
  }, 90_000);
});
