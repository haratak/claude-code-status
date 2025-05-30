#!/bin/bash

# Build and run the Claude Code Status menu bar app

echo "Building Claude Code Status menu bar app..."

# Clean previous builds
rm -rf .build
rm -rf ClaudeCodeStatus.app

# Build the executable
swift build -c release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Create app bundle structure
echo "Creating app bundle..."
mkdir -p ClaudeCodeStatus.app/Contents/MacOS
mkdir -p ClaudeCodeStatus.app/Contents/Resources

# Copy executable
cp .build/release/ClaudeCodeStatus ClaudeCodeStatus.app/Contents/MacOS/

# Create Info.plist for the app bundle
cat > ClaudeCodeStatus.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ClaudeCodeStatus</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.ClaudeCodeStatus</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Claude Code Status</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "App bundle created at: ClaudeCodeStatus.app"

# Kill any existing instances
pkill -f ClaudeCodeStatus || true

# Run the app
echo "Launching Claude Code Status..."
open ClaudeCodeStatus.app

echo "Done! The app should now appear in your menu bar."
echo "Look for a circle icon in the top right of your screen."