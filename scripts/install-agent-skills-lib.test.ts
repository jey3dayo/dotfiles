#!/usr/bin/env bun

import { afterEach, describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const helperPath = path.join(__dirname, "install-agent-skills-lib.ps1");

const writeUtf8NoBom = (filePath: string, content: string): void => {
  fs.writeFileSync(filePath, content, "utf8");
};

const resolvePowerShellCommand = (): string => {
  const candidates =
    process.platform === "win32" ? ["powershell.exe", "pwsh"] : ["pwsh", "powershell.exe", "powershell"];

  for (const candidate of candidates) {
    const probe = spawnSync(candidate, ["-NoProfile", "-Command", "exit 0"], {
      encoding: "utf8",
      stdio: "ignore",
    });

    if (!probe.error && probe.status === 0) {
      return candidate;
    }
  }

  throw new Error(`No supported PowerShell executable found: ${candidates.join(", ")}`);
};

const shellCommand = resolvePowerShellCommand();

const runNormalization = (targetPath: string): ReturnType<typeof spawnSync> => {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "install-agent-skills-lib-run-"));
  const wrapperPath = path.join(tempDir, "run.ps1");
  const escapedHelperPath = helperPath.replace(/'/g, "''");
  const escapedTargetPath = targetPath.replace(/'/g, "''");

  writeUtf8NoBom(
    wrapperPath,
    [`. '${escapedHelperPath}'`, `Normalize-Utf8TextFileLineEndings -Path '${escapedTargetPath}'`].join("\n"),
  );

  try {
    return spawnSync(shellCommand, ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", wrapperPath], {
      encoding: "utf8",
    });
  } finally {
    fs.rmSync(tempDir, { recursive: true, force: true });
  }
};

describe("scripts/install-agent-skills-lib.ps1", () => {
  let tempRoot: string;

  afterEach(() => {
    if (tempRoot) {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("normalizes line endings without mojibake for UTF-8 markdown", () => {
    tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "install-agent-skills-lib-test-"));
    const targetPath = path.join(tempRoot, "SKILL.md");
    const originalContent = [
      "---",
      "name: atomic-commit",
      "description: |",
      "  変更ファイルを論理的な最小単位でグループ化し、グループごとに個別コミットする。",
      "  「最小単位でコミット」などのリクエストで使用する。",
      "---",
      "",
      "# Atomic Commit",
      "",
    ].join("\r\n");

    writeUtf8NoBom(targetPath, originalContent);

    const result = runNormalization(targetPath);

    expect(result.error).toBeUndefined();
    expect(result.status).toBe(0);
    expect(result.stderr).toBe("");
    expect(fs.readFileSync(targetPath, "utf8")).toBe(originalContent.replace(/\r\n/g, "\n"));
    const bytes = fs.readFileSync(targetPath);
    expect(Array.from(bytes.subarray(0, 3))).not.toEqual([0xef, 0xbb, 0xbf]);
  });
});
