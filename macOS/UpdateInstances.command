#!/bin/bash

# ==============================================================================
# UPDATE ALL INSTANCES - ANTIGRAVITY IDE
# ==============================================================================

clear
ORIGINAL_APP="/Applications/Antigravity IDE.app"
BASE_DIR="$HOME/.antigravity-projetos"

if [ ! -d "$ORIGINAL_APP" ]; then
    echo "❌ Error: 'Antigravity IDE.app' not found in /Applications."
    exit 1
fi

if [ ! -d "$BASE_DIR" ] || [ -z "$(ls -A "$BASE_DIR" 2>/dev/null)" ]; then
    echo "ℹ️  No active instances found to update."
    sleep 2
    exit 0
fi

echo "================================================================"
echo "       UPDATING ALL ANTIGRAVITY INSTANCES TO LATEST VERSION"
echo "================================================================"
echo ""

# Close all running Antigravity processes
pkill -f "Antigravity" 2>/dev/null || true

PROJECTS=($(ls "$BASE_DIR"))

for PROJECT_SLUG in "${PROJECTS[@]}"; do
    PROJECT_DIR="$BASE_DIR/$PROJECT_SLUG"
    DATA_DIR="$PROJECT_DIR/data"
    EXT_DIR="$PROJECT_DIR/extensions"

    # Find matching app bundle in /Applications
    APP_PATH=$(find /Applications -maxdepth 1 -iname "*$PROJECT_SLUG*" 2>/dev/null | head -n 1)

    if [ -n "$APP_PATH" ]; then
        echo "🔄 Updating code for: $(basename "$APP_PATH")..."

        # Overwrite app core code with the updated base version
        rsync -a --delete "$ORIGINAL_APP/" "$APP_PATH/"

        # Re-apply the launcher wrapper
        MAC_DIR="$APP_PATH/Contents/MacOS"
        PLIST="$APP_PATH/Contents/Info.plist"
        BIN_NAME=$(plutil -extract CFBundleExecutable raw "$PLIST" 2>/dev/null || echo "Antigravity IDE")

        mv "$MAC_DIR/$BIN_NAME" "$MAC_DIR/${BIN_NAME}_bin"

        cat << WRAPPER_EOF > "$MAC_DIR/$BIN_NAME"
#!/bin/bash
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
REAL_HOME="\$HOME"

export HOME="$PROJECT_DIR"

mkdir -p "\$HOME/Library"
ln -sf "\$REAL_HOME/Library/Keychains" "\$HOME/Library/Keychains" 2>/dev/null || true
ln -sf "\$REAL_HOME/.ssh" "\$HOME/.ssh" 2>/dev/null || true
ln -sf "\$REAL_HOME/.gitconfig" "\$HOME/.gitconfig" 2>/dev/null || true

exec -a "\$0" "\$DIR/${BIN_NAME}_bin" --user-data-dir="$DATA_DIR" --extensions-dir="$EXT_DIR" "\$@"
WRAPPER_EOF

        chmod +x "$MAC_DIR/$BIN_NAME"

        # Re-sign for macOS security
        xattr -cr "$APP_PATH" 2>/dev/null || true
        codesign --force --sign - "$MAC_DIR/${BIN_NAME}_bin" 2>/dev/null || true
        codesign --force --sign - "$APP_PATH" 2>/dev/null || true
    fi
done

echo ""
echo "================================================================"
echo " ✨ All instances have been successfully updated!"
echo " Your login sessions, MCP setups, and data remain untouched."
echo "================================================================"