# zoxide directory jumping for PowerShell.

$zoxideCommand = Get-Command "zoxide.exe" -ErrorAction SilentlyContinue
if (-not $zoxideCommand) {
  return
}

$zoxideInit = & $zoxideCommand.Source init powershell 2>$null | Out-String
if ([string]::IsNullOrWhiteSpace($zoxideInit)) {
  return
}

Invoke-Expression $zoxideInit

function global:j {
  z @args
}
