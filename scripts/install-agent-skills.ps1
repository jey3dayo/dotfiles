param(
  [ValidateSet("all", "claude", "codex", "cursor", "opencode", "openclaw")]
  [string[]]$Targets = @("all"),

  [switch]$IncludeNixBundle,

  [switch]$Force
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "install-agent-skills-lib.ps1")

$AllTargets = @("claude", "codex", "cursor", "opencode", "openclaw")

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
    "cursor" {
      return @{
        Root = Join-Path $HOME ".cursor"
        SkillsDir = "skills"
        ConfigSource = "AGENTS.md"
        ConfigName = "AGENTS.md"
      }
    }
    "opencode" {
      return @{
        Root = Join-Path $HOME ".opencode"
        SkillsDir = "skills"
        ConfigSource = "AGENTS.md"
        ConfigName = "CLAUDE.md"
      }
    }
    "openclaw" {
      return @{
        Root = Join-Path $HOME ".openclaw"
        SkillsDir = "skills"
        ConfigSource = "AGENTS.md"
        ConfigName = "CLAUDE.md"
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

function Resolve-Targets {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$RequestedTargets
  )

  $resolvedTargets = @()
  foreach ($target in $RequestedTargets) {
    if ($target -eq "all") {
      $resolvedTargets += $AllTargets
    } else {
      $resolvedTargets += $target
    }
  }

  return $resolvedTargets | Select-Object -Unique
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
  $stdoutPath = Join-Path $env:TEMP "codex-wsl-command.out"
  $stderrPath = Join-Path $env:TEMP "codex-wsl-command.err"
  if (Test-Path -LiteralPath $stdoutPath) {
    Remove-Item -LiteralPath $stdoutPath -Force
  }
  if (Test-Path -LiteralPath $stderrPath) {
    Remove-Item -LiteralPath $stderrPath -Force
  }

  $exitCode = 0
  try {
    $process = Start-Process `
      -FilePath "wsl.exe" `
      -ArgumentList @("bash", "--noprofile", "--norc", $tempScriptWsl) `
      -NoNewWindow `
      -Wait `
      -PassThru `
      -RedirectStandardOutput $stdoutPath `
      -RedirectStandardError $stderrPath
    $exitCode = $process.ExitCode
  } finally {
    $stdout = if (Test-Path -LiteralPath $stdoutPath) {
      [System.IO.File]::ReadAllText($stdoutPath)
    } else {
      ""
    }
    $stderr = if (Test-Path -LiteralPath $stderrPath) {
      [System.IO.File]::ReadAllText($stderrPath)
    } else {
      ""
    }

    if (Test-Path -LiteralPath $stdoutPath) {
      Remove-Item -LiteralPath $stdoutPath -Force
    }
    if (Test-Path -LiteralPath $stderrPath) {
      Remove-Item -LiteralPath $stderrPath -Force
    }
  }
  if ($exitCode -ne 0) {
    $details = @($stdout.Trim(), $stderr.Trim()) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    throw "WSL command failed: $Command`n$($details -join "`n")"
  }
  return $stdout.Trim()
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
      Normalize-Utf8TextFileLineEndings -Path $_.FullName
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

function Ensure-CopiedFile {
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

    Remove-Item -LiteralPath $DestinationPath -Force
  }

  $parent = Split-Path -Parent $DestinationPath
  if (-not [string]::IsNullOrEmpty($parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
  return "copied"
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

function Get-ExternalAssetSources {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
  )

  $sourcesFile = Join-Path $RepoRoot "nix\agent-skills-sources.nix"
  if (-not (Test-Path -LiteralPath $sourcesFile)) {
    return @()
  }

  $lines = Get-Content -LiteralPath $sourcesFile
  $depth = 0
  $currentName = $null
  $currentLines = @()
  $sources = @()

  foreach ($line in $lines) {
    $sanitized = $line -replace '#.*$', ''

    if ($depth -eq 1 -and $null -eq $currentName) {
      if ($sanitized -match '^\s*([A-Za-z0-9_-]+)\s*=\s*\{\s*$') {
        $currentName = $matches[1]
        $currentLines = @($line)
      }
    } elseif ($null -ne $currentName) {
      $currentLines += $line
    }

    $openCount = ([regex]::Matches($sanitized, '\{')).Count
    $closeCount = ([regex]::Matches($sanitized, '\}')).Count
    $depth += ($openCount - $closeCount)

    if ($null -ne $currentName -and $depth -eq 1) {
      $blockText = $currentLines -join "`n"
      $url = $null
      $agentsPath = $null
      $commandsPath = $null

      if ($blockText -match '(?m)^\s*url\s*=\s*"([^"]+)"\s*;') {
        $url = $matches[1]
      }
      if ($blockText -match '(?m)^\s*agents\s*=\s*"([^"]+)"\s*;') {
        $agentsPath = $matches[1]
      }
      if ($blockText -match '(?m)^\s*commands\s*=\s*"([^"]+)"\s*;') {
        $commandsPath = $matches[1]
      }

      if ($url -and ($agentsPath -or $commandsPath)) {
        $sources += [pscustomobject]@{
          Name = $currentName
          Url = $url
          AgentsPath = $agentsPath
          CommandsPath = $commandsPath
        }
      }

      $currentName = $null
      $currentLines = @()
    }
  }

  return $sources
}

function Get-ExternalSourceCheckoutPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot,

    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source
  )

  if ($Source.Url.StartsWith("path:")) {
    $relativePath = $Source.Url.Substring(5)
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $relativePath))
  }

  $cloneUrl = $null
  $ref = $null

  if ($Source.Url -match '^github:([^/]+)/([^/]+?)(?:/([^/]+))?$') {
    $owner = $matches[1]
    $repo = $matches[2]
    $ref = if ($matches.Count -ge 4) { $matches[3] } else { $null }
    $cloneUrl = "https://github.com/$owner/$repo.git"
  } elseif ($Source.Url.StartsWith("git+")) {
    $cloneUrl = $Source.Url.Substring(4)
    if ($cloneUrl -match '^(.*?)[?&]ref=([^&#]+).*$') {
      $cloneUrl = $matches[1]
      $ref = $matches[2]
    }
  } else {
    $cloneUrl = $Source.Url
  }

  if (-not $cloneUrl) {
    throw "Unsupported source URL: $($Source.Url)"
  }

  $checkoutRoot = Join-Path $env:TEMP "agent-skills-external"
  New-Item -ItemType Directory -Path $checkoutRoot -Force | Out-Null
  $checkoutPath = Join-Path $checkoutRoot $Source.Name

  if (Test-Path -LiteralPath $checkoutPath) {
    Remove-Item -LiteralPath $checkoutPath -Recurse -Force
  }

  $cloneArgs = @("clone", "--depth", "1")
  if (-not [string]::IsNullOrWhiteSpace($ref)) {
    $cloneArgs += @("--branch", $ref)
  }
  $cloneArgs += @($cloneUrl, $checkoutPath)

  & git @cloneArgs | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone external source: $cloneUrl"
  }

  return $checkoutPath
}

function Copy-MarkdownTree {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [Parameter(Mandatory = $true)]
    [string]$DestinationRoot,

    [Parameter(Mandatory = $true)]
    [bool]$AllowReplace
  )

  if (-not (Test-Path -LiteralPath $SourceRoot)) {
    return @{
      Copied = 0
      Kept = 0
    }
  }

  $copied = 0
  $kept = 0
  $sourceRootFull = [System.IO.Path]::GetFullPath($SourceRoot)

  Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Filter *.md | ForEach-Object {
    $relativePath = $_.FullName.Substring($sourceRootFull.Length).TrimStart('\', '/')
    $destinationPath = Join-Path $DestinationRoot $relativePath
    $result = Ensure-CopiedFile -SourcePath $_.FullName -DestinationPath $destinationPath -AllowReplace:$AllowReplace
    switch ($result) {
      "copied" { $copied++ }
      "kept" { $kept++ }
    }
  }

  return @{
    Copied = $copied
    Kept = $kept
  }
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

$externalAssetSources = Get-ExternalAssetSources -RepoRoot $repoRoot
$externalAssetCheckouts = @()
foreach ($externalSource in $externalAssetSources) {
  $externalAssetCheckouts += [pscustomobject]@{
    Source = $externalSource
    CheckoutPath = Get-ExternalSourceCheckoutPath -RepoRoot $repoRoot -Source $externalSource
  }
}

$resolvedTargets = Resolve-Targets -RequestedTargets $Targets

foreach ($targetName in $resolvedTargets) {
  $target = Get-TargetConfig -TargetName $targetName
  $targetRoot = $target.Root
  $targetSkillsRoot = Join-Path $targetRoot $target.SkillsDir
  $targetRulesRoot = Join-Path $targetRoot "rules"
  $targetAgentsRoot = Join-Path $targetRoot "agents"
  $targetCommandsRoot = Join-Path $targetRoot "commands"
  $configSource = Join-Path $repoRoot $target.ConfigSource
  $configDestination = Join-Path $targetRoot $target.ConfigName

  New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $targetSkillsRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $targetRulesRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $targetAgentsRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $targetCommandsRoot -Force | Out-Null

  if (Test-Path -LiteralPath $configSource) {
    Copy-Item -LiteralPath $configSource -Destination $configDestination -Force
  }

  $linked = 0
  $kept = 0
  $skipped = 0
  $copied = 0
  $rulesCopied = 0
  $rulesKept = 0
  $agentsCopied = 0
  $agentsKept = 0
  $commandsCopied = 0
  $commandsKept = 0

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

  $internalRules = Copy-MarkdownTree -SourceRoot (Join-Path $repoRoot "agents\src\rules") -DestinationRoot $targetRulesRoot -AllowReplace:$Force
  $rulesCopied += $internalRules.Copied
  $rulesKept += $internalRules.Kept

  $internalAgents = Copy-MarkdownTree -SourceRoot (Join-Path $repoRoot "agents\src\agents") -DestinationRoot $targetAgentsRoot -AllowReplace:$Force
  $agentsCopied += $internalAgents.Copied
  $agentsKept += $internalAgents.Kept

  foreach ($externalAssetCheckout in $externalAssetCheckouts) {
    $externalSource = $externalAssetCheckout.Source
    $checkoutPath = $externalAssetCheckout.CheckoutPath

    if ($externalSource.AgentsPath) {
      $externalAgents = Copy-MarkdownTree -SourceRoot (Join-Path $checkoutPath $externalSource.AgentsPath) -DestinationRoot $targetAgentsRoot -AllowReplace:$Force
      $agentsCopied += $externalAgents.Copied
      $agentsKept += $externalAgents.Kept
    }

    if ($externalSource.CommandsPath) {
      $externalCommands = Copy-MarkdownTree -SourceRoot (Join-Path $checkoutPath $externalSource.CommandsPath) -DestinationRoot $targetCommandsRoot -AllowReplace:$Force
      $commandsCopied += $externalCommands.Copied
      $commandsKept += $externalCommands.Kept
    }
  }

  Write-Host "[$targetName] config: $configDestination"
  Write-Host "[$targetName] skills: $targetSkillsRoot"
  Write-Host "[$targetName] linked=$linked copied=$copied kept=$kept skipped=$skipped"
  Write-Host "[$targetName] rules copied=$rulesCopied kept=$rulesKept"
  Write-Host "[$targetName] agents copied=$agentsCopied kept=$agentsKept"
  Write-Host "[$targetName] commands copied=$commandsCopied kept=$commandsKept"
}
