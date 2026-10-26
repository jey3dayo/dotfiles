# Shared mise bootstrap for PowerShell on Windows.
#
# MISE_ENV selects machine type and overlays (entry goes last so entry settings win).
# Uses standard global config discovery (~/.config/mise/config.<env>.toml).
# Windows: bun,shared,workstation,workstation-windows
$miseEnvironmentTokens = @($env:MISE_ENV -split "," | Where-Object { $_ })
foreach ($requiredToken in @("bun", "shared", "workstation", "workstation-windows")) {
  if ($miseEnvironmentTokens -notcontains $requiredToken) {
    $miseEnvironmentTokens += $requiredToken
  }
}
$env:MISE_ENV = ($miseEnvironmentTokens -join ",")

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

$miseShims = Join-Path $env:LOCALAPPDATA "mise\shims"
$pathEntries = $env:PATH -split [IO.Path]::PathSeparator
if ((Test-Path $miseShims) -and ($pathEntries -notcontains $miseShims)) {
  $env:PATH = $miseShims + [IO.Path]::PathSeparator + $env:PATH
}

# Windows PowerShell 5 can use the pwsh activation script, but chpwd warnings are noisy there.
$env:MISE_PWSH_CHPWD_WARNING = "0"

& $miseExe activate pwsh | Out-String | Invoke-Expression
