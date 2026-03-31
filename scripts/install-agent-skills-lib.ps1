function Read-Utf8TextFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $bytes = [System.IO.File]::ReadAllBytes($Path)
  $utf8 = [System.Text.UTF8Encoding]::new($true, $true)
  return $utf8.GetString($bytes)
}

function Normalize-Utf8TextFileLineEndings {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $content = Read-Utf8TextFile -Path $Path
  $normalized = $content -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($false))
}
