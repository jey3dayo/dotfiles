[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Command = "help",

  [Alias("profile")]
  [string]$InternalProfileOverride,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$CommandArgs
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WorkspaceDir = if ($env:APM_WORKSPACE_DIR) { $env:APM_WORKSPACE_DIR } else { Join-Path $HOME ".apm" }
$WorkspaceRepo = if ($env:APM_WORKSPACE_REPO) { $env:APM_WORKSPACE_REPO } else { "https://github.com/jey3dayo/apm-workspace.git" }
$InitialInternalProfile = if ($InternalProfileOverride) { $InternalProfileOverride } elseif ($env:APM_INTERNAL_PROFILE) { $env:APM_INTERNAL_PROFILE } else { "first-batch" }
$InternalProfile = $InitialInternalProfile
$LegacySkillsDir = Join-Path $RepoRoot "agents\src\skills"
$InternalPilotInventoryFile = Join-Path $RepoRoot ("agents\src\internal-apm-{0}.txt" -f $InternalProfile)
$ExternalSourcesFile = Join-Path $RepoRoot "nix\agent-skills-sources.nix"
$CodexOutput = if ($env:APM_CODEX_OUTPUT) { $env:APM_CODEX_OUTPUT } else { Join-Path $HOME ".codex\AGENTS.md" }
$MiseTemplate = Join-Path $RepoRoot "templates\apm-workspace\mise.toml"
$MiseDestination = Join-Path $WorkspaceDir "mise.toml"
$InternalSeedDir = Join-Path $WorkspaceDir ".internal-seed"
$InternalBundleName = "internal-$InternalProfile"
$TrackedInternalBundlesDirName = "internal-bundles"
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

function Test-InternalProfileName {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  if ($ProfileName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw "Invalid internal profile: $ProfileName"
  }
}

function Set-InternalProfileContext {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  Test-InternalProfileName -ProfileName $ProfileName
  $script:InternalProfile = $ProfileName
  $script:InternalPilotInventoryFile = Join-Path $RepoRoot ("agents\src\internal-apm-{0}.txt" -f $ProfileName)
  $script:InternalBundleName = "internal-$ProfileName"
}

function Resolve-InternalCommandArgs {
  param(
    [string[]]$Args
  )

  if ($Args.Count -ge 2 -and $Args[0] -eq "--profile") {
    Set-InternalProfileContext -ProfileName $Args[1]
    if ($Args.Count -gt 2) {
      return @($Args[2..($Args.Count - 1)])
    }
    return @()
  }

  return @($Args)
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

  $canonicalEntries = @("/.apm/", "/apm_modules/", "/.internal-seed/")
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
  Ensure-GitignoreEntry -Entry "/.internal-seed/"

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Writing bootstrap apm.yml in $WorkspaceDir"
    Write-WorkspaceManifestTemplate
  }
}

function Get-InternalBundleDir {
  return (Join-Path $InternalSeedDir $InternalBundleName)
}

function Get-InternalBundleSkillsRoot {
  return (Join-Path (Get-InternalBundleDir) ".apm\skills")
}

function Get-TrackedInternalBundlesDir {
  return (Join-Path $WorkspaceDir $TrackedInternalBundlesDirName)
}

function Get-TrackedInternalBundleDir {
  return (Join-Path (Get-TrackedInternalBundlesDir) $InternalBundleName)
}

function Get-TrackedInternalBundleRelativePath {
  return "$TrackedInternalBundlesDirName/$InternalBundleName"
}

function Write-InternalBundleManifestTemplate {
  $bundleDir = Get-InternalBundleDir
  $manifestPath = Join-Path $bundleDir "apm.yml"
  $manifestContent = @(
    "name: $InternalBundleName",
    "version: 1.0.0",
    "description: Generated internal bundled skills pilot for global APM migration",
    "dependencies:",
    "  apm: []",
    "  mcp: []",
    "scripts: {}"
  ) -join [Environment]::NewLine

  [System.IO.File]::WriteAllText($manifestPath, $manifestContent)
}

function Write-InternalBundleReadme {
  $bundleDir = Get-InternalBundleDir
  $readmePath = Join-Path $bundleDir "README.md"
  $content = @(
    ('# {0} Bundle' -f $InternalBundleName),
    '',
    'This bundle is generated from ~/.config internal bundled skills for the global APM migration pilot.',
    '',
    ('- Source inventory: `~/.config/agents/src/internal-apm-{0}.txt`' -f $InternalProfile),
    '- Source skills: `~/.config/agents/src/skills/<id>/`',
    '- Purpose: provide a valid APM package artifact for future publish/install work',
    '- Current limitation: `apm install -g <local-path>` is rejected by APM 0.8.11 at user scope, so this bundle is for validation and publication prep only'
  ) -join [Environment]::NewLine

  [System.IO.File]::WriteAllText($readmePath, $content)
}

function Reset-InternalBundleDir {
  $bundleDir = Get-InternalBundleDir
  if (Test-Path -LiteralPath $bundleDir) {
    Remove-Item -LiteralPath $bundleDir -Recurse -Force
  }

  New-Item -ItemType Directory -Path (Get-InternalBundleSkillsRoot) -Force | Out-Null
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

function Reset-TrackedInternalBundleDir {
  $trackedDir = Get-TrackedInternalBundleDir
  if (Test-Path -LiteralPath $trackedDir) {
    Remove-Item -LiteralPath $trackedDir -Recurse -Force
  }

  New-Item -ItemType Directory -Path $trackedDir -Force | Out-Null
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

function Get-TrackedInternalBundleReference {
  $tracking = Get-WorkspaceTrackingInfo
  $repoReference = Get-WorkspaceRepoReference -RemoteName $tracking.RemoteName
  return "{0}/{1}#{2}" -f $repoReference, (Get-TrackedInternalBundleRelativePath), $tracking.BranchName
}

function Assert-TrackedInternalBundlePublished {
  $trackedRelativePath = Get-TrackedInternalBundleRelativePath
  $trackedDir = Get-TrackedInternalBundleDir

  if (-not (Test-Path -LiteralPath $trackedDir)) {
    throw "Tracked internal bundle missing: $trackedDir. Run 'mise run stage-internal' first."
  }

  $dirty = & git -C $WorkspaceDir status --porcelain -- $trackedRelativePath 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to inspect git status for $trackedRelativePath"
  }
  if (-not [string]::IsNullOrWhiteSpace(($dirty | Out-String))) {
    throw "Tracked internal bundle has uncommitted changes. Commit and push $trackedRelativePath before registering it."
  }

  $tracking = Get-WorkspaceTrackingInfo
  $upstream = "{0}/{1}" -f $tracking.RemoteName, $tracking.BranchName
  $unpushed = & git -C $WorkspaceDir rev-list "$upstream..HEAD" -- $trackedRelativePath 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to compare $trackedRelativePath against $upstream"
  }
  if (-not [string]::IsNullOrWhiteSpace(($unpushed | Out-String))) {
    throw "Tracked internal bundle has commits not on $upstream. Push the branch before registering it."
  }
}

function Copy-InternalSkillIntoBundle {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceDir = Get-LegacySkillContentDir -SkillId $SkillId
  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Legacy skill not found: $sourceDir"
  }

  $destinationDir = Get-InternalBundleSkillsRoot
  foreach ($segment in (Convert-SkillIdToPathSegments -SkillId $SkillId)) {
    $destinationDir = Join-Path $destinationDir $segment
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $destinationDir
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
      if ($reference -match '^jey3dayo/apm-workspace/internal-bundles/') {
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
  Invoke-ValidateInternal

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Packages are seeded in ~/.apm/apm.yml, but rollout should stay on the legacy path until a later phase."
  }

  Remove-InternalTargetReparsePoints -SkillIds @(Get-AllInternalPilotSkillIds)
  Invoke-WorkspaceInstallCommand -InstallArgs @("-g")
  Normalize-WorkspaceGitignore
  Invoke-CodexCompile
}

function Invoke-Update {
  Require-Apm
  Ensure-WorkspaceRepo
  Refresh-WorkspaceCheckout
  Ensure-WorkspaceScaffold
  Invoke-ValidateInternal

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; keep using the legacy deploy path for now."
  }

  Remove-InternalTargetReparsePoints -SkillIds @(Get-AllInternalPilotSkillIds)
  & apm deps update -g
  if ($LASTEXITCODE -ne 0) {
    throw "apm deps update -g failed."
  }
  Invoke-WorkspaceInstallCommand -InstallArgs @("-g")
  Normalize-WorkspaceGitignore
  Invoke-CodexCompile
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

function Get-TrackedInternalBundleSkillIds {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Profile
  )

  $skillsRoot = Join-Path $WorkspaceDir ("internal-bundles\internal-{0}\.apm\skills" -f $Profile)
  if (-not (Test-Path -LiteralPath $skillsRoot)) {
    return @()
  }

  $result = New-Object System.Collections.Generic.List[string]
  foreach ($skillFile in (Get-ChildItem -LiteralPath $skillsRoot -Recurse -Filter "SKILL.md" -File | Sort-Object FullName)) {
    $skillDir = Split-Path -Parent $skillFile.FullName
    $relativePath = $skillDir.Substring($skillsRoot.Length).TrimStart('\')
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      continue
    }

    $skillId = ($relativePath -replace '\\', ':')
    if (-not $result.Contains($skillId)) {
      $result.Add($skillId)
    }
  }

  return $result.ToArray()
}

function Invoke-ValidateInternal {
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  $hasFailure = $false
  $listedSkillIds = @(Get-AllInternalPilotSkillIds)
  $legacySkillIds = @(Get-LegacyInternalSkillIds)
  $unassignedSkillIds = @($legacySkillIds | Where-Object { $_ -notin $listedSkillIds })
  $orphanedSkillIds = @($listedSkillIds | Where-Object { $_ -notin $legacySkillIds })

  if ($unassignedSkillIds.Count -gt 0) {
    Write-ErrorLine ("Unassigned legacy skills: {0}" -f ($unassignedSkillIds -join ", "))
    $hasFailure = $true
  }
  if ($orphanedSkillIds.Count -gt 0) {
    Write-ErrorLine ("Inventory entries without source directories: {0}" -f ($orphanedSkillIds -join ", "))
    $hasFailure = $true
  }

  foreach ($profile in @(Get-InternalInventoryProfiles)) {
    $trackedManifest = Join-Path $WorkspaceDir ("internal-bundles\internal-{0}\apm.yml" -f $profile.Profile)
    if (-not (Test-Path -LiteralPath $trackedManifest)) {
      Write-ErrorLine ("Tracked internal bundle manifest is missing for profile '{0}': {1}" -f $profile.Profile, $trackedManifest)
      $hasFailure = $true
      continue
    }

    if (-not (Test-ManifestHasInternalBundleReference -Profile $profile.Profile)) {
      Write-ErrorLine ("Global apm.yml is missing the internal bundle ref for profile '{0}'" -f $profile.Profile)
      $hasFailure = $true
    }

    $expectedSkillIds = @(Get-InternalPilotSkillIdsFromInventoryFile -InventoryFile $profile.InventoryFile)
    $trackedSkillIds = @(Get-TrackedInternalBundleSkillIds -Profile $profile.Profile)
    $missingTrackedSkillIds = @($expectedSkillIds | Where-Object { $_ -notin $trackedSkillIds })
    $extraTrackedSkillIds = @($trackedSkillIds | Where-Object { $_ -notin $expectedSkillIds })

    if ($missingTrackedSkillIds.Count -gt 0) {
      Write-ErrorLine ("Tracked bundle for profile '{0}' is missing skills: {1}" -f $profile.Profile, ($missingTrackedSkillIds -join ", "))
      $hasFailure = $true
    }
    if ($extraTrackedSkillIds.Count -gt 0) {
      Write-ErrorLine ("Tracked bundle for profile '{0}' has unexpected skills: {1}" -f $profile.Profile, ($extraTrackedSkillIds -join ", "))
      $hasFailure = $true
    }
  }

  if ($hasFailure) {
    throw "Internal APM validation failed"
  }

  Write-SuccessLine ("Internal APM validation passed ({0} skills across {1} profiles)" -f $listedSkillIds.Count, (@(Get-InternalInventoryProfiles)).Count)
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
  foreach ($path in @("$HOME/.claude/skills", "$HOME/.cursor/skills", "$HOME/.opencode/skills", "$HOME/.codex/AGENTS.md")) {
    if (Test-Path $path) {
      Write-Host ("  present  {0}" -f $path)
    } else {
      Write-Host ("  missing  {0}" -f $path)
    }
  }
  Write-Host ("external pins: unpinned={0}" -f (@(Get-UnpinnedExternalReferences)).Count)
  Write-InternalInventoryCoverageSummary
  Write-InternalProfileSummary
  Invoke-List
}

function Copy-LegacySkill {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceDir = Get-LegacySkillContentDir -SkillId $SkillId
  $destinationDir = Join-Path $InternalSeedDir (Convert-SkillIdToPackageRelativePath -SkillId $SkillId)

  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Legacy skill not found: $sourceDir"
  }

  if (Test-Path -LiteralPath $destinationDir) {
    if ($env:APM_MIGRATE_FORCE -ne "1") {
      return $false
    }

    Remove-Item -LiteralPath $destinationDir -Recurse -Force
  }

  Copy-DirectoryContents -SourceDir $sourceDir -DestinationDir $destinationDir
  return $true
}

function Get-InternalPilotSkillIds {
  if (-not (Test-Path -LiteralPath $InternalPilotInventoryFile)) {
    throw "Internal pilot inventory not found: $InternalPilotInventoryFile"
  }

  $result = New-Object System.Collections.Generic.List[string]
  foreach ($line in (Get-Content -LiteralPath $InternalPilotInventoryFile)) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
      continue
    }

    Test-SkillId -SkillId $trimmed
    if (-not $result.Contains($trimmed)) {
      $result.Add($trimmed)
    }
  }

  if ($result.Count -eq 0) {
    throw "Internal pilot inventory is empty: $InternalPilotInventoryFile"
  }

  return $result.ToArray()
}

function Get-InternalPilotSkillIdsFromInventoryFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$InventoryFile
  )

  if (-not (Test-Path -LiteralPath $InventoryFile)) {
    throw "Internal pilot inventory not found: $InventoryFile"
  }

  $result = New-Object System.Collections.Generic.List[string]
  foreach ($line in (Get-Content -LiteralPath $InventoryFile)) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
      continue
    }

    Test-SkillId -SkillId $trimmed
    if (-not $result.Contains($trimmed)) {
      $result.Add($trimmed)
    }
  }

  return $result.ToArray()
}

function Get-AllInternalPilotSkillIds {
  $inventoryDir = Join-Path $RepoRoot "agents\src"
  $inventoryFiles = @(Get-ChildItem -LiteralPath $inventoryDir -Filter "internal-apm-*.txt" -File | Sort-Object Name)
  $result = New-Object System.Collections.Generic.List[string]

  foreach ($inventoryFile in $inventoryFiles) {
    foreach ($skillId in (Get-InternalPilotSkillIdsFromInventoryFile -InventoryFile $inventoryFile.FullName)) {
      if (-not $result.Contains($skillId)) {
        $result.Add($skillId)
      }
    }
  }

  return $result.ToArray()
}

function Get-LegacyInternalSkillIds {
  $skillsDir = Join-Path $RepoRoot "agents\src\skills"
  if (-not (Test-Path -LiteralPath $skillsDir)) {
    return @()
  }

  return @(Get-ChildItem -LiteralPath $skillsDir -Directory | Sort-Object Name | Select-Object -ExpandProperty Name)
}

function Get-InternalInventoryProfiles {
  $inventoryDir = Join-Path $RepoRoot "agents\src"
  return @(Get-ChildItem -LiteralPath $inventoryDir -Filter "internal-apm-*.txt" -File | Sort-Object Name | ForEach-Object {
      [pscustomobject]@{
        Profile = ($_.BaseName -replace '^internal-apm-', '')
        InventoryFile = $_.FullName
      }
    })
}

function Test-ManifestHasInternalBundleReference {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Profile
  )

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return $false
  }

  $pattern = [regex]::Escape("jey3dayo/apm-workspace/internal-bundles/internal-$Profile#main")
  return [bool](Get-Content -LiteralPath $manifestPath -ErrorAction SilentlyContinue | Select-String -Pattern $pattern)
}

function Write-InternalInventoryCoverageSummary {
  $listedSkillIds = @(Get-AllInternalPilotSkillIds)
  $legacySkillIds = @(Get-LegacyInternalSkillIds)

  if ($listedSkillIds.Count -eq 0 -and $legacySkillIds.Count -eq 0) {
    return
  }

  $unassignedSkillIds = @($legacySkillIds | Where-Object { $_ -notin $listedSkillIds })
  $orphanedSkillIds = @($listedSkillIds | Where-Object { $_ -notin $legacySkillIds })
  $coverageState = if ($unassignedSkillIds.Count -eq 0 -and $orphanedSkillIds.Count -eq 0) { "ok" } else { "drift" }

  Write-Host ("internal inventory: listed={0} source={1} status={2}" -f $listedSkillIds.Count, $legacySkillIds.Count, $coverageState)
  if ($unassignedSkillIds.Count -gt 0) {
    Write-Host ("  unassigned: {0}" -f ($unassignedSkillIds -join ", "))
  }
  if ($orphanedSkillIds.Count -gt 0) {
    Write-Host ("  missing-source: {0}" -f ($orphanedSkillIds -join ", "))
  }
}

function Write-InternalProfileSummary {
  $profiles = @(Get-InternalInventoryProfiles)
  if ($profiles.Count -eq 0) {
    return
  }

  Write-Host "internal profiles:"
  foreach ($profile in $profiles) {
    $skillCount = @(
      Get-InternalPilotSkillIdsFromInventoryFile -InventoryFile $profile.InventoryFile
    ).Count
    $trackedManifest = Join-Path $WorkspaceDir ("internal-bundles\internal-{0}\apm.yml" -f $profile.Profile)
    $trackedState = if (Test-Path -LiteralPath $trackedManifest) { "yes" } else { "no" }
    $manifestState = if (Test-ManifestHasInternalBundleReference -Profile $profile.Profile) { "yes" } else { "no" }
    Write-Host ("  {0,-12} skills={1,-3} tracked={2,-3} manifest={3,-3}" -f $profile.Profile, $skillCount, $trackedState, $manifestState)
  }
}

function Get-RequestedInternalSkillIds {
  param(
    [string[]]$RequestedSkillIds
  )

  if ($RequestedSkillIds -and $RequestedSkillIds.Count -gt 0) {
    foreach ($skillId in $RequestedSkillIds) {
      Test-SkillId -SkillId $skillId
    }
    return $RequestedSkillIds
  }

  return Get-InternalPilotSkillIds
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

function Invoke-MigrateInternal {
  param(
    [string[]]$RequestedSkillIds,
    [switch]$LegacyAlias
  )

  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile

  $skillIds = @(Get-RequestedInternalSkillIds -RequestedSkillIds $RequestedSkillIds)
  if ($LegacyAlias) {
    Write-WarnLine "migrate is now a compatibility alias. Prefer 'migrate-internal' for internal pilot work."
  }

  if (-not $RequestedSkillIds -or $RequestedSkillIds.Count -eq 0) {
    Write-Host "Using internal pilot inventory ($InternalProfile): $($skillIds -join ', ')"
  }

  foreach ($skillId in $skillIds) {
    $copied = Copy-LegacySkill -SkillId $skillId
    if ($copied) {
      Write-Host "Seeded internal skill $skillId into ~/.apm/.internal-seed/$skillId for pilot/reference only. Global apm.yml was left unchanged."
    } else {
      Write-Host "Skipped internal skill $skillId because ~/.apm/.internal-seed/$skillId already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    }
  }
}

function Invoke-BundleInternal {
  param(
    [string[]]$RequestedSkillIds
  )

  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile

  $skillIds = @(Get-RequestedInternalSkillIds -RequestedSkillIds $RequestedSkillIds)
  Reset-InternalBundleDir
  Write-InternalBundleManifestTemplate
  Write-InternalBundleReadme

  foreach ($skillId in $skillIds) {
    Copy-InternalSkillIntoBundle -SkillId $skillId
  }

  Write-Host "Built internal bundle at ~/.apm/.internal-seed/$InternalBundleName from: $($skillIds -join ', ')"
}

function Invoke-StageInternal {
  param(
    [string[]]$RequestedSkillIds
  )

  $skillIds = @(Get-RequestedInternalSkillIds -RequestedSkillIds $RequestedSkillIds)
  Invoke-BundleInternal -RequestedSkillIds $skillIds

  $trackedDir = Get-TrackedInternalBundleDir
  Reset-TrackedInternalBundleDir
  Copy-DirectoryContents -SourceDir (Get-InternalBundleDir) -DestinationDir $trackedDir

  $reference = Get-TrackedInternalBundleReference
  Write-Host "Staged repo-tracked internal bundle at $trackedDir"
  Write-Host "Candidate upstream ref: $reference"
  Write-Host "Push the updated apm-workspace repo before using 'apm install -g $reference'."
}

function Invoke-RegisterInternal {
  param(
    [string[]]$RequestedSkillIds
  )

  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold
  Ensure-WorkspaceMiseFile
  Assert-TrackedInternalBundlePublished
  Invoke-ValidateInternal

  $skillIds = @(Get-AllInternalPilotSkillIds)
  Remove-InternalTargetReparsePoints -SkillIds $skillIds

  $reference = Get-TrackedInternalBundleReference
  Invoke-InstallReference -Reference $reference
  Write-Host "Registered internal bundle from upstream ref: $reference"
}

function Invoke-SmokeInternal {
  param(
    [string[]]$RequestedSkillIds
  )

  Require-Apm

  $skillIds = @(Get-RequestedInternalSkillIds -RequestedSkillIds $RequestedSkillIds)
  Invoke-BundleInternal -RequestedSkillIds $skillIds

  $tempDir = Join-Path $env:TEMP ("apm-internal-bundle-smoke-{0}" -f ([guid]::NewGuid().ToString("N")))
  $success = $false

  try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Push-Location $tempDir
    try {
      & apm install (Get-InternalBundleDir) --target codex
      if ($LASTEXITCODE -ne 0) {
        throw "apm install failed for internal bundle smoke test."
      }
    }
    finally {
      Pop-Location
    }

    foreach ($skillId in $skillIds) {
      $bundleSkillDir = Get-InternalBundleSkillsRoot
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
        throw ("Smoke test failed: installed skill tree for {0} differed from bundle.`nExpected:`n{1}`nActual:`n{2}" -f $skillId, ($expectedFiles -join "`n"), ($installedFiles -join "`n"))
      }
    }

    $success = $true
    Write-Host "Smoke verified internal bundle via temp project install: $($skillIds -join ', ')"
  }
  finally {
    if ($success) {
      Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path -LiteralPath $tempDir) {
      Write-WarnLine "Internal bundle smoke test workspace left at $tempDir for inspection."
    }
  }
}

function Test-InternalSkillExists {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $relativePath = Convert-SkillIdToPackageRelativePath -SkillId $SkillId
  return Test-Path -LiteralPath (Join-Path $LegacySkillsDir $relativePath)
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
        Write-Host "Skipping $skillId from $($source.Name): internal bundled skill already owns this id"
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

  "validate-internal" {
    Invoke-ValidateInternal
  }

  "doctor" {
    Invoke-Doctor
  }

  "migrate" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-MigrateInternal -RequestedSkillIds $internalArgs -LegacyAlias
  }

  "migrate-internal" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-MigrateInternal -RequestedSkillIds $internalArgs
  }

  "bundle-internal" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-BundleInternal -RequestedSkillIds $internalArgs
  }

  "stage-internal" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-StageInternal -RequestedSkillIds $internalArgs
  }

  "register-internal" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-RegisterInternal -RequestedSkillIds $internalArgs
  }

  "smoke-internal" {
    $internalArgs = @(Resolve-InternalCommandArgs -Args $CommandArgs)
    Invoke-SmokeInternal -RequestedSkillIds $internalArgs
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
  validate-internal  Fail on internal inventory / bundle / manifest drift
  doctor             Print workspace and target state
  migrate            Compatibility alias for migrate-internal
  migrate-internal   Seed internal pilot skills into ~/.apm/.internal-seed/ without changing global apm.yml
  bundle-internal    Build ~/.apm/.internal-seed/internal-<profile> as a valid internal APM bundle artifact
  stage-internal     Copy the generated bundle into ~/.apm/internal-bundles/ and print its upstream ref
  register-internal  Install the staged internal bundle by upstream ref after commit/push
  smoke-internal     Smoke-test the generated internal bundle via temp project install
  migrate-external   Register selected external skills by upstream reference
  smoke              Validate script syntax and workspace template wiring

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
  APM_CODEX_OUTPUT
  APM_INTERNAL_PROFILE=first-batch
  APM_BOOTSTRAP_FORCE_MISE=1
  APM_MIGRATE_FORCE=1

Internal command option:
  --profile <name>   Override the default internal profile for migrate/bundle/stage/register/smoke
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
