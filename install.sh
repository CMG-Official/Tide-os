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

if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This installer is only for MacOS systems${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}Administrator access is required for installation${NC}"
if ! sudo -v; then
    echo -e "${RED}Error: Failed to obtain administrator privileges${NC}"
    exit 1
fi

echo -e "${BLUE}Downloading Tide...${NC}"
TEMP_DMG=$(mktemp)

DOWNLOAD_URL="https://raw.githubusercontent.com/CMG-Official/Tide-os/refs/heads/main/Tide.zip"

if ! curl -L -o "$TEMP_DMG" "$DOWNLOAD_URL" 2>/dev/null; then
    echo -e "${RED}Error: Failed to download Tide${NC}"
    rm -f "$TEMP_DMG" 2>/dev/null
    exit 1
fi

echo -e "${BLUE}Installing Tide...${NC}"

if [ -d "/Applications/Tide.app" ]; then
    sudo rm -rf "/Applications/Tide.app"
fi

hdiutil attach -nobrowse -noautoopen "$TEMP_DMG" > /dev/null
MOUNT_POINT="/Volumes/Tide"

if [ ! -d "$MOUNT_POINT" ]; then
    echo -e "${RED}Error: Failed to mount disk image${NC}"
    rm -f "$TEMP_DMG" 2>/dev/null
    exit 1
fi

if [ ! -d "$MOUNT_POINT/Tide.app" ]; then
    echo -e "${RED}Error: Could not find Tide.app in the mounted image${NC}"
    hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1
    rm -f "$TEMP_DMG" 2>/dev/null
    exit 1
fi

if pgrep -f "Tide" > /dev/null; then
    echo -e "${YELLOW}Closing Tide...${NC}"
    osascript -e 'quit app "Tide"' 2>/dev/null
    sleep 2
fi

if [ -d "/Applications/Tide.app" ]; then
    sudo rm -rf "/Applications/Tide.app"
fi

if sudo /usr/bin/ditto -rsrc "$MOUNT_POINT/Tide.app" "/Applications/Tide.app"; then
    sudo chown -R $(whoami):staff "/Applications/Tide.app"
    sudo chmod -R 777 "/Applications/Tide.app"
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Tide.app
    echo -e "${GREEN}✓ Tide has been installed successfully!${NC}"
else
    echo -e "${RED}Error: Failed to install Tide${NC}"
    hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1
    rm -f "$TEMP_DMG" 2>/dev/null
    exit 1
fi

hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1
rm -f "$TEMP_DMG" 2>/dev/null

echo -e "${BLUE}Launching Tide...${NC}"
open -a "Tide"

echo -e "${GREEN}Installation complete! Enjoy using Tide!${NC}"
