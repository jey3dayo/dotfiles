[CmdletBinding()]
param(
    [string]$ProjectRoot,
    [string]$TitleContains,
    [switch]$ActiveWindow,
    [string]$WindowHandle,
    [switch]$ClientArea,
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

        [string[]]$Matches,

        [string]$WindowHandleValue
    )

    $result = [ordered]@{
        ok       = $false
        code     = $Code
        message  = $Message
        selector = $Selector
    }

    if (-not [string]::IsNullOrWhiteSpace($WindowHandleValue)) {
        $result.windowHandle = $WindowHandleValue
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
    public const int DWMWA_EXTENDED_FRAME_BOUNDS = 9;
    public const uint PW_CLIENTONLY = 0x00000001;
    public const uint PW_RENDERFULLCONTENT = 0x00000002;

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int X;
        public int Y;
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
    public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetClientRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ClientToScreen(IntPtr hWnd, ref POINT point);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("dwmapi.dll", PreserveSig = true)]
    public static extern int DwmGetWindowAttribute(IntPtr hWnd, int dwAttribute, out RECT pvAttribute, int cbAttribute);
}
"@

    Add-Type -TypeDefinition $signature
}

function ConvertTo-WindowHandleString {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle
    )

    return ("0x{0:X16}" -f $Handle.ToInt64())
}

function ConvertFrom-WindowHandleValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $trimmed = $Value.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
        return New-FailureResult -Code "invalid_window_handle" -Message "WindowHandle is required when using -WindowHandle." -Selector "window-handle"
    }

    try {
        $numericValue = if ($trimmed -match '^0[xX][0-9a-fA-F]+$') {
            [Convert]::ToInt64($trimmed.Substring(2), 16)
        }
        else {
            [Convert]::ToInt64($trimmed, 10)
        }
    }
    catch {
        return New-FailureResult -Code "invalid_window_handle" -Message "WindowHandle '$trimmed' is not a valid decimal or 0x-prefixed handle." -Selector "window-handle" -WindowHandleValue $trimmed
    }

    if ($numericValue -le 0) {
        return New-FailureResult -Code "invalid_window_handle" -Message "WindowHandle '$trimmed' must be greater than zero." -Selector "window-handle" -WindowHandleValue $trimmed
    }

    $handle = [System.IntPtr]::new($numericValue)
    if (-not [WindowCaptureNative]::IsWindow($handle)) {
        return New-FailureResult -Code "invalid_window_handle" -Message "WindowHandle '$trimmed' does not refer to a live window." -Selector "window-handle" -WindowHandleValue $trimmed
    }

    return $handle
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

function Convert-RectToBounds {
    param(
        [Parameter(Mandatory = $true)]
        $Rect
    )

    $width = [int]($Rect.Right - $Rect.Left)
    $height = [int]($Rect.Bottom - $Rect.Top)
    if ($width -le 0 -or $height -le 0) {
        return $null
    }

    return [ordered]@{
        left   = [int]$Rect.Left
        top    = [int]$Rect.Top
        width  = $width
        height = $height
    }
}

function Get-ExtendedFrameBounds {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle
    )

    $rect = New-Object "WindowCaptureNative+RECT"
    $rectSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type]"WindowCaptureNative+RECT")
    $status = [WindowCaptureNative]::DwmGetWindowAttribute(
        $Handle,
        [WindowCaptureNative]::DWMWA_EXTENDED_FRAME_BOUNDS,
        [ref]$rect,
        $rectSize
    )

    if ($status -ne 0) {
        return $null
    }

    return $rect
}

function Get-WindowBounds {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle,

        [switch]$ClientArea
    )

    if ($ClientArea) {
        $clientRect = New-Object "WindowCaptureNative+RECT"
        if (-not [WindowCaptureNative]::GetClientRect($Handle, [ref]$clientRect)) {
            return $null
        }

        $topLeft = New-Object "WindowCaptureNative+POINT"
        $topLeft.X = $clientRect.Left
        $topLeft.Y = $clientRect.Top

        $bottomRight = New-Object "WindowCaptureNative+POINT"
        $bottomRight.X = $clientRect.Right
        $bottomRight.Y = $clientRect.Bottom

        if (-not [WindowCaptureNative]::ClientToScreen($Handle, [ref]$topLeft)) {
            return $null
        }

        if (-not [WindowCaptureNative]::ClientToScreen($Handle, [ref]$bottomRight)) {
            return $null
        }

        $bounds = [ordered]@{
            left   = [int]$topLeft.X
            top    = [int]$topLeft.Y
            width  = [int]($bottomRight.X - $topLeft.X)
            height = [int]($bottomRight.Y - $topLeft.Y)
        }

        if ($bounds.width -le 0 -or $bounds.height -le 0) {
            return $null
        }

        return $bounds
    }

    $extendedBounds = Get-ExtendedFrameBounds -Handle $Handle
    if ($null -ne $extendedBounds) {
        $bounds = Convert-RectToBounds -Rect $extendedBounds
        if ($null -ne $bounds) {
            return $bounds
        }
    }

    $windowRect = New-Object "WindowCaptureNative+RECT"
    if (-not [WindowCaptureNative]::GetWindowRect($Handle, [ref]$windowRect)) {
        return $null
    }

    return Convert-RectToBounds -Rect $windowRect
}

function Get-WindowInfo {
    param(
        [Parameter(Mandatory = $true)]
        [System.IntPtr]$Handle,

        [switch]$CaptureClientArea
    )

    return [pscustomobject]@{
        Handle    = $Handle
        HandleHex = ConvertTo-WindowHandleString -Handle $Handle
        Title     = Get-WindowTitle -Handle $Handle
        Visible   = [WindowCaptureNative]::IsWindowVisible($Handle)
        Minimized = [WindowCaptureNative]::IsIconic($Handle)
        Bounds    = Get-WindowBounds -Handle $Handle -ClientArea:$CaptureClientArea
    }
}

function Get-TopLevelWindows {
    param(
        [switch]$CaptureClientArea
    )

    $windows = New-Object "System.Collections.Generic.List[object]"
    $callback = [EnumWindowsProc]{
        param(
            [System.IntPtr]$Handle,
            [System.IntPtr]$LParam
        )

        $windows.Add((Get-WindowInfo -Handle $Handle -CaptureClientArea:$CaptureClientArea))

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

        [string]$TitleContainsValue,

        [string]$WindowHandleValue,

        [switch]$CaptureClientArea
    )

    if ($Selector -eq "active-window") {
        $handle = [WindowCaptureNative]::GetForegroundWindow()
        if ($handle -eq [System.IntPtr]::Zero) {
            return New-FailureResult -Code "window_not_found" -Message "No active foreground window was found." -Selector $Selector
        }

        $window = Get-WindowInfo -Handle $handle -CaptureClientArea:$CaptureClientArea

        if (-not (Test-WindowIsCapturable -Window $window)) {
            return New-FailureResult -Code "window_not_visible" -Message "The active window is minimized, hidden, or has zero size." -Selector $Selector -WindowHandleValue $window.HandleHex
        }

        return $window
    }

    if ($Selector -eq "window-handle") {
        $parsedHandle = ConvertFrom-WindowHandleValue -Value $WindowHandleValue
        if (Test-IsFailureResult -Value $parsedHandle) {
            return $parsedHandle
        }

        $window = Get-WindowInfo -Handle $parsedHandle -CaptureClientArea:$CaptureClientArea
        if (-not (Test-WindowIsCapturable -Window $window)) {
            return New-FailureResult -Code "window_not_visible" -Message "The requested window is minimized, hidden, or has zero size." -Selector $Selector -WindowHandleValue $window.HandleHex
        }

        return $window
    }

    $matchedWindows = @(
        Get-TopLevelWindows -CaptureClientArea:$CaptureClientArea | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_.Title) -and
            $_.Title.IndexOf($TitleContainsValue, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        }
    )

    if ($matchedWindows.Count -eq 0) {
        return New-FailureResult -Code "window_not_found" -Message "No window matched TitleContains='$TitleContainsValue'." -Selector $Selector
    }

    $visibleMatches = @($matchedWindows | Where-Object { Test-WindowIsCapturable -Window $_ })

    if ($visibleMatches.Count -gt 1) {
        return New-FailureResult -Code "multiple_windows_matched" -Message "Multiple visible windows matched TitleContains='$TitleContainsValue'." -Selector $Selector -Matches @($visibleMatches | ForEach-Object { "$($_.Title) [$($_.HandleHex)]" })
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
        [string]$Selector,

        [switch]$ClientAreaValue
    )

    $captureBounds = Get-WindowBounds -Handle $Window.Handle -ClientArea:$ClientAreaValue
    if ($null -eq $captureBounds -or $captureBounds.width -le 0 -or $captureBounds.height -le 0) {
        return New-FailureResult -Code "window_not_visible" -Message "The target window no longer has a capturable size." -Selector $Selector -WindowHandleValue $Window.HandleHex
    }

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
    $deviceContext = [System.IntPtr]::Zero
    $captureFailure = $null
    try {
        $bitmap = New-Object System.Drawing.Bitmap ($captureBounds.width), ($captureBounds.height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        $captureFlags = if ($ClientAreaValue) {
            @(
                ([uint32]([WindowCaptureNative]::PW_CLIENTONLY -bor [WindowCaptureNative]::PW_RENDERFULLCONTENT)),
                ([uint32][WindowCaptureNative]::PW_CLIENTONLY)
            )
        }
        else {
            @(
                ([uint32][WindowCaptureNative]::PW_RENDERFULLCONTENT),
                [uint32]0
            )
        }

        $printSucceeded = $false
        $attemptNotes = New-Object "System.Collections.Generic.List[string]"

        foreach ($flag in $captureFlags) {
            $deviceContext = $graphics.GetHdc()
            try {
                if ([WindowCaptureNative]::PrintWindow($Window.Handle, $deviceContext, [uint32]$flag)) {
                    $printSucceeded = $true
                    break
                }

                $lastError = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($lastError -gt 0) {
                    [void]$attemptNotes.Add("flag=$flag error=$lastError")
                }
                else {
                    [void]$attemptNotes.Add("flag=$flag")
                }
            }
            finally {
                if ($deviceContext -ne [System.IntPtr]::Zero) {
                    $graphics.ReleaseHdc($deviceContext)
                    $deviceContext = [System.IntPtr]::Zero
                }
            }
        }

        if (-not $printSucceeded) {
            $details = if ($attemptNotes.Count -gt 0) {
                " Attempts: $($attemptNotes -join ', ')."
            }
            else {
                ""
            }

            $captureFailure = New-FailureResult -Code "capture_failed" -Message "PrintWindow failed for window $($Window.HandleHex).$details" -Selector $Selector -WindowHandleValue $Window.HandleHex
        }
    }
    catch {
        $captureFailure = New-FailureResult -Code "capture_failed" -Message "Failed to capture the window: $($_.Exception.Message)" -Selector $Selector -WindowHandleValue $Window.HandleHex
    }
    finally {
        if ($deviceContext -ne [System.IntPtr]::Zero -and $graphics) {
            $graphics.ReleaseHdc($deviceContext)
        }

        if ($graphics) {
            $graphics.Dispose()
            $graphics = $null
        }
    }

    if ($captureFailure) {
        if ($bitmap) {
            $bitmap.Dispose()
        }

        return $captureFailure
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
        ok            = $true
        savedPath     = $savedPath
        windowTitle   = $Window.Title
        windowHandle  = $Window.HandleHex
        selector      = $Selector
        captureArea   = if ($ClientAreaValue) { "client" } else { "window" }
        captureMethod = "print-window"
        timestamp     = $isoTimestamp
        bounds        = [ordered]@{
            left   = $captureBounds.left
            top    = $captureBounds.top
            width  = $captureBounds.width
            height = $captureBounds.height
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

    if (-not [string]::IsNullOrWhiteSpace($WindowHandle)) {
        $selectorCount += 1
        $selector = "window-handle"
        $WindowHandle = $WindowHandle.Trim()
    }

    if ($ActiveWindow) {
        $selectorCount += 1
        $selector = "active-window"
    }

    if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
        Write-JsonResult -Result (New-FailureResult -Code "save_failed" -Message "ProjectRoot is required." -Selector $selector) -ExitCode 1
    }

    if ($selectorCount -ne 1) {
        Write-JsonResult -Result (New-FailureResult -Code "invalid_selector" -Message "Specify exactly one of -WindowHandle, -TitleContains, or -ActiveWindow." -Selector $selector) -ExitCode 1
    }

    if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
        Write-JsonResult -Result (New-FailureResult -Code "save_failed" -Message "ProjectRoot '$ProjectRoot' does not exist." -Selector $selector) -ExitCode 1
    }

    $resolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
    $target = Resolve-TargetWindow -Selector $selector -TitleContainsValue $TitleContains -WindowHandleValue $WindowHandle -CaptureClientArea:$ClientArea

    if (Test-IsFailureResult -Value $target) {
        Write-JsonResult -Result $target -ExitCode 1
    }

    $result = Save-WindowScreenshot -Window $target -ProjectRootPath $resolvedProjectRoot -LabelValue $Label -Selector $selector -ClientAreaValue:$ClientArea

    if (Test-IsFailureResult -Value $result) {
        Write-JsonResult -Result $result -ExitCode 1
    }

    Write-JsonResult -Result $result
}
catch {
    $selector = if ($ActiveWindow) { "active-window" } elseif (-not [string]::IsNullOrWhiteSpace($WindowHandle)) { "window-handle" } elseif (-not [string]::IsNullOrWhiteSpace($TitleContains)) { "title-contains" } else { "" }
    Write-JsonResult -Result (New-FailureResult -Code "capture_failed" -Message $_.Exception.Message -Selector $selector) -ExitCode 1
}
