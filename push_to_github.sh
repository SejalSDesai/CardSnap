#!/bin/bash
# CardSnap — Push to GitHub
# Usage: bash push_to_github.sh https://github.com/YOUR_USERNAME/YOUR_REPO.git

REPO_URL=$1

if [ -z "$REPO_URL" ]; then
    echo ""
    echo "❌ Please provide your GitHub repo URL."
    echo "   Usage: bash push_to_github.sh https://github.com/USERNAME/REPO.git"
    echo ""
    echo "   How to get the URL:"
    echo "   1. Go to github.com and create a new repository called 'CardSnap'"
    echo "   2. Copy the URL shown (ends in .git)"
    echo "   3. Run this script again with that URL"
    echo ""
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "🚀 Pushing CardSnap to GitHub"
echo "================================"
echo ""

# Init git if not already
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
    git branch -M main
fi

# Stage all files
echo "📁 Staging files..."
git add .

# Commit
echo "💾 Creating commit..."
git commit -m "🎉 Initial CardSnap release

- SwiftUI + SwiftData iOS 17+ app
- VisionKit OCR business card scanner
- Dark mode design system with gradient UI
- Home, Favorites, Settings tabs
- Card detail view with contact actions
- Edit card with color picker
- Export to Contacts & CSV"

# Set remote
echo "🔗 Setting remote origin..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

# Push
echo "⬆️  Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Done! CardSnap is now on GitHub:"
echo "   $REPO_URL"
echo ""
