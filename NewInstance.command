#!/bin/bash

# ==============================================================================
# INSTANCE GENERATOR - ANTIGRAVITY IDE (KEYCHAIN SYM-LINK + FULL MCP ISOLATION)
# ==============================================================================

clear
ORIGINAL_APP="/Applications/Antigravity IDE.app"
BASE_DIR="$HOME/.antigravity-projetos"

if [ ! -d "$ORIGINAL_APP" ]; then
    echo "❌ Error: 'Antigravity IDE.app' not found in /Applications."
    exit 1
fi

# Prompt user for project name
PROJECT_NAME=$(osascript -e 'Tell application "System Events" to display dialog "Enter the name for the new project/instance:" default answer "" with title "Antigravity IDE - New Instance"' -e 'text returned of result' 2>/dev/null)

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Creation canceled."
    exit 0
fi

# Sanitize the name for folder usage
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | iconv -t ascii//TRANSLIT 2>/dev/null | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')

PROJECT_DIR="$BASE_DIR/$PROJECT_SLUG"
DATA_DIR="$PROJECT_DIR/data"
EXT_DIR="$PROJECT_DIR/extensions"
mkdir -p "$DATA_DIR" "$EXT_DIR"

NEW_APP_PATH="/Applications/Antigravity - $PROJECT_NAME.app"

echo "⚙️ Cloning app structure to /Applications..."
rm -rf "$NEW_APP_PATH"
rsync -a "$ORIGINAL_APP/" "$NEW_APP_PATH/"

echo "⚙️ Configuring launcher wrapper with Keychain symlink & MCP isolation..."
MAC_DIR="$NEW_APP_PATH/Contents/MacOS"
PLIST="$NEW_APP_PATH/Contents/Info.plist"
BIN_NAME=$(plutil -extract CFBundleExecutable raw "$PLIST" 2>/dev/null || echo "Antigravity IDE")

mv "$MAC_DIR/$BIN_NAME" "$MAC_DIR/${BIN_NAME}_bin"

# The wrapper sets an isolated HOME so MCP stays 100% separate,
# while symlinking system essentials so Keychain, Git, and SSH work natively.
cat << WRAPPER_EOF > "$MAC_DIR/$BIN_NAME"
#!/bin/bash
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
REAL_HOME="\$HOME"

# 1. Set isolated HOME directory so MCP configs stay strictly separated
export HOME="$PROJECT_DIR"

# 2. Symlink macOS Keychain & system configs to prevent security dialogs
mkdir -p "\$HOME/Library"
ln -sf "\$REAL_HOME/Library/Keychains" "\$HOME/Library/Keychains" 2>/dev/null || true
ln -sf "\$REAL_HOME/.ssh" "\$HOME/.ssh" 2>/dev/null || true
ln -sf "\$REAL_HOME/.gitconfig" "\$HOME/.gitconfig" 2>/dev/null || true

# 3. Launch isolated binary
exec -a "\$0" "\$DIR/${BIN_NAME}_bin" --user-data-dir="$DATA_DIR" --extensions-dir="$EXT_DIR" "\$@"
WRAPPER_EOF

chmod +x "$MAC_DIR/$BIN_NAME"

echo "🔐 Re-signing application for macOS compatibility..."
xattr -cr "$NEW_APP_PATH" 2>/dev/null || true
codesign --force --sign - "$MAC_DIR/${BIN_NAME}_bin" 2>/dev/null || true
codesign --force --sign - "$NEW_APP_PATH" 2>/dev/null || true

echo "🚀 Launching instance '$PROJECT_NAME'..."
open -a "$NEW_APP_PATH"

echo ""
echo "================================================================"
echo " ✨ Instance 'Antigravity - $PROJECT_NAME' is ready!"
echo " MCP is now 100% isolated per instance, with working Keychain."
echo "================================================================"