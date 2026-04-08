# Shared mise bootstrap for PowerShell on Windows.

$windowsMiseConfig = Join-Path $env:USERPROFILE ".config\mise\config.windows.toml"
if (-not $env:MISE_CONFIG_FILE -and (Test-Path $windowsMiseConfig)) {
  $env:MISE_CONFIG_FILE = $windowsMiseConfig
}

$miseCandidates = @(
  (Get-Command "mise.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
  (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin\mise.exe"),
  (Join-Path $env:USERPROFILE ".local\bin\mise.exe"),
  (Join-Path $env:LOCALAPPDATA "mise\bin\mise.exe")
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

$miseExe = $miseCandidates | Select-Object -First 1
if (-not $miseExe) {
  return
}

$miseBin = Split-Path -Parent $miseExe
$pathEntries = $env:PATH -split [IO.Path]::PathSeparator
if ($pathEntries -notcontains $miseBin) {
  $env:PATH = $miseBin + [IO.Path]::PathSeparator + $env:PATH
}

# Windows PowerShell 5 can use the pwsh activation script, but chpwd warnings are noisy there.
$env:MISE_PWSH_CHPWD_WARNING = "0"

& $miseExe activate pwsh | Out-String | Invoke-Expression
