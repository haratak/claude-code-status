import SwiftUI
import Combine

@main
struct ClaudeCodeStatusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var statusMonitor: ClaudeStatusMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupStatusMonitor()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Claude Code Status")
            button.image?.isTemplate = true
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