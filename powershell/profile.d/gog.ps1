# gog completions for PowerShell.

$gogCommand = Get-Command "gog.exe" -ErrorAction SilentlyContinue
if (-not $gogCommand) {
  $gogCommand = Get-Command "gog" -ErrorAction SilentlyContinue
}

if (-not $gogCommand) {
  return
}

$gogCompletionScript = {
  param($commandName, $wordToComplete, $cursorPosition, $commandAst, $fakeBoundParameter)

  $elements = $commandAst.CommandElements | ForEach-Object { $_.ToString() }
  $cword = $elements.Count - 1
  $completions = & $gogCommand.Source __complete --cword $cword -- $elements

  foreach ($completion in $completions) {
    [System.Management.Automation.CompletionResult]::new(
      $completion,
      $completion,
      [System.Management.Automation.CompletionResultType]::ParameterValue,
      $completion
    )
  }
}

Register-ArgumentCompleter -CommandName "gog", "gog.exe" -ScriptBlock $gogCompletionScript
