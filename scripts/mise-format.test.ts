#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { repoFile } from "./repo-file.ts";

interface Fixture {
  root: string;
  log: string;
  bin: string;
}

interface Call {
  tool: string;
  args: string;
  rustLog: string;
}

const createFixture = (): Fixture => {
  const scratch = repoFile("tmp/mise-format-worker");
  fs.mkdirSync(scratch, { recursive: true });
  const root = fs.mkdtempSync(path.join(scratch, "fixture-"));
  const bin = path.join(root, "bin");
  const log = path.join(root, "calls.log");
  fs.mkdirSync(bin);
  fs.writeFileSync(log, "");

  for (const file of [
    "src/one.ts",
    "src/two.ts",
    ".hidden/cfg.lua",
    "visible.lua",
    "skip/ignored.lua",
    "settings.toml",
    "nvim/stylua.toml",
  ]) {
    const target = path.join(root, file);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, "fixture\n");
  }

  const stub = `#!/usr/bin/env bash
printf '%s\\t' "\${0##*/}" >> "$FORMAT_LOG"
printf '<%s>' "$@" >> "$FORMAT_LOG"
printf '\\t%s\\n' "\${RUST_LOG:-}" >> "$FORMAT_LOG"
printf 'stub %s\\n' "\${0##*/}"
if [ "\${FAIL_FORMAT:-0}" = "1" ] && [ "\${0##*/}" = "biome" ] && [ "\${1:-}" = "format" ]; then
  exit 23
fi
`;
  for (const tool of ["biome", "prettier", "stylua", "taplo"]) {
    fs.writeFileSync(path.join(bin, tool), stub, { mode: 0o755 });
  }

  return { root, log, bin };
};

const withFixture = (callback: (fixture: Fixture) => void) => {
  const fixture = createFixture();
  try {
    callback(fixture);
  } finally {
    fs.rmSync(fixture.root, { recursive: true, force: true });
  }
};

const runHelper = (fixture: Fixture, family: string, mode: string, extraEnv: NodeJS.ProcessEnv = {}) =>
  spawnSync("bash", [repoFile("mise/lib/format-code.sh"), family, mode], {
    cwd: fixture.root,
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${fixture.bin}${path.delimiter}${process.env.PATH ?? ""}`,
      FORMAT_LOG: fixture.log,
      TASK_EXCLUDES: "--exclude skip",
      RUST_LOG: "",
      BIOME_FILES: "",
      PRETTIER_FILES: "",
      LUA_FILES: "",
      TOML_FILES: "",
      ...extraEnv,
    },
  });

const readCalls = (log: string): Call[] =>
  fs
    .readFileSync(log, "utf8")
    .trim()
    .split("\n")
    .filter((line) => line.length > 0)
    .map((line) => {
      const [tool = "", args = "", rustLog = ""] = line.split("\t");
      return { tool, args, rustLog };
    });

describe("mise format helper", () => {
  it("splits explicit paths, expands globs, and keeps biome check read-only", () => {
    withFixture((fixture) => {
      const result = runHelper(fixture, "biome", "check", { BIOME_FILES: "src/one.ts src/t*.ts" });
      const [call] = readCalls(fixture.log);
      expect(result.status).toBe(0);
      expect(call?.args).toContain("<check>");
      expect(call?.args).toContain("<src/one.ts><src/two.ts>");
      expect(call?.args).not.toContain("--write");
    });
  });

  it("discovers hidden Lua and preserves multiline exclusions", () => {
    withFixture((fixture) => {
      const result = runHelper(fixture, "lua", "check", { TASK_EXCLUDES: "--exclude\nskip" });
      const [call] = readCalls(fixture.log);
      expect(result.status).toBe(0);
      expect(call?.tool).toBe("stylua");
      expect(call?.args).toContain("--check");
      expect(call?.args).toContain("./.hidden/cfg.lua");
      expect(call?.args).toContain("./visible.lua");
      expect(call?.args).not.toContain("skip");
    });
  });

  it("excludes nvim/stylua.toml from TOML discovery and sets RUST_LOG", () => {
    withFixture((fixture) => {
      const result = runHelper(fixture, "toml", "check");
      const [call] = readCalls(fixture.log);
      expect(result.status).toBe(0);
      expect(call?.tool).toBe("taplo");
      expect(call?.args).toContain("./settings.toml");
      expect(call?.args).not.toContain("stylua.toml");
      expect(call?.rustLog).toBe("taplo=warn");
    });
  });

  it("returns the first Biome failure without running lint", () => {
    withFixture((fixture) => {
      const result = runHelper(fixture, "biome", "write", {
        BIOME_FILES: "src/one.ts",
        FAIL_FORMAT: "1",
      });
      const calls = readCalls(fixture.log);
      expect(result.status).toBe(23);
      expect(calls).toHaveLength(1);
      expect(calls[0]?.args).toContain("<format>");
      expect(calls[0]?.args).not.toContain("<lint>");
    });
  });

  it("uses Prettier's default root and suppresses write output", () => {
    withFixture((fixture) => {
      const result = runHelper(fixture, "prettier", "write", { PRETTIER_FILES: "" });
      const [call] = readCalls(fixture.log);
      expect(result.status).toBe(0);
      expect(result.stdout).toBe("");
      expect(call?.args).toContain("<--write>");
      expect(call?.args.endsWith("<.>")).toBe(true);
    });
  });
});
