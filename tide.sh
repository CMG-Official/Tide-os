#!/bin/bash

ZIP_URL="https://raw.githubusercontent.com/CMG-Official/Tide-os/refs/heads/main/Tide.zip"
TMP_ZIP="/tmp/Tide.zip"
UNZIP_DIR="/tmp/Tide_unzip"
APP_NAME="Tide.app"
DEST_DIR="/Applications"

echo "⬇️ Downloading app zip..."
curl -L -o "$TMP_ZIP" "$ZIP_URL"

echo "🗜 Unzipping..."
rm -rf "$UNZIP_DIR"
mkdir -p "$UNZIP_DIR"
unzip -q "$TMP_ZIP" -d "$UNZIP_DIR"

# 🧹 Delete __MACOSX if it appears
MACOSX_FOLDER="$UNZIP_DIR/__MACOSX"
if [ -d "$MACOSX_FOLDER" ]; then
  echo "🧹 Removing __MACOSX folder..."
  rm -rf "$MACOSX_FOLDER"
fi

echo "📁 Moving app to Applications..."
sudo mv -f "$UNZIP_DIR/$APP_NAME" "$DEST_DIR/$APP_NAME"

echo "🔐 Removing quarantine flag..."
sudo xattr -dr com.apple.quarantine "$DEST_DIR/$APP_NAME"

echo "🧼 Cleaning up temp files..."
rm -rf "$TMP_ZIP" "$UNZIP_DIR"

echo "✅ App is ready in Applications."
echo "🚀 Launching app..."
open "$DEST_DIR/$APP_NAME"
