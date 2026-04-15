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

const resolvePowerShellCommand = (): string | null => {
  const candidates =
    process.platform === "win32" ? ["powershell.exe", "pwsh"] : ["pwsh", "powershell.exe", "powershell"];

  for (const candidate of candidates) {
    let probe: ReturnType<typeof spawnSync>;

    try {
      probe = spawnSync(candidate, ["-NoProfile", "-Command", "exit 0"], {
        encoding: "utf8",
        stdio: "ignore",
      });
    } catch {
      continue;
    }

    if (!probe.error && probe.status === 0) {
      return candidate;
    }
  }

  return null;
};

const shellCommand = resolvePowerShellCommand();
const itWithPowerShell = shellCommand == null ? it.skip : it;
const usesWindowsPathSemantics =
  process.platform !== "win32" && shellCommand != null && shellCommand.toLowerCase().endsWith(".exe");

const toPowerShellPath = (filePath: string): string => {
  if (process.platform === "win32" || !usesWindowsPathSemantics) {
    return filePath;
  }

  const result = spawnSync("wslpath", ["-w", filePath], {
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(`Failed to convert WSL path for PowerShell: ${filePath}`);
  }

  return result.stdout.trim();
};
const runNormalization = (targetPath: string): ReturnType<typeof spawnSync> => {
  if (shellCommand == null) {
    throw new Error("PowerShell is required to run install-agent-skills-lib.ps1 tests");
  }

  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "install-agent-skills-lib-run-"));
  const wrapperPath = path.join(tempDir, "run.ps1");
  const escapedHelperPath = toPowerShellPath(helperPath).replace(/'/g, "''");
  const escapedTargetPath = toPowerShellPath(targetPath).replace(/'/g, "''");
  const powerShellWrapperPath = toPowerShellPath(wrapperPath);

  writeUtf8NoBom(
    wrapperPath,
    [`. '${escapedHelperPath}'`, `Normalize-Utf8TextFileLineEndings -Path '${escapedTargetPath}'`].join("\n"),
  );

  try {
    return spawnSync(shellCommand, ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", powerShellWrapperPath], {
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

  itWithPowerShell("normalizes line endings without mojibake for UTF-8 markdown", () => {
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
