# Shared PowerShell environment defaults.
if (-not $env:OP_ACCOUNT) {
  $env:OP_ACCOUNT = "CNRNCJQSBBBYZESUWAMXLHQFBI"
}

if (-not $env:OP_DOTENV_KEYS_VAULT) {
  $env:OP_DOTENV_KEYS_VAULT = "Dotfiles Automation"
}

if (-not $env:OP_DOTENV_KEYS_ITEM_ID) {
  $env:OP_DOTENV_KEYS_ITEM_ID = "mzy4lhfwqbtbtr3rm466qhrouq"
}

$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$opServiceAccountTokenFile = Join-Path $configRoot "op\service-account-token"

function Import-OpServiceAccountToken {
  if ($env:OP_SERVICE_ACCOUNT_TOKEN) {
    return
  }

  if (-not (Test-Path -LiteralPath $opServiceAccountTokenFile)) {
    return
  }

  $token = Get-Content -LiteralPath $opServiceAccountTokenFile -Raw -ErrorAction SilentlyContinue
  if ([string]::IsNullOrWhiteSpace($token)) {
    return
  }

  $env:OP_SERVICE_ACCOUNT_TOKEN = $token.Trim()
}

function Save-OpServiceAccountToken {
  if ([string]::IsNullOrWhiteSpace($env:OP_SERVICE_ACCOUNT_TOKEN)) {
    throw "OP_SERVICE_ACCOUNT_TOKEN is not set in the current shell."
  }

  $tokenDir = Split-Path -Parent $opServiceAccountTokenFile
  New-Item -ItemType Directory -Path $tokenDir -Force | Out-Null
  [System.IO.File]::WriteAllText(
    $opServiceAccountTokenFile,
    $env:OP_SERVICE_ACCOUNT_TOKEN.Trim(),
    (New-Object System.Text.UTF8Encoding($false))
  )

  Write-Host "Saved OP_SERVICE_ACCOUNT_TOKEN to $opServiceAccountTokenFile"
}

function Clear-OpServiceAccountToken {
  Remove-Item -LiteralPath $opServiceAccountTokenFile -Force -ErrorAction SilentlyContinue
  Remove-Item Env:OP_SERVICE_ACCOUNT_TOKEN -ErrorAction SilentlyContinue
  Write-Host "Cleared OP_SERVICE_ACCOUNT_TOKEN cache."
}

Import-OpServiceAccountToken
