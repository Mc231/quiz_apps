# Quiz Apps Monorepo Development Guide

Complete guide for developing quiz apps in the monorepo using Android Studio, Melos, and Flutter.

## Table of Contents
- [Initial Setup](#initial-setup)
- [Android Studio Configuration](#android-studio-configuration)
- [Melos Commands](#melos-commands)
- [Development Workflow](#development-workflow)
- [Creating a New Quiz App](#creating-a-new-quiz-app)
- [Testing](#testing)
- [Building & Deployment](#building--deployment)
- [Troubleshooting](#troubleshooting)

---

## Initial Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio (latest stable)
- Xcode (for macOS/iOS development)
- Git

### First-Time Setup

1. **Clone the repository:**
```bash
git clone <repository-url>
cd quiz_apps
```

2. **Install Melos globally:**
```bash
dart pub global activate melos
```

Add to your PATH if needed:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

3. **Bootstrap the monorepo:**
```bash
melos bootstrap
```

This command will:
- Run `pub get` in all packages
- Link local dependencies
- Generate necessary files

4. **Verify setup:**
```bash
melos run analyze
```

---

## Android Studio Configuration

### Opening the Project

**Option 1: Open Individual Apps (Recommended for Development)**

1. Open Android Studio
2. File → Open
3. Navigate to `quiz_apps/apps/flagsquiz/`
4. Click "Open"
5. Wait for indexing to complete

This gives you full IDE support for the app, including hot reload.

**Option 2: Open Entire Monorepo (For Multi-Package Editing)**

1. Open Android Studio
2. File → Open
3. Navigate to `quiz_apps/`
4. Click "Open"

Note: This opens the root directory, but you may need to configure run configurations manually.

### Creating Run Configurations

#### For Individual Apps:

1. Run → Edit Configurations
2. Click "+" → Flutter
3. Configure:
   - **Name:** flagsquiz
   - **Dart entrypoint:** `apps/flagsquiz/lib/main.dart`
   - **Working directory:** `$PROJECT_DIR$/apps/flagsquiz`
   - **Additional run args:** (optional)

4. Click "Apply" and "OK"

#### For Running Tests:

1. Run → Edit Configurations
2. Click "+" → Flutter Test
3. Configure:
   - **Name:** All Tests
   - **Test scope:** Directory
   - **Directory:** `$PROJECT_DIR$`

### Flutter Plugin Settings

1. Settings/Preferences → Languages & Frameworks → Flutter
2. Set Flutter SDK path
3. Enable:
   - ✅ Format code on save
   - ✅ Organize imports on save
   - ✅ Perform hot reload on save

### Code Style

1. Settings/Preferences → Editor → Code Style → Dart
2. Import scheme from: `flutter` (if available)
3. Line length: 80
4. Continuation indent: 4

---

## Melos Commands

### Essential Commands

**Bootstrap (after pulling changes):**
```bash
melos bootstrap
```

**Get dependencies:**
```bash
melos run get
```

**Run all tests:**
```bash
melos run test
```

**Analyze code:**
```bash
melos run analyze
```

**Format code:**
```bash
melos run format
```

**Clean all packages:**
```bash
melos run clean
```

**Build all apps:**
```bash
melos run build
```

### Package-Specific Commands

**Run command in specific package:**
```bash
melos exec --scope=flagsquiz -- flutter test
```

**Run command in all packages:**
```bash
melos exec -- flutter pub get
```

**Run command in packages with tests:**
```bash
melos exec --dir-exists=test -- flutter test
```

### Custom Scripts

You can add custom scripts to `melos.yaml`:

```yaml
scripts:
  test:unit:
    description: Run unit tests only
    run: melos exec -- flutter test test/unit

  build:ios:
    description: Build iOS apps
    run: melos exec -c 1 -- flutter build ios
    packageFilters:
      dirExists: ios
```

---

## Development Workflow

### Daily Workflow

1. **Pull latest changes:**
```bash
git pull
melos bootstrap
```

2. **Create feature branch:**
```bash
git checkout -b feature/my-new-feature
```

3. **Make changes** in Android Studio

4. **Run tests frequently:**
```bash
melos run test
# Or test specific package
melos exec --scope=quiz_engine -- flutter test
```

5. **Format and analyze:**
```bash
melos run format
melos run analyze
```

6. **Commit changes:**
```bash
git add .
git commit -m "feat: add new feature"
```

7. **Push and create PR:**
```bash
git push origin feature/my-new-feature
```

### Working with Packages

#### Editing `quiz_engine_core`:

1. Make changes in `packages/quiz_engine_core/lib/`
2. Tests are in `packages/quiz_engine_core/test/`
3. Run tests:
```bash
cd packages/quiz_engine_core
flutter test --coverage
```

4. Changes are immediately available to all apps (via path dependencies)

#### Editing `quiz_engine`:

1. Make changes in `packages/quiz_engine/lib/`
2. Run the example app to test:
```bash
cd packages/quiz_engine
flutter run
```

3. Or run tests:
```bash
flutter test
```

#### Editing `flagsquiz` app:

1. Open in Android Studio: `apps/flagsquiz/`
2. Make changes
3. Hot reload (r) or hot restart (R)
4. Run tests:
```bash
cd apps/flagsquiz
flutter test
```

### Making Cross-Package Changes

If you need to change both `quiz_engine_core` and `quiz_engine`:

1. Make changes to `quiz_engine_core`
2. Bump version in `quiz_engine_core/pubspec.yaml`
3. Make changes to `quiz_engine`
4. Test in `flagsquiz` app
5. Commit all changes together

---

## Creating a New Quiz App

### Using the Generator Script

1. **Run the generator:**
```bash
cd quiz_apps/tools
./create_quiz_app.sh "Capital Quiz" "capital_quiz" "com.yourcompany.capitalquiz"
```

2. **The script creates:**
```
apps/capital_quiz/
├── android/
├── ios/
├── lib/
│   ├── models/
│   ├── ui/
│   ├── extensions/
│   ├── l10n/
│   └── main.dart
├── assets/
│   ├── images/
│   └── data/
├── test/
├── pubspec.yaml
└── l10n.yaml
```

3. **Bootstrap new app:**
```bash
cd ../..
melos bootstrap
```

4. **Open in Android Studio:**
```bash
open -a "Android Studio" apps/capital_quiz
```

### Manual Creation

If you need to create an app manually:

1. **Create Flutter app:**
```bash
cd apps
flutter create capital_quiz
cd capital_quiz
```

2. **Update `pubspec.yaml`:**
```yaml
dependencies:
  quiz_engine:
    path: ../../packages/quiz_engine
  quiz_engine_core:
    path: ../../packages/quiz_engine_core
```

3. **Create directory structure:**
```bash
mkdir -p lib/{models,ui,extensions,l10n}
mkdir -p assets/{images,data}
```

4. **Bootstrap:**
```bash
cd ../..
melos bootstrap
```

### Setting Up Your Domain Model

See `docs/QUIZ_APP_TEMPLATE.md` for detailed examples.

Example `lib/models/capital.dart`:
```dart
import 'package:quiz_engine_core/quiz_engine_core.dart';

class Capital {
  final String countryName;
  final String capitalName;
  final String countryCode;

  Capital.fromJson(Map json)
      : countryName = json['country'] as String,
        capitalName = json['capital'] as String,
        countryCode = json['code'] as String;

  QuestionEntry get toQuestionEntry {
    return QuestionEntry(
      type: ImageQuestion('assets/images/$countryCode.png'),
      otherOptions: {
        "id": countryCode,
        "name": capitalName,
        "correctAnswer": capitalName,
      },
    );
  }
}
```

---

## Testing

### Running Tests

**All tests in monorepo:**
```bash
melos run test
```

**Specific package:**
```bash
melos exec --scope=quiz_engine_core -- flutter test
```

**With coverage:**
```bash
cd packages/quiz_engine_core
flutter test --coverage
```

**View coverage report:**
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Structure

```
test/
├── unit/           # Business logic tests
├── widgets/        # Widget tests
├── integration/    # Integration tests
└── fixtures/       # Test data
```

### Writing Widget Tests

Example:
```dart
testWidgets('QuizWidget displays question', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: QuizWidget(
        entries: testEntries,
        title: 'Test Quiz',
      ),
    ),
  );

  expect(find.text('Test Quiz'), findsOneWidget);
});
```

### Mocking with Mockito

Generate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Building & Deployment

### Local Builds

**Android APK:**
```bash
cd apps/flagsquiz
flutter build apk
```

**iOS (requires macOS):**
```bash
flutter build ios
```

**Web:**
```bash
flutter build web
```

**macOS:**
```bash
flutter build macos
```

### Release Builds

**Android:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ipa --release
```

### Using CI/CD

The monorepo includes GitHub Actions workflows:

- `.github/workflows/tests.yml` - Run tests on PR
- `.github/workflows/deploy_android.yml` - Deploy to Play Store
- `.github/workflows/deploy_ios.yml` - Deploy to App Store
- `.github/workflows/deploy_web.yml` - Deploy to hosting
- `.github/workflows/deploy_mac_os.yml` - Deploy macOS app

Trigger via:
- Push to `main` branch
- Create release tag
- Manual workflow dispatch

---

## Troubleshooting

### Common Issues

#### 1. Packages Not Found

**Symptom:** `Error: Could not find package quiz_engine_core`

**Solution:**
```bash
melos clean
melos bootstrap
```

#### 2. Android Studio Not Recognizing Packages

**Symptom:** Red underlines on imports

**Solution:**
1. File → Invalidate Caches and Restart
2. Run `melos bootstrap`
3. Flutter → Get Dependencies (in IDE)

#### 3. Melos Command Not Found

**Symptom:** `melos: command not found`

**Solution:**
```bash
dart pub global activate melos
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Add export to `~/.bashrc` or `~/.zshrc` for persistence.

#### 4. Version Conflicts

**Symptom:** `version solving failed`

**Solution:**
1. Check SDK constraints in all `pubspec.yaml` files
2. Ensure compatible dependency versions
3. Run `melos clean && melos bootstrap`

#### 5. Hot Reload Not Working

**Symptom:** Changes not appearing

**Solution:**
1. Try hot restart (R) instead of hot reload (r)
2. Rebuild the app
3. Check you're editing the correct file (path dependencies)

#### 6. Tests Failing After Update

**Symptom:** Tests pass locally but fail in CI

**Solution:**
1. Check Flutter version matches CI
2. Run `melos bootstrap` to regenerate lockfiles
3. Check for platform-specific code

#### 7. Build Failures

**Symptom:** Build fails with gradle/cocoapods errors

**Solution:**

Android:
```bash
cd apps/flagsquiz/android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

iOS:
```bash
cd apps/flagsquiz/ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

---

## Best Practices

### Code Organization

```
apps/
  flagsquiz/
    lib/
      models/         # Data models
      ui/             # UI screens
      extensions/     # Extension methods
      l10n/           # Localization files
      main.dart       # App entry point

packages/
  quiz_engine_core/
    lib/
      src/            # Implementation
      quiz_engine_core.dart  # Public API
    test/             # Tests

  quiz_engine/
    lib/
      src/            # Implementation
      quiz_engine.dart  # Public API
    test/             # Tests
```

### Commit Messages

Follow conventional commits:
```
feat: add new feature
fix: fix bug
docs: update documentation
test: add tests
refactor: refactor code
style: format code
chore: update dependencies
```

### Branching Strategy

```
main              # Production-ready code
  ├─ develop      # Integration branch
      ├─ feature/quiz-audio-support
      ├─ feature/new-app-capitals
      └─ fix/quiz-layout-bug
```

### Version Bumping

When updating packages:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Tag release:
```bash
git tag packages/quiz_engine_core/v1.1.0
git push --tags
```

### Code Review Checklist

- [ ] Tests pass (`melos run test`)
- [ ] Code formatted (`melos run format`)
- [ ] No analyzer warnings (`melos run analyze`)
- [ ] Updated documentation
- [ ] Added tests for new features
- [ ] Updated CHANGELOG.md
- [ ] Bumped version if needed

---

## Android Studio Tips

### Keyboard Shortcuts (macOS)

- **Hot Reload:** `Cmd + \`
- **Hot Restart:** `Cmd + Shift + \`
- **Run:** `Ctrl + R`
- **Debug:** `Ctrl + D`
- **Find:** `Cmd + F`
- **Search Everywhere:** `Shift + Shift`
- **Go to Declaration:** `Cmd + B`
- **Quick Fix:** `Option + Enter`

### Useful Plugins

1. **Flutter** - Official Flutter plugin
2. **Dart** - Official Dart plugin
3. **Rainbow Brackets** - Matching bracket colors
4. **Key Promoter X** - Learn keyboard shortcuts
5. **GitToolBox** - Enhanced Git integration

### Productivity Features

**Live Templates:**
1. Type `stless` + Tab → StatelessWidget
2. Type `stful` + Tab → StatefulWidget
3. Type `test` + Tab → test boilerplate

**Code Actions:**
- `Option + Enter` on widget → Wrap with Container, Padding, etc.
- `Cmd + Option + L` → Reformat code
- `Cmd + Option + O` → Optimize imports

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Melos Documentation](https://melos.invertase.dev/)
- [Quiz App Template](/docs/QUIZ_APP_TEMPLATE.md)
- [Monetization Guide](/docs/MONETIZATION_GUIDE.md)
- [App Ideas](/docs/APP_IDEAS.md)

---

## Getting Help

**Check documentation first:**
1. This guide
2. `docs/QUIZ_APP_TEMPLATE.md`
3. Package README files

**Still stuck?**
1. Check existing issues in repository
2. Create new issue with:
   - What you're trying to do
   - What you expected
   - What actually happened
   - Steps to reproduce
   - Environment (Flutter version, OS, etc.)

---

Happy coding! 🚀
