#!/bin/bash

# ==============================================================================
# REMOVE ALL INSTANCES
# ==============================================================================

clear
echo "⚠️  STARTING COMPLETE REMOVAL OF ALL INSTANCES..."
echo "----------------------------------------------------------------"

BASE_DIR="$HOME/.antigravity-projetos"

# Terminate active processes
pkill -f "Antigravity" 2>/dev/null || true
pkill -f "AntiGravity" 2>/dev/null || true

echo "🗑️ Deleting data directories..."
rm -rf "$BASE_DIR"

echo "🗑️ Removing cloned applications from /Applications..."
find /Applications -maxdepth 1 \( -iname "Antigravity - *.app" -o -iname "AntiGravity - *.app" \) -exec rm -rf {} + 2>/dev/null || true

killall Finder 2>/dev/null || true

echo "✨ All instances have been successfully cleaned up!"
sleep 2