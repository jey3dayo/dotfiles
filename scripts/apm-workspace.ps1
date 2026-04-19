[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Command = "help",

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$CommandArgs
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WorkspaceDir = if ($env:APM_WORKSPACE_DIR) { $env:APM_WORKSPACE_DIR } else { Join-Path $HOME ".apm" }
$WorkspaceRepo = if ($env:APM_WORKSPACE_REPO) { $env:APM_WORKSPACE_REPO } else { "https://github.com/jey3dayo/apm-workspace.git" }
$LegacySkillsDir = Join-Path $RepoRoot "agents\src\skills"
$LegacyAgentsDir = Join-Path $RepoRoot "agents\src\agents"
$LegacyCommandsDir = Join-Path $RepoRoot "agents\src\commands"
$LegacyRulesDir = Join-Path $RepoRoot "agents\src\rules"
$LegacyConfigFile = Join-Path $RepoRoot "agents\src\AGENTS.md"
$ExternalSourcesFile = Join-Path $RepoRoot "nix\agent-skills-sources.nix"
$CodexOutput = if ($env:APM_CODEX_OUTPUT) { $env:APM_CODEX_OUTPUT } else { Join-Path $HOME ".codex\AGENTS.md" }
$MiseTemplate = Join-Path $RepoRoot "templates\apm-workspace\mise.toml"
$MiseDestination = Join-Path $WorkspaceDir "mise.toml"
$CatalogBuildRootDir = Join-Path $WorkspaceDir ".catalog-build"
$CatalogDirName = "catalog"
$ManagedMiseMarker = "# Managed by ~/.config bootstrap"

function Test-CommandAvailable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Write-WarnLine {
  param([string]$Message)
  Write-Warning $Message
}

function Write-ErrorLine {
  param([string]$Message)
  Write-Host $Message -ForegroundColor Red
}

function Write-SuccessLine {
  param([string]$Message)
  Write-Host $Message -ForegroundColor Green
}

function Require-Command {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if (-not (Test-CommandAvailable -Name $Name)) {
    throw "$Name not found. Install it first."
  }
}

function Require-Apm {
  if (-not (Test-CommandAvailable -Name "apm")) {
    throw "apm not found. Run 'cd $WorkspaceDir; mise install' (or install it in another shell) before retrying."
  }
}

function Test-SkillId {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  if ($SkillId -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw "Invalid skill id: $SkillId"
  }

  if ($SkillId.Contains("/") -or $SkillId.Contains("\") -or $SkillId -in @(".", "..")) {
    throw "Invalid skill id: $SkillId"
  }
}

function Test-SkillPathSegments {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Segments,

    [Parameter(Mandatory = $true)]
    [string]$OriginalValue
  )

  if (-not $Segments -or $Segments.Count -eq 0) {
    throw "Invalid skill path: $OriginalValue"
  }

  foreach ($segment in $Segments) {
    if ($segment -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
      throw "Invalid skill path: $OriginalValue"
    }

    if ($segment -in @(".", "..")) {
      throw "Invalid skill path: $OriginalValue"
    }
  }
}

function Convert-SkillIdToPathSegments {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $segments = @($SkillId -split ':')
  Test-SkillPathSegments -Segments $segments -OriginalValue $SkillId
  return $segments
}

function Convert-SkillIdToPackageRelativePath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  return ((Convert-SkillIdToPathSegments -SkillId $SkillId) -join [System.IO.Path]::DirectorySeparatorChar)
}

function Convert-SkillIdToManifestRelativePath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  return ((Convert-SkillIdToPathSegments -SkillId $SkillId) -join "/")
}

function Get-WorkspaceProjectName {
  if ($env:APM_WORKSPACE_NAME) {
    return $env:APM_WORKSPACE_NAME
  }

  $repoName = Split-Path -Leaf $WorkspaceRepo
  if ($repoName.EndsWith(".git")) {
    return $repoName.Substring(0, $repoName.Length - 4)
  }

  return $repoName
}

function Get-WorkspaceAuthorName {
  $gitUser = & git config user.name 2>$null
  if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($gitUser | Out-String))) {
    return $gitUser.Trim()
  }

  if ($env:USER) {
    return $env:USER
  }

  if ($env:USERNAME) {
    return $env:USERNAME
  }

  return "unknown"
}

function Ensure-WorkspaceRepo {
  Require-Command -Name "git"

  if (-not (Test-Path -LiteralPath $WorkspaceDir)) {
    Write-Host "Cloning $WorkspaceRepo into $WorkspaceDir"
    & git clone $WorkspaceRepo $WorkspaceDir
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone $WorkspaceRepo"
    }
  } elseif ((Test-Path -LiteralPath $WorkspaceDir -PathType Container) -and -not (Test-Path -LiteralPath (Join-Path $WorkspaceDir ".git"))) {
    $entries = @(Get-ChildItem -LiteralPath $WorkspaceDir -Force)
    if ($entries.Count -ne 0) {
      throw "$WorkspaceDir exists but is not an empty directory or git checkout."
    }

    Write-Host "Cloning $WorkspaceRepo into existing empty directory $WorkspaceDir"
    Push-Location $WorkspaceDir
    try {
      & git clone $WorkspaceRepo .
      if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone $WorkspaceRepo into $WorkspaceDir"
      }
    }
    finally {
      Pop-Location
    }
  } elseif (-not (Test-Path -LiteralPath $WorkspaceDir -PathType Container)) {
    throw "$WorkspaceDir exists but is not a directory."
  }

  if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceDir ".git"))) {
    throw "$WorkspaceDir exists but is not a git checkout."
  }

}

function Ensure-GitignoreEntry {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Entry
  )

  $gitignorePath = Join-Path $WorkspaceDir ".gitignore"
  if (-not (Test-Path -LiteralPath $gitignorePath)) {
    New-Item -ItemType File -Path $gitignorePath -Force | Out-Null
  }

  $content = Get-Content -LiteralPath $gitignorePath -ErrorAction SilentlyContinue
  if ($content -notcontains $Entry) {
    Add-Content -LiteralPath $gitignorePath -Value ""
    Add-Content -LiteralPath $gitignorePath -Value $Entry
  }
}

function Normalize-WorkspaceGitignore {
  $gitignorePath = Join-Path $WorkspaceDir ".gitignore"
  if (-not (Test-Path -LiteralPath $gitignorePath)) {
    return
  }

  $canonicalEntries = @("/.apm/", "/apm_modules/", "/.catalog-build/")
  $normalized = New-Object System.Collections.Generic.List[string]
  $seen = New-Object System.Collections.Generic.HashSet[string]

  foreach ($line in (Get-Content -LiteralPath $gitignorePath -ErrorAction SilentlyContinue)) {
    if ($line -in @("# APM dependencies", "apm_modules/")) {
      continue
    }

    if ($canonicalEntries -contains $line) {
      if ($seen.Add($line)) {
        $normalized.Add($line)
      }
      continue
    }

    $normalized.Add($line)
  }

  foreach ($entry in $canonicalEntries) {
    if ($seen.Add($entry)) {
      if ($normalized.Count -gt 0 -and $normalized[$normalized.Count - 1] -ne "") {
        $normalized.Add("")
      }
      $normalized.Add($entry)
    }
  }

  while ($normalized.Count -gt 0 -and $normalized[$normalized.Count - 1] -eq "") {
    $normalized.RemoveAt($normalized.Count - 1)
  }

  [System.IO.File]::WriteAllText($gitignorePath, (($normalized -join [Environment]::NewLine) + [Environment]::NewLine))
}

function Write-WorkspaceManifestTemplate {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  $projectName = Get-WorkspaceProjectName
  $authorName = Get-WorkspaceAuthorName

  $manifestContent = @(
    "name: $projectName",
    "version: 1.0.0",
    "description: APM project for $projectName",
    "author: $authorName",
    "dependencies:",
    "  apm: []",
    "  mcp: []",
    "scripts: {}"
  ) -join [Environment]::NewLine

  [System.IO.File]::WriteAllText($manifestPath, $manifestContent)
}

function Ensure-WorkspaceScaffold {
  Ensure-WorkspaceRepo
  Ensure-GitignoreEntry -Entry "/.apm/"
  Ensure-GitignoreEntry -Entry "/apm_modules/"
  Ensure-GitignoreEntry -Entry "/.catalog-build/"

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Writing bootstrap apm.yml in $WorkspaceDir"
    Write-WorkspaceManifestTemplate
  }
}

function Copy-DirectoryContents {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Directory not found: $SourceDir"
  }

  New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
  foreach ($entry in Get-ChildItem -LiteralPath $SourceDir -Force) {
    Copy-Item -LiteralPath $entry.FullName -Destination $DestinationDir -Recurse -Force
  }
}

function Get-RelativeFilePaths {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RootDir
  )

  if (-not (Test-Path -LiteralPath $RootDir)) {
    return @()
  }

  $rootFullPath = (Resolve-Path -LiteralPath $RootDir).Path
  $result = New-Object System.Collections.Generic.List[string]
  foreach ($file in Get-ChildItem -LiteralPath $RootDir -Recurse -File) {
    $relativePath = $file.FullName.Substring($rootFullPath.Length).TrimStart('\', '/')
    $result.Add(($relativePath -replace '\\', '/'))
  }

  $array = $result.ToArray()
  [Array]::Sort($array)
  return $array
}

function Convert-WorkspaceRemoteToRepoReference {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RemoteUrl
  )

  if ($RemoteUrl -match '^https://github\.com/([^/]+)/([^/]+?)(?:\.git)?/?$') {
    return "$($matches[1])/$($matches[2])"
  }
  if ($RemoteUrl -match '^git@github\.com:([^/]+)/([^/]+?)(?:\.git)?$') {
    return "$($matches[1])/$($matches[2])"
  }

  throw "Unsupported workspace remote URL for internal bundle reference: $RemoteUrl"
}

function Get-WorkspaceRemoteUrl {
  param(
    [string]$RemoteName = "origin"
  )

  Ensure-WorkspaceRepo

  $remoteUrl = & git -C $WorkspaceDir remote get-url $RemoteName 2>$null
  if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($remoteUrl | Out-String))) {
    return ($remoteUrl | Out-String).Trim()
  }

  if ($RemoteName -eq "origin") {
    return $WorkspaceRepo
  }

  throw "Could not resolve remote URL for '$RemoteName'"
}

function Get-WorkspaceRepoReference {
  param(
    [string]$RemoteName = "origin"
  )

  return Convert-WorkspaceRemoteToRepoReference -RemoteUrl (Get-WorkspaceRemoteUrl -RemoteName $RemoteName)
}

function Get-WorkspaceTrackingInfo {
  $currentBranch = & git -C $WorkspaceDir branch --show-current 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($currentBranch | Out-String))) {
    throw "Cannot register internal bundle from a detached HEAD. Check out a tracking branch first."
  }

  $currentBranch = ($currentBranch | Out-String).Trim()
  $remoteName = & git -C $WorkspaceDir config --get "branch.$currentBranch.remote" 2>$null
  $mergeRef = & git -C $WorkspaceDir config --get "branch.$currentBranch.merge" 2>$null

  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($remoteName | Out-String)) -or [string]::IsNullOrWhiteSpace(($mergeRef | Out-String))) {
    throw "Branch '$currentBranch' has no upstream tracking branch. Push it first."
  }

  $remoteName = ($remoteName | Out-String).Trim()
  $mergeBranch = (($mergeRef | Out-String).Trim()) -replace '^refs/heads/', ''
  return [pscustomobject]@{
    RemoteName = $remoteName
    BranchName = $mergeBranch
  }
}

function Get-LegacySkillContentDir {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $skillRoot = Join-Path $LegacySkillsDir $SkillId
  if (-not (Test-Path -LiteralPath $skillRoot)) {
    throw "Legacy skill not found: $skillRoot"
  }

  if (Test-Path -LiteralPath (Join-Path $skillRoot "SKILL.md")) {
    return $skillRoot
  }

  $nestedSkillsDir = Join-Path $skillRoot "skills"
  if (Test-Path -LiteralPath (Join-Path $nestedSkillsDir "SKILL.md")) {
    return $nestedSkillsDir
  }

  throw "Legacy skill content dir missing SKILL.md: $skillRoot"
}

function Refresh-WorkspaceCheckout {
  Ensure-WorkspaceRepo

  $dirty = & git -C $WorkspaceDir status --porcelain 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to read git status for $WorkspaceDir"
  }

  if (-not [string]::IsNullOrWhiteSpace(($dirty | Out-String))) {
    Write-WarnLine "$WorkspaceDir has local changes; skipping git pull."
    return
  }

  $currentBranch = & git -C $WorkspaceDir branch --show-current 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($currentBranch | Out-String))) {
    return
  }

  $currentBranch = $currentBranch.Trim()
  $remoteName = & git -C $WorkspaceDir config --get "branch.$currentBranch.remote" 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($remoteName | Out-String))) {
    return
  }

  $mergeRef = & git -C $WorkspaceDir config --get "branch.$currentBranch.merge" 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($mergeRef | Out-String))) {
    return
  }

  $remoteName = $remoteName.Trim()
  $mergeBranch = $mergeRef.Trim() -replace '^refs/heads/', ''
  $upstream = "$remoteName/$mergeBranch"

  & git -C $WorkspaceDir show-ref --verify --quiet "refs/remotes/$upstream" 2>$null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  Write-Host "Updating $WorkspaceDir from $upstream"
  & git -C $WorkspaceDir pull --ff-only
  if ($LASTEXITCODE -ne 0) {
    throw "git pull --ff-only failed for $WorkspaceDir"
  }
}

function Ensure-WorkspaceMiseFile {
  if (-not (Test-Path -LiteralPath $MiseTemplate)) {
    throw "Missing mise template: $MiseTemplate"
  }

  if (-not (Test-Path -LiteralPath $MiseDestination)) {
    Copy-Item -LiteralPath $MiseTemplate -Destination $MiseDestination -Force
    Write-Host "Installed workspace mise.toml: $MiseDestination"
    return
  }

  $content = Get-Content -LiteralPath $MiseDestination -Raw
  if ($content.Contains($ManagedMiseMarker)) {
    Copy-Item -LiteralPath $MiseTemplate -Destination $MiseDestination -Force
    Write-Host "Refreshed managed workspace mise.toml: $MiseDestination"
    return
  }

  if ($env:APM_BOOTSTRAP_FORCE_MISE -eq "1") {
    Copy-Item -LiteralPath $MiseTemplate -Destination $MiseDestination -Force
    Write-Host "Replaced workspace mise.toml due to APM_BOOTSTRAP_FORCE_MISE=1"
    return
  }

  Write-WarnLine "$MiseDestination already exists and is not managed by this repo; leaving it unchanged."
}

function Invoke-CodexCompile {
  Require-Apm
  $codexDir = Split-Path -Parent $CodexOutput
  if (-not [string]::IsNullOrWhiteSpace($codexDir)) {
    New-Item -ItemType Directory -Path $codexDir -Force | Out-Null
  }

  Push-Location $WorkspaceDir
  try {
    & apm compile --target codex --output $CodexOutput
    if ($LASTEXITCODE -ne 0) {
      throw "apm compile failed."
    }
  }
  finally {
    Pop-Location
  }
}

function Invoke-WorkspaceCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$CommandArgs
  )

  Push-Location $WorkspaceDir
  try {
    & apm @CommandArgs
    if ($LASTEXITCODE -ne 0) {
      throw "apm command failed: $($CommandArgs -join ' ')"
    }
  }
  finally {
    Pop-Location
  }
}

function Test-ApmInstallDiagnosticsFailure {
  param(
    [string[]]$OutputLines
  )

  $joined = ($OutputLines | ForEach-Object { "$_" }) -join "`n"
  return ($joined -match '\[[xX]\]\s+[1-9][0-9]* packages failed:' -or
    $joined -match 'Installed .* with [1-9][0-9]* error\(s\)\.')
}

function Invoke-WorkspaceInstallCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$InstallArgs
  )

  Push-Location $WorkspaceDir
  try {
    $outputLines = @(& apm install @InstallArgs 2>&1)
    foreach ($line in $outputLines) {
      Write-Host $line
    }
    if ($LASTEXITCODE -ne 0) {
      throw "apm install failed: $($InstallArgs -join ' ')"
    }
    if (Test-ApmInstallDiagnosticsFailure -OutputLines $outputLines) {
      throw "apm install reported integration diagnostics: $($InstallArgs -join ' ')"
    }
  }
  finally {
    Pop-Location
  }
}

function Test-ManifestHasLocalPackages {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return $false
  }

  $manifestContent = Get-Content -LiteralPath $manifestPath -ErrorAction SilentlyContinue
  return [bool]($manifestContent | Select-String -Pattern '^\s*-\s+\./packages/')
}

function Get-LockPinnedReferenceMap {
  $lockPath = Join-Path $WorkspaceDir "apm.lock.yaml"
  if (-not (Test-Path -LiteralPath $lockPath)) {
    throw "Lock file not found: $lockPath"
  }

  $records = @()
  $current = @{}
  foreach ($line in (Get-Content -LiteralPath $lockPath)) {
    if ($line -match '^- repo_url:\s+(.+)$') {
      if ($current.ContainsKey('repo_url')) {
        $records += [pscustomobject]$current
      }
      $current = @{ repo_url = $Matches[1].Trim() }
      continue
    }

    if (-not $current.ContainsKey('repo_url')) {
      continue
    }

    if ($line -match '^\s+resolved_commit:\s+(.+)$') {
      $current.resolved_commit = $Matches[1].Trim()
      continue
    }

    if ($line -match '^\s+virtual_path:\s+(.+)$') {
      $current.virtual_path = $Matches[1].Trim()
      continue
    }
  }

  if ($current.ContainsKey('repo_url')) {
    $records += [pscustomobject]$current
  }

  $map = @{}
  foreach ($record in $records) {
    if (-not $record.PSObject.Properties.Name.Contains('resolved_commit')) {
      continue
    }

    $canonical = if ($record.PSObject.Properties.Name.Contains('virtual_path') -and -not [string]::IsNullOrWhiteSpace($record.virtual_path)) {
      "$($record.repo_url)/$($record.virtual_path)"
    } else {
      $record.repo_url
    }

    $map[$canonical] = "$canonical#$($record.resolved_commit)"
  }

  return $map
}

function Get-UnpinnedExternalReferences {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return @()
  }

  $result = New-Object System.Collections.Generic.List[string]
  foreach ($line in (Get-Content -LiteralPath $manifestPath)) {
    if ($line -match '^\s*-\s+(\S+)\s*$') {
      $reference = $Matches[1]
      if ($reference -match '^jey3dayo/apm-workspace/catalog(?:#|$)') {
        continue
      }
      if ($reference -match '^\.\/') {
        continue
      }
      if ($reference -notmatch '#') {
        $result.Add($reference)
      }
    }
  }

  return $result.ToArray()
}

function Get-ManifestReferenceKeys {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  $keys = New-Object 'System.Collections.Generic.HashSet[string]'
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return $keys
  }

  foreach ($line in (Get-Content -LiteralPath $manifestPath)) {
    if ($line -match '^\s*-\s+(\S+)\s*$') {
      $reference = $Matches[1]
      $null = $keys.Add($reference)
      $baseReference = ($reference -replace '#.*$', '')
      $null = $keys.Add($baseReference)
    }
  }

  return $keys
}

function Invoke-PinExternal {
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest not found: $manifestPath"
  }

  $pinMap = Get-LockPinnedReferenceMap
  $updatedCount = 0
  $updatedLines = New-Object System.Collections.Generic.List[string]

  foreach ($line in (Get-Content -LiteralPath $manifestPath)) {
    if ($line -match '^(\s*-\s+)(\S+)\s*$') {
      $prefix = $Matches[1]
      $reference = $Matches[2]
      if ($reference -notmatch '#' -and $pinMap.ContainsKey($reference)) {
        $updatedLines.Add("$prefix$($pinMap[$reference])")
        $updatedCount += 1
        continue
      }
    }

    $updatedLines.Add($line)
  }

  if ($updatedCount -eq 0) {
    Write-Host "No external dependencies needed pinning."
    return
  }

  $content = (($updatedLines.ToArray()) -join "`r`n") + "`r`n"
  [System.IO.File]::WriteAllText($manifestPath, $content)
  Write-SuccessLine ("Pinned {0} external dependency references in apm.yml" -f $updatedCount)
}

function Invoke-Apply {
  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Invoke-ValidateCatalog

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Remove local package refs from ~/.apm/apm.yml and keep the global manifest on upstream refs such as jey3dayo/apm-workspace/catalog#main."
  }

  Remove-InternalTargetReparsePoints -SkillIds @(Get-ManagedSkillIds)
  Invoke-WorkspaceInstallCommand -InstallArgs @("-g")
  Normalize-WorkspaceGitignore
  Invoke-CodexCompile
  Sync-ManagedCatalogRuntimeAssets
}

function Invoke-Update {
  Require-Apm
  Ensure-WorkspaceRepo
  Refresh-WorkspaceCheckout
  Ensure-WorkspaceScaffold
  Invoke-ValidateCatalog

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; remove local package refs from ~/.apm/apm.yml first."
  }

  Remove-InternalTargetReparsePoints -SkillIds @(Get-ManagedSkillIds)
  & apm deps update -g
  if ($LASTEXITCODE -ne 0) {
    throw "apm deps update -g failed."
  }
  Invoke-WorkspaceInstallCommand -InstallArgs @("-g")
  Normalize-WorkspaceGitignore
  Invoke-CodexCompile
  Sync-ManagedCatalogRuntimeAssets
}

function Invoke-List {
  Require-Apm
  & apm deps list -g
  if ($LASTEXITCODE -ne 0) {
    throw "apm deps list -g failed."
  }
}

function Invoke-Validate {
  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Invoke-WorkspaceCommand -CommandArgs @("compile", "--validate")
}

function Get-CatalogBuildDir {
  return (Join-Path $CatalogBuildRootDir $CatalogDirName)
}

function Get-CatalogBuildSkillsRoot {
  return (Join-Path (Get-CatalogBuildDir) ".apm\skills")
}

function Get-CatalogBuildAgentsRoot {
  return (Join-Path (Get-CatalogBuildDir) "agents")
}

function Get-CatalogBuildCommandsRoot {
  return (Join-Path (Get-CatalogBuildDir) "commands")
}

function Get-CatalogBuildRulesRoot {
  return (Join-Path (Get-CatalogBuildDir) "rules")
}

function Get-CatalogBuildInstructionsPath {
  return (Join-Path (Get-CatalogBuildDir) "AGENTS.md")
}

function Get-TrackedCatalogDir {
  return (Join-Path $WorkspaceDir $CatalogDirName)
}

function Get-TrackedCatalogSkillsRoot {
  return (Join-Path (Get-TrackedCatalogDir) ".apm\skills")
}

function Get-TrackedCatalogAgentsRoot {
  return (Join-Path (Get-TrackedCatalogDir) "agents")
}

function Get-TrackedCatalogCommandsRoot {
  return (Join-Path (Get-TrackedCatalogDir) "commands")
}

function Get-TrackedCatalogRulesRoot {
  return (Join-Path (Get-TrackedCatalogDir) "rules")
}

function Get-TrackedCatalogInstructionsPath {
  return (Join-Path (Get-TrackedCatalogDir) "AGENTS.md")
}

function Get-TrackedCatalogRelativePath {
  return $CatalogDirName
}

function Get-SkillIdsFromRoot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillsRoot
  )

  if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    return @()
  }

  $result = New-Object System.Collections.Generic.List[string]
  foreach ($skillFile in (Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter "SKILL.md" -File | Sort-Object FullName)) {
    $skillDir = Split-Path -Parent $skillFile.FullName
    $relativePath = $skillDir.Substring($SkillsRoot.Length).TrimStart('\', '/')
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      continue
    }

    $skillId = ($relativePath -replace '[\\/]', ':')
    if (-not $result.Contains($skillId)) {
      $result.Add($skillId)
    }
  }

  return $result.ToArray()
}

function Get-ManagedSkillIds {
  return @(Get-SkillIdsFromRoot -SkillsRoot (Get-TrackedCatalogSkillsRoot))
}

function Get-RequestedManagedSkillIds {
  param(
    [string[]]$RequestedSkillIds
  )

  if ($RequestedSkillIds -and $RequestedSkillIds.Count -gt 0) {
    foreach ($skillId in $RequestedSkillIds) {
      Test-SkillId -SkillId $skillId
    }
    return $RequestedSkillIds
  }

  return @(Get-ManagedSkillIds)
}

function Get-TrackedCatalogAgentRelativePaths {
  return @(Get-RelativeFilePaths -RootDir (Get-TrackedCatalogAgentsRoot))
}

function Get-ManagedAgentRelativePaths {
  return @(Get-TrackedCatalogAgentRelativePaths)
}

function Get-TrackedCatalogCommandRelativePaths {
  return @(Get-RelativeFilePaths -RootDir (Get-TrackedCatalogCommandsRoot))
}

function Get-ManagedCommandRelativePaths {
  return @(Get-TrackedCatalogCommandRelativePaths)
}

function Get-TrackedCatalogRuleRelativePaths {
  return @(Get-RelativeFilePaths -RootDir (Get-TrackedCatalogRulesRoot))
}

function Get-ManagedRuleRelativePaths {
  return @(Get-TrackedCatalogRuleRelativePaths)
}

function Test-FileContentEqual {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ExpectedPath,

    [Parameter(Mandatory = $true)]
    [string]$ActualPath
  )

  if ((-not (Test-Path -LiteralPath $ExpectedPath)) -or (-not (Test-Path -LiteralPath $ActualPath))) {
    return $false
  }

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $expectedStream = [System.IO.File]::OpenRead($ExpectedPath)
    try {
      $expectedHash = [System.BitConverter]::ToString($sha.ComputeHash($expectedStream)).Replace("-", "")
    }
    finally {
      $expectedStream.Dispose()
    }

    $actualStream = [System.IO.File]::OpenRead($ActualPath)
    try {
      $actualHash = [System.BitConverter]::ToString($sha.ComputeHash($actualStream)).Replace("-", "")
    }
    finally {
      $actualStream.Dispose()
    }
  }
  finally {
    $sha.Dispose()
  }

  return $expectedHash -eq $actualHash
}

function Test-DirectoryTreeEqual {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ExpectedRoot,

    [Parameter(Mandatory = $true)]
    [string]$ActualRoot
  )

  if ((-not (Test-Path -LiteralPath $ExpectedRoot)) -or (-not (Test-Path -LiteralPath $ActualRoot))) {
    return $false
  }

  $expectedPaths = @(Get-RelativeFilePaths -RootDir $ExpectedRoot)
  $actualPaths = @(Get-RelativeFilePaths -RootDir $ActualRoot)
  if ((@($expectedPaths) -join "`n") -ne (@($actualPaths) -join "`n")) {
    return $false
  }

  foreach ($relativePath in $expectedPaths) {
    $expectedPath = Join-Path $ExpectedRoot ($relativePath -replace '/', '\')
    $actualPath = Join-Path $ActualRoot ($relativePath -replace '/', '\')
    if (-not (Test-FileContentEqual -ExpectedPath $expectedPath -ActualPath $actualPath)) {
      return $false
    }
  }

  return $true
}

function Get-CatalogManifestContent {
  return @(
    "name: $CatalogDirName",
    "version: 1.0.0",
    "description: Managed catalog package for global APM rollout",
    "dependencies:",
    "  apm: []",
    "  mcp: []",
    "scripts: {}"
  ) -join [Environment]::NewLine
}

function Get-CatalogReadmeContent {
  return @(
    '# catalog',
    '',
    'This directory is the managed catalog source of truth for the global APM workspace.',
    '',
    '- Edit skills in `~/.apm/catalog/.apm/skills/<id>/`',
    '- Edit shared guidance in `~/.apm/catalog/AGENTS.md`, `agents/**`, `commands/**`, and `rules/**`',
    '- `skills` live under `.apm/skills/**` because they are installable APM package content',
    '- `commands/**` stays top-level because it is runtime-synced shared guidance, not nested skill package content',
    '- `mise run stage-catalog` normalizes this package and refreshes the transitional mirror in `~/.config/agents/src/`',
    '- Install ref: `jey3dayo/apm-workspace/catalog#main`'
  ) -join [Environment]::NewLine
}

function Get-TrackedCatalogSkillIds {
  return @(Get-SkillIdsFromRoot -SkillsRoot (Get-TrackedCatalogSkillsRoot))
}

function Get-MirrorSkillIds {
  return @(Get-SkillIdsFromRoot -SkillsRoot $LegacySkillsDir)
}

function Get-MirrorAgentRelativePaths {
  return @(Get-RelativeFilePaths -RootDir $LegacyAgentsDir)
}

function Get-MirrorCommandRelativePaths {
  return @(Get-RelativeFilePaths -RootDir $LegacyCommandsDir)
}

function Get-MirrorRuleRelativePaths {
  return @(Get-RelativeFilePaths -RootDir $LegacyRulesDir)
}

function Test-ManifestHasCatalogReference {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return $false
  }

  $repoReference = Convert-WorkspaceRemoteToRepoReference -RemoteUrl $WorkspaceRepo
  $pattern = [regex]::Escape("$repoReference/$CatalogDirName#")
  return [bool](Get-Content -LiteralPath $manifestPath -ErrorAction SilentlyContinue | Select-String -Pattern $pattern)
}

function Write-CatalogSummary {
  $sourceSkillIds = @(Get-ManagedSkillIds)
  $mirrorSkillIds = @(Get-MirrorSkillIds)
  $sourceAgentPaths = @(Get-ManagedAgentRelativePaths)
  $mirrorAgentPaths = @(Get-MirrorAgentRelativePaths)
  $sourceCommandPaths = @(Get-ManagedCommandRelativePaths)
  $mirrorCommandPaths = @(Get-MirrorCommandRelativePaths)
  $sourceRulePaths = @(Get-ManagedRuleRelativePaths)
  $mirrorRulePaths = @(Get-MirrorRuleRelativePaths)
  $sourceInstructionsPresent = Test-Path -LiteralPath $LegacyConfigFile
  $trackedInstructionsPath = Get-TrackedCatalogInstructionsPath
  $trackedInstructionsPresent = Test-Path -LiteralPath $trackedInstructionsPath
  $trackedManifest = Join-Path (Get-TrackedCatalogDir) "apm.yml"
  $trackedState = if (Test-Path -LiteralPath $trackedManifest) { "yes" } else { "no" }
  $manifestState = if (Test-ManifestHasCatalogReference) { "yes" } else { "no" }
  $skillsInSync = ($mirrorSkillIds.Count -eq $sourceSkillIds.Count) -and (@($sourceSkillIds | Where-Object { $_ -notin $mirrorSkillIds }).Count -eq 0) -and (@($mirrorSkillIds | Where-Object { $_ -notin $sourceSkillIds }).Count -eq 0)
  $agentsInSync = ($mirrorAgentPaths.Count -eq $sourceAgentPaths.Count) -and (@($sourceAgentPaths | Where-Object { $_ -notin $mirrorAgentPaths }).Count -eq 0) -and (@($mirrorAgentPaths | Where-Object { $_ -notin $sourceAgentPaths }).Count -eq 0)
  $commandsInSync = ($mirrorCommandPaths.Count -eq $sourceCommandPaths.Count) -and (@($sourceCommandPaths | Where-Object { $_ -notin $mirrorCommandPaths }).Count -eq 0) -and (@($mirrorCommandPaths | Where-Object { $_ -notin $sourceCommandPaths }).Count -eq 0)
  $rulesInSync = ($mirrorRulePaths.Count -eq $sourceRulePaths.Count) -and (@($sourceRulePaths | Where-Object { $_ -notin $mirrorRulePaths }).Count -eq 0) -and (@($mirrorRulePaths | Where-Object { $_ -notin $sourceRulePaths }).Count -eq 0)
  $instructionsState = if (-not $sourceInstructionsPresent) {
    "missing-mirror"
  } elseif (-not $trackedInstructionsPresent) {
    "missing-catalog"
  } elseif (Test-FileContentEqual -ExpectedPath $LegacyConfigFile -ActualPath $trackedInstructionsPath) {
    "ok"
  } else {
    "drift"
  }
  $mirrorState = if ($skillsInSync -and $agentsInSync -and $commandsInSync -and $rulesInSync -and ($instructionsState -eq "ok")) { "ok" } else { "drift" }
  $coverageState = if (($trackedState -eq "yes") -and ($manifestState -eq "yes") -and ($mirrorState -eq "ok")) { "ok" } else { "drift" }

  Write-Host ("catalog: skills={0}/{1} agents={2}/{3} commands={4}/{5} rules={6}/{7} instructions={8} tracked-manifest={9} global-ref={10} mirror={11} status={12}" -f $sourceSkillIds.Count, $mirrorSkillIds.Count, $sourceAgentPaths.Count, $mirrorAgentPaths.Count, $sourceCommandPaths.Count, $mirrorCommandPaths.Count, $sourceRulePaths.Count, $mirrorRulePaths.Count, $instructionsState, $trackedState, $manifestState, $mirrorState, $coverageState)
}

function Get-ManagedExternalOverlapEntries {
  $managedSkillIds = New-Object 'System.Collections.Generic.HashSet[string]'
  foreach ($skillId in (Get-ManagedSkillIds)) {
    $null = $managedSkillIds.Add($skillId)
  }

  $overlaps = New-Object System.Collections.Generic.List[object]
  foreach ($source in (Get-ExternalSkillSources)) {
    foreach ($skillId in $source.SelectedSkills) {
      if ($managedSkillIds.Contains($skillId)) {
        $overlaps.Add([pscustomobject]@{
          SourceName = $source.Name
          SkillId = $skillId
        })
      }
    }
  }

  return @($overlaps | Sort-Object SourceName, SkillId)
}

function Write-ManagedExternalOverlapSummary {
  $overlaps = @(Get-ManagedExternalOverlapEntries)
  Write-Host ("external selection overlap: count={0}" -f $overlaps.Count)
  foreach ($entry in $overlaps) {
    Write-WarnLine ("  {0}: {1}" -f $entry.SourceName, $entry.SkillId)
  }
}

function Get-ManagedCatalogRuntimeTargets {
  return @(
    [pscustomobject]@{ Name = "claude"; Root = (Join-Path $HOME ".claude"); ConfigName = "CLAUDE.md" },
    [pscustomobject]@{ Name = "codex"; Root = (Join-Path $HOME ".codex"); ConfigName = "AGENTS.md" },
    [pscustomobject]@{ Name = "cursor"; Root = (Join-Path $HOME ".cursor"); ConfigName = "AGENTS.md" },
    [pscustomobject]@{ Name = "opencode"; Root = (Join-Path $HOME ".opencode"); ConfigName = "CLAUDE.md" },
    [pscustomobject]@{ Name = "openclaw"; Root = (Join-Path $HOME ".openclaw"); ConfigName = "CLAUDE.md" }
  )
}

function Copy-ManagedCatalogFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$DestinationPath
  )

  $destinationDir = Split-Path -Parent $DestinationPath
  if (-not [string]::IsNullOrWhiteSpace($destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
}

function Sync-ManagedCatalogRuntimeAssets {
  $trackedDir = Get-TrackedCatalogDir
  if (-not (Test-Path -LiteralPath $trackedDir)) {
    throw "Tracked catalog missing: $trackedDir. Run 'mise run stage-catalog' first."
  }

  $instructionsSource = Get-TrackedCatalogInstructionsPath
  $agentsSource = Get-TrackedCatalogAgentsRoot
  $commandsSource = Get-TrackedCatalogCommandsRoot
  $rulesSource = Get-TrackedCatalogRulesRoot

  foreach ($target in (Get-ManagedCatalogRuntimeTargets)) {
    New-Item -ItemType Directory -Path $target.Root -Force | Out-Null

    if (Test-Path -LiteralPath $instructionsSource) {
      Copy-ManagedCatalogFile -SourcePath $instructionsSource -DestinationPath (Join-Path $target.Root $target.ConfigName)
    }

    if (Test-Path -LiteralPath $agentsSource) {
      Copy-DirectoryContents -SourceDir $agentsSource -DestinationDir (Join-Path $target.Root "agents")
    }

    if (Test-Path -LiteralPath $commandsSource) {
      Copy-DirectoryContents -SourceDir $commandsSource -DestinationDir (Join-Path $target.Root "commands")
    }

    if (Test-Path -LiteralPath $rulesSource) {
      Copy-DirectoryContents -SourceDir $rulesSource -DestinationDir (Join-Path $target.Root "rules")
    }
  }
}

function Invoke-ValidateCatalog {
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  $hasFailure = $false
  $sourceSkillIds = @(Get-ManagedSkillIds)
  $mirrorSkillIds = @(Get-MirrorSkillIds)
  $sourceAgentPaths = @(Get-ManagedAgentRelativePaths)
  $mirrorAgentPaths = @(Get-MirrorAgentRelativePaths)
  $sourceCommandPaths = @(Get-ManagedCommandRelativePaths)
  $mirrorCommandPaths = @(Get-MirrorCommandRelativePaths)
  $sourceRulePaths = @(Get-ManagedRuleRelativePaths)
  $mirrorRulePaths = @(Get-MirrorRuleRelativePaths)
  $trackedInstructionsPath = Get-TrackedCatalogInstructionsPath
  $trackedManifest = Join-Path (Get-TrackedCatalogDir) "apm.yml"
  $trackedReadme = Join-Path (Get-TrackedCatalogDir) "README.md"

  if (-not (Test-Path -LiteralPath $trackedManifest)) {
    Write-ErrorLine ("Tracked catalog manifest is missing: {0}" -f $trackedManifest)
    $hasFailure = $true
  } elseif ((Get-Content -LiteralPath $trackedManifest -Raw) -ne (Get-CatalogManifestContent)) {
    Write-ErrorLine "Tracked catalog manifest is not normalized"
    $hasFailure = $true
  }

  if (-not (Test-Path -LiteralPath $trackedReadme)) {
    Write-ErrorLine ("Tracked catalog README is missing: {0}" -f $trackedReadme)
    $hasFailure = $true
  } elseif ((Get-Content -LiteralPath $trackedReadme -Raw) -ne (Get-CatalogReadmeContent)) {
    Write-ErrorLine "Tracked catalog README is not normalized"
    $hasFailure = $true
  }

  if (-not (Test-ManifestHasCatalogReference)) {
    Write-ErrorLine "Global apm.yml is missing the tracked catalog ref"
    $hasFailure = $true
  }

  $missingMirrorSkillIds = @($sourceSkillIds | Where-Object { $_ -notin $mirrorSkillIds })
  $extraMirrorSkillIds = @($mirrorSkillIds | Where-Object { $_ -notin $sourceSkillIds })

  if ($missingMirrorSkillIds.Count -gt 0) {
    Write-ErrorLine ("Managed mirror is missing skills: {0}" -f ($missingMirrorSkillIds -join ", "))
    $hasFailure = $true
  }
  if ($extraMirrorSkillIds.Count -gt 0) {
    Write-ErrorLine ("Managed mirror has unexpected skills: {0}" -f ($extraMirrorSkillIds -join ", "))
    $hasFailure = $true
  }
  if (-not (Test-DirectoryTreeEqual -ExpectedRoot (Get-TrackedCatalogSkillsRoot) -ActualRoot $LegacySkillsDir)) {
    Write-ErrorLine "Managed mirror skills drift from ~/.apm/catalog/.apm/skills"
    $hasFailure = $true
  }

  $missingMirrorAgentPaths = @($sourceAgentPaths | Where-Object { $_ -notin $mirrorAgentPaths })
  $extraMirrorAgentPaths = @($mirrorAgentPaths | Where-Object { $_ -notin $sourceAgentPaths })
  if ($missingMirrorAgentPaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror is missing agents: {0}" -f ($missingMirrorAgentPaths -join ", "))
    $hasFailure = $true
  }
  if ($extraMirrorAgentPaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror has unexpected agents: {0}" -f ($extraMirrorAgentPaths -join ", "))
    $hasFailure = $true
  }
  if (-not (Test-DirectoryTreeEqual -ExpectedRoot (Get-TrackedCatalogAgentsRoot) -ActualRoot $LegacyAgentsDir)) {
    Write-ErrorLine "Managed mirror agents drift from ~/.apm/catalog/agents"
    $hasFailure = $true
  }

  $missingMirrorCommandPaths = @($sourceCommandPaths | Where-Object { $_ -notin $mirrorCommandPaths })
  $extraMirrorCommandPaths = @($mirrorCommandPaths | Where-Object { $_ -notin $sourceCommandPaths })
  if ($missingMirrorCommandPaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror is missing commands: {0}" -f ($missingMirrorCommandPaths -join ", "))
    $hasFailure = $true
  }
  if ($extraMirrorCommandPaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror has unexpected commands: {0}" -f ($extraMirrorCommandPaths -join ", "))
    $hasFailure = $true
  }
  if (-not (Test-DirectoryTreeEqual -ExpectedRoot (Get-TrackedCatalogCommandsRoot) -ActualRoot $LegacyCommandsDir)) {
    Write-ErrorLine "Managed mirror commands drift from ~/.apm/catalog/commands"
    $hasFailure = $true
  }

  $missingMirrorRulePaths = @($sourceRulePaths | Where-Object { $_ -notin $mirrorRulePaths })
  $extraMirrorRulePaths = @($mirrorRulePaths | Where-Object { $_ -notin $sourceRulePaths })
  if ($missingMirrorRulePaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror is missing rules: {0}" -f ($missingMirrorRulePaths -join ", "))
    $hasFailure = $true
  }
  if ($extraMirrorRulePaths.Count -gt 0) {
    Write-ErrorLine ("Managed mirror has unexpected rules: {0}" -f ($extraMirrorRulePaths -join ", "))
    $hasFailure = $true
  }
  if (-not (Test-DirectoryTreeEqual -ExpectedRoot (Get-TrackedCatalogRulesRoot) -ActualRoot $LegacyRulesDir)) {
    Write-ErrorLine "Managed mirror rules drift from ~/.apm/catalog/rules"
    $hasFailure = $true
  }

  if (-not (Test-Path -LiteralPath $LegacyConfigFile)) {
    Write-ErrorLine ("Managed mirror instructions are missing: {0}" -f $LegacyConfigFile)
    $hasFailure = $true
  } elseif (-not (Test-Path -LiteralPath $trackedInstructionsPath)) {
    Write-ErrorLine ("Tracked catalog is missing instructions: {0}" -f $trackedInstructionsPath)
    $hasFailure = $true
  } elseif (-not (Test-FileContentEqual -ExpectedPath $LegacyConfigFile -ActualPath $trackedInstructionsPath)) {
    Write-ErrorLine "Managed mirror instructions drift from ~/.apm/catalog/AGENTS.md"
    $hasFailure = $true
  }

  if ($hasFailure) {
    throw "Catalog validation failed"
  }

  Write-SuccessLine ("Catalog validation passed ({0} skills, {1} agents, {2} commands, {3} rules; mirror in sync)" -f $sourceSkillIds.Count, $sourceAgentPaths.Count, $sourceCommandPaths.Count, $sourceRulePaths.Count)
}

function Invoke-Doctor {
  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  $manifestState = if (Test-Path (Join-Path $WorkspaceDir "apm.yml")) { "present" } else { "missing" }
  Write-Host ("apm: {0}" -f (apm --version))
  Write-Host ("workspace: {0}" -f $WorkspaceDir)
  Write-Host ("manifest: {0}" -f $manifestState)
  $branch = & git -C $WorkspaceDir branch --show-current 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($branch | Out-String))) {
    $branch = "detached"
  }
  Write-Host ("branch: {0}" -f ($branch | Out-String).Trim())
  Write-Host "remote:"
  & git -C $WorkspaceDir remote -v
  Write-Host "targets:"
  foreach ($target in (Get-ManagedCatalogRuntimeTargets)) {
    $skillsPath = Join-Path $target.Root "skills"
    $configPath = Join-Path $target.Root $target.ConfigName
    $agentsPath = Join-Path $target.Root "agents"
    $commandsPath = Join-Path $target.Root "commands"
    $rulesPath = Join-Path $target.Root "rules"
    Write-Host ("  {0}: config={1} agents={2} commands={3} rules={4} skills={5}" -f $target.Name, $(if (Test-Path $configPath) { "present" } else { "missing" }), $(if (Test-Path $agentsPath) { "present" } else { "missing" }), $(if (Test-Path $commandsPath) { "present" } else { "missing" }), $(if (Test-Path $rulesPath) { "present" } else { "missing" }), $(if (Test-Path $skillsPath) { "present" } else { "missing" }))
  }
  Write-Host ("external pins: unpinned={0}" -f (@(Get-UnpinnedExternalReferences)).Count)
  Write-ManagedExternalOverlapSummary
  Write-CatalogSummary
  Invoke-List
}

function Get-InternalDeployTargetRoots {
  return @(
    (Join-Path $HOME ".claude\skills"),
    (Join-Path $HOME ".cursor\skills"),
    (Join-Path $HOME ".opencode\skills"),
    (Join-Path $HOME ".copilot\skills")
  )
}

function Get-InternalTargetSkillPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $path = $TargetRoot
  foreach ($segment in (Convert-SkillIdToPathSegments -SkillId $SkillId)) {
    $path = Join-Path $path $segment
  }
  return $path
}

function Remove-InternalTargetReparsePoints {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$SkillIds
  )

  foreach ($targetRoot in (Get-InternalDeployTargetRoots)) {
    if (-not (Test-Path -LiteralPath $targetRoot)) {
      continue
    }

    foreach ($skillId in $SkillIds) {
      $targetPath = Get-InternalTargetSkillPath -TargetRoot $targetRoot -SkillId $skillId
      if (-not (Test-Path -LiteralPath $targetPath)) {
        continue
      }

      $item = Get-Item -LiteralPath $targetPath -Force
      if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        try {
          Remove-Item -LiteralPath $targetPath -Force -ErrorAction Stop
        }
        catch {
          [System.IO.Directory]::Delete($targetPath, $false)
        }
        Write-Host "Removed existing reparse-point skill target before APM install: $targetPath"
      }
    }
  }
}

function Write-CatalogManifestTemplate {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  $manifestPath = Join-Path $DestinationDir "apm.yml"
  [System.IO.File]::WriteAllText($manifestPath, (Get-CatalogManifestContent))
}

function Write-CatalogReadme {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  $readmePath = Join-Path $DestinationDir "README.md"
  [System.IO.File]::WriteAllText($readmePath, (Get-CatalogReadmeContent))
}

function Reset-CatalogBuildDir {
  $buildDir = Get-CatalogBuildDir
  if (Test-Path -LiteralPath $buildDir) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
  }

  New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
  New-Item -ItemType Directory -Path (Get-CatalogBuildSkillsRoot) -Force | Out-Null
}

function Reset-TrackedCatalogDir {
  $trackedDir = Get-TrackedCatalogDir
  if (Test-Path -LiteralPath $trackedDir) {
    Remove-Item -LiteralPath $trackedDir -Recurse -Force
  }

  New-Item -ItemType Directory -Path $trackedDir -Force | Out-Null
}

function Get-ManagedSkillContentDir {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $skillRoot = Get-TrackedCatalogSkillsRoot
  foreach ($segment in (Convert-SkillIdToPathSegments -SkillId $SkillId)) {
    $skillRoot = Join-Path $skillRoot $segment
  }

  if (-not (Test-Path -LiteralPath (Join-Path $skillRoot "SKILL.md"))) {
    throw "Managed catalog skill missing SKILL.md: $skillRoot"
  }

  return $skillRoot
}

function Copy-ManagedSkillIntoCatalog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId,

    [Parameter(Mandatory = $true)]
    [string]$SkillsRoot
  )

  $sourceDir = Get-ManagedSkillContentDir -SkillId $SkillId
  $destinationDir = $SkillsRoot
  foreach ($segment in (Convert-SkillIdToPathSegments -SkillId $SkillId)) {
    $destinationDir = Join-Path $destinationDir $segment
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $destinationDir
}

function Copy-ManagedInstructionsIntoCatalog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationPath
  )

  $sourcePath = Get-TrackedCatalogInstructionsPath
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Managed catalog instructions missing: $sourcePath"
  }

  Copy-ManagedCatalogFile -SourcePath $sourcePath -DestinationPath $DestinationPath
}

function Copy-ManagedAgentAssetsIntoCatalog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  $sourceDir = Get-TrackedCatalogAgentsRoot
  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Managed catalog agents missing: $sourceDir"
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $DestinationDir
}

function Copy-ManagedCommandAssetsIntoCatalog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  $sourceDir = Get-TrackedCatalogCommandsRoot
  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Managed catalog commands missing: $sourceDir"
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $DestinationDir
}

function Copy-ManagedRuleAssetsIntoCatalog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir
  )

  $sourceDir = Get-TrackedCatalogRulesRoot
  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Managed catalog rules missing: $sourceDir"
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $DestinationDir
}

function Sync-ManagedCatalogMirror {
  $trackedDir = Get-TrackedCatalogDir
  if (-not (Test-Path -LiteralPath $trackedDir)) {
    throw "Tracked catalog missing: $trackedDir. Run 'mise run stage-catalog' first."
  }

  foreach ($mirrorDir in @($LegacySkillsDir, $LegacyAgentsDir, $LegacyCommandsDir, $LegacyRulesDir)) {
    if (Test-Path -LiteralPath $mirrorDir) {
      Remove-Item -LiteralPath $mirrorDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $mirrorDir -Force | Out-Null
  }

  Copy-DirectoryContents -SourceDir (Get-TrackedCatalogSkillsRoot) -DestinationDir $LegacySkillsDir
  Copy-DirectoryContents -SourceDir (Get-TrackedCatalogAgentsRoot) -DestinationDir $LegacyAgentsDir
  Copy-DirectoryContents -SourceDir (Get-TrackedCatalogCommandsRoot) -DestinationDir $LegacyCommandsDir
  Copy-DirectoryContents -SourceDir (Get-TrackedCatalogRulesRoot) -DestinationDir $LegacyRulesDir
  Copy-ManagedCatalogFile -SourcePath (Get-TrackedCatalogInstructionsPath) -DestinationPath $LegacyConfigFile
}

function Get-TrackedCatalogReference {
  $tracking = Get-WorkspaceTrackingInfo
  $repoReference = Get-WorkspaceRepoReference -RemoteName $tracking.RemoteName
  return "{0}/{1}#{2}" -f $repoReference, (Get-TrackedCatalogRelativePath), $tracking.BranchName
}

function Assert-TrackedCatalogPublished {
  $trackedRelativePath = Get-TrackedCatalogRelativePath
  $trackedDir = Get-TrackedCatalogDir

  if (-not (Test-Path -LiteralPath $trackedDir)) {
    throw "Tracked catalog missing: $trackedDir. Run 'mise run stage-catalog' first."
  }

  $dirty = & git -C $WorkspaceDir status --porcelain -- $trackedRelativePath 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to inspect git status for $trackedRelativePath"
  }
  if (-not [string]::IsNullOrWhiteSpace(($dirty | Out-String))) {
    throw "Tracked catalog has uncommitted changes. Commit and push $trackedRelativePath before registering it."
  }

  $tracking = Get-WorkspaceTrackingInfo
  $upstream = "{0}/{1}" -f $tracking.RemoteName, $tracking.BranchName
  $unpushed = & git -C $WorkspaceDir rev-list "$upstream..HEAD" -- $trackedRelativePath 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to compare $trackedRelativePath against $upstream"
  }
  if (-not [string]::IsNullOrWhiteSpace(($unpushed | Out-String))) {
    throw "Tracked catalog has commits not on $upstream. Push the branch before registering it."
  }
}

function Invoke-SeedCatalogBuild {
  param(
    [string[]]$RequestedSkillIds,
    [switch]$LegacyAlias
  )

  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile

  $skillIds = @(Get-RequestedManagedSkillIds -RequestedSkillIds $RequestedSkillIds)
  if ($LegacyAlias) {
    Write-WarnLine "migrate is now a compatibility alias. Prefer 'stage-catalog' for the catalog flow."
  }

  Reset-CatalogBuildDir
  Write-CatalogManifestTemplate -DestinationDir (Get-CatalogBuildDir)
  Write-CatalogReadme -DestinationDir (Get-CatalogBuildDir)
  Copy-ManagedInstructionsIntoCatalog -DestinationPath (Get-CatalogBuildInstructionsPath)
  Copy-ManagedAgentAssetsIntoCatalog -DestinationDir (Get-CatalogBuildAgentsRoot)
  Copy-ManagedCommandAssetsIntoCatalog -DestinationDir (Get-CatalogBuildCommandsRoot)
  Copy-ManagedRuleAssetsIntoCatalog -DestinationDir (Get-CatalogBuildRulesRoot)
  foreach ($skillId in $skillIds) {
    Copy-ManagedSkillIntoCatalog -SkillId $skillId -SkillsRoot (Get-CatalogBuildSkillsRoot)
  }

  Write-Host "Seeded catalog build at ~/.apm/.catalog-build/$CatalogDirName from: $($skillIds -join ', ')"
}

function Invoke-BundleCatalog {
  param(
    [string[]]$RequestedSkillIds
  )

  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile

  Invoke-SeedCatalogBuild -RequestedSkillIds $RequestedSkillIds
  Write-Host "Built catalog package at ~/.apm/.catalog-build/$CatalogDirName"
}

function Invoke-StageCatalog {
  param(
    [string[]]$RequestedSkillIds
  )

  Invoke-BundleCatalog -RequestedSkillIds $RequestedSkillIds
  $trackedDir = Get-TrackedCatalogDir
  Reset-TrackedCatalogDir
  Copy-DirectoryContents -SourceDir (Get-CatalogBuildDir) -DestinationDir $trackedDir
  Sync-ManagedCatalogMirror

  $reference = Get-TrackedCatalogReference
  Write-Host "Staged repo-tracked catalog at $trackedDir"
  Write-Host "Refreshed transitional mirror at $RepoRoot\agents\src"
  Write-Host "Candidate upstream ref: $reference"
  Write-Host "Push the updated apm-workspace repo before using 'apm install -g $reference'."
}

function Invoke-RegisterCatalog {
  param(
    [string[]]$RequestedSkillIds
  )

  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile
  Assert-TrackedCatalogPublished
  Invoke-ValidateCatalog

  $skillIds = @(Get-ManagedSkillIds)
  Remove-InternalTargetReparsePoints -SkillIds $skillIds

  $reference = Get-TrackedCatalogReference
  Invoke-WorkspaceInstallCommand -InstallArgs @("-g", $reference)
  Normalize-WorkspaceGitignore
  Sync-ManagedCatalogRuntimeAssets
  Write-Host "Registered catalog from upstream ref: $reference"
}

function Invoke-SmokeCatalog {
  param(
    [string[]]$RequestedSkillIds
  )

  Require-Apm

  $skillIds = @(Get-RequestedManagedSkillIds -RequestedSkillIds $RequestedSkillIds)
  Invoke-BundleCatalog -RequestedSkillIds $skillIds

  $tempDir = Join-Path $env:TEMP ("apm-catalog-smoke-{0}" -f ([guid]::NewGuid().ToString("N")))
  $success = $false

  try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Push-Location $tempDir
    try {
      & apm install (Get-CatalogBuildDir) --target codex
      if ($LASTEXITCODE -ne 0) {
        throw "apm install failed for catalog smoke test."
      }
    }
    finally {
      Pop-Location
    }

    foreach ($skillId in $skillIds) {
      $bundleSkillDir = Get-CatalogBuildSkillsRoot
      $installedSkillDir = Join-Path $tempDir ".agents/skills"
      foreach ($segment in (Convert-SkillIdToPathSegments -SkillId $skillId)) {
        $bundleSkillDir = Join-Path $bundleSkillDir $segment
        $installedSkillDir = Join-Path $installedSkillDir $segment
      }
      $skillPath = Join-Path $installedSkillDir "SKILL.md"

      if (-not (Test-Path -LiteralPath $skillPath)) {
        throw "Smoke test failed: expected installed skill file missing: $skillPath"
      }

      $expectedFiles = @(Get-RelativeFilePaths -RootDir $bundleSkillDir)
      $installedFiles = @(Get-RelativeFilePaths -RootDir $installedSkillDir)
      if ((@($expectedFiles) -join "`n") -ne (@($installedFiles) -join "`n")) {
        throw ("Smoke test failed: installed skill tree for {0} differed from catalog.`nExpected:`n{1}`nActual:`n{2}" -f $skillId, ($expectedFiles -join "`n"), ($installedFiles -join "`n"))
      }
    }

    $success = $true
    Write-Host "Smoke verified catalog via temp project install: $($skillIds -join ', ')"
  }
  finally {
    if ($success) {
      Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path -LiteralPath $tempDir) {
      Write-WarnLine "Catalog smoke test workspace left at $tempDir for inspection."
    }
  }
}

function Test-InternalSkillExists {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $relativePath = Convert-SkillIdToPackageRelativePath -SkillId $SkillId
  return Test-Path -LiteralPath (Join-Path (Get-TrackedCatalogSkillsRoot) $relativePath)
}

function Get-ExternalSkillSources {
  if (-not (Test-Path -LiteralPath $ExternalSourcesFile)) {
    return @()
  }

  $lines = Get-Content -LiteralPath $ExternalSourcesFile
  $depth = 0
  $currentName = $null
  $currentLines = @()
  $sources = @()

  foreach ($line in $lines) {
    $sanitized = $line -replace '#.*$', ''

    if ($depth -eq 1 -and $null -eq $currentName) {
      if ($sanitized -match '^\s*([A-Za-z0-9._-]+)\s*=\s*\{\s*$') {
        $currentName = $matches[1]
        $currentLines = @($line)
      }
    } elseif ($null -ne $currentName) {
      $currentLines += $line
    }

    $openCount = ([regex]::Matches($sanitized, '\{')).Count
    $closeCount = ([regex]::Matches($sanitized, '\}')).Count
    $depth += ($openCount - $closeCount)

    if ($null -ne $currentName -and $depth -eq 1) {
      $blockText = $currentLines -join "`n"
      $url = $null
      $baseDir = "."
      $idPrefix = $null
      $catalogs = @()
      $selectedSkills = @()

      if ($blockText -match '(?m)^\s*url\s*=\s*"([^"]+)"\s*;') {
        $url = $matches[1]
      }
      if ($blockText -match '(?m)^\s*baseDir\s*=\s*"([^"]+)"\s*;') {
        $baseDir = $matches[1]
      }
      if ($blockText -match '(?m)^\s*idPrefix\s*=\s*"([^"]+)"\s*;') {
        $idPrefix = $matches[1]
      }
      if ($blockText -match '(?ms)^\s*catalogs\s*=\s*\{(?<body>.*?)^\s*\};') {
        foreach ($match in [regex]::Matches($matches['body'], '(?m)^\s*([A-Za-z0-9._-]+)\s*=\s*"([^"]+)"\s*;')) {
          $catalogs += [pscustomobject]@{
            Name = $match.Groups[1].Value
            Path = $match.Groups[2].Value
          }
        }
      }
      if ($blockText -match '(?ms)selection\.enable\s*=\s*\[(?<body>.*?)\];') {
        foreach ($match in [regex]::Matches($matches['body'], '"([^"]+)"')) {
          $selectedSkills += $match.Groups[1].Value
        }
      }

      if ($url -and $catalogs.Count -gt 0 -and $selectedSkills.Count -gt 0) {
        $sources += [pscustomobject]@{
          Name = $currentName
          Url = $url
          BaseDir = $baseDir
          IdPrefix = $idPrefix
          Catalogs = $catalogs
          SelectedSkills = $selectedSkills
        }
      }

      $currentName = $null
      $currentLines = @()
    }
  }

  return $sources
}

function Get-ExternalSourceCheckoutPath {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source
  )

  Require-Command -Name "git"

  if ($Source.Url.StartsWith("path:")) {
    $relativePath = $Source.Url.Substring(5)
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $relativePath))
  }

  $cloneUrl = $null
  $ref = $null

  if ($Source.Url -match '^github:([^/]+)/([^/]+?)(?:/([^/]+))?$') {
    $owner = $matches[1]
    $repo = $matches[2]
    $ref = if ($matches.Count -ge 4) { $matches[3] } else { $null }
    $cloneUrl = "https://github.com/$owner/$repo.git"
  } elseif ($Source.Url.StartsWith("git+")) {
    $cloneUrl = $Source.Url.Substring(4)
    if ($cloneUrl -match '^(.*?)[?&]ref=([^&#]+).*$') {
      $cloneUrl = $matches[1]
      $ref = $matches[2]
    }
  } else {
    $cloneUrl = $Source.Url
  }

  if (-not $cloneUrl) {
    throw "Unsupported source URL: $($Source.Url)"
  }

  $checkoutRoot = Join-Path $env:TEMP "apm-workspace-external"
  New-Item -ItemType Directory -Path $checkoutRoot -Force | Out-Null
  $checkoutPath = Join-Path $checkoutRoot $Source.Name

  if (Test-Path -LiteralPath $checkoutPath) {
    Remove-Item -LiteralPath $checkoutPath -Recurse -Force
  }

  $cloneArgs = @("clone", "--depth", "1")
  if (-not [string]::IsNullOrWhiteSpace($ref)) {
    $cloneArgs += @("--branch", $ref)
  }
  $cloneArgs += @($cloneUrl, $checkoutPath)

  & git @cloneArgs | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone external source: $cloneUrl"
  }

  return $checkoutPath
}

function Get-ExternalSourceRepoReference {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source
  )

  if ($Source.Url -match '^github:([^/]+)/([^/]+?)(?:/([^/]+))?$') {
    return [pscustomobject]@{
      Repo = "$($matches[1])/$($matches[2])"
      Ref = if ($matches.Count -ge 4) { $matches[3] } else { $null }
    }
  }

  throw "Cannot derive canonical upstream reference from source URL: $($Source.Url)"
}

function Resolve-ExternalSkillSourceDir {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source,

    [Parameter(Mandatory = $true)]
    [string]$CheckoutPath,

    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceRelativeId = $SkillId
  if (-not [string]::IsNullOrWhiteSpace($Source.IdPrefix)) {
    if (-not $SkillId.StartsWith($Source.IdPrefix)) {
      throw "Skill '$SkillId' does not match idPrefix '$($Source.IdPrefix)' for source '$($Source.Name)'"
    }

    $sourceRelativeId = $SkillId.Substring($Source.IdPrefix.Length)
  }

  $sourceSegments = Convert-SkillIdToPathSegments -SkillId $sourceRelativeId
  $basePath = if ($Source.BaseDir -eq "." -or [string]::IsNullOrWhiteSpace($Source.BaseDir)) {
    $CheckoutPath
  } else {
    Join-Path $CheckoutPath $Source.BaseDir
  }

  foreach ($catalog in $Source.Catalogs) {
    $catalogRoot = if ($catalog.Path -eq "." -or [string]::IsNullOrWhiteSpace($catalog.Path)) {
      $basePath
    } else {
      Join-Path $basePath $catalog.Path
    }

    if (Test-Path -LiteralPath (Join-Path $catalogRoot "SKILL.md")) {
      return $catalogRoot
    }

    $candidate = $catalogRoot
    foreach ($segment in $sourceSegments) {
      $candidate = Join-Path $candidate $segment
    }

    if (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md")) {
      return $candidate
    }
  }

  $relativeTail = [System.IO.Path]::Combine($sourceSegments)
  $fallbackMatches = Get-ChildItem -LiteralPath $CheckoutPath -Recurse -File -Filter "SKILL.md" -ErrorAction SilentlyContinue |
    Where-Object {
      $relativeDir = $_.DirectoryName.Substring($CheckoutPath.Length).TrimStart('\', '/')
      $relativeDir -eq $relativeTail -or $relativeDir.EndsWith([System.IO.Path]::DirectorySeparatorChar + $relativeTail)
    } |
    Sort-Object { $_.DirectoryName.Length }

  if ($fallbackMatches) {
    return $fallbackMatches[0].DirectoryName
  }

  throw "Could not find external skill '$SkillId' in source '$($Source.Name)'"
}

function Get-ExternalSkillReference {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source,

    [Parameter(Mandatory = $true)]
    [string]$CheckoutPath,

    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceDir = Resolve-ExternalSkillSourceDir -Source $Source -CheckoutPath $CheckoutPath -SkillId $SkillId
  $repoInfo = Get-ExternalSourceRepoReference -Source $Source
  $basePath = [System.IO.Path]::GetFullPath($CheckoutPath)
  $targetPath = [System.IO.Path]::GetFullPath($sourceDir)
  $baseUri = [Uri](($basePath.TrimEnd('\', '/')) + [System.IO.Path]::DirectorySeparatorChar)
  $targetUri = [Uri]$targetPath
  $relativeDir = [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('\', '/').TrimEnd('/')

  $reference = if ([string]::IsNullOrWhiteSpace($relativeDir) -or $relativeDir -eq ".") {
    $repoInfo.Repo
  } else {
    "$($repoInfo.Repo)/$relativeDir"
  }

  if (-not [string]::IsNullOrWhiteSpace($repoInfo.Ref)) {
    $reference = "$reference#$($repoInfo.Ref)"
  }

  return $reference
}

function Invoke-InstallReferences {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$References
  )

  if ($References.Count -eq 0) {
    return
  }

  Push-Location $WorkspaceDir
  try {
    Invoke-WorkspaceInstallCommand -InstallArgs (@("-g") + $References)
    Normalize-WorkspaceGitignore
  }
  finally {
    Pop-Location
  }
}

function Invoke-MigrateExternal {
  param(
    [string[]]$RequestedSources = @()
  )

  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile

  $requestedSources = @($RequestedSources | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
  $sources = @(Get-ExternalSkillSources)
  if ($sources.Count -eq 0) {
    throw "No external skill sources found in $ExternalSourcesFile"
  }

  if ($requestedSources.Count -gt 0) {
    $sourcesByName = @{}
    foreach ($source in $sources) {
      $sourcesByName[$source.Name.Trim()] = $source
    }

    $selectedSources = @()
    foreach ($sourceName in $requestedSources) {
      if (-not $sourcesByName.ContainsKey($sourceName)) {
        throw "Unknown external source: $sourceName"
      }

      $selectedSources += $sourcesByName[$sourceName]
    }

    $sources = @($selectedSources)
  }

  $references = New-Object System.Collections.Generic.List[string]
  $referenceSet = New-Object 'System.Collections.Generic.HashSet[string]'
  $registrationMessages = New-Object System.Collections.Generic.List[string]
  $manifestReferences = Get-ManifestReferenceKeys

  foreach ($source in $sources) {
    $checkoutPath = Get-ExternalSourceCheckoutPath -Source $source
    foreach ($skillId in $source.SelectedSkills) {
      if (Test-InternalSkillExists -SkillId $skillId) {
        Write-Host "Skipping $skillId from $($source.Name): managed catalog already owns this id"
        continue
      }

      $reference = Get-ExternalSkillReference -Source $source -CheckoutPath $checkoutPath -SkillId $skillId
      $baseReference = ($reference -replace '#.*$', '')
      if ($manifestReferences.Contains($reference) -or $manifestReferences.Contains($baseReference)) {
        Write-Host "Skipping $skillId from $($source.Name): already registered as $baseReference"
        continue
      }

      if ($referenceSet.Add($reference)) {
        $references.Add($reference)
        $null = $manifestReferences.Add($reference)
        $null = $manifestReferences.Add($baseReference)
      }
      $registrationMessages.Add("Registered external skill $skillId from $($source.Name) as $reference")
    }
  }

  if ($references.Count -gt 0) {
    Invoke-InstallReferences -References $references.ToArray()
    foreach ($message in $registrationMessages) {
      Write-Host $message
    }
  }
  else {
    Write-Host "No external skills selected for registration."
  }

  Invoke-PinExternal
}

if ($env:APM_WORKSPACE_LIB_ONLY -eq "1") {
  return
}

switch ($Command) {
  "bootstrap" {
    Ensure-WorkspaceRepo
    Refresh-WorkspaceCheckout
    Ensure-WorkspaceScaffold
    Ensure-WorkspaceMiseFile
    Write-Host "APM workspace ready: $WorkspaceDir"
    Write-Host ""
    Write-Host "Next:"
    Write-Host "  cd $WorkspaceDir"
    Write-Host "  mise install"
    Write-Host "  mise run migrate-external"
    Write-Host "  mise run apply"
  }

  "inject-mise" {
    Ensure-WorkspaceRepo
    Ensure-WorkspaceMiseFile
  }

  "apply" {
    Invoke-Apply
  }

  "update" {
    Invoke-Update
  }

  "list" {
    Invoke-List
  }

  "pin-external" {
    Invoke-PinExternal
  }

  "validate" {
    Invoke-Validate
  }

  "validate-catalog" {
    Invoke-ValidateCatalog
  }

  "doctor" {
    Invoke-Doctor
  }

  "bundle-catalog" {
    Invoke-BundleCatalog -RequestedSkillIds $CommandArgs
  }

  "stage-catalog" {
    Invoke-StageCatalog -RequestedSkillIds $CommandArgs
  }

  "register-catalog" {
    Invoke-RegisterCatalog -RequestedSkillIds $CommandArgs
  }

  "smoke-catalog" {
    Invoke-SmokeCatalog -RequestedSkillIds $CommandArgs
  }

  "migrate-external" {
    Invoke-MigrateExternal -RequestedSources $CommandArgs
  }

  "help" {
    @"
Usage: scripts/apm-workspace.ps1 <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + mise.toml are ready
  inject-mise        Copy or refresh the managed ~/.apm/mise.toml template
  apply              Deploy user-scope-compatible dependencies and compile Codex output
  update             Pull clean checkout, update deps, then apply
  list               Show APM global dependencies
  pin-external       Pin external manifest refs to lockfile commits
  validate           Validate the ~/.apm workspace
  validate-catalog   Fail when the tracked catalog is not normalized or the transitional mirror drifts
  doctor             Print workspace and target state
  bundle-catalog     Build ~/.apm/.catalog-build/catalog as the catalog package artifact
  stage-catalog      Normalize ~/.apm/catalog, refresh the transitional mirror, and print its upstream ref
  register-catalog   Install the staged catalog by upstream ref after commit/push
  smoke-catalog      Smoke-test the generated catalog package via temp project install
  migrate-external   Register selected external skills by upstream reference
  smoke              Validate script syntax and workspace template wiring

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
  APM_CODEX_OUTPUT
  APM_BOOTSTRAP_FORCE_MISE=1
  APM_MIGRATE_FORCE=1
"@ | Write-Host
  }

  "smoke" {
    Push-Location $RepoRoot
    try {
      & bash -n ./scripts/apm-workspace.sh
      if ($LASTEXITCODE -ne 0) {
        throw "bash syntax check failed."
      }
    }
    finally {
      Pop-Location
    }

    if (-not (Test-Path -LiteralPath $MiseTemplate)) {
      throw "Missing workspace mise template: $MiseTemplate"
    }

    $templateContent = Get-Content -LiteralPath $MiseTemplate -Raw
    if (-not $templateContent.Contains($ManagedMiseMarker)) {
      throw "Workspace mise template is missing the managed marker."
    }
  }

  default {
    throw "Unknown command: $Command"
  }
}
