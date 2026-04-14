$ErrorActionPreference = "Stop"

$configPath = Join-Path $PSScriptRoot "packages.config"

if (-not (Test-Path -LiteralPath $configPath)) {
  throw "Chocolatey package manifest not found: $configPath"
}

$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($null -eq $choco) {
  throw "Chocolatey is not installed. Run windows/setup.ps1 first."
}

Write-Host "Installing Chocolatey bootstrap packages from $configPath..."
& $choco.Source install $configPath -y
if ($LASTEXITCODE -ne 0) {
  throw "Chocolatey package install failed."
}
