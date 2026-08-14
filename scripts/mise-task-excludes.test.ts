#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const configDir = path.join(repoRoot, "mise");

const readConfigEnv = (file: string, key: string): string | undefined => {
  const text = fs.readFileSync(path.join(configDir, file), "utf8");
  const match = text.match(new RegExp(`^${key} = "(.*)"$`, "m"));
  return match === null ? undefined : match[1];
};

const configFiles = fs
  .readdirSync(configDir)
  .filter((name) => name.startsWith("config") && name.endsWith(".toml"))
  .sort();

const tokenize = (value: string): string[] => value.split(/\s+/).filter((token) => token.length > 0);

// タスク側は `fd -e md ${TASK_EXCLUDES}` のように unquoted 展開するため、
// glob 文字が残っていると実ファイルへ pathname expansion され `--exclude` のペアが崩れる。
describe("mise TASK_EXCLUDES", () => {
  const files = configFiles.filter((file) => readConfigEnv(file, "TASK_EXCLUDES") !== undefined);

  it("is defined in at least one mise config", () => {
    expect(files.length).toBeGreaterThan(0);
  });

  for (const file of files) {
    describe(file, () => {
      const value = readConfigEnv(file, "TASK_EXCLUDES") ?? "";

      it("contains no shell glob metacharacters", () => {
        expect(value).not.toMatch(/[*?[\]]/);
      });

      it("pairs every --exclude with a value", () => {
        const tokens = tokenize(value);
        expect(tokens.length % 2).toBe(0);
        for (let i = 0; i < tokens.length; i += 2) {
          expect(tokens[i]).toBe("--exclude");
          expect(tokens[i + 1]).not.toMatch(/^--/);
        }
      });

      it("survives unquoted word splitting in the repository root", () => {
        const result = spawnSync("sh", ["-c", 'printf "%s\\n" $TASK_EXCLUDES_UNDER_TEST'], {
          cwd: repoRoot,
          encoding: "utf8",
          env: { ...process.env, TASK_EXCLUDES_UNDER_TEST: value },
        });

        expect(result.status).toBe(0);
        const expanded = result.stdout.split("\n").filter((line) => line.length > 0);
        expect(expanded).toEqual(tokenize(value));
      });
    });
  }
});

// MD_EXCLUDES は markdownlint の否定パターンなので glob を残す。`#` 前置が展開を防いでいる。
describe("mise MD_EXCLUDES", () => {
  const files = configFiles.filter((file) => readConfigEnv(file, "MD_EXCLUDES") !== undefined);

  for (const file of files) {
    it(`${file} prefixes every pattern with # so globs cannot expand`, () => {
      for (const token of tokenize(readConfigEnv(file, "MD_EXCLUDES") ?? "")) {
        expect(token).toMatch(/^#/);
      }
    });
  }
});
