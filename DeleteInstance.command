#!/bin/bash

# ==============================================================================
# REMOVE INDIVIDUAL INSTANCE
# ==============================================================================

clear
BASE_DIR="$HOME/.antigravity-projetos"

if [ ! -d "$BASE_DIR" ] || [ -z "$(ls -A "$BASE_DIR" 2>/dev/null)" ]; then
    echo "ℹ️  No active instances found."
    sleep 2
    exit 0
fi

echo "================================================================"
echo "           DELETE ANTIGRAVITY INSTANCE"
echo "================================================================"
echo ""

PROJECTS=($(ls "$BASE_DIR"))

echo "Found instances:"
for i in "${!PROJECTS[@]}"; do
    echo " [$((i+1))] ${PROJECTS[$i]}"
done
echo ""

read -p "Enter the number of the instance you want to delete (or 0 to cancel): " CHOICE

if [ "$CHOICE" -eq 0 ] 2>/dev/null || [ -z "$CHOICE" ]; then
    echo "❌ Operation canceled."
    sleep 1
    exit 0
fi

INDEX=$((CHOICE-1))
PROJECT_SLUG="${PROJECTS[$INDEX]}"

if [ -z "$PROJECT_SLUG" ]; then
    echo "❌ Invalid choice."
    sleep 2
    exit 1
fi

echo ""
echo "🗑️ Deleting instance '$PROJECT_SLUG'..."

# Terminate running app processes for this instance
pkill -f "$PROJECT_SLUG" 2>/dev/null || true

# Delete isolated data folder
rm -rf "$BASE_DIR/$PROJECT_SLUG"

# Remove application from /Applications
find /Applications -maxdepth 1 -iname "*$PROJECT_SLUG*" -exec rm -rf {} + 2>/dev/null || true

killall Finder 2>/dev/null || true

echo "✨ Instance '$PROJECT_SLUG' successfully removed!"
sleep 2