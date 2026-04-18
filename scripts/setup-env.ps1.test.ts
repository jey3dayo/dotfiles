#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const scriptPath = path.join(__dirname, "setup-env.ps1");
const isWindows = process.platform === "win32";

const resolvePowerShellCommand = (): string => {
  const candidates = isWindows ? ["powershell.exe", "pwsh"] : ["pwsh", "powershell.exe", "powershell"];

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

(isWindows ? describe : describe.skip)("scripts/setup-env.ps1", () => {
  it("allows concurrent runs without false failures", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-ps1-test-"));
    const runnerPath = path.join(tempRoot, "run.ps1");
    const escapedScriptPath = scriptPath.replace(/'/g, "''");

    fs.writeFileSync(
      runnerPath,
      [
        "$ErrorActionPreference = 'Stop'",
        "$tempRoot = Join-Path $env:TEMP ('setup-env-race-' + [guid]::NewGuid().ToString())",
        "$configHome = Join-Path $tempRoot 'config'",
        "$binDir = Join-Path $tempRoot 'bin'",
        "New-Item -ItemType Directory -Force -Path $configHome, $binDir | Out-Null",
        "Set-Content -Path (Join-Path $configHome '.env') -Value \"SECRET=from-env`n\"",
        "Set-Content -Path (Join-Path $configHome '.env.keys') -Value \"private-key`n\"",
        '$dotenvxCmd = @"',
        "@echo off",
        'powershell -NoProfile -Command ""Start-Sleep -Milliseconds 700; Write-Output \'SECRET=decrypted\'""',
        '"@',
        "Set-Content -Path (Join-Path $binDir 'dotenvx.cmd') -Value $dotenvxCmd",
        `$setupScript = '${escapedScriptPath}'`,
        "$psi = New-Object System.Diagnostics.ProcessStartInfo",
        "$psi.FileName = 'powershell.exe'",
        '$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$setupScript`""',
        "$psi.RedirectStandardOutput = $true",
        "$psi.RedirectStandardError = $true",
        "$psi.UseShellExecute = $false",
        "$psi.Environment['XDG_CONFIG_HOME'] = $configHome",
        "$psi.Environment['PATH'] = \"$binDir;\" + $env:PATH",
        "$p1 = [System.Diagnostics.Process]::Start($psi)",
        "$p2 = [System.Diagnostics.Process]::Start($psi)",
        "$p1.WaitForExit()",
        "$p2.WaitForExit()",
        "$result = [ordered]@{",
        "  first = [ordered]@{ exit = $p1.ExitCode; stdout = $p1.StandardOutput.ReadToEnd(); stderr = $p1.StandardError.ReadToEnd() }",
        "  second = [ordered]@{ exit = $p2.ExitCode; stdout = $p2.StandardOutput.ReadToEnd(); stderr = $p2.StandardError.ReadToEnd() }",
        "  envLocal = if (Test-Path (Join-Path $configHome '.env.local')) { [string](Get-Content -Raw (Join-Path $configHome '.env.local')) } else { $null }",
        "}",
        "$result | ConvertTo-Json -Compress",
        "Remove-Item -LiteralPath $tempRoot -Recurse -Force",
      ].join("\n"),
      "utf8",
    );

    try {
      const result = spawnSync(shellCommand, ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", runnerPath], {
        encoding: "utf8",
      });

      expect(result.error).toBeUndefined();
      expect(result.status).toBe(0);

      const parsed = JSON.parse(result.stdout.trim()) as {
        first: { exit: number; stdout: string; stderr: string };
        second: { exit: number; stdout: string; stderr: string };
        envLocal: string | null;
      };

      expect(parsed.first.exit).toBe(0);
      expect(parsed.first.stderr).toBe("");
      expect(parsed.second.exit).toBe(0);
      expect(parsed.second.stderr).toBe("");
      expect(parsed.envLocal).toBe("SECRET=decrypted");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
