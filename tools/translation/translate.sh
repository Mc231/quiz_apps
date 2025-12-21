#!/bin/bash
# Translation wrapper script for quiz apps
# This script makes it easy to translate ARB files from any app

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <source_arb_file> [output_directory]"
    echo ""
    echo "Translates an English ARB file to 60+ languages using AWS Translate."
    echo ""
    echo "Arguments:"
    echo "  source_arb_file    Path to the English ARB file (e.g., lib/l10n/app_en.arb)"
    echo "  output_directory   (Optional) Directory for translated files. Defaults to source directory."
    echo ""
    echo "Examples:"
    echo "  # From within an app directory:"
    echo "  $0 lib/l10n/app_en.arb"
    echo ""
    echo "  # From monorepo root:"
    echo "  $0 apps/flagsquiz/lib/l10n/app_en.arb"
    echo ""
    echo "  # Specify custom output directory:"
    echo "  $0 lib/l10n/app_en.arb lib/l10n/generated"
    echo ""
    echo "Prerequisites:"
    echo "  - Python 3 installed"
    echo "  - boto3 installed (pip3 install boto3)"
    echo "  - AWS credentials configured (~/.aws/credentials)"
    echo "  - AWS Translate access enabled"
    exit 1
}

# Check if help requested
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    usage
fi

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed${NC}"
    echo "Install it with: brew install python3"
    exit 1
fi

# Check if boto3 is installed
if ! python3 -c "import boto3" 2>/dev/null; then
    echo -e "${RED}Error: boto3 is not installed${NC}"
    echo "Install it with: pip3 install boto3"
    exit 1
fi

# Check if AWS credentials are configured
if [[ ! -f ~/.aws/credentials && -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo -e "${YELLOW}Warning: AWS credentials not found${NC}"
    echo "Configure with: aws configure"
    echo "Or set environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
fi

SOURCE_FILE="$1"
OUTPUT_DIR="${2:-$(dirname "$SOURCE_FILE")}"

# Verify source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo -e "${RED}Error: Source file not found: $SOURCE_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Starting translation...${NC}"
echo "Source: $SOURCE_FILE"
echo "Output: $OUTPUT_DIR"
echo ""

# Run the translation script
python3 "$SCRIPT_DIR/translate_all.py" "$SOURCE_FILE" "$OUTPUT_DIR"

if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ Translation completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the generated files in: $OUTPUT_DIR"
    echo "2. Run 'flutter gen-l10n' to generate Dart code"
    echo "3. Restart your app to see the translations"
else
    echo ""
    echo -e "${RED}✗ Translation failed${NC}"
    exit 1
fi
