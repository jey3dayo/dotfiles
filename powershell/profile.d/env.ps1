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
$opDotenvEnvFile = Join-Path $configRoot ".env"

function Invoke-OpServiceAccount {
  dotenvx run -f $opDotenvEnvFile -- op @args
}

function Save-OpServiceAccountToken {
  if ([string]::IsNullOrWhiteSpace($env:OP_SERVICE_ACCOUNT_TOKEN)) {
    throw "OP_SERVICE_ACCOUNT_TOKEN is not set in the current shell."
  }

  dotenvx set OP_SERVICE_ACCOUNT_TOKEN $env:OP_SERVICE_ACCOUNT_TOKEN.Trim() `
    -f $opDotenvEnvFile `
    -fk "$opDotenvEnvFile.keys" `
    --encrypt
  Write-Host "Saved OP_SERVICE_ACCOUNT_TOKEN to dotenvx env file."
}

function Clear-OpServiceAccountToken {
  Remove-Item Env:OP_SERVICE_ACCOUNT_TOKEN -ErrorAction SilentlyContinue
  Write-Host "Cleared OP_SERVICE_ACCOUNT_TOKEN from current shell."
  Write-Host "Remove or rotate OP_SERVICE_ACCOUNT_TOKEN in $opDotenvEnvFile with dotenvx if needed."
}
