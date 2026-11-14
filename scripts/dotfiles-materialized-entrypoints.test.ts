#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import * as fs from "node:fs";
import { repoFile } from "./repo-file.ts";

describe("dotfiles materialized entrypoints", () => {
  // aicommits は HOME 直下の実ファイルを要求するため、
  // symlink ではなく copy で配布する。配布は mise bootstrap（mise/config.toml [dotfiles]）が担当。
  it("distributes the aicommits config file via mise dotfiles copy mode", () => {
    const miseConfig = fs.readFileSync(repoFile("mise", "config.toml"), "utf8");

    for (const target of ["~/.aicommits"]) {
      const entry = miseConfig.split("\n").find((line) => line.trimStart().startsWith(`"${target}"`));
      expect(entry).toBeDefined();
      expect(entry).toContain('mode = "copy"');
      expect(entry).not.toContain('mode = "symlink"');
    }
  });
});
