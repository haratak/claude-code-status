# Running Claude Code Status Menu Bar App

## Issues Fixed

The original implementation had several issues that prevented the menu bar app from showing up:

1. **Missing Info.plist**: macOS apps require an Info.plist with `LSUIElement` set to `true` for menu bar apps
2. **Wrong App Structure**: The app was configured as a command-line executable instead of a macOS app bundle
3. **Missing Activation Policy**: The app needs to set `.accessory` activation policy to hide from dock
4. **SwiftUI Configuration Issues**: Simplified to use AppKit directly for better reliability

## How to Run

### Option 1: Build and Run as App Bundle (Recommended)
```bash
./build_and_run.sh
```
This script will:
- Build the app in release mode
- Create a proper .app bundle with Info.plist
- Launch the app
- The menu bar icon should appear in the top-right of your screen

### Option 2: Debug Mode (See Console Output)
```bash
./run_debug.sh
```
This will run the app in terminal so you can see debug output.

### Option 3: Manual Build
```bash
# Build
swift build -c release

# Create app bundle
mkdir -p ClaudeCodeStatus.app/Contents/MacOS
cp .build/release/ClaudeCodeStatus ClaudeCodeStatus.app/Contents/MacOS/
cp Sources/ClaudeCodeStatus/Info.plist ClaudeCodeStatus.app/Contents/

# Run
open ClaudeCodeStatus.app
```

## Troubleshooting

1. **Icon Not Appearing**: 
   - Check if the app is running: `ps aux | grep ClaudeCodeStatus`
   - Look for any error messages in Console.app
   - Try running in debug mode to see output

2. **Permission Issues**:
   - The app needs to read from `~/.claude/logs/claude.log`
   - Make sure this file exists or create it: `mkdir -p ~/.claude/logs && touch ~/.claude/logs/claude.log`

3. **Icon Not Changing**:
   - Use the test script to simulate status changes: `./test_status.sh`
   - Check that log entries are being written correctly

## What to Look For

- A circle icon in your menu bar (top-right of screen)
- Icon states:
  - Empty circle (○): Claude is idle
  - Filled circle (●): Claude is executing a task
  - Circle with exclamation (⚠): Claude is waiting for permission
- Click the icon to see a menu with "Quit" option
- Hover over icon to see tooltip with current status