import Foundation
import CoreGraphics
import ApplicationServices
import AppKit

final class KeySender {
    static let shared = KeySender()
    
    private init() {}
    
    /// Checks if the app has Accessibility permissions.
    var isAccessibilityGranted: Bool {
        return AXIsProcessTrusted()
    }
    
    /// Requests Accessibility permission from the OS.
    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
    
    /// Opens the Accessibility pane in macOS System Settings.
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// Sends a simulated Enter / Return key press (Virtual Key 0x24).
    func sendEnterKey() {
        guard isAccessibilityGranted else {
            print("[3Tap] Cannot send Enter: Accessibility permission not granted.")
            requestAccessibilityPermission()
            return
        }
        
        let returnKeyCode: CGKeyCode = 0x24 // Virtual key code for Return / Enter
        
        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: returnKeyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: returnKeyCode, keyDown: false) else {
            print("[3Tap] Failed to create CGEvent for Return key")
            return
        }
        
        // Post key down and key up events to HID event tap
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        print("[3Tap] Enter/Return key sent successfully!")
    }
}
