[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("submodules", "brew", "apt", "external-repos")]
  [string]$TaskName,

  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not $DryRun -and $env:MISE_UPDATE_DRY_RUN -eq "1") {
  $DryRun = $true
}

function Test-CommandAvailable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Description,

    [Parameter(Mandatory = $true)]
    [scriptblock]$Action
  )

  if ($DryRun) {
    Write-Host "[dry-run] $Description"
    return
  }

  & $Action
}

switch ($TaskName) {
  "submodules" {
    if (-not (Test-Path -LiteralPath ".gitmodules")) {
      Write-Host "No submodules configured, skipping"
      break
    }

    if (-not (Test-CommandAvailable "git")) {
      Write-Host "git not installed, skipping submodule update"
      break
    }

    Invoke-Step "git submodule sync --recursive" {
      git submodule sync --recursive
    }

    Invoke-Step "git submodule foreach --recursive 'git reset --hard HEAD && git clean -fd'" {
      git submodule foreach --recursive "git reset --hard HEAD && git clean -fd"
    }

    Invoke-Step "git -c http.version=HTTP/1.1 submodule update --remote" {
      git -c http.version=HTTP/1.1 submodule update --remote
    }

    Invoke-Step "git submodule update --init --recursive" {
      git submodule update --init --recursive
    }

    break
  }

  "brew" {
    if (-not (Test-CommandAvailable "brew")) {
      Write-Host "Homebrew not installed, skipping brew update"
      break
    }

    Invoke-Step "brew update" {
      $updateOutput = brew update 2>&1
      $updateOutput | Where-Object { $_ -notmatch "definition is invalid" } | ForEach-Object { Write-Host $_ }
    }

    Invoke-Step "brew upgrade --formula" {
      brew upgrade --formula
    }

    break
  }

  "apt" {
    if (-not (Test-CommandAvailable "apt-get") -or -not (Test-Path -LiteralPath "/etc/debian_version")) {
      Write-Host "APT not available, skipping apt update"
      break
    }

    Invoke-Step "sudo apt-get update" {
      sudo apt-get update
    }

    Invoke-Step "sudo apt-get upgrade -y" {
      sudo apt-get upgrade -y
    }

    break
  }

  "external-repos" {
    $repoPath = Join-Path $HOME "src/github.com/brookhong/Surfingkeys"
    if (-not (Test-Path -LiteralPath $repoPath)) {
      Write-Host "Skip: $repoPath not found"
      break
    }

    if (-not (Test-CommandAvailable "git")) {
      Write-Host "git not installed, skipping external repo update"
      break
    }

    Invoke-Step "Update external repo at $repoPath" {
      Push-Location $repoPath
      try {
        git fetch origin
        git reset --hard origin/master
        git clean -fd
      }
      finally {
        Pop-Location
      }
    }

    break
  }
}
