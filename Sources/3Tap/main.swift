import AppKit

// Avoid two copies when an old LaunchAgent and SMAppService are both enabled.
let currentPID = ProcessInfo.processInfo.processIdentifier
let otherInstances = NSWorkspace.shared.runningApplications.filter {
    $0.bundleIdentifier == Bundle.main.bundleIdentifier && $0.processIdentifier != currentPID
}
if !otherInstances.isEmpty {
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
