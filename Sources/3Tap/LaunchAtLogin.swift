import Foundation
import ServiceManagement
import AppKit

final class LaunchAtLogin {
    static let shared = LaunchAtLogin()
    
    private let launchAgentIdentifier = "com.victor.3tap"
    
    private var plistPath: String {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return libraryURL.appendingPathComponent("LaunchAgents/\(launchAgentIdentifier).plist").path
    }
    
    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                return FileManager.default.fileExists(atPath: plistPath)
            }
        }
        set {
            setLaunchAtLogin(newValue)
        }
    }
    
    private func setLaunchAtLogin(_ enable: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enable {
                    try SMAppService.mainApp.register()
                    print("[3Tap] Registered launch at login via SMAppService")
                } else {
                    try SMAppService.mainApp.unregister()
                    print("[3Tap] Unregistered launch at login via SMAppService")
                }
                return
            } catch {
                print("[3Tap] SMAppService error (falling back to LaunchAgent): \(error)")
            }
        }
        
        // Fallback: LaunchAgent plist
        let fileManager = FileManager.default
        if enable {
            let appPath = Bundle.main.bundlePath
            let executablePath = appPath.hasSuffix(".app")
                ? "\(appPath)/Contents/MacOS/3Tap"
                : Bundle.main.executablePath ?? appPath
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(launchAgentIdentifier)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(executablePath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
            </dict>
            </plist>
            """
            
            let launchAgentFolder = (plistPath as NSString).deletingLastPathComponent
            try? fileManager.createDirectory(atPath: launchAgentFolder, withIntermediateDirectories: true, attributes: nil)
            try? plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
            print("[3Tap] Created LaunchAgent plist at \(plistPath)")
        } else {
            try? fileManager.removeItem(atPath: plistPath)
            print("[3Tap] Removed LaunchAgent plist at \(plistPath)")
        }
    }
}
