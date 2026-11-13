#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { repoFile } from "./repo-file.ts";

type Family = "biome" | "prettier" | "yaml" | "lua" | "toml" | "python";
type Mode = "write" | "check";

interface LoggedCall {
  tool: string;
  rustLog: string;
  args: string[];
}

const families: readonly Family[] = ["biome", "prettier", "yaml", "lua", "toml", "python"];
const modes: readonly Mode[] = ["write", "check"];
const fileVariables: Record<Family, string> = {
  biome: "BIOME_FILES",
  prettier: "PRETTIER_FILES",
  yaml: "YAML_FILES",
  lua: "LUA_FILES",
  toml: "TOML_FILES",
  python: "PY_FILES",
};
const extensions: Record<Family, string> = {
  biome: "ts",
  prettier: "txt",
  yaml: "yml",
  lua: "lua",
  toml: "toml",
  python: "py",
};
const defaultPaths: Record<Family, readonly string[]> = {
  biome: ["."],
  prettier: ["."],
  yaml: ["./selected.yaml", "./selected.yml"],
  lua: ["./.hidden/selected.lua", "./visible.lua"],
  toml: ["./settings.toml"],
  python: ["./main.py"],
};

const expectedCommands = (family: Family, mode: Mode): readonly { tool: string; prefix: readonly string[] }[] => {
  switch (`${family}:${mode}`) {
    case "biome:write":
      return [
        { tool: "biome", prefix: ["format", "--write"] },
        { tool: "biome", prefix: ["lint", "--write"] },
      ];
    case "biome:check":
      return [{ tool: "biome", prefix: ["check", "--formatter-enabled=true", "--linter-enabled=true"] }];
    case "prettier:write":
      return [{ tool: "prettier", prefix: ["--write", "--ignore-unknown", "--log-level", "error"] }];
    case "prettier:check":
      return [{ tool: "prettier", prefix: ["--check", "--ignore-unknown", "--log-level", "error"] }];
    case "yaml:write":
      return [{ tool: "prettier", prefix: ["--write", "--log-level", "error"] }];
    case "yaml:check":
      return [{ tool: "prettier", prefix: ["--check", "--log-level", "error"] }];
    case "lua:write":
      return [{ tool: "stylua", prefix: [] }];
    case "lua:check":
      return [{ tool: "stylua", prefix: ["--check"] }];
    case "toml:write":
      return [{ tool: "taplo", prefix: ["format"] }];
    case "toml:check":
      return [{ tool: "taplo", prefix: ["format", "--check"] }];
    case "python:write":
      return [{ tool: "uvx", prefix: ["ruff", "format"] }];
    case "python:check":
      return [{ tool: "uvx", prefix: ["ruff", "format", "--check"] }];
  }
  throw new Error(`No command contract for ${family} ${mode}`);
};

const createFixture = (): { root: string; log: string; bin: string } => {
  const scratch = repoFile("tmp/mise-format-worker");
  fs.mkdirSync(scratch, { recursive: true });
  const root = fs.mkdtempSync(path.join(scratch, "fixture-"));
  const bin = path.join(root, "bin");
  const log = path.join(root, "calls.bin");
  fs.mkdirSync(bin);
  fs.writeFileSync(log, "");

  const files = [
    "selected.yml",
    "selected.yaml",
    "ignored.md",
    ".hidden/selected.lua",
    "visible.lua",
    "settings.toml",
    "nvim/stylua.toml",
    "main.py",
    "skip/ignored.yml",
    "skip/ignored.lua",
    "skip/ignored.toml",
    "skip/ignored.py",
    ...families.map((family) => `skip/first.${extensions[family]}`),
    ...families.map((family) => `skip/second.${extensions[family]}`),
  ];
  for (const file of files) {
    const target = path.join(root, file);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, "fixture\n");
  }

  const stub = `#!/usr/bin/env bash
printf '%s\\0' "\${0##*/}|\${RUST_LOG:-}" "$@" >> "$FORMAT_LOG"
printf '\\0' >> "$FORMAT_LOG"
printf 'stub %s\\n' "\${0##*/}"
if [ "\${FORMAT_FAIL_TOOL:-}" = "\${0##*/}" ] && [ "\${FORMAT_FAIL_ARG:-}" = "\${1:-}" ]; then
  exit "\${FORMAT_FAIL_STATUS:-23}"
fi
`;
  for (const tool of ["biome", "prettier", "stylua", "taplo", "uvx"]) {
    const executable = path.join(bin, tool);
    fs.writeFileSync(executable, stub, { mode: 0o755 });
  }

  return { root, log, bin };
};

const readCalls = (log: string): LoggedCall[] => {
  const records = fs.readFileSync(log, "utf8").split("\0");
  const calls: LoggedCall[] = [];
  let values: string[] = [];
  for (const value of records) {
    if (value.length > 0) {
      values.push(value);
      continue;
    }
    if (values.length > 0) {
      const label = values[0] ?? "";
      const separator = label.indexOf("|");
      calls.push({
        tool: label.slice(0, separator),
        rustLog: label.slice(separator + 1),
        args: values.slice(1),
      });
      values = [];
    }
  }
  return calls;
};

const runHelper = (
  fixture: ReturnType<typeof createFixture>,
  family: Family,
  mode: Mode,
  files: string | undefined,
  overrides: NodeJS.ProcessEnv = {},
) => {
  const env: NodeJS.ProcessEnv = {
    ...process.env,
    PATH: `${fixture.bin}${path.delimiter}${process.env.PATH ?? ""}`,
    FORMAT_LOG: fixture.log,
    TASK_EXCLUDES: "--exclude skip",
    RUST_LOG: "",
    [fileVariables[family]]: files,
    ...overrides,
  };
  return spawnSync("bash", [repoFile("mise/lib/format-code.sh"), family, mode], {
    cwd: fixture.root,
    encoding: "utf8",
    env,
  });
};

const expectCalls = (calls: readonly LoggedCall[], family: Family, mode: Mode, files: readonly string[]) => {
  const commands = expectedCommands(family, mode);
  expect(calls).toHaveLength(commands.length);
  for (const [index, command] of commands.entries()) {
    const call = calls[index];
    expect(call?.tool).toBe(command.tool);
    expect(call?.args.slice(0, command.prefix.length)).toEqual(command.prefix);
    expect(call?.args.slice(command.prefix.length).sort()).toEqual([...files].sort());
    expect(call?.rustLog).toBe(family === "toml" ? "taplo=warn" : "");
  }
};

const verifyContract = (family: Family, mode: Mode, files: string | undefined, expected: readonly string[]) => {
  const fixture = createFixture();
  try {
    const result = runHelper(fixture, family, mode, files);
    expect(result.status).toBe(0);
    const calls = readCalls(fixture.log);
    expectCalls(calls, family, mode, expected);
    if (mode === "check") {
      expect(calls.every((call) => !call.args.includes("--write"))).toBe(true);
    }
    if (mode === "write" && (family === "prettier" || family === "yaml")) {
      expect(result.stdout).toBe("");
    }
  } finally {
    fs.rmSync(fixture.root, { recursive: true, force: true });
  }
};

describe("mise format helper", () => {
  for (const family of families) {
    for (const mode of modes) {
      it(`${family} ${mode} routes explicit targets and default discovery`, () => {
        const files = [`skip/first.${extensions[family]}`, `skip/second.${extensions[family]}`];
        verifyContract(family, mode, files.join(" "), files);
        verifyContract(family, mode, undefined, defaultPaths[family]);
      });
    }
  }

  it("expands explicit path globs as the task shell did", () => {
    verifyContract("biome", "check", "skip/*.ts", ["skip/first.ts", "skip/second.ts"]);
  });

  it("keeps multiline TASK_EXCLUDES pairs intact", () => {
    const fixture = createFixture();
    try {
      const result = runHelper(fixture, "python", "check", undefined, {
        TASK_EXCLUDES: "--exclude\nskip",
      });
      expect(result.status).toBe(0);
      expectCalls(readCalls(fixture.log), "python", "check", defaultPaths.python);
    } finally {
      fs.rmSync(fixture.root, { recursive: true, force: true });
    }
  });

  it("stops after a failing first Biome stage", () => {
    const fixture = createFixture();
    try {
      const result = runHelper(fixture, "biome", "write", "skip/first.ts", {
        FORMAT_FAIL_TOOL: "biome",
        FORMAT_FAIL_ARG: "format",
      });
      expect(result.status).toBe(23);
      expect(readCalls(fixture.log)).toHaveLength(1);
      expect(readCalls(fixture.log)[0]?.args.slice(0, 2)).toEqual(["format", "--write"]);
    } finally {
      fs.rmSync(fixture.root, { recursive: true, force: true });
    }
  });
});
