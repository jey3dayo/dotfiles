param(
  [ValidateSet("codex", "claude")]
  [string[]]$Targets = @("codex"),

  [switch]$IncludeNixBundle,

  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  $scriptDir = Split-Path -Parent $PSCommandPath
  return Split-Path -Parent $scriptDir
}

function Get-TargetConfig {
  param(
    [Parameter(Mandatory = $true)]
    [string]$TargetName
  )

  switch ($TargetName) {
    "codex" {
      return @{
        Root = Join-Path $HOME ".codex"
        SkillsDir = "skills"
        ConfigSource = "AGENTS.md"
        ConfigName = "AGENTS.md"
      }
    }
    "claude" {
      return @{
        Root = Join-Path $HOME ".claude"
        SkillsDir = "skills"
        ConfigSource = "AGENTS.md"
        ConfigName = "CLAUDE.md"
      }
    }
    default {
      throw "Unsupported target: $TargetName"
    }
  }
}

function Invoke-Wsl {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command
  )

  $wslHome = (& wsl.exe bash --noprofile --norc -lc 'printf %s "$HOME"' 2>$null)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($wslHome)) {
    throw "Failed to detect WSL HOME"
  }

  $wslHome = $wslHome.Trim()
  $tempScriptWin = Join-Path $env:TEMP "codex-wsl-command.sh"
  $scriptContent = @(
    "#!/usr/bin/env bash"
    "set -euo pipefail"
    "export PATH=""$wslHome/.nix-profile/bin:`$PATH"""
    $Command
  ) -join "`n"
  [System.IO.File]::WriteAllText($tempScriptWin, $scriptContent, (New-Object System.Text.UTF8Encoding($false)))

  $tempScriptWsl = (& wsl.exe wslpath -a ($tempScriptWin -replace "\\", "/") 2>$null)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tempScriptWsl)) {
    throw "Failed to convert temp script path for WSL: $tempScriptWin"
  }

  $tempScriptWsl = $tempScriptWsl.Trim()
  $previousNativePref = $PSNativeCommandUseErrorActionPreference
  $PSNativeCommandUseErrorActionPreference = $false
  try {
    $output = & wsl.exe bash --noprofile --norc $tempScriptWsl 2>&1
  } finally {
    $PSNativeCommandUseErrorActionPreference = $previousNativePref
  }
  if ($LASTEXITCODE -ne 0) {
    throw "WSL command failed: $Command`n$output"
  }
  return ($output -join "`n").Trim()
}

function Get-BundleWindowsPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
  )

  $tempRepoWin = Join-Path $env:TEMP "dotfiles-bundle-win"
  if (Test-Path -LiteralPath $tempRepoWin) {
    Remove-Item -LiteralPath $tempRepoWin -Recurse -Force
  }

  New-Item -ItemType Directory -Path $tempRepoWin -Force | Out-Null

  Get-ChildItem -LiteralPath $RepoRoot -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $tempRepoWin -Recurse -Force
  }

  $textExtensions = @(
    ".md", ".nix", ".toml", ".json", ".jsonc", ".yaml", ".yml", ".sh", ".zsh",
    ".bash", ".txt", ".ts", ".tsx", ".js", ".jsx", ".lua", ".py", ".rc", ".conf"
  )

  Get-ChildItem -LiteralPath $tempRepoWin -Recurse -File | ForEach-Object {
    $extension = $_.Extension.ToLowerInvariant()
    $shouldNormalize = $textExtensions -contains $extension -or $_.Name -in @(
      "AGENTS.md", "CLAUDE.md", "README.md", ".mise.toml", ".markdownlint-cli2.jsonc",
      ".markdown-link-check.json", ".luacheckrc", ".editorconfig", ".gitignore",
      ".gitattributes", ".fdignore", ".ignore", ".prettierignore", ".shellcheckrc"
    )

    if ($shouldNormalize) {
      $content = Get-Content -LiteralPath $_.FullName -Raw
      $content = $content -replace "`r`n", "`n"
      [System.IO.File]::WriteAllText($_.FullName, $content, (New-Object System.Text.UTF8Encoding($false)))
    }
  }

  $tempRepoWsl = (& wsl.exe wslpath -a ($tempRepoWin -replace "\\", "/")) 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tempRepoWsl)) {
    throw "Failed to convert temp repo path for WSL: $tempRepoWin"
  }

  $tempRepoWsl = $tempRepoWsl.Trim()
  $bundlePath = Invoke-Wsl -Command "nix build '$tempRepoWsl'#bundle --no-link --print-out-paths"
  $bundleWindowsPath = (& wsl.exe wslpath -w $bundlePath) 2>&1
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($bundleWindowsPath)) {
    throw "Failed to convert bundle path to Windows path: $bundlePath"
  }

  return $bundleWindowsPath.Trim()
}

function Test-LinkMatches {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]$Item,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedTarget
  )

  if ($null -eq $Item.LinkType) {
    return $false
  }

  $actualTarget = [System.IO.Path]::GetFullPath($Item.Target)
  $expected = [System.IO.Path]::GetFullPath($ExpectedTarget)
  return $actualTarget -eq $expected
}

function Ensure-Junction {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$DestinationPath,

    [Parameter(Mandatory = $true)]
    [bool]$AllowReplace
  )

  if (Test-Path -LiteralPath $DestinationPath) {
    $existing = Get-Item -LiteralPath $DestinationPath -Force
    if ($existing -is [System.IO.DirectoryInfo] -and (Test-LinkMatches -Item $existing -ExpectedTarget $SourcePath)) {
      return "kept"
    }

    if (-not $AllowReplace) {
      return "skipped"
    }

    Remove-Item -LiteralPath $DestinationPath -Recurse -Force
  }

  New-Item -ItemType Junction -Path $DestinationPath -Target $SourcePath | Out-Null
  return "linked"
}

function Get-SkillDestinationPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillsRoot,

    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $normalizedSkillId = $SkillId.Replace([char]0xF03A, ":")
  $segments = $normalizedSkillId -split ":"
  $path = $SkillsRoot
  foreach ($segment in $segments) {
    $path = Join-Path $path $segment
  }

  return $path
}

function Ensure-CopiedDirectory {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$DestinationPath,

    [Parameter(Mandatory = $true)]
    [bool]$AllowReplace
  )

  if (Test-Path -LiteralPath $DestinationPath) {
    if (-not $AllowReplace) {
      return "kept"
    }

    Remove-Item -LiteralPath $DestinationPath -Recurse -Force
  }

  $parent = Split-Path -Parent $DestinationPath
  if (-not [string]::IsNullOrEmpty($parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Recurse -Force
  return "copied"
}

$repoRoot = Get-RepoRoot
$skillsSourceRoot = Join-Path $repoRoot "agents\src\skills"

if (-not (Test-Path -LiteralPath $skillsSourceRoot)) {
  throw "Skills source directory not found: $skillsSourceRoot"
}

$skillDirs = Get-ChildItem -LiteralPath $skillsSourceRoot -Directory | Sort-Object Name
if ($skillDirs.Count -eq 0) {
  throw "No skills found under: $skillsSourceRoot"
}

$bundleWindowsPath = $null
if ($IncludeNixBundle) {
  $bundleWindowsPath = Get-BundleWindowsPath -RepoRoot $repoRoot
}

foreach ($targetName in $Targets) {
  $target = Get-TargetConfig -TargetName $targetName
  $targetRoot = $target.Root
  $targetSkillsRoot = Join-Path $targetRoot $target.SkillsDir
  $configSource = Join-Path $repoRoot $target.ConfigSource
  $configDestination = Join-Path $targetRoot $target.ConfigName

  New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $targetSkillsRoot -Force | Out-Null

  if (Test-Path -LiteralPath $configSource) {
    Copy-Item -LiteralPath $configSource -Destination $configDestination -Force
  }

  $linked = 0
  $kept = 0
  $skipped = 0
  $copied = 0

  foreach ($skillDir in $skillDirs) {
    $destination = Join-Path $targetSkillsRoot $skillDir.Name
    $result = Ensure-Junction -SourcePath $skillDir.FullName -DestinationPath $destination -AllowReplace:$Force
    switch ($result) {
      "linked" { $linked++ }
      "kept" { $kept++ }
      "skipped" {
        $skipped++
        Write-Warning "Skipped existing path without --Force: $destination"
      }
    }
  }

  if ($bundleWindowsPath) {
    $bundleSkillDirs = Get-ChildItem -LiteralPath $bundleWindowsPath -Directory |
      Where-Object { $_.Name -ne ".bundle-info" } |
      Sort-Object Name

    foreach ($bundleSkillDir in $bundleSkillDirs) {
      $destination = Get-SkillDestinationPath -SkillsRoot $targetSkillsRoot -SkillId $bundleSkillDir.Name
      $result = Ensure-CopiedDirectory -SourcePath $bundleSkillDir.FullName -DestinationPath $destination -AllowReplace:$Force
      switch ($result) {
        "copied" { $copied++ }
        "kept" { $kept++ }
      }
    }
  }

  Write-Host "[$targetName] config: $configDestination"
  Write-Host "[$targetName] skills: $targetSkillsRoot"
  Write-Host "[$targetName] linked=$linked copied=$copied kept=$kept skipped=$skipped"
}
