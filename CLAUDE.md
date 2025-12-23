# Claude Code Guide - Quiz Apps Monorepo

This document helps AI assistants work efficiently with this Flutter quiz apps monorepo.

---

## Primary Workflow: Architecture Implementation

**The main task is implementing features from `docs/CORE_ARCHITECTURE_GUIDE.md`.**

### How It Works

1. **User requests a sprint/task** from the architecture guide (e.g., "implement Sprint 5.2")
2. **Read the guide** to understand the task requirements and expected deliverables
3. **Implement the code** following the specifications in the guide
4. **Write tests** for all new code
5. **Update the guide** to mark completed tasks with `[x]` and add `✅` to the sprint title
6. **List created files** under the sprint section
7. **Use the commiter agent** to create dedicated commits for each file with appropriate prefixes

### Quick Reference

```bash
# Architecture guide location
docs/CORE_ARCHITECTURE_GUIDE.md

# When implementing a sprint:
1. Read the sprint section in CORE_ARCHITECTURE_GUIDE.md
2. Create files as specified
3. Write unit tests
4. Run: flutter test (in the relevant package)
5. Update the guide: mark tasks [x], add ✅, list created files
6. Use commiter agent with prefix (feat/fix/refactor/test/docs)
```

### Committing Changes

After completing a sprint implementation, use the **commiter agent** to create individual commits:

```
# Example: After implementing Sprint 5.3
Use commiter agent with prefix='feat'
```

The commiter agent will:
- Analyze each changed file
- Create individual commits with descriptive messages
- Use the specified prefix (feat, fix, refactor, test, docs, chore)

### Marking Tasks Complete

```markdown
# Before:
### Sprint 5.2: Data Sources Implementation
- [ ] Implement QuizSessionDataSource

# After:
### Sprint 5.2: Data Sources Implementation ✅
- [x] Implement QuizSessionDataSource

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/data_sources/quiz_session_data_source.dart`
```

---

## Project Overview

A Flutter monorepo for building multiple quiz applications using shared packages and reusable architecture. Built with Melos for monorepo management.

**Current Apps:**
- `apps/flagsquiz` - Country flags quiz game

**Core Packages:**
- `packages/quiz_engine_core` - Business logic and data layer
- `packages/quiz_engine` - Reusable UI components and widgets
- `packages/shared_services` - Analytics, ads, IAP, remote config

## Quick Start Commands

```bash
# Bootstrap after changes to dependencies
melos bootstrap

# Run all tests
melos run test

# Analyze all packages
melos run analyze

# Format all code
melos run format

# Clean all packages
melos run clean

# Build all apps
melos run build

# Run specific app
cd apps/flagsquiz && flutter run

# Test specific package
melos exec --scope=quiz_engine_core -- flutter test
```

## Creating New Quiz Apps

Use the generator script:

```bash
cd tools
./create_quiz_app.sh "App Name" "app_name" "com.company.appname"
cd ..
melos bootstrap
```

The script creates a complete Flutter app with:
- Core quiz functionality integrated
- Platform support (iOS, Android, Web, macOS)
- Monetization setup
- CI/CD workflows

## Project Structure

```
quiz_apps/
├── apps/                    # Quiz applications
│   └── flagsquiz/          # Example: Flags quiz
├── packages/               # Shared packages
│   ├── quiz_engine_core/  # Core business logic
│   ├── quiz_engine/       # UI components
│   └── shared_services/   # Shared services
├── tools/                  # Development tools
│   ├── create_quiz_app.sh # App generator
│   └── translation/       # Translation tools
├── docs/                   # Documentation
│   ├── APP_IDEAS.md
│   ├── DEVELOPMENT_GUIDE.md
│   ├── MONETIZATION_GUIDE.md
│   └── ANDROID_STUDIO_SETUP.md
├── .github/workflows/     # CI/CD pipelines
└── melos.yaml             # Monorepo configuration
```

## Key Architecture Concepts

### quiz_engine_core
- Defines sealed question types: `ImageQuestion`, `TextQuestion`, `AudioQuestion`, `VideoQuestion`
- Provides `QuizDataLoader` interface for loading quiz data
- Handles quiz state management
- Type-safe with sealed classes

### quiz_engine
- Provides `QuizWidget` - main quiz interface
- Question display widgets for each type
- BLoC pattern for state management
- Responsive layouts (mobile/tablet/desktop)

### shared_services
- Analytics service (Firebase, Google Analytics)
- Ads service (AdMob, mediation)
- In-app purchase service
- Remote config service

### Apps
Each app:
- Defines domain-specific models
- Provides quiz data (JSON files or API)
- Customizes UI theme
- Implements monetization strategy
- Handles localization

## Common Development Tasks

### Adding a New Question Type
1. Define sealed class in `quiz_engine_core/lib/src/domain/`
2. Create widget in `quiz_engine/lib/src/widgets/`
3. Update QuizWidget to handle new type
4. Update apps to use new question type

### Updating Shared Dependencies
1. Update `pubspec.yaml` in root or specific package
2. Run `melos bootstrap`
3. Test affected packages: `melos run test`

### Adding Analytics Events
1. Add event constants to `shared_services/lib/src/analytics/`
2. Implement in analytics service
3. Call from app code

### Testing Changes
```bash
# Test all packages
melos run test

# Test specific package
cd packages/quiz_engine_core && flutter test

# Test with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Working with Melos

Melos commands can target specific packages:

```bash
# Run command in specific package
melos exec --scope=flagsquiz -- flutter pub get

# Run in packages matching pattern
melos exec --scope="quiz_*" -- flutter analyze

# Run in all packages with tests
melos exec --dir-exists=test -- flutter test
```

## CI/CD Workflows

Located in `.github/workflows/`:
- `tests.yml` - Run tests on PRs
- `deploy_android.yml` - Deploy to Play Store
- `deploy_ios.yml` - Deploy to App Store
- `deploy_web.yml` - Deploy web apps
- `deploy_mac_os.yml` - Deploy macOS apps

Triggered by:
- Push to `main`
- Pull requests
- Release tags
- Manual dispatch

## Git Workflow

**IMPORTANT - Commit Authorship:**
- All commits MUST be authored by: **Volodymyr Shyrochuk **
- NEVER include AI agent references or mentions in commit messages
- Do NOT add "Generated with Claude Code" or similar footers
- Commits should appear as if written by a human developer

Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Refactoring
- `chore:` - Maintenance

Before committing:
1. `melos run test`
2. `melos run format`
3. `melos run analyze`

Example commit message:
```
feat: add audio question support to quiz engine

- Implement AudioQuestion sealed class
- Add audio player widget
- Update QuizWidget to handle audio questions
```

## Important Files

- `melos.yaml` - Monorepo configuration and scripts
- `pubspec.yaml` - Root dependencies
- `tools/create_quiz_app.sh` - App generator script
- `.github/workflows/` - CI/CD configuration

## Development Tips

1. **Always run `melos bootstrap`** after pulling changes or modifying dependencies
2. **Use the Task tool** for complex multi-step operations
3. **Check existing docs** in `docs/` before implementing features
4. **Test locally** before creating PRs
5. **Use the app generator** for new apps - don't copy manually
6. **Keep packages focused** - core logic in quiz_engine_core, UI in quiz_engine
7. **Shared services** should be app-agnostic

## Troubleshooting

### "Package not found" errors
Run `melos bootstrap`

### Build failures
1. `melos clean`
2. `melos bootstrap`
3. Try building specific app

### Test failures
Check if local packages are properly linked with `melos bootstrap`

### IDE not recognizing packages
Open individual app directories (e.g., `apps/flagsquiz/`) in Android Studio/VS Code, not the root

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Melos Documentation](https://melos.invertase.dev/)
- Project docs in `docs/` directory
- Example implementation in `apps/flagsquiz`

## Quick Reference

| Task | Command |
|------|---------|
| Setup | `melos bootstrap` |
| Test all | `melos run test` |
| Format | `melos run format` |
| Analyze | `melos run analyze` |
| Clean | `melos run clean` |
| New app | `tools/create_quiz_app.sh` |
| Run app | `cd apps/{name} && flutter run` |

---

*This guide is for AI assistants. For human developers, see README.md and docs/ directory.*