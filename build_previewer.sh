#!/bin/bash
set -e

echo "🚀 Building standalone macOS .app bundle for SimpleGUI RAD Code Explorer & Live Previewer..."

TARGET_FILE="vlang_simple_gui_previewer.v"
if [ ! -f "$TARGET_FILE" ]; then
    TARGET_FILE="demo_previewer.v"
fi

ICON_FILE="resources/developer.png"
if [ ! -f "$ICON_FILE" ]; then
    ICON_FILE="resources/icon.png"
fi

APP_NAME="V Code Previewer"

v run build.vsh "$TARGET_FILE" --name "$APP_NAME" --icon "$ICON_FILE" --out dist

echo "🎉 Build complete! Your standalone macOS application is ready at dist/${APP_NAME}.app"
