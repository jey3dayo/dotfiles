#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const isWindows = process.platform === "win32";

const shellQuote = (value: string) => `'${value.replace(/'/g, "'\\''")}'`;

const wslPath = (args: string[]) => {
  const result = spawnSync("bash", ["-lc", `wslpath ${args.map(shellQuote).join(" ")}`], {
    cwd: repoRoot,
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || "wslpath failed");
  }

  return result.stdout.trim();
};

const repoRootForNix = isWindows ? wslPath(["-a", repoRoot]) : repoRoot;
const nixBin = "/nix/var/nix/profiles/default/bin/nix";
const flakeUrl = `git+file://${repoRootForNix}`;
const user = process.env.USER ?? "j138";

const runNix = (args: string[]) =>
  isWindows
    ? spawnSync("bash", ["-lc", `cd ${shellQuote(repoRootForNix)} && nix ${args.map(shellQuote).join(" ")}`], {
        cwd: repoRoot,
        encoding: "utf8",
        env: {
          ...process.env,
          NIX_CONFIG: "experimental-features = nix-command flakes",
        },
      })
    : spawnSync(nixBin, args, {
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

describe("dotfiles materialized entrypoints", () => {
  // aicommits / opencommit は HOME 直下の実ファイルを要求するため、
  // symlink ではなく copy で配布する。配布は mise bootstrap（mise/config.toml [dotfiles]）が担当。
  it("distributes oco and aic config files via mise dotfiles copy mode", () => {
    const miseConfig = fs.readFileSync(path.join(repoRoot, "mise", "config.toml"), "utf8");

    for (const target of ["~/.aicommits", "~/.opencommit"]) {
      const entry = miseConfig.split("\n").find((line) => line.trimStart().startsWith(`"${target}"`));
      expect(entry).toBeDefined();
      expect(entry).toContain('mode = "copy"');
      expect(entry).not.toContain('mode = "symlink"');
    }
  });

  // 撤去待ちの Home Manager 側が symlink 管理を再導入していないことを保証する
  it("keeps oco and aic out of home-manager home.file", () => {
    const evalResult = evalDotfilesMaterializationState();
    expect(evalResult.status).toBe(0);

    const state = JSON.parse(evalResult.stdout) as {
      aicManagedByHomeFile: boolean;
      ocoManagedByHomeFile: boolean;
    };

    expect(state.aicManagedByHomeFile).toBe(false);
    expect(state.ocoManagedByHomeFile).toBe(false);
  }, 90_000);
});
