#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
████████╗██╗██████╗░███████╗
╚══██╔══╝██║██╔══██╗██╔════╝
░░░██║░░░██║██║░░██║█████╗░░
░░░██║░░░██║██║░░██║██╔══╝░░
░░░██║░░░██║██████╔╝███████╗
░░░╚═╝░░░╚═╝╚═════╝░╚══════╝
EOF
echo -e "${NC}"

ZIP_URL="https://raw.githubusercontent.com/CMG-Official/Tide-os/refs/heads/main/Tide.zip"
TMP_ZIP="/tmp/Tide.zip"
UNZIP_DIR="/tmp/Tide_unzip"
APP_NAME="Tide.app"
DEST_DIR="/Applications"

if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ Error: This installer is only for macOS systems${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ Error: curl is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}🔐 Administrator access is required for installation${NC}"
if ! sudo -v; then
    echo -e "${RED}❌ Error: Failed to obtain administrator privileges${NC}"
    exit 1
fi

echo -e "${BLUE}⬇️  Downloading Tide...${NC}"
if ! curl -L -o "$TMP_ZIP" "$ZIP_URL"; then
    echo -e "${RED}❌ Error: Failed to download Tide.zip${NC}"
    exit 1
fi

echo -e "${BLUE}🗜️  Unzipping Tide...${NC}"
rm -rf "$UNZIP_DIR"
mkdir -p "$UNZIP_DIR"
unzip -q "$TMP_ZIP" -d "$UNZIP_DIR"

MACOSX_FOLDER="$UNZIP_DIR/__MACOSX"
if [ -d "$MACOSX_FOLDER" ]; then
    echo -e "${YELLOW}🧹 Removing __MACOSX folder...${NC}"
    rm -rf "$MACOSX_FOLDER"
fi

echo -e "${BLUE}📁 Moving Tide to Applications...${NC}"
if [ -d "$DEST_DIR/$APP_NAME" ]; then
    sudo rm -rf "$DEST_DIR/$APP_NAME"
fi
sudo mv -f "$UNZIP_DIR/$APP_NAME" "$DEST_DIR/$APP_NAME"

echo -e "${BLUE}🔐 Removing quarantine flag...${NC}"
sudo xattr -dr com.apple.quarantine "$DEST_DIR/$APP_NAME"

echo -e "${BLUE}🧼 Cleaning up temporary files...${NC}"
rm -rf "$TMP_ZIP" "$UNZIP_DIR"

echo -e "${GREEN}✅ Tide is installed and ready in Applications.${NC}"
echo -e "${BLUE}🚀 Launching Tide...${NC}"
open "$DEST_DIR/$APP_NAME"
