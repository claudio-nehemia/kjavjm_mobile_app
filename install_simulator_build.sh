#!/bin/bash

# Script untuk install iOS Simulator Build dari Codemagic
# Usage: ./install_simulator_build.sh [path-to-zip-file]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  iOS Simulator Build Installer for Codemagic  ${NC}"
echo -e "${GREEN}=================================================${NC}\n"

# Check if zip file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide path to the zip file${NC}"
    echo "Usage: ./install_simulator_build.sh path/to/ios-simulator-app.zip"
    exit 1
fi

ZIP_FILE="$1"

# Check if file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}Error: File not found: $ZIP_FILE${NC}"
    exit 1
fi

# Extract zip file
echo -e "${YELLOW}Extracting $ZIP_FILE...${NC}"
TEMP_DIR=$(mktemp -d)
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

# Find the .app file
APP_FILE=$(find "$TEMP_DIR" -name "*.app" -type d | head -n 1)

if [ -z "$APP_FILE" ]; then
    echo -e "${RED}Error: No .app file found in the zip${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}Found: $(basename "$APP_FILE")${NC}\n"

# List available simulators
echo -e "${YELLOW}Available Simulators:${NC}"
xcrun simctl list devices available | grep -E "iPhone|iPad" | nl

# Check if any simulator is booted
BOOTED_SIMULATOR=$(xcrun simctl list devices | grep "Booted" | head -n 1)

if [ -z "$BOOTED_SIMULATOR" ]; then
    echo -e "\n${YELLOW}No simulator is currently running.${NC}"
    echo -e "${YELLOW}Starting default simulator...${NC}"
    
    # Boot default simulator (iPhone 15 Pro if available, or first iPhone)
    DEFAULT_DEVICE=$(xcrun simctl list devices available | grep "iPhone 15 Pro" | head -n 1 | sed 's/.*(\(.*\)).*/\1/')
    
    if [ -z "$DEFAULT_DEVICE" ]; then
        DEFAULT_DEVICE=$(xcrun simctl list devices available | grep "iPhone" | head -n 1 | sed 's/.*(\(.*\)).*/\1/')
    fi
    
    if [ -n "$DEFAULT_DEVICE" ]; then
        xcrun simctl boot "$DEFAULT_DEVICE"
        open -a Simulator
        echo -e "${GREEN}Simulator started!${NC}"
        sleep 5
    else
        echo -e "${RED}Error: No suitable simulator found${NC}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

# Install the app
echo -e "\n${YELLOW}Installing app to simulator...${NC}"
xcrun simctl install booted "$APP_FILE"

# Get bundle identifier
BUNDLE_ID=$(defaults read "$APP_FILE/Info.plist" CFBundleIdentifier)

echo -e "${GREEN}App installed successfully!${NC}"
echo -e "Bundle ID: ${YELLOW}$BUNDLE_ID${NC}\n"

# Ask if user wants to launch the app
read -p "Do you want to launch the app? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Launching app...${NC}"
    xcrun simctl launch booted "$BUNDLE_ID"
    echo -e "${GREEN}App launched!${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}Done!${NC}"
echo -e "${YELLOW}To uninstall later, run:${NC}"
echo -e "  xcrun simctl uninstall booted $BUNDLE_ID"
