import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    
    private var toggleItem: NSMenuItem!
    private var accessibilityItem: NSMenuItem!
    private var launchAtLoginItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        // Setup status item in system menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "return", accessibilityDescription: "3Tap") {
                button.image = image
                button.imagePosition = .imageLeft
            } else {
                button.title = "↵ 3Tap"
            }
        }
        
        setupMenu()
        
        // Connect TouchListener callback to KeySender
        TouchListener.shared.on3FingerTap = {
            KeySender.shared.sendEnterKey()
        }
        
        // Start listening
        TouchListener.shared.start()
        
        // Periodic check for accessibility permission status
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMenuState()
        }
        
        print("[3Tap] App launched successfully in background menu bar!")
    }

    @objc private func handleSleep(_ notification: Notification) {
        // The private multitouch stream is reset by macOS during sleep. Keep
        // the user's enabled state and rebuild the stream after wake.
    }

    @objc private func handleWake(_ notification: Notification) {
        TouchListener.shared.restartAfterWake()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    private func setupMenu() {
        menu = NSMenu()
        
        // Title Header
        let titleItem = NSMenuItem(title: "3Tap (3-Finger Tap -> Enter)", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Active Toggle
        toggleItem = NSMenuItem(title: "Ativo", action: #selector(toggleActive), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        // Accessibility Permission Item
        accessibilityItem = NSMenuItem(title: "Acessibilidade: Verificando...", action: #selector(openAccessibilitySettings), keyEquivalent: "")
        accessibilityItem.target = self
        menu.addItem(accessibilityItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Launch at Login Toggle
        launchAtLoginItem = NSMenuItem(title: "Iniciar com o Sistema", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit Item
        let quitItem = NSMenuItem(title: "Sair do 3Tap", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        updateMenuState()
    }
    
    @objc private func toggleActive() {
        TouchListener.shared.toggle()
        updateMenuState()
    }
    
    @objc private func openAccessibilitySettings() {
        if KeySender.shared.isAccessibilityGranted {
            KeySender.shared.openAccessibilitySettings()
        } else {
            KeySender.shared.requestAccessibilityPermission()
            KeySender.shared.openAccessibilitySettings()
        }
    }
    
    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.shared.isEnabled.toggle()
        updateMenuState()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func updateMenuState() {
        let isTouchActive = TouchListener.shared.isEnabled
        toggleItem.state = isTouchActive ? .on : .off
        toggleItem.title = isTouchActive ? "Ativo (Ouvindo toques)" : "Pausado"
        
        let isAccessGranted = KeySender.shared.isAccessibilityGranted
        if isAccessGranted {
            accessibilityItem.title = "✓ Acessibilidade: Concedida"
            accessibilityItem.state = .off
        } else {
            accessibilityItem.title = "⚠️ Permissão de Acessibilidade Necessária!"
            accessibilityItem.state = .off
        }
        
        launchAtLoginItem.state = LaunchAtLogin.shared.isEnabled ? .on : .off
    }
}
