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
$ExternalSourcesFile = Join-Path $RepoRoot "nix\agent-skills-sources.nix"
$PackagesDir = Join-Path $WorkspaceDir "packages"
$CodexOutput = if ($env:APM_CODEX_OUTPUT) { $env:APM_CODEX_OUTPUT } else { Join-Path $HOME ".codex\AGENTS.md" }
$MiseTemplate = Join-Path $RepoRoot "templates\apm-workspace\mise.toml"
$MiseDestination = Join-Path $WorkspaceDir "mise.toml"
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

  New-Item -ItemType Directory -Path $PackagesDir -Force | Out-Null
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

function Ensure-PackagesReadme {
  $packagesReadmePath = Join-Path $PackagesDir "README.md"
  if (Test-Path -LiteralPath $packagesReadmePath) {
    return
  }

  $packagesReadme = @(
    '# Local APM packages',
    '',
    'Store repo-owned local packages under `packages/<skill-id>/`.',
    '',
    'Typical flow:',
    '',
    '```bash',
    'cd ~/.apm',
    'mise install',
    'mise run migrate -- apm-usage',
    'mise run migrate-external',
    'mise run apply',
    '```'
  ) -join [Environment]::NewLine

  [System.IO.File]::WriteAllText($packagesReadmePath, $packagesReadme)
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
  Ensure-GitignoreEntry -Entry ".apm/"
  Ensure-GitignoreEntry -Entry "apm_modules/"
  Ensure-PackagesReadme

  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Writing bootstrap apm.yml in $WorkspaceDir"
    Write-WorkspaceManifestTemplate
  }
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

function Test-ManifestHasLocalPackages {
  $manifestPath = Join-Path $WorkspaceDir "apm.yml"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    return $false
  }

  $manifestContent = Get-Content -LiteralPath $manifestPath -ErrorAction SilentlyContinue
  return [bool]($manifestContent | Select-String -Pattern '^\s*-\s+\./packages/')
}

function Invoke-Apply {
  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Packages are seeded in ~/.apm/apm.yml, but rollout should stay on the legacy path until a later phase."
  }

  Invoke-WorkspaceCommand -CommandArgs @("install", "-g")
  Invoke-CodexCompile
}

function Invoke-Update {
  Require-Apm
  Ensure-WorkspaceRepo
  Refresh-WorkspaceCheckout
  Ensure-WorkspaceScaffold

  if (Test-ManifestHasLocalPackages) {
    throw "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; keep using the legacy deploy path for now."
  }

  & apm deps update -g
  if ($LASTEXITCODE -ne 0) {
    throw "apm deps update -g failed."
  }
  Invoke-WorkspaceCommand -CommandArgs @("install", "-g")
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

function Invoke-Doctor {
  Require-Apm
  Ensure-WorkspaceRepo
  Ensure-WorkspaceScaffold

  $manifestState = if (Test-Path (Join-Path $WorkspaceDir "apm.yml")) { "present" } else { "missing" }
  $packagesState = if (Test-Path $PackagesDir) { "present" } else { "missing" }

  Write-Host ("apm: {0}" -f (apm --version))
  Write-Host ("workspace: {0}" -f $WorkspaceDir)
  Write-Host ("manifest: {0}" -f $manifestState)
  Write-Host ("packages: {0}" -f $packagesState)
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
  Invoke-List
}

function Copy-LegacySkill {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceDir = Join-Path $LegacySkillsDir $SkillId
  $destinationDir = Join-Path $PackagesDir $SkillId

  if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Legacy skill not found: $sourceDir"
  }

  if (Test-Path -LiteralPath $destinationDir) {
    if ($env:APM_MIGRATE_FORCE -ne "1") {
      throw "$destinationDir already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    }

    Remove-Item -LiteralPath $destinationDir -Recurse -Force
  }

  Copy-Item -LiteralPath $sourceDir -Destination $destinationDir -Recurse -Force
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

function Copy-ExternalSkill {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Source,

    [Parameter(Mandatory = $true)]
    [string]$CheckoutPath,

    [Parameter(Mandatory = $true)]
    [string]$SkillId
  )

  $sourceDir = Resolve-ExternalSkillSourceDir -Source $Source -CheckoutPath $CheckoutPath -SkillId $SkillId
  $packageRelativePath = Convert-SkillIdToManifestRelativePath -SkillId $SkillId
  $destinationDir = Join-Path $PackagesDir (Convert-SkillIdToPackageRelativePath -SkillId $SkillId)
  $destinationParent = Split-Path -Parent $destinationDir

  if (Test-Path -LiteralPath $destinationDir) {
    if ($env:APM_MIGRATE_FORCE -ne "1") {
      throw "$destinationDir already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    }

    Remove-Item -LiteralPath $destinationDir -Recurse -Force
  }

  if (-not [string]::IsNullOrWhiteSpace($destinationParent)) {
    New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
  }

  Copy-Item -LiteralPath $sourceDir -Destination $destinationDir -Recurse -Force
  return $packageRelativePath
}

function Invoke-MigratePackage {
  param(
    [Parameter(Mandatory = $true)]
    [string]$PackageRelativePath
  )

  Invoke-WorkspaceCommand -CommandArgs @("install", "./packages/$PackageRelativePath")
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

  foreach ($source in $sources) {
    $checkoutPath = Get-ExternalSourceCheckoutPath -Source $source
    foreach ($skillId in $source.SelectedSkills) {
      if (Test-InternalSkillExists -SkillId $skillId) {
        Write-Host "Skipping $skillId from $($source.Name): internal bundled skill already owns this id"
        continue
      }

      $packageRelativePath = Copy-ExternalSkill -Source $source -CheckoutPath $checkoutPath -SkillId $skillId
      Invoke-MigratePackage -PackageRelativePath $packageRelativePath
      Write-Host "Migrated external skill $skillId from $($source.Name) into ~/.apm/packages/$packageRelativePath"
    }
  }
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
    Write-Host "  mise run migrate -- apm-usage"
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

  "validate" {
    Invoke-Validate
  }

  "doctor" {
    Invoke-Doctor
  }

  "migrate" {
    if (-not $CommandArgs -or $CommandArgs.Count -eq 0) {
      throw "usage: scripts/apm-workspace.ps1 migrate <skill-id> [skill-id ...]"
    }

    Require-Apm
    Ensure-WorkspaceRepo
    Ensure-WorkspaceScaffold
    Ensure-WorkspaceMiseFile
    foreach ($skillId in $CommandArgs) {
      Test-SkillId -SkillId $skillId
      Copy-LegacySkill -SkillId $skillId
      Invoke-MigratePackage -PackageRelativePath $skillId

      Write-Host "Migrated legacy skill into ~/.apm/packages/$skillId and recorded ./packages/$skillId in apm.yml"
    }
  }

  "migrate-external" {
    Invoke-MigrateExternal -RequestedSources $CommandArgs
  }

  "help" {
    @"
Usage: scripts/apm-workspace.ps1 <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + packages/ + mise.toml are ready
  inject-mise        Copy or refresh the managed ~/.apm/mise.toml template
  apply              Deploy user-scope-compatible dependencies and compile Codex output
  update             Pull clean checkout, update deps, then apply
  list               Show APM global dependencies
  validate           Validate the ~/.apm workspace
  doctor             Print workspace and target state
  migrate <skills>   Copy legacy skills into ~/.apm/packages/<id> and register them
  migrate-external   Vendor selected external skills into ~/.apm/packages and register them
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
