// swiftc theme-watcher.swift -o theme-watcher
// chmod +x theme-watcher

import Cocoa

func runThemeScript() {
    let isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"

    // Determine arguments based on system state
    let mode = isDark ? "dark" : "light"
    let themeName = isDark ? "gruvbox_dark" : "gruvbox_light"

    print("Detected system change to \(mode). Executing switch-theme.sh \(mode) \(themeName)")

    // Path to your specific script
    let scriptPath = NSString(string: "~/.config/scripts/switch-theme.sh").expandingTildeInPath

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = [scriptPath, mode, themeName]

    // Set up pipes to see output if needed (optional)
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print("Failed to run script: \(error)")
    }
}

// Initial run to sync on launch
runThemeScript()

// Observer for system theme changes
DistributedNotificationCenter.default.addObserver(
    forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil,
    queue: nil
) { _ in
    runThemeScript()
}

NSApplication.shared.run()
