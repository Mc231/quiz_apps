#!/bin/bash
# Setup production environment files for Flags Quiz app
# This script creates env.json from the template for production builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================="
echo "  Flags Quiz Production Setup"
echo "=================================="
echo ""

# Setup env.json
ENV_FILE="$APP_DIR/config/env.json"
ENV_TEMPLATE="$APP_DIR/config/env.template.json"

if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}[!] config/env.json already exists${NC}"
    read -p "    Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "    Skipping env.json"
        exit 0
    fi
fi

cp "$ENV_TEMPLATE" "$ENV_FILE"
echo -e "${GREEN}[+] Created config/env.json from template${NC}"

echo ""
echo "=================================="
echo "  Setup Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit config/env.json with your production AdMob IDs"
echo "  2. For iOS, update ios/Flutter/AdMob.xcconfig with your App ID"
echo "  3. Run the app with:"
echo ""
echo "     flutter run --dart-define-from-file=config/env.json"
echo ""
echo "Note: For development, just run 'flutter run' - test IDs are used by default."
echo ""
