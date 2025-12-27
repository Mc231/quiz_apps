# Claude Code Guide - Quiz Apps Monorepo

This document helps AI assistants work efficiently with this Flutter quiz apps monorepo.

---

## Primary Workflow: Architecture Implementation

**The main task is implementing features from `docs/CORE_ARCHITECTURE_GUIDE.md`.**

### How It Works

1. **User requests a sprint/task** (e.g., "implement Sprint 5.2")
2. **Read `CORE_ARCHITECTURE_GUIDE.md`** for architecture patterns and design
3. **Check `PHASE_IMPLEMENTATION.md`** for specific tasks and requirements
4. **Implement the code** following the specifications
5. **Write tests** for all new code
6. **Update `PHASE_IMPLEMENTATION.md`** to mark completed tasks with `[x]` and add `✅` to the sprint title
7. **List created files** under the sprint section
8. **Use the commiter agent** to create dedicated commits for each file with appropriate prefixes

### Quick Reference

```bash
# Documentation locations
docs/CORE_ARCHITECTURE_GUIDE.md  # Architecture patterns & design
docs/PHASE_IMPLEMENTATION.md     # Phase/sprint progress tracking

# When implementing a sprint:
1. Read architecture patterns in CORE_ARCHITECTURE_GUIDE.md
2. Check sprint tasks in PHASE_IMPLEMENTATION.md
3. Create files as specified
4. Write unit tests
5. Run: flutter test (in the relevant package)
6. Update PHASE_IMPLEMENTATION.md: mark tasks [x], add ✅, list created files
7. Use commiter agent with prefix (feat/fix/refactor/test/docs)
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

In `PHASE_IMPLEMENTATION.md`:

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

### Post-Sprint Integration Check (MANDATORY)

**After completing any sprint, ALWAYS check for missing integrations:**

1. **Review what was created vs. what uses it:**
   - New classes/models → Are they used by BLoCs, screens, or services?
   - New services → Are they provided to widgets via DI/Provider?
   - New events/types → Are they fired/triggered at appropriate points?

2. **Create a TODO list for missing integrations:**
   - If new code is created but not yet integrated, add pending tasks
   - Example: "Event classes created" → Need "Integrate events with QuizBloc"

3. **Document pending integrations in PHASE_IMPLEMENTATION.md:**
   ```markdown
   **Pending Integrations (for future sprints):**
   - [ ] Integrate QuizEvent with QuizBloc
   - [ ] Add AnalyticsService provider to quiz screens
   ```

4. **Ask the user if they want to continue with integrations immediately**

This ensures no orphaned code is created without a clear path to integration.

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

## Specialized Agents

Use these specialized agents for specific tasks:

### flutter-architect
Use for Flutter development tasks including:
- Creating new widgets and screens
- Implementing features
- Architecture decisions
- SwiftUI/UIKit-style implementations
- Performance optimization

```
Use flutter-architect agent for: "Implement the new settings screen with dark mode toggle"
```

### unit-tester
Use for writing tests:
- Unit tests for new code
- Test coverage for existing code
- Mock implementations
- Edge case testing

```
Use unit-tester agent after implementing new code: "Write unit tests for the new AchievementsDataProvider"
```

### commiter
Use for committing changes:
- Creates individual commits per file
- Uses conventional commit prefixes

```
Use commiter agent with prefix='feat' after completing a feature
```

## Coding Rules

### 1. Localization (MANDATORY)

**Every UI-related string MUST be localized:**
- Never hardcode user-facing strings in Dart code
- All strings must come from localization (ARB files)
- Add new strings to the appropriate `.arb` file
- Use the generated localization class (e.g., `AppLocalizations`, `QuizLocalizations`)
- Run `flutter gen-l10n` after adding new strings

```dart
// ❌ WRONG - Hardcoded string
Text('Complete your first quiz')
Text('Play')
Text('Challenges')
label: 'Practice',

// ✅ CORRECT - Localized string
Text(l10n.firstQuizDescription)
Text(l10n.play)
Text(l10n.challenges)
label: l10n.practice,
```

**ARB file locations:**
- `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Shared quiz UI strings
- `apps/flagsquiz/lib/l10n/intl_en.arb` - App-specific strings

**Adding new strings:**
1. Add the string to the appropriate `.arb` file:
```json
{
  "play": "Play",
  "@play": {
    "description": "Label for play tab/button"
  },
  "challenges": "Challenges",
  "@challenges": {
    "description": "Label for challenges tab"
  }
}
```

2. Run `flutter gen-l10n` in the package directory
3. Use the generated class in your code:
```dart
final l10n = QuizL10n.of(context);
Text(l10n.play)
```

**What must be localized:**
- All button labels
- All tab labels
- All screen titles
- All dialog messages
- All error messages
- All placeholder texts
- All tooltips
- All accessibility labels

**What should NOT be localized:**
- Technical identifiers (IDs, keys)
- Code comments
- Log messages (for debugging)
- API endpoints

### 2. Sealed Classes (MANDATORY)

**Every sealed class MUST have factory methods for all cases:**
- Provides cleaner API for creating instances
- Makes code more readable and maintainable
- Ensures all cases are covered

```dart
// ❌ WRONG - No factory methods
sealed class QuizModeConfig {
  const QuizModeConfig();
}

class StandardMode extends QuizModeConfig { ... }
class TimedMode extends QuizModeConfig { ... }

// ✅ CORRECT - Factory methods for all cases
sealed class QuizModeConfig {
  const QuizModeConfig();

  factory QuizModeConfig.standard({bool allowSkip = false}) = StandardMode;
  factory QuizModeConfig.timed({int timePerQuestion = 30}) = TimedMode;
  factory QuizModeConfig.lives({int lives = 3}) = LivesMode;
  factory QuizModeConfig.endless() = EndlessMode;
  factory QuizModeConfig.survival({int lives = 3, int timePerQuestion = 30}) = SurvivalMode;
}
```

### 3. Reusable State Widgets (MANDATORY)

**Always use the built-in state widgets for loading, error, and empty states:**

These widgets are located in `packages/quiz_engine/lib/src/widgets/` and are exported from `quiz_engine.dart`.

#### LoadingIndicator
Use for all loading states instead of `CircularProgressIndicator`:

```dart
import 'package:quiz_engine/quiz_engine.dart';

// ❌ WRONG - Raw CircularProgressIndicator
return const Center(child: CircularProgressIndicator());

// ✅ CORRECT - Use LoadingIndicator
return const LoadingIndicator();

// With optional message
return LoadingIndicator(message: l10n.loadingData);

// Size variants
return const LoadingIndicator.small();   // 20px - for inline/compact areas
return const LoadingIndicator.medium();  // 36px - default
return const LoadingIndicator.large();   // 48px - for full-screen loading
```

#### EmptyStateWidget
Use for all empty states with consistent styling:

```dart
// ❌ WRONG - Inline empty state
return Center(
  child: Column(
    children: [
      Icon(Icons.category_outlined, size: 64),
      Text('No items found'),
    ],
  ),
);

// ✅ CORRECT - Use EmptyStateWidget
return EmptyStateWidget(
  icon: Icons.category_outlined,
  title: l10n.noItemsFound,
  message: l10n.noItemsDescription,  // optional
);

// With action button
return EmptyStateWidget(
  icon: Icons.search,
  title: l10n.noResults,
  actionLabel: l10n.clearFilters,
  onAction: () => clearFilters(),
);

// Factory constructors for common cases
return EmptyStateWidget.noResults();  // For search/filter results
return EmptyStateWidget.noData();     // For missing data
return EmptyStateWidget.compact(      // For inline/small areas
  icon: Icons.leaderboard,
  title: l10n.noLeaderboardData,
);
```

#### ErrorStateWidget
Use for all error states with retry capability:

```dart
// ❌ WRONG - Inline error display
return Center(
  child: Column(
    children: [
      Icon(Icons.error, color: Colors.red),
      Text('Something went wrong'),
      ElevatedButton(onPressed: retry, child: Text('Retry')),
    ],
  ),
);

// ✅ CORRECT - Use ErrorStateWidget
return ErrorStateWidget(
  message: l10n.errorGeneric,
  onRetry: () => loadData(),
);

// Factory constructors for common cases
return ErrorStateWidget.network(onRetry: loadData);  // Network errors
return ErrorStateWidget.server(onRetry: loadData);   // Server errors
```

**Widget locations:**
- `packages/quiz_engine/lib/src/widgets/loading_indicator.dart`
- `packages/quiz_engine/lib/src/widgets/empty_state_widget.dart`
- `packages/quiz_engine/lib/src/widgets/error_state_widget.dart`

**Localization strings available:**
- `l10n.retry` - "Retry" button label
- `l10n.errorTitle` - "Something Went Wrong"
- `l10n.errorGeneric` - Generic error message
- `l10n.errorNetwork` - Network error message
- `l10n.errorServer` - Server error message
- `l10n.loadingData` - "Loading..." message

### 4. Animation Constants (MANDATORY)

**Always use `QuizAnimations` for consistent animations:**

Located at `packages/quiz_engine/lib/src/theme/quiz_animations.dart`.

```dart
import 'package:quiz_engine/quiz_engine.dart';

// ❌ WRONG - Hardcoded durations and curves
AnimationController(
  duration: const Duration(milliseconds: 300),
  vsync: this,
);
CurvedAnimation(parent: controller, curve: Curves.easeOut);

// ✅ CORRECT - Use QuizAnimations constants
AnimationController(
  duration: QuizAnimations.durationMedium,
  vsync: this,
);
CurvedAnimation(parent: controller, curve: QuizAnimations.curveEnter);
```

**Duration Tiers:**
| Constant | Duration | Use Case |
|----------|----------|----------|
| `durationInstant` | 50ms | Immediate feedback |
| `durationFast` | 100ms | Tap feedback, micro-interactions |
| `durationQuick` | 200ms | Tooltips, small movements |
| `durationMedium` | 300ms | Standard transitions |
| `durationSlow` | 500ms | Important feedback (correct/incorrect) |
| `durationLong` | 800ms | Celebration effects |
| `durationExtended` | 1500ms | Counting, continuous effects |

**Curve Categories:**
| Constant | Curve | Use Case |
|----------|-------|----------|
| `curveStandard` | easeInOut | Most transitions |
| `curveEnter` | easeOut | Elements appearing |
| `curveExit` | easeIn | Elements disappearing |
| `curveBounce` | elasticOut | Playful, bouncy effects |
| `curveDecelerate` | easeOutCubic | Counting/progress |
| `curveOvershoot` | easeOutBack | Subtle bounce |

**Scale Values:**
- `pressedScale` (0.95) - Button press
- `pulseScale` (1.1) - Pulse animation max
- `bounceOvershoot` (1.2) - Bounce overshoot

**Specific Animation Presets:**
```dart
// Answer feedback
QuizAnimations.answerFeedbackDuration
QuizAnimations.answerFeedbackScaleCurve

// Achievement notification
QuizAnimations.achievementSlideDuration
QuizAnimations.achievementBounceDuration
QuizAnimations.achievementDisplayDuration

// Game resources
QuizAnimations.resourceTapDuration
QuizAnimations.resourcePulseDuration
QuizAnimations.resourceShakeDuration

// Score display
QuizAnimations.scoreCountDuration
QuizAnimations.scoreCountCurve
```

### 5. Accessibility (MANDATORY)

**All interactive widgets MUST have proper accessibility support:**

Located at `packages/quiz_engine/lib/src/theme/quiz_accessibility.dart`.

#### Semantics Pattern for Cards/Buttons

```dart
import 'package:quiz_engine/quiz_engine.dart';

// ❌ WRONG - No accessibility support
return Card(
  child: InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(Icons.category),
        Text(title),
        Icon(Icons.chevron_right),
      ],
    ),
  ),
);

// ✅ CORRECT - With Semantics wrapper
return Semantics(
  label: l10n.accessibilityCategoryButton(title),
  hint: l10n.accessibilityDoubleTapToSelect,
  button: true,
  enabled: onTap != null,
  child: Card(
    child: InkWell(
      onTap: onTap,
      excludeFromSemantics: true,  // Prevent duplicate announcements
      child: Row(
        children: [
          ExcludeSemantics(child: Icon(Icons.category)),  // Decorative
          Text(title),
          ExcludeSemantics(child: Icon(Icons.chevron_right)),  // Decorative
        ],
      ),
    ),
  ),
);
```

#### QuizAccessibility Helper Class

```dart
import 'package:quiz_engine/quiz_engine.dart';

// Minimum touch target (WCAG 2.1 AA)
QuizAccessibility.minTouchTarget  // 48.0

// Helper for semantic buttons
QuizAccessibility.semanticButton(
  label: 'Play Quiz',
  hint: 'Double tap to start',
  enabled: true,
  child: myButton,
);

// Wrap decorative elements
QuizAccessibility.decorative(child: Icon(Icons.star));

// Live region for dynamic content
QuizAccessibility.liveRegion(
  label: 'Score: 85%',
  child: scoreWidget,
);

// Ensure minimum touch target
QuizAccessibility.ensureMinTouchTarget(child: smallButton);
```

#### Key Accessibility Rules

1. **Wrap interactive cards with `Semantics`** - Provide label, hint, button=true
2. **Add `excludeFromSemantics: true` to InkWell** - When parent has Semantics
3. **Wrap decorative icons with `ExcludeSemantics`** - Icons that don't convey information
4. **Use localized accessibility strings** - All labels from l10n
5. **Minimum 48x48 touch targets** - Per WCAG 2.1 AA guidelines

#### Accessibility Localization Strings

Located in `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb`:

```dart
l10n.accessibilityCategoryButton(title)      // "Category: {title}"
l10n.accessibilityChallengeButton(name, difficulty)  // "{name}, {difficulty}"
l10n.accessibilityAnswerOption(answer)       // "Answer option: {answer}"
l10n.accessibilityAnswerDisabled(answer)     // "{answer}, disabled"
l10n.accessibilitySessionCard(quiz, score)   // "Quiz: {quiz}, Score: {score}"
l10n.accessibilityDoubleTapToSelect          // "Double tap to select"
l10n.accessibilityDoubleTapToStart           // "Double tap to start"
l10n.accessibilityProgress(current, total)   // "Question {current} of {total}"
l10n.accessibilityTimer(seconds)             // "{seconds} seconds remaining"
l10n.accessibilityLives(count)               // "{count} lives remaining"
l10n.accessibilityScore(points)              // "Score: {points} points"
```

### 6. Audio & Haptic Feedback (MANDATORY)

**Use `QuizFeedbackService` for consistent audio and haptic feedback:**

Located at `packages/quiz_engine/lib/src/feedback/quiz_feedback_service.dart`.

#### Basic Usage

```dart
import 'package:quiz_engine/quiz_engine.dart';

// ❌ WRONG - Direct HapticFeedback calls (ignores user settings)
HapticFeedback.mediumImpact();

// ✅ CORRECT - Use QuizFeedbackService
final feedbackService = QuizFeedbackService();
await feedbackService.initialize();
await feedbackService.trigger(QuizFeedbackPattern.correctAnswer);
```

#### Available Feedback Patterns

| Pattern | Audio | Haptic | Use Case |
|---------|-------|--------|----------|
| `correctAnswer` | correctAnswer.mp3 | Light | Correct answer |
| `incorrectAnswer` | incorrectAnswer.mp3 | Medium | Wrong answer |
| `buttonTap` | buttonClick.mp3 | Selection | UI button clicks |
| `resourceTap` | - | Selection | Resource button tap |
| `resourceDepleted` | lifeLost.mp3 | Heavy | Resource ran out |
| `hintUsed` | hintUsed.mp3 | Light | Hint activated |
| `lifeLost` | lifeLost.mp3 | Medium | Life lost |
| `quizStart` | quizStart.mp3 | Light | Quiz begins |
| `quizComplete` | quizComplete.mp3 | Heavy | Quiz finished |
| `achievementUnlocked` | achievement.mp3 | Heavy | Achievement earned |
| `timerWarning` | timerWarning.mp3 | Light | Time running low |
| `timeout` | timeOut.mp3 | Medium | Time expired |
| `selectionChange` | - | Selection | Option selected |
| `error` | - | Vibrate | Invalid action |

#### Using QuizFeedbackProvider

Wrap your widget tree with `QuizFeedbackProvider` to make the service available to child widgets:

```dart
// In quiz_screen.dart (already done)
QuizFeedbackProvider(
  feedbackService: _feedbackService,
  child: Scaffold(...),
)

// In any child widget
final service = QuizFeedbackProvider.of(context);
await service.trigger(QuizFeedbackPattern.buttonTap);

// Or use the context extension
await context.triggerFeedback(QuizFeedbackPattern.hintUsed);
```

#### Widget Integration Pattern

For widgets that need feedback (like GameResourceButton):

```dart
class MyWidget extends StatelessWidget {
  final QuizFeedbackService? feedbackService;

  void _handleTap() {
    // Try to get service from widget, then context, then fallback
    final service = feedbackService ?? QuizFeedbackProvider.maybeOf(context);
    if (service != null) {
      service.triggerHaptic(QuizFeedbackPattern.buttonTap);
    } else {
      // Fallback to direct HapticFeedback
      HapticFeedback.selectionClick();
    }
  }
}
```

#### Volume Recommendations

From `QuizFeedbackConstants`:
- UI interactions: 0.5 (subtle)
- Feedback sounds: 0.8 (standard)
- Alerts: 0.9 (attention-getting)
- Celebrations: 1.0 (maximum)

#### Sound Assets

Located in `packages/quiz_engine/assets/sounds/`:
- `buttonClick.mp3` - UI clicks
- `correctAnswer.mp3` - Correct answer
- `incorrectAnswer.mp3` - Wrong answer
- `achievement.mp3` - Achievement unlocked
- `quizComplete.mp3` - Quiz finished
- `quizStart.mp3` - Quiz begins
- `hintUsed.mp3` - Hint activated
- `lifeLost.mp3` - Life lost
- `timerWarning.mp3` - Timer low
- `timeOut.mp3` - Time expired

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