#!/bin/bash

# Debug run script for Claude Code Status

echo "Building Claude Code Status (debug mode)..."

# Clean and build
swift build

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Kill any existing instances
pkill -f ClaudeCodeStatus || true

echo "Running Claude Code Status in terminal (debug mode)..."
echo "You should see debug output here and the icon in the menu bar."
echo "Press Ctrl+C to stop."
echo ""

# Run directly (not as app bundle) for debugging
.build/debug/ClaudeCodeStatus