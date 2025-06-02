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
            button.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Claude Code Status")
            button.image?.isTemplate = true
            print("Status button configured")
        } else {
            print("ERROR: Could not get status button!")
        }
        
        let menu = NSMenu()
        
        // ステータス表示用のメニューアイテム
        let statusMenuItem = NSMenuItem(title: "Status: Idle", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    private func setupStatusMonitor() {
        statusMonitor = ClaudeStatusMonitor()
        statusMonitor?.onStatusChange = { [weak self] status in
            print("Status changed to: \(status)")
            DispatchQueue.main.async {
                self?.updateStatusIcon(for: status)
            }
        }
        statusMonitor?.start()
        
        // 初期状態を設定
        updateStatusIcon(for: .idle)
    }
    
    private func updateStatusIcon(for status: ClaudeStatus) {
        guard let button = statusItem?.button else { return }
        
        // メニューの最初のアイテムを更新
        if let menu = statusItem?.menu,
           let statusMenuItem = menu.items.first {
            switch status {
            case .idle:
                statusMenuItem.title = "Status: Idle 🟢"
            case .waitingForPermission:
                statusMenuItem.title = "Status: Waiting for permission 🟡"
            case .executing:
                statusMenuItem.title = "Status: Executing 🔴"
            }
        }
        
        switch status {
        case .idle:
            button.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Idle")
            button.toolTip = "Claude Code: Idle"
        case .waitingForPermission:
            button.image = NSImage(systemSymbolName: "exclamationmark.circle.fill", accessibilityDescription: "Waiting for permission")
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