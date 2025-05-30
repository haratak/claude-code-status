import Cocoa

// Create the application
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Create the app delegate
let delegate = AppDelegate()
app.delegate = delegate

// Run the app
app.run()