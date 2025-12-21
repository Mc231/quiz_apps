#!/bin/bash
# Quiz App Generator for Monorepo
# Usage: ./create_quiz_app.sh "AppName" "app_name" "com.yourcompany"

APP_NAME=$1
APP_ID=$2
BUNDLE_ID=$3
SCRIPT_DIR=$(dirname "$0")
MONOREPO_ROOT="$SCRIPT_DIR/.."
NEW_APP_DIR="$MONOREPO_ROOT/apps/${APP_ID}"

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
cd "$MONOREPO_ROOT/apps"
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

  # Quiz Engine - using local path dependencies
  quiz_engine:
    path: ../../packages/quiz_engine

  quiz_engine_core:
    path: ../../packages/quiz_engine_core

  # Shared services
  shared_services:
    path: ../../packages/shared_services

  # Other dependencies
  responsive_builder: ^0.7.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
  coverage: ^1.6.0

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
mkdir -p test/models
mkdir -p test/widgets

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
  },
  "startQuiz": "Start Quiz",
  "@startQuiz": {
    "description": "Button text to start the quiz"
  },
  "score": "Score: {current}/{total}",
  "@score": {
    "description": "Display current score",
    "placeholders": {
      "current": {
        "type": "int"
      },
      "total": {
        "type": "int"
      }
    }
  }
}
EOF

# Create basic main.dart template
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Quiz App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement quiz start
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quiz coming soon!')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Start Quiz', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Create sample model template
cat > lib/models/quiz_item.dart << 'EOF'
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// Sample model for quiz items
/// Customize this based on your quiz type
class QuizItem {
  static const _keyId = 'id';
  static const _keyName = 'name';
  // Add more keys as needed

  final String id;
  final String name;
  // Add more fields as needed

  QuizItem({
    required this.id,
    required this.name,
  });

  /// Creates a QuizItem from JSON
  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: json[_keyId] as String,
      name: json[_keyName] as String,
    );
  }

  /// Converts to QuestionEntry for quiz engine
  QuestionEntry get toQuestionEntry {
    return QuestionEntry(
      // TODO: Choose appropriate question type:
      // - ImageQuestion('path/to/image.png')
      // - TextQuestion('Question text')
      // - AudioQuestion('path/to/audio.mp3')
      // - VideoQuestion('path/to/video.mp4')
      type: TextQuestion(name),
      otherOptions: {
        "id": id,
        "name": name,
        "correctAnswer": name,
      },
    );
  }
}
EOF

# Create sample data file
cat > assets/data/sample_data.json << 'EOF'
[
  {
    "id": "item1",
    "name": "Sample Item 1"
  },
  {
    "id": "item2",
    "name": "Sample Item 2"
  },
  {
    "id": "item3",
    "name": "Sample Item 3"
  }
]
EOF

# Create README for the app
cat > README.md << EOF
# $APP_NAME

A quiz application built with the quiz_engine framework.

## Getting Started

1. Add your data to \`assets/data/\`
2. Update the model in \`lib/models/\`
3. Add images/audio/video to \`assets/images/\`
4. Customize the UI in \`lib/ui/\`
5. Update localization in \`lib/l10n/\`

## Running

\`\`\`bash
flutter pub get
flutter run
\`\`\`

## Testing

\`\`\`bash
flutter test
\`\`\`

## Building

\`\`\`bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build macos        # macOS
\`\`\`

## See Also

- [Quiz App Template](../../docs/QUIZ_APP_TEMPLATE.md)
- [Monetization Guide](../../docs/MONETIZATION_GUIDE.md)
- [App Ideas](../../docs/APP_IDEAS.md)
- [Development Guide](../../docs/DEVELOPMENT_GUIDE.md)
EOF

echo "✅ Created new quiz app: $APP_NAME"
echo ""
echo "📝 Next steps:"
echo "1. cd $NEW_APP_DIR"
echo "2. flutter pub get"
echo "3. Update lib/models/quiz_item.dart for your domain"
echo "4. Add your data to assets/data/"
echo "5. Add your assets to assets/images/"
echo "6. Update lib/main.dart to load and display your quiz"
echo "7. flutter run"
echo ""
echo "📚 Documentation:"
echo "- Quiz App Template: $MONOREPO_ROOT/docs/QUIZ_APP_TEMPLATE.md"
echo "- Monetization Guide: $MONOREPO_ROOT/docs/MONETIZATION_GUIDE.md"
echo "- App Ideas: $MONOREPO_ROOT/docs/APP_IDEAS.md"
echo ""
echo "🔄 Don't forget to run 'melos bootstrap' from the monorepo root!"
echo ""
echo "Happy coding! 🚀"
