#!/bin/bash

# Script untuk build Flutter Web dengan berbagai opsi
# Usage: ./build_web.sh [mode] [renderer]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}       Flutter Web Build Script               ${NC}"
echo -e "${GREEN}=================================================${NC}\n"

# Default values
MODE=${1:-release}
RENDERER=${2:-canvaskit}
API_BASE_URL=${API_BASE_URL:-https://api.example.com}

echo -e "${YELLOW}Build Configuration:${NC}"
echo -e "  Mode: ${GREEN}$MODE${NC}"
echo -e "  Renderer: ${GREEN}$RENDERER${NC}"
echo -e "  API Base URL: ${GREEN}$API_BASE_URL${NC}\n"

# Clean build
echo -e "${YELLOW}Cleaning previous build...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Build based on mode
echo -e "\n${YELLOW}Building web app...${NC}"

case $MODE in
  debug)
    flutter build web \
      --web-renderer $RENDERER \
      --dart-define=API_BASE_URL=$API_BASE_URL
    ;;
    
  profile)
    flutter build web \
      --profile \
      --web-renderer $RENDERER \
      --dart-define=API_BASE_URL=$API_BASE_URL \
      --source-maps
    ;;
    
  release)
    flutter build web \
      --release \
      --web-renderer $RENDERER \
      --dart-define=API_BASE_URL=$API_BASE_URL \
      --tree-shake-icons
    ;;
    
  *)
    echo -e "${RED}Invalid mode: $MODE${NC}"
    echo -e "Valid modes: debug, profile, release"
    exit 1
    ;;
esac

# Calculate build size
echo -e "\n${YELLOW}Build completed!${NC}"
BUILD_SIZE=$(du -sh build/web 2>/dev/null | cut -f1)
echo -e "Build size: ${GREEN}$BUILD_SIZE${NC}"

# Show main.dart.js size
if [ -f "build/web/main.dart.js" ]; then
  MAIN_SIZE=$(du -h build/web/main.dart.js | cut -f1)
  echo -e "Main JS size: ${GREEN}$MAIN_SIZE${NC}"
fi

# Instructions
echo -e "\n${GREEN}Build successful!${NC}\n"
echo -e "${YELLOW}To test locally:${NC}"
echo -e "  cd build/web"
echo -e "  python3 -m http.server 8000"
echo -e "  Open: ${GREEN}http://localhost:8000${NC}\n"

echo -e "${YELLOW}To deploy:${NC}"
echo -e "  Firebase:  ${GREEN}firebase deploy --only hosting${NC}"
echo -e "  Netlify:   ${GREEN}netlify deploy --dir=build/web --prod${NC}"
echo -e "  Vercel:    ${GREEN}vercel --prod build/web${NC}\n"
