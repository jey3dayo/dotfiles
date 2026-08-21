#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("mise", "lib", "pre-push-check.sh");
const isWindows = process.platform === "win32";

const classify = (files: string[]) =>
  spawnSync("sh", [scriptPath, "--classify"], {
    encoding: "utf8",
    input: files.join("\n"),
  });

(isWindows ? describe.skip : describe)("mise/lib/pre-push-check.sh --classify", () => {
  it("selects TypeScript tests for bin and scripts paths", () => {
    const result = classify(["bin/send-telegram", "README.md"]);
    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("1 0");
  });

  it("selects Lua tests for nvim lua files", () => {
    const result = classify(["nvim/lua/lsp/config.lua"]);
    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("0 1");
  });

  it("selects both suites when mixed paths change", () => {
    const result = classify(["mise/lib/run-ts-tests.sh", "spec/wezterm_utils_spec.lua"]);
    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("1 1");
  });

  it("selects neither suite for unrelated docs", () => {
    const result = classify(["docs/setup.md"]);
    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("0 0");
  });
});
