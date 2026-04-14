#!/usr/bin/env swift

import AppKit
import CoreGraphics
import Foundation

struct Bounds: Encodable {
    let left: Int
    let top: Int
    let width: Int
    let height: Int
}

struct FailureResult: Encodable {
    let ok = false
    let code: String
    let message: String
    let selector: String
    let matches: [String]?
    let windowHandle: String?
}

struct SuccessResult: Encodable {
    let ok = true
    let savedPath: String
    let windowTitle: String
    let windowHandle: String
    let selector: String
    let captureArea: String
    let captureMethod: String
    let timestamp: String
    let bounds: Bounds
}

struct ParsedArguments {
    let projectRoot: String?
    let titleContains: String?
    let activeWindow: Bool
    let windowHandle: String?
    let clientArea: Bool
    let label: String?
}

struct WindowInfo {
    let id: CGWindowID
    let ownerPID: pid_t
    let ownerName: String
    let windowName: String
    let bounds: Bounds
    let layer: Int
    let alpha: Double
    let isOnscreen: Bool

    var displayTitle: String {
        if !windowName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return windowName
        }

        return ownerName
    }

    var handleHex: String {
        String(format: "0x%016llX", UInt64(id))
    }

    var matchStrings: [String] {
        let composite = "\(ownerName) \(windowName)".trimmingCharacters(in: .whitespacesAndNewlines)
        return [ownerName, windowName, displayTitle, composite].filter { !$0.isEmpty }
    }

    var isCapturable: Bool {
        isOnscreen && layer == 0 && alpha > 0 && bounds.width > 0 && bounds.height > 0
    }
}

enum ExitFailure: Error {
    case invalidArguments(String)
}

func emitJSON<T: Encodable>(_ value: T, exitCode: Int32 = 0) -> Never {
    let encoder = JSONEncoder()

    do {
        let data = try encoder.encode(value)
        FileHandle.standardOutput.write(data)
        FileHandle.standardOutput.write(Data([0x0a]))
    } catch {
        let fallback = #"{"ok":false,"code":"capture_failed","message":"Failed to encode JSON output.","selector":""}"#
        FileHandle.standardOutput.write(Data(fallback.utf8))
        FileHandle.standardOutput.write(Data([0x0a]))
    }

    exit(exitCode)
}

func failure(
    code: String,
    message: String,
    selector: String,
    matches: [String]? = nil,
    windowHandle: String? = nil,
    exitCode: Int32 = 1
) -> Never {
    emitJSON(
        FailureResult(
            code: code,
            message: message,
            selector: selector,
            matches: matches,
            windowHandle: windowHandle
        ),
        exitCode: exitCode
    )
}

func parseArguments() throws -> ParsedArguments {
    let args = Array(CommandLine.arguments.dropFirst())
    var projectRoot: String?
    var titleContains: String?
    var activeWindow = false
    var windowHandle: String?
    var clientArea = false
    var label: String?

    var index = 0
    while index < args.count {
        let arg = args[index]

        switch arg {
        case "--project-root":
            index += 1
            guard index < args.count else {
                throw ExitFailure.invalidArguments("Missing value for --project-root.")
            }
            projectRoot = args[index]
        case "--title-contains":
            index += 1
            guard index < args.count else {
                throw ExitFailure.invalidArguments("Missing value for --title-contains.")
            }
            titleContains = args[index]
        case "--window-handle":
            index += 1
            guard index < args.count else {
                throw ExitFailure.invalidArguments("Missing value for --window-handle.")
            }
            windowHandle = args[index]
        case "--label":
            index += 1
            guard index < args.count else {
                throw ExitFailure.invalidArguments("Missing value for --label.")
            }
            label = args[index]
        case "--active-window":
            activeWindow = true
        case "--client-area":
            clientArea = true
        default:
            throw ExitFailure.invalidArguments("Unknown argument '\(arg)'.")
        }

        index += 1
    }

    return ParsedArguments(
        projectRoot: projectRoot,
        titleContains: titleContains,
        activeWindow: activeWindow,
        windowHandle: windowHandle,
        clientArea: clientArea,
        label: label
    )
}

func parseWindowHandle(_ rawValue: String) -> CGWindowID? {
    let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return nil
    }

    let numericValue: UInt64?
    if trimmed.lowercased().hasPrefix("0x") {
        numericValue = UInt64(trimmed.dropFirst(2), radix: 16)
    } else {
        numericValue = UInt64(trimmed, radix: 10)
    }

    guard let numericValue, numericValue > 0, numericValue <= UInt64(UInt32.max) else {
        return nil
    }

    return CGWindowID(numericValue)
}

func sanitizeLabel(_ rawValue: String?) -> String {
    guard let rawValue else {
        return ""
    }

    let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return ""
    }

    let replaced = trimmed.replacingOccurrences(
        of: #"[^A-Za-z0-9._-]+"#,
        with: "-",
        options: .regularExpression
    )

    return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
}

func loadWindows() -> [WindowInfo] {
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    let rawWindows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []

    return rawWindows.compactMap { window in
        guard
            let idValue = window[kCGWindowNumber as String] as? UInt32 ?? (window[kCGWindowNumber as String] as? Int).map(UInt32.init),
            let ownerPIDValue = window[kCGWindowOwnerPID as String] as? Int32 ?? (window[kCGWindowOwnerPID as String] as? Int).map(Int32.init),
            let ownerName = window[kCGWindowOwnerName as String] as? String,
            let boundsDictionary = window[kCGWindowBounds as String] as? [String: Any],
            let x = boundsDictionary["X"] as? Int ?? (boundsDictionary["X"] as? Double).map(Int.init),
            let y = boundsDictionary["Y"] as? Int ?? (boundsDictionary["Y"] as? Double).map(Int.init),
            let width = boundsDictionary["Width"] as? Int ?? (boundsDictionary["Width"] as? Double).map(Int.init),
            let height = boundsDictionary["Height"] as? Int ?? (boundsDictionary["Height"] as? Double).map(Int.init)
        else {
            return nil
        }

        return WindowInfo(
            id: CGWindowID(idValue),
            ownerPID: pid_t(ownerPIDValue),
            ownerName: ownerName,
            windowName: (window[kCGWindowName as String] as? String) ?? "",
            bounds: Bounds(left: x, top: y, width: width, height: height),
            layer: window[kCGWindowLayer as String] as? Int ?? 0,
            alpha: window[kCGWindowAlpha as String] as? Double ?? 1,
            isOnscreen: window[kCGWindowIsOnscreen as String] as? Bool ?? true
        )
    }
}

func resolveSelector(arguments: ParsedArguments) -> (count: Int, selector: String) {
    var count = 0
    var selector = ""

    if let titleContains = arguments.titleContains, !titleContains.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        count += 1
        selector = "title-contains"
    }

    if let windowHandle = arguments.windowHandle, !windowHandle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        count += 1
        selector = "window-handle"
    }

    if arguments.activeWindow {
        count += 1
        selector = "active-window"
    }

    return (count, selector)
}

func resolveTargetWindow(arguments: ParsedArguments, windows: [WindowInfo], selector: String) -> WindowInfo? {
    switch selector {
    case "active-window":
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        return windows.first(where: { $0.ownerPID == frontmostApp.processIdentifier && $0.isCapturable })
    case "window-handle":
        guard
            let rawHandle = arguments.windowHandle,
            let targetID = parseWindowHandle(rawHandle)
        else {
            failure(
                code: "invalid_window_handle",
                message: "WindowHandle '\(arguments.windowHandle ?? "")' is not a valid decimal or 0x-prefixed handle.",
                selector: selector,
                windowHandle: arguments.windowHandle
            )
        }

        guard let match = windows.first(where: { $0.id == targetID }) else {
            failure(
                code: "invalid_window_handle",
                message: "WindowHandle '\(rawHandle)' does not refer to a live window.",
                selector: selector,
                windowHandle: rawHandle
            )
        }

        guard match.isCapturable else {
            failure(
                code: "window_not_visible",
                message: "The requested window is hidden, filtered, or has zero size.",
                selector: selector,
                windowHandle: match.handleHex
            )
        }

        return match
    case "title-contains":
        let needle = (arguments.titleContains ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let visibleMatches = windows.filter { window in
            window.isCapturable && window.matchStrings.contains {
                $0.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }

        if visibleMatches.isEmpty {
            failure(
                code: "window_not_found",
                message: "No window matched TitleContains='\(needle)'.",
                selector: selector
            )
        }

        if visibleMatches.count > 1 {
            failure(
                code: "multiple_windows_matched",
                message: "Multiple visible windows matched TitleContains='\(needle)'.",
                selector: selector,
                matches: visibleMatches.map { "\($0.displayTitle) [\($0.handleHex)]" }
            )
        }

        return visibleMatches[0]
    default:
        return nil
    }
}

func makeTimestamp() -> (fileComponent: String, iso8601: String) {
    let now = Date()

    let fileFormatter = DateFormatter()
    fileFormatter.calendar = Calendar(identifier: .gregorian)
    fileFormatter.locale = Locale(identifier: "en_US_POSIX")
    fileFormatter.timeZone = TimeZone.current
    fileFormatter.dateFormat = "yyyyMMdd-HHmmss"

    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.timeZone = TimeZone.current
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    return (fileFormatter.string(from: now), isoFormatter.string(from: now))
}

func ensureScreenshotDirectory(projectRoot: String, selector: String) -> URL {
    let rootURL = URL(fileURLWithPath: projectRoot, isDirectory: true)
    let screenshotDirectory = rootURL.appendingPathComponent("tmp/screenshots", isDirectory: true)

    do {
        try FileManager.default.createDirectory(at: screenshotDirectory, withIntermediateDirectories: true)
    } catch {
        failure(
            code: "save_failed",
            message: "Failed to prepare screenshot directory '\(screenshotDirectory.path)': \(error.localizedDescription)",
            selector: selector
        )
    }

    return screenshotDirectory
}

func hasScreenRecordingPermission() -> Bool {
    if #available(macOS 10.15, *) {
        return CGPreflightScreenCaptureAccess()
    }

    return true
}

func runScreenCapture(window: WindowInfo, destinationPath: String, selector: String) {
    let process = Process()
    let stderrPipe = Pipe()
    let stdoutPipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    process.arguments = ["-x", "-o", "-l\(window.id)", destinationPath]
    process.standardError = stderrPipe
    process.standardOutput = stdoutPipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        failure(
            code: "capture_failed",
            message: "Failed to launch screencapture: \(error.localizedDescription)",
            selector: selector,
            windowHandle: window.handleHex
        )
    }

    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    let stderrText = String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    guard process.terminationStatus == 0 else {
        let message = stderrText.isEmpty ? "screencapture exited with status \(process.terminationStatus)." : stderrText
        failure(
            code: "capture_failed",
            message: "Failed to capture the window: \(message)",
            selector: selector,
            windowHandle: window.handleHex
        )
    }
}

do {
    let arguments = try parseArguments()
    let selectorInfo = resolveSelector(arguments: arguments)

    guard let projectRoot = arguments.projectRoot?.trimmingCharacters(in: .whitespacesAndNewlines), !projectRoot.isEmpty else {
        failure(code: "save_failed", message: "ProjectRoot is required.", selector: selectorInfo.selector)
    }

    guard selectorInfo.count == 1 else {
        failure(
            code: "invalid_selector",
            message: "Specify exactly one of --window-handle, --title-contains, or --active-window.",
            selector: selectorInfo.selector
        )
    }

    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: projectRoot, isDirectory: &isDirectory), isDirectory.boolValue else {
        failure(
            code: "save_failed",
            message: "ProjectRoot '\(projectRoot)' does not exist.",
            selector: selectorInfo.selector
        )
    }

    if arguments.clientArea {
        failure(
            code: "capture_failed",
            message: "ClientArea is not supported on macOS yet.",
            selector: selectorInfo.selector
        )
    }

    let windows = loadWindows()
    guard let window = resolveTargetWindow(arguments: arguments, windows: windows, selector: selectorInfo.selector) else {
        failure(
            code: "window_not_found",
            message: "No target window was found.",
            selector: selectorInfo.selector
        )
    }

    guard hasScreenRecordingPermission() else {
        failure(
            code: "permission_denied",
            message: "macOS Screen Recording permission is required for window capture.",
            selector: selectorInfo.selector,
            windowHandle: window.handleHex
        )
    }

    let screenshotDirectory = ensureScreenshotDirectory(projectRoot: projectRoot, selector: selectorInfo.selector)
    let timestamp = makeTimestamp()
    let safeLabel = sanitizeLabel(arguments.label)
    let fileName = safeLabel.isEmpty ? "\(timestamp.fileComponent).png" : "\(timestamp.fileComponent)-\(safeLabel).png"
    let savedURL = screenshotDirectory.appendingPathComponent(fileName)

    runScreenCapture(window: window, destinationPath: savedURL.path, selector: selectorInfo.selector)

    guard FileManager.default.fileExists(atPath: savedURL.path) else {
        failure(
            code: "save_failed",
            message: "screencapture completed but no file was written to '\(savedURL.path)'.",
            selector: selectorInfo.selector,
            windowHandle: window.handleHex
        )
    }

    emitJSON(
        SuccessResult(
            savedPath: savedURL.path,
            windowTitle: window.displayTitle,
            windowHandle: window.handleHex,
            selector: selectorInfo.selector,
            captureArea: "window",
            captureMethod: "screencapture-window-id",
            timestamp: timestamp.iso8601,
            bounds: window.bounds
        )
    )
} catch ExitFailure.invalidArguments(let message) {
    failure(code: "invalid_selector", message: message, selector: "")
} catch {
    failure(code: "capture_failed", message: error.localizedDescription, selector: "")
}
