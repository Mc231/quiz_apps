#!/bin/bash
# Quiz App Generator
# Usage: ./create_quiz_app.sh "AppName" "app_name" "com.yourcompany"

APP_NAME=$1
APP_ID=$2
BUNDLE_ID=$3
BASE_DIR=$(dirname "$0")/..
NEW_APP_DIR="$BASE_DIR/../${APP_ID}"

if [ -z "$APP_NAME" ] || [ -z "$APP_ID" ] || [ -z "$BUNDLE_ID" ]; then
    echo "Usage: $0 'Display Name' 'app_id' 'com.bundle.id'"
    echo "Example: $0 'Capital Quiz' 'capital_quiz' 'com.mycompany.capitalquiz'"
    exit 1
fi

echo "🎯 Creating new quiz app: $APP_NAME"
echo "📁 Directory: $NEW_APP_DIR"
echo "📦 Bundle ID: $BUNDLE_ID"
echo ""

# Create new Flutter project
cd "$BASE_DIR/.."
flutter create --org "$BUNDLE_ID" "$APP_ID"

cd "$NEW_APP_DIR"

# Copy shared dependencies
echo "📋 Copying dependencies..."
cat > pubspec.yaml << EOF
name: $APP_ID
description: $APP_NAME - A quiz application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Quiz Engine
  quiz_engine:
    git:
      url: https://github.com/Mc231/quiz_engine.git
      # Or use path during development:
      # path: ../quiz_engine

  quiz_engine_core:
    git:
      url: https://github.com/Mc231/quiz_engine_core.git
      # Or use path during development:
      # path: ../quiz_engine_core

  # Other dependencies from flagsquiz
  responsive_builder: ^0.7.0
  # Add others as needed

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/data/
EOF

# Create basic structure
mkdir -p lib/models
mkdir -p lib/ui
mkdir -p lib/extensions
mkdir -p lib/l10n
mkdir -p assets/images
mkdir -p assets/data
mkdir -p test

# Create l10n configuration
cat > l10n.yaml << EOF
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
EOF

# Create basic ARB file
cat > lib/l10n/app_en.arb << EOF
{
  "@@locale": "en",
  "appTitle": "$APP_NAME",
  "@appTitle": {
    "description": "The title of the application"
  },
  "gameOver": "Game Over!",
  "@gameOver": {
    "description": "Displayed when quiz is complete"
  }
}
EOF

echo "✅ Created new quiz app: $APP_NAME"
echo ""
echo "📝 Next steps:"
echo "1. cd $NEW_APP_DIR"
echo "2. Add your domain models to lib/models/"
echo "3. Add your data to assets/data/"
echo "4. Add your assets to assets/images/"
echo "5. Update lib/main.dart"
echo "6. flutter pub get"
echo "7. flutter run"
echo ""
echo "Happy coding! 🚀"
