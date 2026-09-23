[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("self", "submodules", "brew", "apt", "external-repos")]
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

function Test-Administrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

  $global:LASTEXITCODE = 0
  & $Action

  if ($LASTEXITCODE -ne 0) {
    throw "$Description failed with exit code $LASTEXITCODE"
  }
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

  "self" {
    # Windows の mise は Chocolatey 管理（windows/chocolatey/packages.config）のため
    # mise self-update ではなく choco upgrade を使う（package manager 管理下の
    # self-update は拒否されるか、管理外バイナリの上書きになるかのどちらか）。
    if (-not (Test-CommandAvailable "choco")) {
      Write-Host "Chocolatey not installed, skipping mise self update"
      break
    }

    # Chocolatey の既定配置への package upgrade は elevated rights を要求するため、
    # 非昇格なら黙って skip せず再実行手順を出して失敗させる（Windows のみのドリフト防止）。
    if (-not (Test-Administrator)) {
      throw "mise self update requires an elevated shell. Re-run from an Administrator PowerShell: mise run update:self"
    }

    Invoke-Step "choco upgrade mise -y" {
      choco upgrade mise -y
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

    Invoke-Step "brew upgrade --formula --no-ask" {
      brew upgrade --formula --no-ask
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

    Push-Location $repoPath
    try {
      Invoke-Step "git fetch origin in $repoPath" {
        git fetch origin
      }

      Invoke-Step "git reset --hard origin/master in $repoPath" {
        git reset --hard origin/master
      }

      Invoke-Step "git clean -fd in $repoPath" {
        git clean -fd
      }
    }
    finally {
      Pop-Location
    }

    break
  }
}
