[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("format", "check", "lint")]
  [string]$Mode
)

$ErrorActionPreference = "Stop"

function Get-BiomeTargets {
  if ([string]::IsNullOrWhiteSpace($env:BIOME_FILES)) {
    return @(".")
  }

  return @(
    $env:BIOME_FILES -split "\s+" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
}

function Invoke-Biome {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & biome @Arguments
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

$targets = Get-BiomeTargets

switch ($Mode) {
  "format" {
    $formatArgs = @("format", "--write") + $targets
    $lintArgs = @("lint", "--write") + $targets
    Invoke-Biome -Arguments $formatArgs
    Invoke-Biome -Arguments $lintArgs
  }
  "check" {
    $checkArgs = @(
      "check",
      "--formatter-enabled=true",
      "--linter-enabled=true"
    ) + $targets
    Invoke-Biome -Arguments $checkArgs
  }
  "lint" {
    $lintArgs = @("lint") + $targets
    Invoke-Biome -Arguments $lintArgs
  }
}
