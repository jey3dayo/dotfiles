#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");

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
});
