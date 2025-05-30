import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var statusMonitor: ClaudeStatusMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application launched")
        setupStatusBar()
        setupStatusMonitor()
        print("Setup complete")
    }
    
    private func setupStatusBar() {
        print("Setting up status bar...")
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            print("Configuring status button...")
            button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Claude Code Status")
            button.image?.isTemplate = true
            print("Status button configured")
        } else {
            print("ERROR: Could not get status button!")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Claude Code Status", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    private func setupStatusMonitor() {
        statusMonitor = ClaudeStatusMonitor()
        statusMonitor?.onStatusChange = { [weak self] status in
            DispatchQueue.main.async {
                self?.updateStatusIcon(for: status)
            }
        }
        statusMonitor?.start()
    }
    
    private func updateStatusIcon(for status: ClaudeStatus) {
        guard let button = statusItem?.button else { return }
        
        switch status {
        case .idle:
            button.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Idle")
            button.toolTip = "Claude Code: Idle"
        case .waitingForPermission:
            button.image = NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "Waiting for permission")
            button.toolTip = "Claude Code: Waiting for permission"
        case .executing:
            button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Executing")
            button.toolTip = "Claude Code: Executing task"
        }
        
        button.image?.isTemplate = true
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}