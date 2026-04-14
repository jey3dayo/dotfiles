[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

if ($env:SKIP_NIX_VALIDATE -eq "1") {
  Write-Host "Skip skills:validate (SKIP_NIX_VALIDATE=1)"
  exit 0
}

function Invoke-WslScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptContent
  )

  $tempScriptWin = Join-Path $env:TEMP "codex-skills-validate.sh"
  $normalizedScript = $ScriptContent -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText(
    $tempScriptWin,
    $normalizedScript,
    [System.Text.UTF8Encoding]::new($false)
  )

  try {
    $tempScriptWsl = (& wsl.exe wslpath -a ($tempScriptWin -replace "\\", "/") 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tempScriptWsl)) {
      throw "Failed to convert temp script path for WSL: $tempScriptWin"
    }

    & wsl.exe bash --noprofile --norc $tempScriptWsl.Trim()
    exit $LASTEXITCODE
  }
  finally {
    if (Test-Path -LiteralPath $tempScriptWin) {
      Remove-Item -LiteralPath $tempScriptWin -Force
    }
  }
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  Write-Error "wsl.exe not found. Install WSL or set SKIP_NIX_VALIDATE=1."
}

$repoRootWin = Split-Path -Parent $PSScriptRoot
$repoRootWsl = (& wsl.exe wslpath -a ($repoRootWin -replace "\\", "/") 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRootWsl)) {
  throw "Failed to convert repo path for WSL: $repoRootWin"
}

$repoRootWsl = $repoRootWsl.Trim()
$scriptContent = @(
  "#!/usr/bin/env bash"
  "set -euo pipefail"
  ""
  'export PATH="$HOME/.nix-profile/bin:$PATH"'
  ""
  'if ! command -v nix >/dev/null 2>&1; then'
  '  echo "❌ nix not found. Install Nix in WSL or run with SKIP_NIX_VALIDATE=1." >&2'
  '  exit 127'
  'fi'
  ""
  ("cd '{0}'" -f $repoRootWsl)
  'cache_root="${TMPDIR:-/tmp}/${USER:-user}/dotfiles-mise-cache"'
  'mkdir -p "$cache_root"'
  'XDG_CACHE_HOME="$cache_root" nix run --no-write-lock-file .#validate'
) -join "`n"

Invoke-WslScript -ScriptContent $scriptContent
