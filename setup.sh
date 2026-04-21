#!/bin/bash
# CardSnap — One-command Xcode project setup
# Run this from the CardSnap folder: bash setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "🚀 CardSnap Project Setup"
echo "========================="
echo ""

# Step 1: Check for Homebrew
if ! command -v brew &>/dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew found"
fi

# Step 2: Install xcodegen if needed
if ! command -v xcodegen &>/dev/null; then
    echo "📦 Installing xcodegen..."
    brew install xcodegen
else
    echo "✅ xcodegen found"
fi

# Step 3: Remove old .xcodeproj if exists
if [ -d "CardSnap.xcodeproj" ]; then
    echo "🗑  Removing old CardSnap.xcodeproj..."
    rm -rf CardSnap.xcodeproj
fi

# Step 4: Generate the Xcode project
echo ""
echo "⚙️  Generating CardSnap.xcodeproj..."
xcodegen generate --spec project.yml

# Step 5: Verify it was created
if [ -d "CardSnap.xcodeproj" ]; then
    echo ""
    echo "✅ CardSnap.xcodeproj created successfully!"
    echo ""
    echo "🎉 Opening in Xcode now..."
    open CardSnap.xcodeproj
else
    echo "❌ Something went wrong — .xcodeproj was not created."
    exit 1
fi

echo ""
echo "Done! In Xcode:"
echo "  1. Select 'CardSnap' target → Signing & Capabilities"
echo "  2. Set your Apple ID team"
echo "  3. Press ⌘R to build and run!"
echo ""
