[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

$WorkspaceDir = if ($env:APM_WORKSPACE_DIR) { $env:APM_WORKSPACE_DIR } else { Join-Path $HOME ".apm" }
$WorkspaceRepo = if ($env:APM_WORKSPACE_REPO) { $env:APM_WORKSPACE_REPO } else { "https://github.com/jey3dayo/apm-workspace.git" }

function Test-CommandAvailable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Require-Command {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if (-not (Test-CommandAvailable -Name $Name)) {
    throw "$Name not found. Install it first."
  }
}

function Get-WorkspaceProjectName {
  if ($env:APM_WORKSPACE_NAME) {
    return $env:APM_WORKSPACE_NAME
  }

  $repoName = Split-Path -Leaf $WorkspaceRepo
  if ($repoName.EndsWith(".git")) {
    return $repoName.Substring(0, $repoName.Length - 4)
  }

  return $repoName
}

function Get-WorkspaceAuthorName {
  $gitUser = & git config user.name 2>$null
  if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($gitUser | Out-String))) {
    return $gitUser.Trim()
  }

  if ($env:USER) {
    return $env:USER
  }

  if ($env:USERNAME) {
    return $env:USERNAME
  }

  return "unknown"
}

function Ensure-WorkspaceRepo {
  Require-Command -Name "git"

  if (-not (Test-Path -LiteralPath $WorkspaceDir)) {
    Write-Host "Cloning $WorkspaceRepo into $WorkspaceDir"
    & git clone $WorkspaceRepo $WorkspaceDir
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone $WorkspaceRepo"
    }
  } elseif ((Test-Path -LiteralPath $WorkspaceDir -PathType Container) -and -not (Test-Path -LiteralPath (Join-Path $WorkspaceDir ".git"))) {
    $entries = @(Get-ChildItem -LiteralPath $WorkspaceDir -Force)
    if ($entries.Count -ne 0) {
      throw "$WorkspaceDir exists but is not an empty directory or git checkout."
    }

    Write-Host "Cloning $WorkspaceRepo into existing empty directory $WorkspaceDir"
    Push-Location $WorkspaceDir
    try {
      & git clone $WorkspaceRepo .
      if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone $WorkspaceRepo into $WorkspaceDir"
      }
    }
    finally {
      Pop-Location
    }
  } elseif (-not (Test-Path -LiteralPath $WorkspaceDir -PathType Container)) {
    throw "$WorkspaceDir exists but is not a directory."
  }

  if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceDir ".git"))) {
    throw "$WorkspaceDir exists but is not a git checkout."
  }
}

function Refresh-WorkspaceCheckout {
  $currentBranch = & git -C $WorkspaceDir branch --show-current 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($currentBranch | Out-String))) {
    return
  }
  $currentBranch = $currentBranch.Trim()

  $remoteName = & git -C $WorkspaceDir config --get "branch.$currentBranch.remote" 2>$null
  $mergeRef = & git -C $WorkspaceDir config --get "branch.$currentBranch.merge" 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($remoteName | Out-String)) -or [string]::IsNullOrWhiteSpace(($mergeRef | Out-String))) {
    return
  }

  $remoteName = $remoteName.Trim()
  $mergeBranch = $mergeRef.Trim() -replace '^refs/heads/', ''
  $upstream = "$remoteName/$mergeBranch"

  & git -C $WorkspaceDir show-ref --verify --quiet "refs/remotes/$upstream" 2>$null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  Write-Host "Updating $WorkspaceDir from $upstream"
  & git -C $WorkspaceDir pull --ff-only
  if ($LASTEXITCODE -ne 0) {
    throw "git pull --ff-only failed for $WorkspaceDir"
  }
}

function Ensure-GitignoreEntry {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Entry
  )

  $gitignorePath = Join-Path $WorkspaceDir ".gitignore"
  if (-not (Test-Path -LiteralPath $gitignorePath)) {
    New-Item -ItemType File -Path $gitignorePath -Force | Out-Null
  }

  $content = Get-Content -LiteralPath $gitignorePath -ErrorAction SilentlyContinue
  if ($content -notcontains $Entry) {
    Add-Content -LiteralPath $gitignorePath -Value ""
    Add-Content -LiteralPath $gitignorePath -Value $Entry
  }
}

function Normalize-WorkspaceGitignore {
  $gitignorePath = Join-Path $WorkspaceDir ".gitignore"
  if (-not (Test-Path -LiteralPath $gitignorePath)) {
    return
  }

  $canonicalEntries = @("/.apm/", "/apm_modules/", "/.catalog-build/")
  $normalized = New-Object System.Collections.Generic.List[string]
  $seen = New-Object System.Collections.Generic.HashSet[string]

  foreach ($line in (Get-Content -LiteralPath $gitignorePath -ErrorAction SilentlyContinue)) {
    if ($line -in @("# APM dependencies", "apm_modules/")) {
      continue
    }

    if ($canonicalEntries -contains $line) {
      if ($seen.Add($line)) {
        $normalized.Add($line)
      }
      continue
    }

    $normalized.Add($line)
  }

  foreach ($entry in $canonicalEntries) {
    if ($seen.Add($entry)) {
      if ($normalized.Count -gt 0 -and $normalized[$normalized.Count - 1] -ne "") {
        $normalized.Add("")
      }
      $normalized.Add($entry)
    }
  }

  while ($normalized.Count -gt 0 -and $normalized[$normalized.Count - 1] -eq "") {
    $normalized.RemoveAt($normalized.Count - 1)
  }

  [System.IO.File]::WriteAllText($gitignorePath, (($normalized -join [Environment]::NewLine) + [Environment]::NewLine))
}

function Write-WorkspaceManifestTemplate {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  $projectName = Get-WorkspaceProjectName
  $authorName = Get-WorkspaceAuthorName

  $manifestContent = @(
    "name: $projectName",
    "version: 1.0.0",
    "description: APM project for $projectName",
    "author: $authorName",
    "dependencies:",
    "  apm: []",
    "  mcp: []",
    "scripts: {}"
  ) -join [Environment]::NewLine

  [System.IO.File]::WriteAllText($manifestPath, $manifestContent)
}

function Ensure-WorkspaceScaffold {
  Ensure-WorkspaceRepo
  Ensure-GitignoreEntry -Entry "/.apm/"
  Ensure-GitignoreEntry -Entry "/apm_modules/"
  Ensure-GitignoreEntry -Entry "/.catalog-build/"

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Writing bootstrap apm.yml in $WorkspaceDir"
    Write-WorkspaceManifestTemplate
  }

  Normalize-WorkspaceGitignore
}

function Ensure-WorkspaceMiseFile {
  $misePath = Join-Path $WorkspaceDir "mise.toml"
  if (-not (Test-Path -LiteralPath $misePath)) {
    throw "Missing workspace mise.toml: $misePath"
  }
}

function Invoke-Bootstrap {
  Ensure-WorkspaceRepo
  Refresh-WorkspaceCheckout
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile
  Write-Host "APM workspace ready: $WorkspaceDir"
  Write-Host ""
  Write-Host "Next:"
  Write-Host "  cd $WorkspaceDir"
  Write-Host "  mise install"
}

function Show-Help {
@"
Usage: scripts/apm-workspace.ps1 <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + mise.toml are ready

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
"@ | Write-Host
}

switch ($Command) {
  "bootstrap" {
    Invoke-Bootstrap
  }

  "help" {
    Show-Help
  }

  "-h" {
    Show-Help
  }

  "--help" {
    Show-Help
  }

  default {
    throw "unsupported command in ~/.config: $Command (use ~/.apm tasks for daily operation)"
  }
}
