$ErrorActionPreference = "Stop"

$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$envFile = Join-Path $configRoot ".env"
$envKeys = Join-Path $configRoot ".env.keys"
$envLocal = Join-Path $configRoot ".env.local"
$tempFile = "$envLocal.tmp.$PID"
$opDotenvKeysVault = if ($env:OP_DOTENV_KEYS_VAULT) { $env:OP_DOTENV_KEYS_VAULT } else { "Dotfiles Automation" }
$previousMiseEnv = $env:MISE_ENV
$usingWindowsMiseEnv = $false

function Write-Critical {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  [Console]::Error.WriteLine("")
  [Console]::Error.WriteLine("❌ CRITICAL: $Message")
  [Console]::Error.WriteLine("")
}

function Set-OwnerOnlyFileAcl {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $acl = New-Object System.Security.AccessControl.FileSecurity
  $acl.SetAccessRuleProtection($true, $false)
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $currentUser,
    [System.Security.AccessControl.FileAccessRights]::FullControl,
    [System.Security.AccessControl.AccessControlType]::Allow
  )
  $acl.SetAccessRule($rule)
  Set-Acl -LiteralPath $Path -AclObject $acl
}

if (-not (Test-Path -LiteralPath $envFile)) {
  Write-Critical "$envFile not found"
  exit 1
}

if (-not (Test-Path -LiteralPath $envKeys)) {
  Write-Critical "$envKeys not found"
  [Console]::Error.WriteLine("Restore from 1Password:")
  [Console]::Error.WriteLine("  op document get "".env.keys | dotfiles"" --vault ""$opDotenvKeysVault"" --output ""$envKeys""")
  [Console]::Error.WriteLine("")
  exit 1
}

$isWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
if ($isWindows) {
  Remove-Item Env:MISE_CONFIG_FILE, Env:MISE_GLOBAL_CONFIG_FILE -ErrorAction SilentlyContinue
  $managedMiseTokens = @("macos", "bun", "shared", "workstation", "workstation-unix", "workstation-windows", "server-pi", "ci")
  $miseEnvironmentTokens = @($env:MISE_ENV -split "," | Where-Object { $_ -and ($managedMiseTokens -notcontains $_) })
  # Windows: bun,shared,workstation,workstation-windows (entry goes last)
  foreach ($requiredToken in @("bun", "shared", "workstation", "workstation-windows")) {
    if ($miseEnvironmentTokens -notcontains $requiredToken) {
      $miseEnvironmentTokens += $requiredToken
    }
  }
  $newMiseEnv = ($miseEnvironmentTokens -join ",")
  if ($newMiseEnv -ne $env:MISE_ENV) {
    $env:MISE_ENV = $newMiseEnv
    $usingWindowsMiseEnv = $true
  }
}

$dotenvx = Get-Command dotenvx -ErrorAction SilentlyContinue
if ($null -eq $dotenvx) {
  Write-Critical "dotenvx not found"
  [Console]::Error.WriteLine("Install with: mise install")
  [Console]::Error.WriteLine("")
  exit 1
}

if (Test-Path -LiteralPath $envLocal) {
  $envInfo = Get-Item -LiteralPath $envFile
  $localInfo = Get-Item -LiteralPath $envLocal
  if ($envInfo.LastWriteTimeUtc -le $localInfo.LastWriteTimeUtc) {
    exit 0
  }
  Write-Output "Updating .env.local (detected changes in .env)..."
} else {
  Write-Output "Generating .env.local for the first time..."
}

try {
  $previousKeyPath = $env:DOTENV_PRIVATE_KEY_PATH
  $env:DOTENV_PRIVATE_KEY_PATH = $envKeys
  $output = & $dotenvx.Source decrypt -f $envFile --stdout 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "decrypt failed"
  }

  # Create an empty temp file first, harden ACL while empty, then write plaintext.
  [System.IO.File]::WriteAllText($tempFile, "", (New-Object System.Text.UTF8Encoding($false)))
  if ($isWindows) {
    Set-OwnerOnlyFileAcl -Path $tempFile
  }
  [System.IO.File]::WriteAllText($tempFile, ($output -join [Environment]::NewLine), (New-Object System.Text.UTF8Encoding($false)))
  Move-Item -LiteralPath $tempFile -Destination $envLocal -Force
  if ($isWindows) {
    Set-OwnerOnlyFileAcl -Path $envLocal
  }
  Write-Output "✓ .env.local updated successfully"
} catch {
  Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
  Write-Critical "Failed to decrypt .env"
  [Console]::Error.WriteLine("Check that .env.keys contains the correct private key.")
  [Console]::Error.WriteLine("")
  exit 1
} finally {
  if ($null -eq $previousKeyPath) {
    Remove-Item Env:DOTENV_PRIVATE_KEY_PATH -ErrorAction SilentlyContinue
  } else {
    $env:DOTENV_PRIVATE_KEY_PATH = $previousKeyPath
  }

  if ($usingWindowsMiseEnv) {
    if ($null -eq $previousMiseEnv) {
      Remove-Item Env:MISE_ENV -ErrorAction SilentlyContinue
    } else {
      $env:MISE_ENV = $previousMiseEnv
    }
  }
}
