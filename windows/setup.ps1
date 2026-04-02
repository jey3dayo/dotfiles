$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  return Split-Path -Parent $PSScriptRoot
}

function Ensure-Chocolatey {
  if (Get-Command choco -ErrorAction SilentlyContinue) {
    return
  }

  Write-Host "Chocolatey is not installed. Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
}

function Add-ChocolateyBinToPath {
  $chocoRoot = if ($env:ChocolateyInstall) {
    $env:ChocolateyInstall
  } else {
    "C:\ProgramData\chocolatey"
  }

  $chocoBin = Join-Path $chocoRoot "bin"
  if ((Test-Path -LiteralPath $chocoBin) -and ($env:Path -notlike "*$chocoBin*")) {
    $env:Path = "$chocoBin;$env:Path"
  }
}

function Get-MiseExecutable {
  $mise = Get-Command mise -ErrorAction SilentlyContinue
  if ($null -ne $mise) {
    return $mise.Source
  }

  $candidates = @()
  if ($env:ChocolateyInstall) {
    $candidates += (Join-Path $env:ChocolateyInstall "bin\mise.exe")
  }
  $candidates += "C:\ProgramData\chocolatey\bin\mise.exe"

  foreach ($candidate in $candidates | Select-Object -Unique) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  return $null
}

$repoRoot = Get-RepoRoot
$installScript = Join-Path $PSScriptRoot "chocolatey\install.ps1"
$windowsMiseConfig = Join-Path $repoRoot "mise\config.windows.toml"

Ensure-Chocolatey
Add-ChocolateyBinToPath

if (-not (Test-Path -LiteralPath $installScript)) {
  throw "Chocolatey install script not found: $installScript"
}

& $installScript

$miseExe = Get-MiseExecutable
if ($null -eq $miseExe) {
  throw "mise executable was not found after Chocolatey install."
}

if (-not (Test-Path -LiteralPath $windowsMiseConfig)) {
  throw "Windows mise config not found: $windowsMiseConfig"
}

$env:MISE_CONFIG_FILE = $windowsMiseConfig
Write-Host "Installing mise-managed Windows tools using $windowsMiseConfig..."
& $miseExe install
if ($LASTEXITCODE -ne 0) {
  throw "mise install failed."
}

Write-Host "Windows bootstrap complete."
Write-Host "MISE_CONFIG_FILE=$windowsMiseConfig"
