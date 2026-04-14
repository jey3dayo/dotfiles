# zoxide directory jumping for PowerShell.

$zoxideCommand = Get-Command "zoxide.exe" -ErrorAction SilentlyContinue
if (-not $zoxideCommand) {
  return
}

Invoke-Expression (& $zoxideCommand.Source init powershell | Out-String)

function global:j {
  z @args
}
