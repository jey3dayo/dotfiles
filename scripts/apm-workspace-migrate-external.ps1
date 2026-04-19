[CmdletBinding()]
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RequestedSources
)

$ErrorActionPreference = "Stop"
$env:APM_WORKSPACE_LIB_ONLY = "1"
try {
  . (Join-Path $PSScriptRoot "apm-workspace.ps1")
}
finally {
  Remove-Item Env:APM_WORKSPACE_LIB_ONLY -ErrorAction SilentlyContinue
}

Invoke-MigrateExternal -RequestedSources $RequestedSources
