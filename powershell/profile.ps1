# Shared PowerShell profile managed in ~/.config/powershell.
if ($global:DotfilesPowerShellProfileLoaded) {
  return
}
$global:DotfilesPowerShellProfileLoaded = $true

$repoProfileDir = Split-Path -Parent $PSCommandPath
$profileDir = Join-Path $repoProfileDir "profile.d"
if (Test-Path $profileDir) {
  Get-ChildItem -Path $profileDir -Filter "*.ps1" -File |
    Sort-Object Name |
    ForEach-Object {
      . $_.FullName
    }
}

$localProfileDir = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\profile.local.d"
if (Test-Path $localProfileDir) {
  Get-ChildItem -Path $localProfileDir -Filter "*.ps1" -File |
    Sort-Object Name |
    ForEach-Object {
      . $_.FullName
    }
}
