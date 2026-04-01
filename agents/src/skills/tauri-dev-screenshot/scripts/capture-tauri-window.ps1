[CmdletBinding()]
param(
    [string]$ProjectRoot,
    [string]$TitleContains,
    [switch]$ActiveWindow,
    [string]$Label
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-JsonResult {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Result,

        [int]$ExitCode = 0
    )

    $Result | ConvertTo-Json -Compress -Depth 6
    exit $ExitCode
}

function New-FailureResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Selector,

        [string[]]$Matches
    )

    $result = [ordered]@{
        ok       = $false
        code     = $Code
        message  = $Message
        selector = $Selector
    }

    if ($Matches -and $Matches.Count -gt 0) {
        $result.matches = $Matches
    }

    return $result
}

function Test-IsFailureResult {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    return (
        $Value -is [System.Collections.IDictionary] -and
        $Value.Contains("ok") -and
        -not [bool]$Value["ok"]
    )
}

function Initialize-NativeDependencies {
    Add-Type -AssemblyName System.Drawing

    if ("WindowCaptureNative" -as [type]) {
        return
    }

    $signature = @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

public static class WindowCaptureNative {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowTextLengthW(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int GetWindowTextW(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

    Add-Type -TypeDefinition $signature
}

function Get-WindowTitle {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle
    )

    $length = [WindowCaptureNative]::GetWindowTextLengthW($Handle)
    if ($length -le 0) {
        return ""
    }

    $builder = New-Object System.Text.StringBuilder ($length + 1)
    [void][WindowCaptureNative]::GetWindowTextW($Handle, $builder, $builder.Capacity)
    return $builder.ToString()
}

function Get-WindowBounds {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle
    )

    $rect = New-Object "WindowCaptureNative+RECT"
    if (-not [WindowCaptureNative]::GetWindowRect($Handle, [ref]$rect)) {
        return $null
    }

    return [ordered]@{
        left   = [int]$rect.Left
        top    = [int]$rect.Top
        width  = [int]($rect.Right - $rect.Left)
        height = [int]($rect.Bottom - $rect.Top)
    }
}

function Get-TopLevelWindows {
    $windows = New-Object "System.Collections.Generic.List[object]"
    $callback = [EnumWindowsProc]{
        param(
            [System.IntPtr]$Handle,
            [System.IntPtr]$LParam
        )

        $title = Get-WindowTitle -Handle $Handle
        $bounds = Get-WindowBounds -Handle $Handle

        $windows.Add([pscustomobject]@{
                Handle    = $Handle
                Title     = $title
                Visible   = [WindowCaptureNative]::IsWindowVisible($Handle)
                Minimized = [WindowCaptureNative]::IsIconic($Handle)
                Bounds    = $bounds
            })

        return $true
    }

    [void][WindowCaptureNative]::EnumWindows($callback, [System.IntPtr]::Zero)
    return $windows
}

function Test-WindowIsCapturable {
    param(
        [Parameter(Mandatory = $true)]
        $Window
    )

    return (
        $Window.Visible -and
        -not $Window.Minimized -and
        $null -ne $Window.Bounds -and
        $Window.Bounds.width -gt 0 -and
        $Window.Bounds.height -gt 0
    )
}

function Get-SafeLabel {
    param(
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    $safe = [System.Text.RegularExpressions.Regex]::Replace($Value.Trim(), "[^A-Za-z0-9._-]+", "-")
    return $safe.Trim("-")
}

function Resolve-TargetWindow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Selector,

        [string]$TitleContainsValue
    )

    if ($Selector -eq "active-window") {
        $handle = [WindowCaptureNative]::GetForegroundWindow()
        if ($handle -eq [System.IntPtr]::Zero) {
            return New-FailureResult -Code "window_not_found" -Message "No active foreground window was found." -Selector $Selector
        }

        $window = [pscustomobject]@{
            Handle    = $handle
            Title     = Get-WindowTitle -Handle $handle
            Visible   = [WindowCaptureNative]::IsWindowVisible($handle)
            Minimized = [WindowCaptureNative]::IsIconic($handle)
            Bounds    = Get-WindowBounds -Handle $handle
        }

        if (-not (Test-WindowIsCapturable -Window $window)) {
            return New-FailureResult -Code "window_not_visible" -Message "The active window is minimized, hidden, or has zero size." -Selector $Selector
        }

        return $window
    }

    $matchedWindows = @(
        Get-TopLevelWindows | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_.Title) -and
            $_.Title.IndexOf($TitleContainsValue, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        }
    )

    if ($matchedWindows.Count -eq 0) {
        return New-FailureResult -Code "window_not_found" -Message "No window matched TitleContains='$TitleContainsValue'." -Selector $Selector
    }

    $visibleMatches = @($matchedWindows | Where-Object { Test-WindowIsCapturable -Window $_ })

    if ($visibleMatches.Count -gt 1) {
        return New-FailureResult -Code "multiple_windows_matched" -Message "Multiple visible windows matched TitleContains='$TitleContainsValue'." -Selector $Selector -Matches @($visibleMatches.Title)
    }

    if ($visibleMatches.Count -eq 0) {
        return New-FailureResult -Code "window_not_visible" -Message "Matched window was found but is minimized, hidden, or has zero size." -Selector $Selector
    }

    return $visibleMatches[0]
}

function Save-WindowScreenshot {
    param(
        [Parameter(Mandatory = $true)]
        $Window,

        [Parameter(Mandatory = $true)]
        [string]$ProjectRootPath,

        [string]$LabelValue,

        [Parameter(Mandatory = $true)]
        [string]$Selector
    )

    $timestamp = Get-Date
    $timestampText = $timestamp.ToString("yyyyMMdd-HHmmss")
    $isoTimestamp = $timestamp.ToString("o")
    $safeLabel = Get-SafeLabel -Value $LabelValue
    $fileName = if ([string]::IsNullOrWhiteSpace($safeLabel)) {
        "$timestampText.png"
    }
    else {
        "$timestampText-$safeLabel.png"
    }

    $screenshotDir = Join-Path $ProjectRootPath "tmp/screenshots"
    try {
        [void](New-Item -ItemType Directory -Path $screenshotDir -Force)
    }
    catch {
        return New-FailureResult -Code "save_failed" -Message "Failed to prepare screenshot directory '$screenshotDir': $($_.Exception.Message)" -Selector $Selector
    }

    $bitmap = $null
    $graphics = $null
    try {
        $bitmap = New-Object System.Drawing.Bitmap ($Window.Bounds.width), ($Window.Bounds.height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($Window.Bounds.left, $Window.Bounds.top, 0, 0, $bitmap.Size)
    }
    catch {
        if ($graphics) {
            $graphics.Dispose()
        }
        if ($bitmap) {
            $bitmap.Dispose()
        }

        return New-FailureResult -Code "capture_failed" -Message "Failed to capture the window: $($_.Exception.Message)" -Selector $Selector
    }
    finally {
        if ($graphics) {
            $graphics.Dispose()
            $graphics = $null
        }
    }

    $savedPath = Join-Path $screenshotDir $fileName
    try {
        $bitmap.Save($savedPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    catch {
        return New-FailureResult -Code "save_failed" -Message "Failed to save screenshot to '$savedPath': $($_.Exception.Message)" -Selector $Selector
    }
    finally {
        if ($bitmap) {
            $bitmap.Dispose()
        }
    }

    return [ordered]@{
        ok         = $true
        savedPath  = $savedPath
        windowTitle = $Window.Title
        selector   = $Selector
        timestamp  = $isoTimestamp
        bounds     = [ordered]@{
            left   = $Window.Bounds.left
            top    = $Window.Bounds.top
            width  = $Window.Bounds.width
            height = $Window.Bounds.height
        }
    }
}

try {
    Initialize-NativeDependencies

    $selectorCount = 0
    $selector = ""

    if (-not [string]::IsNullOrWhiteSpace($TitleContains)) {
        $selectorCount += 1
        $selector = "title-contains"
        $TitleContains = $TitleContains.Trim()
    }

    if ($ActiveWindow) {
        $selectorCount += 1
        $selector = "active-window"
    }

    if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
        Write-JsonResult -Result (New-FailureResult -Code "save_failed" -Message "ProjectRoot is required." -Selector $selector) -ExitCode 1
    }

    if ($selectorCount -ne 1) {
        Write-JsonResult -Result (New-FailureResult -Code "invalid_selector" -Message "Specify exactly one of -TitleContains or -ActiveWindow." -Selector $selector) -ExitCode 1
    }

    if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
        Write-JsonResult -Result (New-FailureResult -Code "save_failed" -Message "ProjectRoot '$ProjectRoot' does not exist." -Selector $selector) -ExitCode 1
    }

    $resolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
    $target = Resolve-TargetWindow -Selector $selector -TitleContainsValue $TitleContains

    if (Test-IsFailureResult -Value $target) {
        Write-JsonResult -Result $target -ExitCode 1
    }

    $result = Save-WindowScreenshot -Window $target -ProjectRootPath $resolvedProjectRoot -LabelValue $Label -Selector $selector

    if (Test-IsFailureResult -Value $result) {
        Write-JsonResult -Result $result -ExitCode 1
    }

    Write-JsonResult -Result $result
}
catch {
    $selector = if ($ActiveWindow) { "active-window" } elseif (-not [string]::IsNullOrWhiteSpace($TitleContains)) { "title-contains" } else { "" }
    Write-JsonResult -Result (New-FailureResult -Code "capture_failed" -Message $_.Exception.Message -Selector $selector) -ExitCode 1
}
