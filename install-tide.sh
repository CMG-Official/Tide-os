#!/bin/bash

# Colors for styled output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Banner
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

# Variables
ZIP_URL="https://raw.githubusercontent.com/CMG-Official/Tide-os/refs/heads/main/Tide.zip"
TMP_ZIP="/tmp/Tide.zip"
UNZIP_DIR="/tmp/Tide_unzip"
DEST_DIR="/Applications"

# Ensure macOS system
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ Error: This installer is only for macOS systems${NC}"
    exit 1
fi

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ Error: curl is not installed${NC}"
    exit 1
fi

# Get admin privileges
echo -e "${YELLOW}🔐 Administrator access is required for installation...${NC}"
if ! sudo -v; then
    echo -e "${RED}❌ Error: Failed to obtain administrator privileges${NC}"
    exit 1
fi

# Download the zip
echo -e "${BLUE}⬇️  Downloading Tide.zip...${NC}"
if ! curl -L -o "$TMP_ZIP" "$ZIP_URL"; then
    echo -e "${RED}❌ Error: Failed to download the ZIP file${NC}"
    exit 1
fi

# Unzip
echo -e "${BLUE}🗜️  Unzipping...${NC}"
rm -rf "$UNZIP_DIR"
mkdir -p "$UNZIP_DIR"
unzip -q "$TMP_ZIP" -d "$UNZIP_DIR"

# Find the .app
APP_PATH=$(find "$UNZIP_DIR" -name "*.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Error: No .app file found in the ZIP archive${NC}"
    exit 1
fi

APP_NAME=$(basename "$APP_PATH")

# Move to /Applications
echo -e "${BLUE}📁 Moving ${APP_NAME} to Applications folder...${NC}"
if [ -d "$DEST_DIR/$APP_NAME" ]; then
    sudo rm -rf "$DEST_DIR/$APP_NAME"
fi
sudo mv -f "$APP_PATH" "$DEST_DIR/"

# Remove quarantine
echo -e "${BLUE}🔐 Removing quarantine flag...${NC}"
sudo xattr -dr com.apple.quarantine "$DEST_DIR/$APP_NAME"

# Cleanup
echo -e "${BLUE}🧼 Cleaning up temporary files...${NC}"
rm -rf "$TMP_ZIP" "$UNZIP_DIR"

# Launch the app
echo -e "${GREEN}✅ Installation complete! Launching ${APP_NAME}...${NC}"
open "$DEST_DIR/$APP_NAME"
