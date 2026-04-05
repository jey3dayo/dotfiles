[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$TaskName
)

$ErrorActionPreference = "Stop"

function Read-Utf8TextFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $bytes = [System.IO.File]::ReadAllBytes($Path)
  $utf8 = [System.Text.UTF8Encoding]::new($true, $true)
  return $utf8.GetString($bytes)
}

function Normalize-Utf8TextFileLineEndings {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $content = Read-Utf8TextFile -Path $Path
  $normalized = $content -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($false))
}

function Test-TextFileForNormalization {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $textExtensions = @(
    ".md", ".nix", ".toml", ".json", ".jsonc", ".yaml", ".yml", ".sh", ".zsh",
    ".bash", ".txt", ".ts", ".tsx", ".js", ".jsx", ".lua", ".py", ".rc", ".conf"
  )

  $name = [System.IO.Path]::GetFileName($Path)
  $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
  return $textExtensions -contains $extension -or $name -in @(
    "AGENTS.md", "CLAUDE.md", "README.md", ".mise.toml", ".markdownlint-cli2.jsonc",
    ".markdown-link-check.json", ".luacheckrc", ".editorconfig", ".gitignore",
    ".gitattributes", ".fdignore", ".ignore", ".prettierignore", ".shellcheckrc",
    "Brewfile"
  )
}

function New-NormalizedRepoSnapshot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRootWin,

    [Parameter(Mandatory = $true)]
    [string]$SourceRootWsl
  )

  $snapshotId = [System.Guid]::NewGuid().ToString("N")
  $snapshotRootWsl = "/tmp/codex-mise-wsl-repo-$snapshotId"

  & wsl.exe bash --noprofile --norc -lc "git clone --quiet '$SourceRootWsl' '$snapshotRootWsl'"
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone repo into WSL snapshot: $SourceRootWsl"
  }

  $snapshotRootWin = (& wsl.exe wslpath -w $snapshotRootWsl 2>$null)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($snapshotRootWin)) {
    throw "Failed to convert WSL snapshot path: $snapshotRootWsl"
  }

  $snapshotRootWin = $snapshotRootWin.Trim()
  $localMiseFile = Join-Path $snapshotRootWin ".mise.toml"
  if (Test-Path -LiteralPath $localMiseFile) {
    $miseConfig = Read-Utf8TextFile -Path $localMiseFile
    $miseConfig = $miseConfig.Replace(".config/mise/tasks/", "mise/tasks/")
    [System.IO.File]::WriteAllText($localMiseFile, $miseConfig, [System.Text.UTF8Encoding]::new($false))
  }

  $changedFiles = @(
    & git -C $SourceRootWin diff --name-only HEAD
    & git -C $SourceRootWin ls-files --others --exclude-standard
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique

  $deletedFiles = @(
    & git -C $SourceRootWin diff --name-only --diff-filter=D HEAD
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique

  foreach ($relativePath in $changedFiles) {
    $relativePathWin = $relativePath -replace "/", "\"
    $sourcePath = Join-Path $SourceRootWin $relativePathWin
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
      continue
    }

    $destinationPath = Join-Path $snapshotRootWin $relativePathWin
    $destinationDir = Split-Path -Parent $destinationPath
    if (-not [string]::IsNullOrWhiteSpace($destinationDir)) {
      New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
    if (Test-TextFileForNormalization -Path $destinationPath) {
      Normalize-Utf8TextFileLineEndings -Path $destinationPath
    }
  }

  foreach ($relativePath in $deletedFiles) {
    $relativePathWin = $relativePath -replace "/", "\"
    $destinationPath = Join-Path $snapshotRootWin $relativePathWin
    if (Test-Path -LiteralPath $destinationPath) {
      Remove-Item -LiteralPath $destinationPath -Recurse -Force
    }
  }

  return @{
    WinPath = $snapshotRootWin
    WslPath = $snapshotRootWsl
  }
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  throw "wsl.exe not found. Install WSL to run '$TaskName' from Windows."
}

$repoRootWin = Split-Path -Parent $PSScriptRoot
$repoRootWsl = (& wsl.exe wslpath -a ($repoRootWin -replace "\\", "/") 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRootWsl)) {
  throw "Failed to convert repo path for WSL: $repoRootWin"
}
$repoRootWsl = $repoRootWsl.Trim()
$snapshot = New-NormalizedRepoSnapshot -SourceRootWin $repoRootWin -SourceRootWsl $repoRootWsl
$snapshotRootWin = $snapshot.WinPath
$repoRootWsl = $snapshot.WslPath
$tempScriptWin = Join-Path $env:TEMP ("codex-mise-wsl-task-" + [System.Guid]::NewGuid().ToString("N") + ".sh")
$taskCommands = switch ($TaskName) {
  "ci:quick" {
    @(
      "mise run check:format",
      "mise run check:lint:quick"
    )
    break
  }
  "ci" {
    @(
      "mise run check",
      "mise run test:lua",
      "mise run test:ts",
      "mise run skills:validate",
      "mise run skills:validate:internal",
      "mise run skills:check:sync",
      "mise run ci:gitleaks"
    )
    break
  }
  "ci:full" {
    @(
      "mise run ci:verify-deploy",
      "mise run check",
      "mise run test:lua",
      "mise run test:ts",
      "mise run skills:validate",
      "mise run skills:validate:internal",
      "mise run skills:check:sync",
      "mise run ci:gitleaks"
    )
    break
  }
  default {
    @(("mise run '{0}'" -f $TaskName.Replace("'", "'\''")))
  }
}
$scriptContent = @(
  "#!/usr/bin/env bash"
  "set -euo pipefail"
  'export PATH="$HOME/.nix-profile/bin:$PATH"'
  ("mise trust '{0}/.mise.toml' >/dev/null" -f $repoRootWsl)
  ("cd '{0}'" -f $repoRootWsl)
  $taskCommands
) -join "`n"

[System.IO.File]::WriteAllText(
  $tempScriptWin,
  $scriptContent,
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
  if (Test-Path -LiteralPath $snapshotRootWin) {
    & wsl.exe bash --noprofile --norc -lc "rm -rf '$repoRootWsl'" | Out-Null
  }
}
