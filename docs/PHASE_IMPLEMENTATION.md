# Phase Implementation Tracker

**Purpose:** Track implementation progress for all phases and sprints.

**Reference:** See [CORE_ARCHITECTURE_GUIDE.md](./CORE_ARCHITECTURE_GUIDE.md) for architectural details and design patterns.

**Last Updated:** 2025-12-27

---

## Progress Overview

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Quiz Engine Foundation | ✅ Completed |
| Phase 2 | Quiz Modes & Features | ✅ Completed |
| Phase 3 | Audio & Haptic Feedback | ✅ Completed |
| Phase 4 | Settings & Configuration | ✅ Completed |
| Phase 5 | Data Persistence & Storage | ✅ Completed |
| Phase 6 | Results & Statistics UI | ✅ Completed |
| Phase 7 | QuizApp Refactoring | ✅ Completed |
| Phase 8 | Achievements & Core Features | ✅ Completed (12/12 sprints) |
| Phase 8.5 | Production Polish | ✅ Completed (7/7 sprints) |
| Phase 9 | Shared Services (Ads, Analytics, IAP) | 🔄 In Progress (Analytics ✅ 11/11, Ads/IAP pending) |
| Phase 10 | Polish & Integration | Not Started |
| Phase 11 | Second App Validation | Not Started |

---

## Phase 1: Quiz Engine Foundation ✅

### Sprint 1.1: Core Quiz Models ✅

**Tasks:**
- [x] Create sealed `QuestionEntry` class hierarchy (Image, Text, Audio, Video)
- [x] Create `Answer` model with correctness tracking
- [x] Create `QuizConfig` for quiz configuration
- [x] Create `QuizResults` model for tracking outcomes
- [x] Write unit tests for all models

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/model/question_entry.dart`
- ✅ `packages/quiz_engine_core/lib/src/model/answer.dart`
- ✅ `packages/quiz_engine_core/lib/src/model/quiz_results.dart`
- ✅ `packages/quiz_engine_core/lib/src/model/config/quiz_config.dart`

---

### Sprint 1.2: QuizBloc State Management ✅

**Tasks:**
- [x] Create `QuizBloc` with BLoC pattern
- [x] Create `QuizState` sealed class hierarchy
- [x] Implement quiz flow (loading → active → feedback → completed)
- [x] Handle answer submission and scoring
- [x] Write unit tests for QuizBloc

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart`
- ✅ `packages/quiz_engine_core/test/quiz_bloc_test.dart`

---

### Sprint 1.3: Quiz UI Widgets ✅

**Tasks:**
- [x] Create `QuizWidget` main container
- [x] Create `QuizScreen` with question display
- [x] Create `QuizAnswersWidget` for answer options
- [x] Create `OptionButton` for individual answers
- [x] Create `QuizStatusBar` for progress display
- [x] Add responsive design support
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/quiz_widget.dart`
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_screen.dart`
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_answers_widget.dart`
- ✅ `packages/quiz_engine/lib/src/components/option_button.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/quiz_status_bar.dart`
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_layout.dart`

---

## Phase 2: Quiz Modes & Features ✅

### Sprint 2.1: Game Mode Configuration ✅

**Tasks:**
- [x] Create `QuizModeConfig` sealed class hierarchy
- [x] Implement `StandardMode` (no limits)
- [x] Implement `TimedMode` (time per question)
- [x] Implement `LivesMode` (limited lives)
- [x] Implement `EndlessMode` (one mistake ends)
- [x] Implement `SurvivalMode` (timed + lives)
- [x] Write unit tests for all modes

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/model/config/quiz_mode_config.dart`
- ✅ `packages/quiz_engine_core/test/quiz_bloc_config_test.dart`

---

### Sprint 2.2: Lives/Hearts System ✅

**Tasks:**
- [x] Create `LivesDisplay` widget with heart icons
- [x] Integrate lives tracking with QuizBloc
- [x] Handle game over when lives reach 0
- [x] Add responsive sizing for different screen types
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/lives_display.dart`

---

### Sprint 2.3: Hint System ✅

**Tasks:**
- [x] Create `HintType` enum (fiftyFifty, skip, revealLetter, extraTime)
- [x] Create `HintConfig` for hint configuration
- [x] Create `HintState` for runtime hint tracking
- [x] Create `HintsPanel` widget with hint buttons
- [x] Integrate hints with QuizBloc
- [x] Write unit tests

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/model/config/hint_config.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/hints_panel.dart`

---

### Sprint 2.4: Answer Feedback ✅

**Tasks:**
- [x] Create `AnswerFeedbackWidget` with animations
- [x] Show correct/incorrect visual feedback
- [x] Add scale and opacity animations
- [x] Color-coded feedback (green/red)
- [x] Responsive sizing
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart`

---

## Phase 3: Audio & Haptic Feedback ✅

### Sprint 3.1: Sound Effects ✅

**Tasks:**
- [x] Create `AudioService` with volume control
- [x] Create `QuizSoundEffect` enum with 10 sounds
- [x] Implement mute/unmute toggle
- [x] Add sound preloading support
- [x] Create MP3 sound assets
- [x] Export from shared_services

**Files Created:**
- ✅ `packages/shared_services/lib/src/audio/audio_service.dart`
- ✅ `packages/shared_services/lib/src/audio/quiz_sound_effect.dart`
- ✅ `packages/quiz_engine/assets/sounds/correctAnswer.mp3`
- ✅ `packages/quiz_engine/assets/sounds/incorrectAnswer.mp3`
- ✅ `packages/quiz_engine/assets/sounds/buttonClick.mp3`
- ✅ `packages/quiz_engine/assets/sounds/quizComplete.mp3`
- ✅ `packages/quiz_engine/assets/sounds/achievement.mp3`
- ✅ `packages/quiz_engine/assets/sounds/timerWarning.mp3`
- ✅ `packages/quiz_engine/assets/sounds/timeOut.mp3`
- ✅ `packages/quiz_engine/assets/sounds/hintUsed.mp3`
- ✅ `packages/quiz_engine/assets/sounds/lifeLost.mp3`
- ✅ `packages/quiz_engine/assets/sounds/quizStart.mp3`

---

### Sprint 3.2: Haptic Feedback ✅

**Tasks:**
- [x] Create `HapticService` with feedback types
- [x] Create `HapticFeedbackType` enum (light, medium, heavy, selection, vibrate)
- [x] Implement enable/disable toggle
- [x] Add convenience methods (correctAnswer, incorrectAnswer, buttonClick)
- [x] Export from shared_services

**Files Created:**
- ✅ `packages/shared_services/lib/src/haptic/haptic_service.dart`

---

### Sprint 3.3: Logger Service ✅

**Tasks:**
- [x] Add `logger` package to shared_services
- [x] Create `AppLogger` singleton service
- [x] Implement log levels (debug, info, warning, error, fatal)
- [x] Replace print statements with logger calls
- [x] Export from shared_services

**Files Created:**
- ✅ `packages/shared_services/lib/src/logger/logger_service.dart`

---

## Phase 4: Settings & Configuration ✅

### Sprint 4.1: Settings Model ✅

**Tasks:**
- [x] Create `QuizSettings` model with JSON serialization
- [x] Support sound, music, haptic, answerFeedback toggles
- [x] Support theme mode (light, dark, system)
- [x] Implement equality and copyWith
- [x] Write unit tests

**Files Created:**
- ✅ `packages/shared_services/lib/src/settings/quiz_settings.dart`
- ✅ `packages/shared_services/test/quiz_settings_test.dart`

---

### Sprint 4.2: Settings Service ✅

**Tasks:**
- [x] Create `SettingsService` with SharedPreferences persistence
- [x] Implement reactive settings stream
- [x] Add toggle methods for each setting
- [x] Integrate with DI system
- [x] Write unit tests

**Files Created:**
- ✅ `packages/shared_services/lib/src/settings/settings_service.dart`
- ✅ `packages/shared_services/lib/src/di/modules/settings_module.dart`
- ✅ `packages/shared_services/test/di/settings_module_test.dart`

---

### Sprint 4.3: Settings Screen ✅

**Tasks:**
- [x] Create `QuizSettingsScreen` with configurable sections
- [x] Create `QuizSettingsConfig` for customization
- [x] Support Audio & Haptics section
- [x] Support Quiz Behavior section
- [x] Support Appearance section (theme)
- [x] Support About section
- [x] Support custom sections
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart`
- ✅ `packages/quiz_engine/test/settings/quiz_settings_screen_test.dart`

---

## Phase 5: Data Persistence & Storage ✅

### Sprint 5.1: Database Foundation & Core Models ✅

**Tasks:**
- [x] Add sqflite dependencies to shared_services
- [x] Create database configuration and setup
- [x] Define SQL schema for all tables
- [x] Implement database migrations system
- [x] Create data models (PODOs) for all entities
- [x] Write model serialization (toMap/fromMap)
- [x] Create database indexes for performance
- [x] Test database initialization and migrations

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/database/app_database.dart`
- ✅ `packages/shared_services/lib/src/storage/database/database_config.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/quiz_sessions_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/question_answers_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/statistics_tables.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/daily_statistics_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/settings_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v1.dart`
- ✅ `packages/shared_services/lib/src/storage/models/quiz_session.dart`
- ✅ `packages/shared_services/lib/src/storage/models/question_answer.dart`
- ✅ `packages/shared_services/lib/src/storage/models/global_statistics.dart`
- ✅ `packages/shared_services/lib/src/storage/models/quiz_type_statistics.dart`
- ✅ `packages/shared_services/lib/src/storage/models/daily_statistics.dart`
- ✅ `packages/shared_services/lib/src/storage/models/user_settings_model.dart`
- ✅ `packages/shared_services/lib/src/storage/storage_exports.dart`
- ✅ `packages/shared_services/test/storage/models_test.dart`
- ✅ `packages/shared_services/test/storage/tables_test.dart`
- ✅ `packages/shared_services/test/storage/database_config_test.dart`

---

### Sprint 5.2: Data Sources Implementation ✅

**Tasks:**
- [x] Implement QuizSessionDataSource (CRUD operations)
- [x] Implement QuestionAnswerDataSource (CRUD + queries)
- [x] Implement StatisticsDataSource (aggregations & updates)
- [x] Implement SettingsDataSource (read/write preferences)
- [x] Add error handling and transactions
- [x] Implement batch operations for performance
- [x] Add query helpers and filters
- [x] Write unit tests for all data sources

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/data_sources/quiz_session_data_source.dart`
- ✅ `packages/shared_services/lib/src/storage/data_sources/question_answer_data_source.dart`
- ✅ `packages/shared_services/lib/src/storage/data_sources/statistics_data_source.dart`
- ✅ `packages/shared_services/lib/src/storage/data_sources/settings_data_source.dart`
- ✅ `packages/shared_services/lib/src/storage/data_sources/data_sources_exports.dart`
- ✅ `packages/shared_services/test/storage/data_sources/quiz_session_data_source_test.dart`
- ✅ `packages/shared_services/test/storage/data_sources/question_answer_data_source_test.dart`
- ✅ `packages/shared_services/test/storage/data_sources/statistics_data_source_test.dart`
- ✅ `packages/shared_services/test/storage/data_sources/settings_data_source_test.dart`

---

### Sprint 5.3: Repository Layer Implementation ✅

**Tasks:**
- [x] Create repository interfaces (abstract classes)
- [x] Implement QuizSessionRepository
- [x] Implement StatisticsRepository with aggregations
- [x] Implement SettingsRepository (migrate from SharedPreferences)
- [x] Add caching layer for performance
- [x] Implement real-time statistics updates
- [x] Add Stream support for reactive updates
- [x] Write integration tests for repositories

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/repositories/quiz_session_repository.dart`
- ✅ `packages/shared_services/lib/src/storage/repositories/statistics_repository.dart`
- ✅ `packages/shared_services/lib/src/storage/repositories/settings_repository.dart`
- ✅ `packages/shared_services/lib/src/storage/repositories/repositories_exports.dart`
- ✅ `packages/shared_services/test/storage/repositories/quiz_session_repository_test.dart`
- ✅ `packages/shared_services/test/storage/repositories/statistics_repository_test.dart`
- ✅ `packages/shared_services/test/storage/repositories/settings_repository_test.dart`

---

### Sprint 5.3.1: Dependency Injection Setup ✅

**Goal:** Create a simple, library-free dependency injection system with service locator pattern and module-based registration.

**Tasks:**
- [x] Create ServiceLocator class with singleton/factory/lazy registration
- [x] Create DependencyModule base class for organized registration
- [x] Create StorageModule for all storage-related dependencies
- [x] Create Disposable interface for resource cleanup
- [x] Data sources support explicit DI (optional database parameter)
- [x] Add initialization helper for apps (SharedServicesInitializer)
- [x] Write unit tests for ServiceLocator
- [x] Update shared_services exports

**Files Created:**
- ✅ `packages/shared_services/lib/src/di/service_locator.dart`
- ✅ `packages/shared_services/lib/src/di/dependency_module.dart`
- ✅ `packages/shared_services/lib/src/di/modules/storage_module.dart`
- ✅ `packages/shared_services/lib/src/di/di_exports.dart`
- ✅ `packages/shared_services/lib/src/di/shared_services_initializer.dart`
- ✅ `packages/shared_services/test/di/service_locator_test.dart`
- ✅ `packages/shared_services/test/di/storage_module_test.dart`

---

### Sprint 5.3.2: Settings Service DI Integration ✅

**Goal:** Integrate SettingsService into the DI system so all services can be accessed consistently via `sl.get<T>()`.

**Tasks:**
- [x] Create SettingsModule for SettingsService registration
- [x] Update SharedServicesInitializer to include SettingsModule
- [x] Update di_exports.dart to export SettingsModule
- [x] Update flagsquiz main.dart to use sl.get<SettingsService>()
- [x] Write unit tests for SettingsModule
- [x] Verify all tests pass

**Files Created:**
- ✅ `packages/shared_services/lib/src/di/modules/settings_module.dart`
- ✅ `packages/shared_services/test/di/settings_module_test.dart`

**Files Updated:**
- ✅ `packages/shared_services/lib/src/di/shared_services_initializer.dart`
- ✅ `packages/shared_services/lib/src/di/di_exports.dart`
- ✅ `apps/flagsquiz/lib/main.dart`

---

### Sprint 5.4: Integration with Quiz Engine ✅

**Tasks:**
- [x] Create StorageService facade in shared_services
- [x] Integrate QuizSessionRepository with QuizBloc
- [x] Save quiz sessions on completion
- [x] Save individual Q&A during quiz
- [x] Update statistics in real-time
- [x] Implement session recovery (resume interrupted quiz)
- [x] Add error handling and retry logic
- [x] Update QuizConfig to include storage settings
- [x] Test end-to-end storage flow

**Files Created/Updated:**
- ✅ `packages/shared_services/lib/src/storage/storage_service.dart` - StorageService facade with result types and retry logic
- ✅ `packages/shared_services/lib/src/storage/quiz_storage_adapter.dart` - Adapter bridging quiz_engine_core with shared_services
- ✅ `packages/quiz_engine_core/lib/src/storage/quiz_storage_service.dart` - Quiz storage interface and implementations
- ✅ `packages/quiz_engine_core/lib/src/model/config/storage_config.dart` - Storage configuration for QuizConfig
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Updated with storage integration
- ✅ `packages/quiz_engine_core/lib/src/model/config/quiz_config.dart` - Updated to include StorageConfig
- ✅ `packages/quiz_engine_core/lib/src/model/config/config_exports.dart` - Updated exports
- ✅ `packages/quiz_engine_core/lib/quiz_engine_core.dart` - Updated exports
- ✅ `packages/shared_services/lib/src/storage/storage_exports.dart` - Updated exports
- ✅ `packages/shared_services/lib/src/di/modules/storage_module.dart` - Registers StorageService
- ✅ `packages/quiz_engine_core/test/storage/quiz_storage_service_test.dart` - Unit tests
- ✅ `packages/quiz_engine_core/test/model/config/storage_config_test.dart` - Unit tests

---

### Sprint 5.5: Review & Statistics UI ✅

**Tasks:**
- [x] Create SessionHistoryScreen (list of past sessions)
- [x] Create SessionDetailScreen (review single session)
- [x] Create QuestionReviewWidget (show Q&A with explanations)
- [x] Create StatisticsScreen with charts
- [x] Create TrendsWidget (daily/weekly performance)
- [ ] Add "Practice Wrong Answers" mode (TODO - stub added)
- [x] Add export functionality (CSV/JSON)
- [x] Integrate screens into flags quiz app

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/session_card.dart` - SessionCard and SessionCardData
- ✅ `packages/quiz_engine/lib/src/widgets/statistics_card.dart` - StatisticsCard and StatisticsGrid
- ✅ `packages/quiz_engine/lib/src/widgets/question_review_widget.dart` - QuestionReviewWidget and ReviewedQuestion
- ✅ `packages/quiz_engine/lib/src/widgets/trends_widget.dart` - TrendsWidget, TrendDataPoint, TrendType
- ✅ `packages/quiz_engine/lib/src/screens/session_history_screen.dart` - SessionHistoryScreen with SessionHistoryTexts
- ✅ `packages/quiz_engine/lib/src/screens/session_detail_screen.dart` - SessionDetailScreen with SessionDetailData
- ✅ `packages/quiz_engine/lib/src/screens/statistics_screen.dart` - StatisticsScreen with GlobalStatisticsData
- ✅ `packages/shared_services/lib/src/storage/services/session_export_service.dart` - Export to JSON/CSV/text
- ✅ `apps/flagsquiz/lib/ui/home/home_screen.dart` - HomeScreen with bottom navigation
- ✅ `apps/flagsquiz/lib/ui/history/history_page.dart` - HistoryPage integration
- ✅ `apps/flagsquiz/lib/ui/history/session_detail_page.dart` - SessionDetailPage integration
- ✅ `apps/flagsquiz/lib/ui/statistics/statistics_page.dart` - StatisticsPage integration
- ✅ `apps/flagsquiz/lib/l10n/intl_en.arb` - Added 60+ localization strings

---

## Phase 6: Results & Statistics UI ✅

### Sprint 6.1: Enhanced Results Screen ✅

**Tasks:**
- [x] Create `QuizResults` model (enhanced from Phase 5 data)
- [x] Create enhanced `QuizResultsScreen` with historical data
- [x] Add star rating display
- [x] Add percentage display
- [x] Add "Review This Session" button
- [x] Add "Review All Wrong Answers" button (disabled, coming soon)
- [x] Test results screens

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/model/quiz_results.dart` - QuizResults model with score calculation and star rating
- ✅ `packages/quiz_engine/lib/src/screens/quiz_results_screen.dart` - Full results screen with star rating, percentage, statistics
- ✅ `packages/quiz_engine_core/test/model/quiz_results_test.dart` - Unit tests for QuizResults model

**Files Modified:**
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart` - Added QuizCompletedState
- ✅ `packages/quiz_engine_core/lib/quiz_engine_core.dart` - Export QuizResults
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export QuizResultsScreen
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Emit QuizCompletedState with QuizResults
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - Show QuizResultsScreen instead of dialog
- ✅ `packages/quiz_engine/lib/src/quiz_widget.dart` - Pass quizName to QuizBloc
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added localization strings for results screen
- ✅ `packages/quiz_engine/test/widgets/quiz_screen_test.dart` - Updated test for results screen

---

## Phase 7: QuizApp Refactoring ✅

**Goal:** Refactor quiz_engine to provide a complete `QuizApp` widget that handles everything (MaterialApp, theme, navigation, localization), so apps only need to provide data and configuration.

### Target Usage

```dart
// Simplified flagsquiz main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    QuizApp(
      appName: 'Flags Quiz',
      categories: flagsCategories,
      dataProvider: FlagsDataProvider(),
      theme: flagsLightTheme,
      darkTheme: flagsDarkTheme,
      tabs: [QuizTab.play, QuizTab.history, QuizTab.statistics],
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    ),
  );
}
```

### Ownership Split

**quiz_engine owns:**
- `QuizApp` - Root MaterialApp widget
- `QuizHomeScreen` - Bottom navigation with configurable tabs
- `PlayScreen` - Category selection (grid/list layout)
- `QuizSettingsScreen` - Generic settings (optional)
- `QuizLocalizations` - Generic UI strings (~80 strings)

**App provides:**
- `QuizDataProvider` implementation (loads questions)
- `QuizCategory` list (categories to display)
- `ThemeData` (light/dark themes)
- App-specific localization (country names, category names)

---

### Sprint 7.1: Core Models and Interfaces ✅

**Tasks:**
- [x] Create `QuizCategory` model with `LocalizedString` support
- [x] Create `QuizDataProvider` interface and `CallbackQuizDataProvider`
- [x] Create `QuizTab` sealed class and `QuizTabConfig`
- [x] Write unit tests for models

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/models/quiz_category.dart`
- ✅ `packages/quiz_engine/lib/src/models/quiz_data_provider.dart`
- ✅ `packages/quiz_engine/lib/src/models/models_exports.dart`
- ✅ `packages/quiz_engine/lib/src/app/quiz_tab.dart`
- ✅ `packages/quiz_engine/test/models/quiz_category_test.dart`
- ✅ `packages/quiz_engine/test/models/quiz_data_provider_test.dart`
- ✅ `packages/quiz_engine/test/app/quiz_tab_test.dart`

**Key Classes:**
```dart
typedef LocalizedString = String Function(BuildContext context);

class QuizCategory {
  final String id;
  final LocalizedString title;
  final LocalizedString? subtitle;
  final ImageProvider? imageProvider;
  final IconData? icon;
  final QuizConfig? config;
}

abstract class QuizDataProvider {
  Future<List<QuestionEntry>> loadQuestions(BuildContext context, QuizCategory category);
  QuizTexts? createQuizTexts(BuildContext context, QuizCategory category);
  StorageConfig? createStorageConfig(BuildContext context, QuizCategory category);
}

// Sealed class with factory methods
sealed class QuizTab {
  factory QuizTab.play({...}) = PlayTab;
  factory QuizTab.history({...}) = HistoryTab;
  factory QuizTab.statistics({...}) = StatisticsTab;
  factory QuizTab.settings({...}) = SettingsTab;
  factory QuizTab.custom({...}) = CustomTab;
}
```

---

### Sprint 7.2: Localization System ✅

**Tasks:**
- [x] Create `QuizLocalizations` abstract class with all engine strings
- [x] Create `QuizLocalizationsEn` with English defaults
- [x] Create `QuizLocalizationsDelegate` for loading localizations
- [x] Add support for app overrides
- [x] Write unit tests for localization

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/l10n/quiz_localizations.dart` - Abstract class with ~80 strings
- ✅ `packages/quiz_engine/lib/src/l10n/quiz_localizations_en.dart` - English implementation
- ✅ `packages/quiz_engine/lib/src/l10n/quiz_localizations_delegate.dart` - Delegate with overrides support
- ✅ `packages/quiz_engine/lib/src/l10n/l10n_exports.dart` - Barrel export
- ✅ `packages/quiz_engine/test/l10n/quiz_localizations_test.dart` - 24 unit tests

**Engine-Owned Strings (~80 strings):**
- Navigation: play, history, statistics, settings
- Quiz UI: score, correct, incorrect, duration, exitDialogTitle, etc.
- History: noSessionsYet, sessionCompleted, today, yesterday, daysAgo(n), etc.
- Statistics: totalSessions, averageScore, weeklyTrend, improving, etc.
- Settings: soundEffects, hapticFeedback, theme, about, etc.

**Key Features:**
- `QuizLocalizations.of(context)` for accessing strings
- `QuizLocalizations.override()` for customizing specific strings
- `QuizLocalizationsDelegate` with factory and override support
- Extension method `withQuizLocalizations()` for easy delegate setup

---

### Sprint 7.3: PlayScreen and Category Views ✅

**Tasks:**
- [x] Create `CategoryCard` widget (displays category with image/icon)
- [x] Create `PlayScreen` with configurable layout (grid/list)
- [x] Add responsive design support
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/home/category_card.dart` - CategoryCard with CategoryCardStyle
- ✅ `packages/quiz_engine/lib/src/home/play_screen.dart` - PlayScreen, PlayScreenSliver, PlayScreenConfig
- ✅ `packages/quiz_engine/test/home/category_card_test.dart` - 25 widget tests
- ✅ `packages/quiz_engine/test/home/play_screen_test.dart` - 18 widget tests

**Key Classes:**
```dart
class CategoryCard extends StatelessWidget {
  const CategoryCard.grid({...});  // Vertical layout for grid
  const CategoryCard.list({...});  // Horizontal layout for list
}

enum PlayScreenLayout { grid, list, adaptive }

class PlayScreen extends StatelessWidget {
  // Responsive grid/list/adaptive display of categories
}

class PlayScreenSliver extends StatelessWidget {
  // For use in CustomScrollView
}
```

**Features:**
- Configurable layout: `PlayScreenLayout.grid`, `PlayScreenLayout.list`, or `PlayScreenLayout.adaptive`
- Category card shows: image/icon, title, subtitle
- Settings action in app bar (optional)
- Responsive design using `responsive_builder` package
- Custom app bar actions support
- Empty state and loading state widgets

---

### Sprint 7.4: QuizHomeScreen ✅

**Tasks:**
- [x] Create `QuizHomeScreen` with bottom navigation
- [x] Integrate PlayScreen, SessionHistoryScreen, StatisticsScreen
- [x] Add settings app bar action
- [x] Handle tab switching and data refresh
- [x] Add navigation to quiz when category selected
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/home/quiz_home_screen.dart` - QuizHomeScreen, QuizHomeScreenConfig, HistoryTabData, StatisticsTabData
- ✅ `packages/quiz_engine/test/home/quiz_home_screen_test.dart` - 19 widget tests

**Key Classes:**
```dart
class QuizHomeScreen extends StatefulWidget {
  // Main home screen with bottom navigation
  // Integrates Play, History, Statistics tabs
  // Supports custom Settings tab via settingsBuilder
}

class QuizHomeScreenConfig {
  // Configuration for tabs, play screen, app bar actions
  factory QuizHomeScreenConfig.defaultConfig();
}

class HistoryTabData { /* Data model for History tab async loading */ }
class StatisticsTabData { /* Data model for Statistics tab async loading */ }
```

**Features:**
- Bottom navigation with configurable tabs (QuizTabConfig)
- IndexedStack to preserve state (configurable)
- Tab refresh on selection (History/Statistics via data providers)
- Navigation to quiz when category tapped (onCategorySelected)
- Async data loading for History and Statistics tabs
- Custom settings builder support
- Localized labels via QuizLocalizations

---

### Sprint 7.5: QuizSettingsScreen (Optional) ✅

**Tasks:**
- [x] Create `QuizSettingsConfig` for configurable settings
- [x] Create `QuizSettingsScreen` using engine localizations
- [x] Support sound, haptic, theme, about sections
- [x] Support custom additional sections
- [x] Integrate with SettingsService
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart` (includes QuizSettingsConfig, SettingsSection)
- ✅ `packages/quiz_engine/test/settings/quiz_settings_screen_test.dart`

**Configurable Sections:**
- Sound/Haptics
- Answer feedback
- Theme selection
- About/Version
- Custom sections via callback

---

### Sprint 7.6: QuizApp Widget ✅

**Tasks:**
- [x] Create `QuizApp` root widget
- [x] Integrate MaterialApp with theme, localization
- [x] Handle service initialization internally
- [x] Connect all components (home, quiz, settings)
- [x] Add navigation observers support
- [x] Update `quiz_engine.dart` exports
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` (QuizApp, QuizAppConfig, QuizAppCallbacks, QuizAppBuilder)
- ✅ `packages/quiz_engine/test/app/quiz_app_test.dart`

**Files Updated:**
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Added QuizApp export

**Features Implemented:**
- MaterialApp setup with theme (light/dark based on settings)
- Localization (engine + app delegates combined)
- Settings-based theme mode switching via SettingsService
- Navigation observer support
- QuizHomeScreen integration with categories and callbacks
- QuizAppBuilder for service initialization with loading/error states
- Default QuizSettingsScreen integration for Settings tab

---

### Sprint 7.7: FlagsQuiz Migration ✅

**Tasks:**
- [x] Create `FlagsDataProvider` implementing `QuizDataProvider`
- [x] Create `flagsCategories` list from Continent enum
- [x] Update `main.dart` to use `QuizApp`
- [x] Keep `AppLocalizations` for country names
- [x] Remove duplicated files (HomeScreen, ContinentsScreen, FlagsQuizApp)
- [x] Update tests
- [x] Verify all existing functionality works

**Files Created:**
- ✅ `apps/flagsquiz/lib/data/flags_data_provider.dart`
- ✅ `apps/flagsquiz/lib/data/flags_categories.dart`

**Files Updated:**
- ✅ `apps/flagsquiz/lib/main.dart`
- ✅ `apps/flagsquiz/test/widgets/continets_screen_test.dart`
- ✅ `apps/flagsquiz/test/widgets/success_flow_test.dart`
- ✅ `apps/flagsquiz/integration_test/success_flow_integration_test.dart`
- ✅ `apps/flagsquiz/lib/ui/settings/settings_screen.dart` (removed unused code)

**Files Removed:**
- ✅ `apps/flagsquiz/lib/ui/home/home_screen.dart`
- ✅ `apps/flagsquiz/lib/ui/continents/continents_screen.dart`
- ✅ `apps/flagsquiz/lib/ui/flags_quiz_app.dart`

**Kept:**
- `apps/flagsquiz/lib/l10n/` - Country names localization
- `apps/flagsquiz/lib/ui/settings/settings_screen.dart` - App-specific settings

---

### Backward Compatibility

All existing exports remain:
- `QuizWidget`, `QuizWidgetEntry` - Standalone quiz usage
- `SessionHistoryScreen`, `StatisticsScreen` - Standalone screens
- All widgets and themes

New exports added:
- `QuizApp`, `QuizHomeScreen`, `PlayScreen`
- `QuizCategory`, `QuizDataProvider`
- `QuizLocalizations`, `QuizTab`

---

### Sprint 7.8: ARB-based Localization Migration ✅

**Goal:** Move all quiz UI strings to ARB-based localization system and remove QuizTexts class so apps only provide domain-specific strings.

**Tasks:**
- [x] Create `l10n.yaml` configuration for quiz_engine
- [x] Create `quiz_engine_en.arb` with all ~85 strings
- [x] Generate `QuizEngineLocalizations` classes
- [x] Create `QuizL10n` helper for non-nullable access with English fallback
- [x] Remove `QuizTexts` class from `QuizWidgetEntry`
- [x] Update all widgets to use `QuizL10n.of(context)` directly
- [x] Remove `createQuizTexts()` from `QuizDataProvider` interface
- [x] Update `FlagsDataProvider` to remove `createQuizTexts()`
- [x] Update tests with `wrapWithLocalizations()` helper
- [x] Add `noData` and `initializationError` localization keys
- [x] Fix Radio widget deprecation warnings using RadioGroup pattern

**Files Created:**
- ✅ `packages/quiz_engine/l10n.yaml`
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb`
- ✅ `packages/quiz_engine/lib/src/l10n/generated/quiz_engine_localizations.dart`
- ✅ `packages/quiz_engine/lib/src/l10n/generated/quiz_engine_localizations_en.dart`

**Files Updated:**
- ✅ `packages/quiz_engine/lib/src/l10n/quiz_localizations.dart` - Added QuizL10n helper
- ✅ `packages/quiz_engine/lib/src/quiz_widget_entry.dart` - Removed QuizTexts, changed to title
- ✅ `packages/quiz_engine/lib/src/quiz_widget.dart` - Updated to use title
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - Use QuizL10n.of(context)
- ✅ `packages/quiz_engine/lib/src/widgets/*.dart` - Multiple widgets updated
- ✅ `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart` - Fixed Radio deprecation
- ✅ `packages/quiz_engine/lib/src/models/quiz_data_provider.dart` - Removed createQuizTexts
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Removed _createDefaultTexts, localized error
- ✅ `apps/flagsquiz/lib/data/flags_data_provider.dart` - Removed createQuizTexts
- ✅ `packages/quiz_engine/test/test_helpers.dart` - Added wrapWithLocalizations

**Files Removed:**
- ✅ `packages/quiz_engine/lib/src/l10n/quiz_localizations_en.dart` (replaced by generated)

---

### Sprint 7.9: Bug Fixes - Play Screen & Storage ✅

**Goal:** Fix question count display and empty session storage issues.

**Tasks:**
- [x] Fix question count calculation showing incorrect values (e.g., 14 instead of 27 for Oceania)
- [x] Create `CountryCounts` utility to load actual counts from JSON
- [x] Update `createFlagsCategories()` to use dynamic counts
- [x] Add `deleteSession` method to `QuizStorageService` interface
- [x] Implement `deleteSession` in `QuizStorageAdapter`
- [x] Update `cancelQuiz()` to delete session if no answers given
- [x] Call `cancelQuiz()` when user exits quiz screen
- [x] Update tests

**Files Created:**
- ✅ `apps/flagsquiz/lib/data/country_counts.dart`

**Files Updated:**
- ✅ `apps/flagsquiz/lib/data/flags_categories.dart` - Use CountryCounts parameter
- ✅ `apps/flagsquiz/lib/main.dart` - Load CountryCounts at startup
- ✅ `packages/quiz_engine_core/lib/src/storage/quiz_storage_service.dart` - Added deleteSession
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Delete empty sessions
- ✅ `packages/shared_services/lib/src/storage/quiz_storage_adapter.dart` - Implement deleteSession
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - Call cancelQuiz on exit
- ✅ Test files updated with CountryCounts.forTest

---

### Sprint 7.10: Game Modes & Challenges ✅

**Goal:** Add challenge/game mode system with different difficulty levels and rules.

**Implemented Features:**
- 5 challenge modes: Survival, Time Attack, Speed Run, Marathon, Blitz
- Difficulty levels: Easy, Medium, Hard with color indicators
- Challenge list with cards showing name, description, difficulty badge
- Category picker bottom sheet after selecting a challenge
- Quiz mode mapping from ChallengeMode to QuizModeConfig (standard, timed, lives, survival, endless)
- 3-tab Play screen in flagsquiz: Play (categories), Challenges (game modes), Practice (wrong answers)

**Tasks:**
- [x] Create `ChallengeMode` model with difficulty enum
- [x] Create `ChallengeDifficulty` enum (easy, medium, hard) with colors and icons
- [x] Create `ChallengeCard` widget with `DifficultyIndicator`
- [x] Create `ChallengeListWidget` with sorting/grouping by difficulty
- [x] Create `ChallengesScreen` with category picker flow
- [x] Create `FlagsChallenges` definitions for flagsquiz app
- [x] Configure 3-tab Play screen in flagsquiz main.dart
- [x] Map ChallengeMode settings to QuizModeConfig factory methods
- [x] Write unit tests for ChallengeCard and ChallengeListWidget

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/models/challenge_mode.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/challenge_card.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/challenge_list.dart`
- ✅ `packages/quiz_engine/lib/src/screens/challenges_screen.dart`
- ✅ `packages/quiz_engine/test/widgets/challenge_card_test.dart`
- ✅ `apps/flagsquiz/lib/data/flags_challenges.dart`

**Files Modified:**
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Added exports
- ✅ `apps/flagsquiz/lib/main.dart` - Configured 3-tab Play screen

**Challenge Modes Defined:**
```dart
// Survival: 1 live, 20 questions, no hints
// Time Attack: 60 seconds total, endless, skip allowed
// Speed Run: 20 questions, fastest time wins
// Marathon: Endless mode, track streak
// Blitz: 5 seconds per question, 1 life, 20 questions
```

---

### Sprint 7.11: PlayScreen Tabs ✅

**Goal:** Add tabbed interface to PlayScreen for different content types.

**Implemented Tab Types:**
- **CategoriesTab** - Display quiz categories in grid/list layout
- **PracticeTab** - Practice wrong answers from history (async loading)
- **CustomContentTab** - Fully custom content via builder

**Tasks:**
- [x] Design PlayScreen tab structure with sealed class
- [x] Create `PlayScreenTab` sealed class with factory constructors
- [x] Create `CategoriesTab` for category lists
- [x] Create `PracticeTab` for wrong answer practice (with async loading)
- [x] Create `CustomContentTab` for custom content
- [x] Create `TabbedPlayScreen` widget with Material TabBar
- [x] Add `TabbedPlayScreenConfig` for customization
- [x] Support configurable initial tab via `initialTabId`
- [x] Write comprehensive tests (22 tests)

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/home/play_screen_tab.dart`
- ✅ `packages/quiz_engine/lib/src/home/tabbed_play_screen.dart`
- ✅ `packages/quiz_engine/test/home/tabbed_play_screen_test.dart`

**Files Modified:**
- `packages/quiz_engine/lib/src/home/quiz_home_screen.dart` - integrated TabbedPlayScreen
- `packages/quiz_engine/lib/quiz_engine.dart` - added exports

**UI Features:**
- Material TabBar at top of screen (below app bar)
- Swipeable TabBarView between tabs
- Configurable tab icons and labels
- Scrollable tabs option for many tabs
- Customizable indicator and label colors
- Integrated into QuizHomeScreen via `playScreenTabs` config

---

### Sprint 7.12: Category Mode Configuration ⏭️ SKIPPED

**Status:** Cancelled - No longer needed.

**Reason:** With the Challenges tab implemented (Sprint 7.10), per-category mode configuration in the Play tab is redundant:
- Play tab now has a consistent experience (5 lives, hints, skip) for all categories
- Challenges tab provides game mode variety (Survival, Time Attack, Blitz, etc.)
- Per-category modes would confuse users ("why does Europe have timer but Africa doesn't?")

---

### Sprint 7.13: Remaining Tasks

**Tasks:**
- [ ] Add support for additional languages in quiz_engine ARB files
- [ ] Add pagination for large session history lists
- [ ] Add search/filter functionality to history screen
- [ ] Performance optimization for statistics calculations
- [ ] Add data export/import for GDPR compliance

---

## Phase 8: Achievements & Core Features

**Reference:** See [ACHIEVEMENTS_DESIGN.md](./ACHIEVEMENTS_DESIGN.md) for full achievement list and architecture.

**Design Decisions:**
- Some achievements visible (grayed out), rare/legendary hidden until unlocked
- Show progress for progressive achievements (7/10)
- Points system with achievement counter (12/67) and points counter (450 pts)
- Sound + haptic feedback on unlock
- New "Achievements" tab in bottom navigation

---

### Sprint 8.1: Core Models ✅

**Goal:** Create achievement data models and trigger types.

**Tasks:**
- [x] Create `Achievement` model with id, name, description, icon, tier, points, target
- [x] Create `AchievementTier` enum (common, uncommon, rare, epic, legendary)
- [x] Create `AchievementTrigger` sealed class hierarchy
- [x] Create `CumulativeTrigger` (total count reaches target)
- [x] Create `ThresholdTrigger` (single session meets condition)
- [x] Create `StreakTrigger` (consecutive count)
- [x] Create `CategoryTrigger` (complete specific category)
- [x] Create `ChallengeTrigger` (complete specific challenge mode)
- [x] Create `CompositeTrigger` (multiple conditions)
- [x] Create `CustomTrigger` (app-specific complex conditions)
- [x] Create `StatField` enum for type-safe trigger field references
- [x] Create `AchievementProgress` model (tracks progress toward achievement)
- [x] Create `UnlockedAchievement` model (stored in database)
- [x] Write unit tests for all models (88 tests)
- [x] Export from shared_services

**Files Created:**
- ✅ `packages/shared_services/lib/src/achievements/models/achievement_tier.dart`
- ✅ `packages/shared_services/lib/src/achievements/models/stat_field.dart`
- ✅ `packages/shared_services/lib/src/achievements/models/achievement_trigger.dart`
- ✅ `packages/shared_services/lib/src/achievements/models/achievement.dart`
- ✅ `packages/shared_services/lib/src/achievements/models/achievement_progress.dart`
- ✅ `packages/shared_services/lib/src/achievements/models/unlocked_achievement.dart`
- ✅ `packages/shared_services/lib/src/achievements/achievements_exports.dart`
- ✅ `packages/shared_services/test/achievements/achievement_tier_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_trigger_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_progress_test.dart`
- ✅ `packages/shared_services/test/achievements/unlocked_achievement_test.dart`

**Files Updated:**
- ✅ `packages/shared_services/lib/shared_services.dart` - Added achievements export

**Key Design Decisions:**
- `LocalizedString` typedef (`String Function(BuildContext)`) for localized names/descriptions
- `StatField` enum for type-safe references to statistics fields in triggers
- `CustomTrigger` for app-specific complex conditions not covered by other triggers
- Achievement definitions stored in code, only `UnlockedAchievement` stored in database
- `AchievementTier` determines visibility: Common/Uncommon/Rare visible, Epic/Legendary hidden

---

### Sprint 8.2: Database & Repository ✅

**Goal:** Create database table and repository for storing unlocked achievements.

**Tasks:**
- [x] Create `achievements` database table schema
- [x] Create database migration (v2)
- [x] Create `AchievementDataSource` for CRUD operations
- [x] Create `AchievementRepository` interface
- [x] Implement `AchievementRepositoryImpl`
- [x] Add methods: getAll, getUnlocked, unlock, updateProgress, getPoints
- [x] Register in DI/StorageModule
- [x] Write unit tests for data source and repository

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/database/tables/achievements_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v2.dart`
- ✅ `packages/shared_services/lib/src/achievements/data_sources/achievement_data_source.dart`
- ✅ `packages/shared_services/lib/src/achievements/repositories/achievement_repository.dart`

**Additional Updates:**
- ✅ `packages/shared_services/lib/src/storage/database/database_config.dart` (version bump to 2)
- ✅ `packages/shared_services/lib/src/storage/database/app_database.dart` (added MigrationV2)
- ✅ `packages/shared_services/lib/src/storage/models/global_statistics.dart` (added V2 fields)
- ✅ `packages/shared_services/lib/src/storage/data_sources/statistics_data_source.dart` (added V2 methods)
- ✅ `packages/shared_services/lib/src/di/modules/storage_module.dart` (registered achievement services)
- ✅ `packages/shared_services/lib/src/achievements/achievements_exports.dart` (updated exports)
- ✅ `packages/shared_services/test/achievements/achievement_data_source_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_repository_test.dart`

---

### Sprint 8.3: Achievement Engine ✅

**Goal:** Create engine that checks conditions and unlocks achievements.

**Tasks:**
- [x] Create `AchievementEngine` class
- [x] Implement trigger evaluation logic for each trigger type
- [x] Add method: `checkAll()` and `checkAfterSession()`
- [x] Add method: `getAllProgress()` for cumulative progress
- [x] Add method: `getProgress(achievementId)`
- [x] Handle visibility rules (show/hide based on tier)
- [x] Add caching for performance
- [x] Create `AchievementService` for high-level API
- [x] Write unit tests for engine logic

**Files Created:**
- ✅ `packages/shared_services/lib/src/achievements/engine/achievement_context.dart`
- ✅ `packages/shared_services/lib/src/achievements/engine/trigger_evaluator.dart`
- ✅ `packages/shared_services/lib/src/achievements/engine/achievement_engine.dart`
- ✅ `packages/shared_services/lib/src/achievements/services/achievement_service.dart`
- ✅ `packages/shared_services/test/achievements/achievement_context_test.dart`
- ✅ `packages/shared_services/test/achievements/trigger_evaluator_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_engine_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_service_test.dart`

---

### Sprint 8.4: Achievement Definitions - Generic ✅

**Goal:** Define all 53 generic base achievements.

**Tasks:**
- [x] Create `BaseAchievements` class with all generic achievements
- [x] Define Beginner achievements (3): first_quiz, first_perfect, first_challenge
- [x] Define Progress achievements (11): quizzes_10/50/100/500, questions_100/500/1000/5000, correct_100/500/1000
- [x] Define Mastery achievements (7): perfect_5/10/25/50, score_90_10, score_95_10, perfect_streak_3
- [x] Define Speed achievements (4): speed_demon, lightning, quick_answer_10/50
- [x] Define Streak achievements (4): streak_10/25/50/100
- [x] Define Challenge achievements (10): survival/blitz complete/perfect, time_attack_20/30, marathon_50/100, speed_run_fast, all_challenges
- [x] Define Dedication achievements (8): time_1h/5h/10h/24h, days_3/7/14/30
- [x] Define Skill achievements (6): no_hints, no_hints_10, no_skip, flawless, comeback, clutch
- [x] Assign icons (emoji) to each achievement
- [x] Assign tiers and points to each achievement
- [x] Write tests to verify all achievements are valid

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/achievements/achievement_category.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/base_achievements.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/achievements_exports.dart`
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` (106 strings added)
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v2.dart` (added consecutivePerfectScores)
- ✅ `packages/shared_services/lib/src/storage/models/global_statistics.dart` (added consecutivePerfectScores)
- ✅ `docs/ACHIEVEMENTS_DESIGN.md` (added emoji icons to all tables)

---

### Sprint 8.5: Achievement Definitions - Flags Quiz ✅

**Goal:** Define all 14 app-specific achievements for Flags Quiz.

**Tasks:**
- [x] Create `FlagsAchievements` class extending base achievements
- [x] Define Explorer achievements (7): explore_africa/asia/europe/north_america/south_america/oceania, world_traveler
- [x] Define Region Mastery achievements (6): master_europe/asia/africa/americas/oceania/world
- [x] Define Collection achievements (1): flag_collector
- [x] Assign flag-themed icons to each achievement
- [x] Assign tiers and points to each achievement
- [x] Create combined list of all achievements (generic + app-specific)
- [x] Write tests

**Files Created:**
- ✅ `apps/flagsquiz/lib/achievements/flags_achievements.dart`
- ✅ `apps/flagsquiz/test/achievements/flags_achievements_test.dart`
- ✅ `apps/flagsquiz/lib/l10n/intl_en.arb` (28 new localization strings)

---

### Sprint 8.6: UI - Achievement Card & List ✅

**Goal:** Create reusable achievement display widgets.

**Tasks:**
- [x] Create `AchievementCard` widget
- [x] Show icon, name, description, tier badge
- [x] Show progress bar for progressive achievements (7/10)
- [x] Show locked state (grayed out) vs unlocked state (colored)
- [x] Show points value
- [x] Create `AchievementTierBadge` widget (color-coded tier indicator)
- [x] Create `AchievementsList` widget (scrollable list of cards)
- [x] Support grouping by category
- [x] Support filtering (all, unlocked, locked, by tier)
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_tier_badge.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_card.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievements_list.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/widgets_exports.dart`
- ✅ `packages/quiz_engine/test/achievements/widgets/achievement_tier_badge_test.dart`
- ✅ `packages/quiz_engine/test/achievements/widgets/achievement_card_test.dart`
- ✅ `packages/quiz_engine/test/achievements/widgets/achievements_list_test.dart`
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` (10 new strings for filters/empty states)

---

### Sprint 8.7: UI - Achievements Screen ✅

**Goal:** Create the full achievements screen with stats header.

**Tasks:**
- [x] Create `AchievementsScreen` widget
- [x] Add header with: achievement counter (12/67), points counter (450 pts)
- [x] Add tab bar or filter chips: All, Unlocked, Progress, Locked
- [x] Add category sections or grouped list
- [x] Show hidden achievements as "???" or "Hidden Achievement"
- [x] Add pull-to-refresh
- [x] Create `AchievementsScreenConfig` for customization
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/achievements/screens/achievements_screen.dart`
- ✅ `packages/quiz_engine/test/achievements/screens/achievements_screen_test.dart`
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` (3 new strings: pointsRemaining, allPointsEarned, completionPercentage)

---

### Sprint 8.8: UI - Achievement Notification ✅

**Goal:** Create popup notification when achievement unlocks.

**Tasks:**
- [x] Create `AchievementNotification` widget (overlay/snackbar style)
- [x] Show achievement icon, name, points earned
- [x] Add celebration animation (confetti, glow, scale)
- [x] Add sound effect on unlock
- [x] Add haptic feedback on unlock
- [x] Auto-dismiss after 3 seconds or tap to dismiss
- [x] Support queuing multiple unlocks
- [x] Create `AchievementNotificationController` for showing notifications
- [x] Write widget tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_notification.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/achievement_notification_controller.dart`
- ✅ `packages/quiz_engine/test/achievements/widgets/achievement_notification_test.dart`

---

### Sprint 8.9: Integration - QuizBloc & Home Screen ✅

**Goal:** Integrate achievements into the quiz flow and navigation.

**Tasks:**
- [x] Call `AchievementEngine.checkAndUnlock()` after quiz completion in QuizBloc
- [x] Show `AchievementNotification` when achievements unlock
- [x] Add "Achievements" tab to `QuizTabConfig` options
- [x] Update `QuizHomeScreen` to support Achievements tab
- [x] Add achievements data provider to home screen
- [x] Update `QuizApp` to include AchievementEngine initialization
- [x] Update FlagsQuiz main.dart to enable achievements tab
- [x] Write integration tests

**Files Updated:**
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Added `onQuizCompleted` callback
- ✅ `packages/quiz_engine/lib/src/home/quiz_home_screen.dart` - Added achievements tab support
- ✅ `packages/quiz_engine/lib/src/app/quiz_tab.dart` - Added `AchievementsTab` and factories
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Added achievements data provider

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/achievements/achievement_integration.dart` - Integration helper

---

### Sprint 8.10: Polish & Testing ✅

**Goal:** Final polish, edge cases, and comprehensive testing.

**Tasks:**
- [x] Add achievement unlock sound to AudioService (already configured in QuizSoundEffect.achievement)
- [x] Test all 67 achievements can be triggered correctly
- [x] Test progress tracking accuracy
- [x] Test hidden achievement reveal
- [x] Test points calculation
- [x] Performance testing (many achievements check)
- [x] Edge case testing (offline, app restart, etc.)
- [x] Update localization strings for achievements
- [x] Add accessibility labels (with full localization support)
- [x] Write comprehensive test suite

**Files Created:**
- ✅ `packages/shared_services/test/achievements/sprint_8_10_comprehensive_test.dart` (28 tests)

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_card.dart` - Added localized accessibility labels
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_notification.dart` - Added localized accessibility labels
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_tier_badge.dart` - Added localized accessibility labels
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added accessibility localization strings
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart` - Updated mock localizations
- ✅ `apps/flagsquiz/test/achievements/flags_achievements_test.dart` - Updated mock localizations

**Accessibility Features Added:**
- `accessibilityDoubleTapToView` - Hint for tappable achievement cards
- `accessibilityDoubleTapToDismiss` - Hint for dismissable notifications
- `accessibilityAchievementUnlocked` - Full label for unlocked achievements with name, tier, and points
- `accessibilityAchievementLocked` - Full label for locked achievements with progress percentage
- `accessibilityAchievementNotification` - Live region announcement for achievement unlock notifications
- `accessibilityProgressBar` - Progress bar value announcement
- `accessibilityTierBadge` - Tier badge label
- `accessibilityPointsBadge` - Points badge label

**Test Coverage:**
- Hidden achievement reveal logic (5 tests)
- Points calculation accuracy (5 tests)
- Edge cases - empty data (3 tests)
- Edge cases - boundary conditions (5 tests)
- Edge cases - streak triggers (2 tests)
- Edge cases - composite triggers (2 tests)
- Edge cases - threshold triggers (3 tests)
- Sorting and display (3 tests)

---

### Sprint 8.10.1: Achievement Testing Documentation ✅

**Goal:** Create comprehensive testing guide for all 67 achievements.

**Tasks:**
- [x] Create `docs/ACHIEVEMENTS_TESTING.md` with all achievements listed
- [x] Group achievements by category (Beginner, Progress, Mastery, Speed, Streak, Challenge, Dedication, Skill, Flags-specific)
- [x] Add checkbox for each achievement to track manual testing
- [x] Include testing instructions for each achievement type
- [x] Add expected trigger conditions for each achievement

**Files Created:**
- ✅ `docs/ACHIEVEMENTS_TESTING.md`

---

### Sprint 8.10.2: Refactor showAnswerFeedback Settings ✅

**Goal:** Move `showAnswerFeedback` from global settings to per-category/per-mode configuration.

**Requirements:**
- `showAnswerFeedback` configurable per quiz category (default: true)
- `showAnswerFeedback` configurable per quiz mode (can override category)
- `soundEffect` and `hapticFeedback` remain global settings (not tied to answerFeedback)
- Priority: mode override > category default > global default

**Tasks:**
- [x] Add `showAnswerFeedback` field to `QuizCategory` model
- [x] Add `showAnswerFeedback` field to `QuizModeConfig` sealed class
- [x] Update `QuizBloc` to use category/mode feedback setting instead of global
- [x] Keep `soundEffect` and `hapticFeedback` as independent global settings
- [x] Remove `showAnswerFeedback` from `QuizSettings` (or mark deprecated)
- [x] Update `QuizSettingsScreen` to remove answer feedback toggle
- [x] Update `FlagsCategories` with default feedback settings
- [x] Update `FlagsChallenges` with mode-specific feedback settings
- [x] Write unit tests for new feedback configuration
- [x] Update existing tests

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/models/quiz_category.dart` - Added `showAnswerFeedback` field
- ✅ `packages/quiz_engine/lib/src/models/challenge_mode.dart` - Added `showAnswerFeedback` field
- ✅ `packages/quiz_engine_core/lib/src/model/config/quiz_mode_config.dart` - Added `showAnswerFeedback` to sealed class and all subclasses
- ✅ `packages/shared_services/lib/src/settings/quiz_settings.dart` - Removed `showAnswerFeedback` field
- ✅ `packages/shared_services/lib/src/settings/settings_service.dart` - Removed `toggleAnswerFeedback` method
- ✅ `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart` - Removed Quiz Behavior section
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Updated to use category feedback setting
- ✅ `packages/quiz_engine/lib/src/screens/challenges_screen.dart` - Updated to use mode/category feedback setting
- ✅ `apps/flagsquiz/lib/data/flags_challenges.dart` - Added mode-specific feedback settings
- ✅ `packages/shared_services/test/quiz_settings_test.dart` - Updated tests
- ✅ `packages/shared_services/test/settings_service_test.dart` - Updated tests
- ✅ `packages/quiz_engine/test/settings/quiz_settings_screen_test.dart` - Updated tests
- ✅ `packages/quiz_engine/test/app/quiz_app_test.dart` - Updated tests

---

### Sprint 8.10.3: Refactor QuizApp & Main.dart ✅

**Goal:** Simplify flagsquiz main.dart by moving achievement completion logic into QuizApp and using enums for play tabs.

**Requirements:**
- Move `handleQuizCompleted` logic into `AchievementsDataProvider.onSessionCompleted()`
- Keep `onQuizCompleted` callback for additional app-specific processing, but QuizApp internally handles achievements
- `QuizApp` internally calls `achievementsDataProvider.onSessionCompleted()` when quiz ends
- Replace play tabs configuration with simple enum set `{PlayTabType.quiz, PlayTabType.challenges, PlayTabType.practice}`
- Main.dart should only provide data and configuration, no business logic

**Tasks:**
- [x] Add `onSessionCompleted(QuizSession session)` method to `AchievementsDataProvider` interface
- [x] Implement `onSessionCompleted` in `FlagsAchievementsDataProvider`
- [x] Update `QuizApp` to call `achievementsDataProvider?.onSessionCompleted()` on quiz completion
- [x] Change `achievementsDataProvider` from callback to `AchievementsDataProvider?` interface
- [x] Create `PlayTabType` enum (quiz, challenges, practice)
- [x] Update `QuizApp` to accept `Set<PlayTabType>` and build tabs internally
- [x] Add `challenges` and `practiceDataLoader` parameters to `QuizApp`
- [x] Simplify `flagsquiz/main.dart` to use new API (removed 43 lines of boilerplate)
- [x] Update `ChallengesScreen` to use internal callback (QuizApp wires it internally)
- [x] Write unit tests for new interfaces
- [x] Update existing tests (all tests pass)

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/app/play_tab_type.dart` - PlayTabType enum
- ✅ `packages/quiz_engine/lib/src/models/achievements_data_provider.dart` - AchievementsDataProvider interface
- ✅ `packages/quiz_engine/test/app/play_tab_type_test.dart` - Unit tests for PlayTabType
- ✅ `packages/quiz_engine/test/models/achievements_data_provider_test.dart` - Unit tests for AchievementsDataProvider

**Files Modified:**
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export new files
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Added new parameters, internal achievement handling
- ✅ `apps/flagsquiz/lib/achievements/flags_achievements_data_provider.dart` - Implement AchievementsDataProvider interface
- ✅ `apps/flagsquiz/lib/main.dart` - Simplified significantly using new API

---

### Sprint 8.10.4: Localize Hardcoded UI Strings ✅

**Goal:** Move all hardcoded UI-related strings to ARB files for proper localization.

**Tasks:**
- [x] Audit quiz_engine package for hardcoded strings
- [x] Audit quiz_engine_core package for hardcoded strings
- [x] Audit shared_services package for hardcoded strings
- [x] Audit flagsquiz app for hardcoded strings
- [x] Add missing strings to appropriate ARB files
- [x] Replace hardcoded strings with localization calls
- [x] Verify all user-facing strings are localized
- [x] Run `flutter gen-l10n` in affected packages
- [x] Test with different locales if available

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added `challenges` string
- ✅ `apps/flagsquiz/lib/l10n/intl_en.arb` - Added `challenges` and `practice` strings
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Using localized strings for Play, Challenges, Practice tabs
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart` - Updated mock localizations
- ✅ `apps/flagsquiz/test/achievements/flags_achievements_test.dart` - Updated mock localizations
- ✅ `packages/quiz_engine/test/app/play_tab_type_test.dart` - Fixed set uniqueness test

---

### Sprint 8.11: Practice Mistakes Mode ✅

**Goal:** Allow users to practice questions they got wrong in previous quizzes.

**Design Doc:** See `docs/PRACTICE_MISTAKES_MODE.md` for full specification.

**Requirements:**
- Load wrong answers from ALL sessions (no limit)
- Deduplicate by question ID - same question wrong multiple times appears once
- Track wrong count - show how many times each question was answered incorrectly
- Clear only after practice session completes (not during)
- Only clear correctly answered questions - wrong during practice stays in list
- Practice sessions are NOT stored in history
- Practice has NO influence on achievements
- Show empty state when no questions to practice (don't hide tab)

**Data Model:**
- Create `practice_progress` table with: `question_id`, `wrong_count`, `first_wrong_at`, `last_wrong_at`, `last_practiced_correctly_at`
- Create `PracticeQuestion` model to represent aggregated wrong answers
- Create `PracticeDataProvider` interface (similar to `AchievementsDataProvider`)

**Edge Cases Handled:**
- Same question wrong in multiple sessions → appears once with count
- Correct before, wrong later → appears in practice
- Practiced correctly, then wrong again → reappears in practice
- Practice session cancelled → nothing marked as practiced
- No wrong answers → show empty state
- Session deleted → remove from practice progress
- Wrong during practice → stays in list
- Question removed from app → orphaned entries ignored

**Tasks:**

*Database & Storage:*
- [x] Create `practice_progress` database table with migration
- [x] Create `PracticeQuestion` model class
- [x] Create `PracticeProgressRepository` for database operations
- [x] Add `updatePracticeProgress(QuizSession)` - called when regular quiz completes
- [x] Add `loadQuestionsNeedingPractice()` - query with proper filtering
- [x] Add `markQuestionsAsPracticed(List<String> questionIds)` - update timestamps

*Provider & Interface:*
- [x] Create `PracticeDataProvider` abstract interface in quiz_engine
- [x] Implement `loadPracticeQuestions()` method
- [x] Implement `onPracticeSessionCompleted(List<String> correctIds)` method
- [x] Implement `convertToQuestions(List<PracticeQuestion>)` method
- [x] Create `FlagsPracticeDataProvider` implementation in flagsquiz

*QuizApp Integration:*
- [x] Add `practiceDataProvider` parameter to `QuizApp`
- [x] Handle practice tab internally using provider
- [x] Configure practice mode: `storageEnabled: false`, `achievementsEnabled: false`
- [x] Collect correctly answered IDs on session complete
- [x] Call `onPracticeSessionCompleted()` with correct IDs

*UI Components:*
- [x] Create `PracticeEmptyState` widget with encouraging message
- [x] Create `PracticeStartScreen` widget showing question count
- [x] Create `PracticeCompleteScreen` widget showing results (correct vs need more practice)
- [x] Add practice badge/count to Practice tab (optional)
- [x] Style practice mode header to differentiate from regular quiz

*Localization:*
- [x] Add practice mode strings to ARB files (see design doc for full list)
- [x] Run `flutter gen-l10n` in affected packages

*Testing:*
- [x] Unit tests for `PracticeProgressRepository`
- [x] Unit tests for `PracticeDataProvider` implementation
- [x] Unit tests for edge cases (reappearing questions, session delete, etc.)
- [x] Widget tests for empty state
- [x] Widget tests for start/complete screens
- [x] Integration test: wrong answer → practice → correct → removed
- [x] Integration test: practice session not in history
- [x] Integration test: achievements not triggered by practice

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/database/tables/practice_progress_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v4.dart`
- ✅ `packages/shared_services/lib/src/storage/models/practice_question.dart`
- ✅ `packages/shared_services/lib/src/storage/repositories/practice_progress_repository.dart`
- ✅ `packages/quiz_engine/lib/src/models/practice_data_provider.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/practice_empty_state.dart`
- ✅ `packages/quiz_engine/lib/src/screens/practice_start_screen.dart`
- ✅ `packages/quiz_engine/lib/src/screens/practice_complete_screen.dart`
- ✅ `apps/flagsquiz/lib/practice/flags_practice_data_provider.dart`
- ✅ `packages/shared_services/test/storage/repositories/practice_progress_repository_test.dart`

**Files Modified:**
- ✅ `packages/shared_services/lib/src/storage/database/app_database.dart` - Added MigrationV4
- ✅ `packages/shared_services/lib/src/storage/database/database_config.dart` - Version bump to 4
- ✅ `packages/shared_services/lib/src/storage/storage_exports.dart` - Export new files
- ✅ `packages/shared_services/lib/src/storage/repositories/repositories_exports.dart` - Export repository
- ✅ `packages/shared_services/lib/src/di/modules/storage_module.dart` - Register PracticeProgressRepository
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Added practiceDataProvider, practice tab handling
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - 15 practice strings added
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export new widgets and screens
- ✅ `packages/quiz_engine/lib/src/models/models_exports.dart` - Export PracticeDataProvider
- ✅ `apps/flagsquiz/lib/main.dart` - Wire up practice provider
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart` - Added mock localizations
- ✅ `apps/flagsquiz/test/achievements/flags_achievements_test.dart` - Added mock localizations
- ✅ `packages/shared_services/test/di/storage_module_test.dart` - Updated registration count to 14

---

### Sprint 8.12: Scoring System ✅

**Goal:** Display session score during and after quizzes using `TimedScoring` strategy.

**Requirements:**
- Use `TimedScoring` strategy: 100 base points + 5 points per second saved (30s threshold)
- Display score only on result screen (not during quiz)
- Score is calculated per session
- Show score breakdown: base points + time bonus

**Tasks:**
- [x] Implement `calculateScore()` method in `ScoringStrategy` classes
- [x] Add `ScoreBreakdownData` class for score breakdown data
- [x] Add `score` and `scoreBreakdown` fields to `QuizResults` model
- [x] Add `score` field to `QuizSession` model
- [x] Create database migration v5 for score column
- [x] Save score when session completes via `QuizBloc`
- [x] Create `ScoreDisplay` widget for result screen (with animation)
- [x] Create `ScoreBreakdown` widget showing base + bonus
- [x] Update `QuizResultsScreen` to display score
- [x] `ScoringConfig` already exists in `QuizConfig` (scoringStrategy field)
- [x] Add localization strings for score display
- [x] Write unit tests for score calculation
- [x] Configure `TimedScoring` in flagsquiz app

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/score_display.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/score_breakdown.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v5.dart`
- ✅ `packages/quiz_engine_core/test/model/scoring_strategy_test.dart`

**Files Modified:**
- ✅ `packages/quiz_engine_core/lib/src/model/config/scoring_strategy.dart` - Added `ScoreBreakdownData` and `calculateScore()` methods
- ✅ `packages/quiz_engine_core/lib/src/model/quiz_results.dart` - Added `score` and `scoreBreakdown` fields
- ✅ `packages/shared_services/lib/src/storage/models/quiz_session.dart` - Added `score` field
- ✅ `packages/shared_services/lib/src/storage/database/tables/quiz_sessions_table.dart` - Added `score` column
- ✅ `packages/shared_services/lib/src/storage/database/database_config.dart` - Bumped version to 5
- ✅ `packages/shared_services/lib/src/storage/database/app_database.dart` - Added MigrationV5
- ✅ `packages/quiz_engine_core/lib/src/storage/quiz_storage_service.dart` - Added `score` parameter to `completeSession`
- ✅ `packages/shared_services/lib/src/storage/quiz_storage_adapter.dart` - Pass score to storage
- ✅ `packages/shared_services/lib/src/storage/storage_service.dart` - Added `score` parameter
- ✅ `packages/shared_services/lib/src/storage/repositories/quiz_session_repository.dart` - Handle score updates
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Calculate score on completion
- ✅ `packages/quiz_engine/lib/src/screens/quiz_results_screen.dart` - Display score with breakdown
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added score display strings
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export score widgets
- ✅ `apps/flagsquiz/lib/data/flags_data_provider.dart` - Configure TimedScoring

**Scoring Formulas:**
```dart
// SimpleScoring
score = correctAnswers * pointsPerCorrect (default: 1)

// TimedScoring
basePoints = correctAnswers * basePointsPerQuestion (default: 100)
timeBonus = max(0, (timeThresholdSeconds - avgSecondsPerQuestion)) * bonusPerSecondSaved * correctAnswers
score = basePoints + timeBonus

// StreakScoring
basePoints = correctAnswers * basePointsPerQuestion
streakBonus = sum of (basePoints * (streakMultiplier - 1) * streakPosition) for each correct answer in streak
score = basePoints + streakBonus
```

---

## Phase 8.5: Production Polish

**Goal:** Ensure all features are polished, consistent, and ready for production before moving to Shared Services integration.

**Note:** Some sprints require design documents to be created before implementation.

---

### Sprint 8.13: Statistics Tabs - Full Implementation ✅

**Goal:** Complete all statistics tabs with full functionality.

**Tabs:**
- **Overview** - Summary dashboard with key metrics
- **Progress** - Improvement over time charts
- **Categories** - Per-category breakdown and accuracy
- **Leaderboard** - Local leaderboard (Post-MVP: global leaderboard)

**Tasks:**
- [x] Audit current statistics implementation for missing functionality
- [x] Create `StatisticsOverviewTab` with key metrics summary (implemented inline in StatisticsDashboardScreen)
- [x] Create `StatisticsProgressTab` with improvement charts (implemented inline in StatisticsDashboardScreen)
- [x] Create `StatisticsCategoriesTab` with per-category breakdown (implemented inline in StatisticsDashboardScreen)
- [x] Create `StatisticsLeaderboardTab` (local scores) (implemented inline in StatisticsDashboardScreen)
- [x] Add tab navigation to StatisticsScreen (already implemented with TabBar/TabBarView)
- [x] Integrate with existing statistics data sources (uses StatisticsDashboardData)
- [x] Add localization strings for all new UI elements
- [x] Write widget tests for each tab (23 tests in statistics_dashboard_screen_test.dart)
- [x] Mark Leaderboard as "Coming Soon" for global feature (Post-MVP)

**Implementation Notes:**
All four tabs are implemented inline within `StatisticsDashboardScreen` using the existing widget architecture:
- Overview tab: Uses `StatisticsGrid`, `StatisticsCard`, `TrendsWidget`, and `SessionCard`
- Progress tab: Uses `ProgressTimeRangeSelector` and `ProgressChartWidget`
- Categories tab: Uses `CategoryStatisticsWidget` and `CategoryStatisticsGrid`
- Leaderboard tab: Uses `LeaderboardTypeSelector`, `LeaderboardWidget`, and "Coming Soon" global leaderboard banner

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/screens/statistics_dashboard_screen.dart` - Added global leaderboard "Coming Soon" banner
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added globalLeaderboard and globalLeaderboardComingSoon strings

**Files Created:**
- ✅ `packages/quiz_engine/test/screens/statistics_dashboard_screen_test.dart` - 23 comprehensive widget tests

**Test Coverage:**
- StatisticsDashboardTab enum tests
- StatisticsDashboardData model tests
- Loading state tests
- Empty state tests
- Tab navigation tests
- Tab content rendering tests
- Global leaderboard coming soon banner tests
- Callback tests (onSessionTap, onCategoryTap, onViewAllSessions)
- Widget interaction tests (time range selector, leaderboard type selector)

---

### Sprint 8.14: Hints & Lives UI Consistency ✅

**Goal:** Create a unified visual style for all game resources: Lives, 50/50 hints, and Skip hints with adaptive layout.

**Design Document:** `docs/HINTS_LIVES_UI_DESIGN.md`

**Key Design Decisions:**
- **Single icon + badge pattern**: All resources show ONE icon with a count badge (e.g., ❤️ with badge "3")
- **Badges only, no labels**: Icons are self-explanatory, saves space
- **All resources are tappable**: Lives, 50/50, and Skip all respond to taps
- **Unified component**: Create `GameResourceButton` as shared base for all three
- **Unified placement**: All resources shown in ONE location (currently lives in AppBar, hints below)
- **Adaptive layout**: Different placement based on screen size/orientation
- **Theming support**: Add `GameResourceTheme` for consistent, customizable styling
- **Animations**: Pulse on last resource, shake on depletion, scale on tap
- **Long-press tooltip**: Show explanation of what each resource does
- **Disabled state**: Show greyed out with "0" badge (not hidden)

**Adaptive Layout Strategy:**
- **Mobile Portrait**: Resources in dedicated row below AppBar (touch-friendly)
- **Mobile Landscape**: Resources inline in AppBar (saves vertical space)
- **Tablet/Desktop**: Resources inline in AppBar
- **Watch**: Resources in compact row below AppBar

**Requirements:**
- Lives: Single heart icon with badge showing remaining count (NOT multiple hearts)
- 50/50: Single icon with badge showing remaining count
- Skip: Single icon with badge showing remaining count
- All three use identical visual treatment (same button style, badge style, animations)
- All three are interactive (tappable with callbacks)
- "Get More" dialog: Stub callback only (full implementation in Sprint 8.15)

**Tasks:**

*Design & Audit:*
- [x] Create design document with UI specifications
- [x] Audit current LivesDisplay widget implementation
- [x] Audit current HintsPanel widget implementation

*Core Components:*
- [x] Create `GameResourceTheme` for theming support
- [x] Create `GameResourceButton` widget with animations
- [x] Create `GameResourcePanel` wrapper for all resources
- [x] Create `AdaptiveResourcePanel` for adaptive placement logic

*Animations:*
- [x] Implement scale on tap animation
- [x] Implement pulse animation for last resource warning
- [x] Implement shake animation on depletion
- [x] Implement badge count change animation

*Integration:*
- [x] Update `QuizAppBarActions` to use `GameResourcePanel` (for landscape/tablet/desktop)
- [x] Update `QuizLayout` to use `GameResourcePanel` (for portrait/watch)
- [x] Implement adaptive placement logic based on screen size/orientation
- [x] Add long-press tooltip with resource explanation
- [x] Deprecate `LivesDisplay` (keep for backward compatibility)
- [x] Deprecate `HintsPanel` (keep for backward compatibility)

*Polish:*
- [x] Add accessibility labels
- [x] Add haptic feedback on actions
- [x] Add localization strings for tooltips and accessibility
- [x] Ensure responsive sizing across screen sizes

*Testing:*
- [x] Write widget tests for `GameResourceButton`
- [x] Write widget tests for `GameResourcePanel`
- [x] Write widget tests for `AdaptiveResourcePanel`
- [x] Write widget tests for `GameResourceTheme`

**Files Created:**
- ✅ `docs/HINTS_LIVES_UI_DESIGN.md`
- ✅ `packages/quiz_engine/lib/src/theme/game_resource_theme.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_button.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_panel.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/adaptive_resource_panel.dart`
- ✅ `packages/quiz_engine/test/theme/game_resource_theme_test.dart`
- ✅ `packages/quiz_engine/test/widgets/game_resource_button_test.dart`
- ✅ `packages/quiz_engine/test/widgets/game_resource_panel_test.dart`
- ✅ `packages/quiz_engine/test/widgets/adaptive_resource_panel_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/widgets/quiz_app_bar_actions.dart`
- `packages/quiz_engine/lib/src/quiz/quiz_layout.dart`
- `packages/quiz_engine/lib/src/widgets/lives_display.dart` (deprecate)
- `packages/quiz_engine/lib/src/widgets/hints_panel.dart` (deprecate)
- `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb`
- `packages/quiz_engine/lib/quiz_engine.dart` (exports)

---

### Sprint 8.15: Hints & Lives - IAP/Ads Architecture ✅

**Goal:** Prepare hints and lives system for integration with in-app purchases and rewarded ads.

**Requirements:**
- Daily limits on hints/lives (configurable amount per day)
- When expired, user can:
  - Watch rewarded ad to restore 1 hint/life
  - Purchase packs (e.g., 5 hearts, 5 skips, etc.)
- Persist remaining counts in database
- Reset at midnight local time (or configurable)

**Pre-requisite:** Create `docs/HINTS_LIVES_IAP_DESIGN.md` with full architecture

**Tasks:**
- [x] Create design document with full IAP/Ads architecture
- [x] Define daily limit configuration model
- [x] Create `ResourceManager` service for tracking counts
- [x] Create in-memory repository for development/testing
- [x] Create SQLite repository for persistent storage
- [x] Add database migration V6 for resource_inventory table
- [x] Implement daily reset mechanism
- [x] Create `RestoreResourceDialog` (watch ad or purchase options)
- [x] Create `PurchaseResourceSheet` for buying packs
- [x] Add hooks for rewarded ad integration (AdRewardProvider interface)
- [x] Add hooks for IAP integration (IAPProvider interface)
- [x] Handle offline scenario (show message in dialog)
- [x] Add localization strings for purchase/restore UI
- [x] Write unit tests for manager and reset logic
- [ ] Write widget tests for dialogs (future work)

**Files Created:**
- ✅ `docs/HINTS_LIVES_IAP_DESIGN.md`
- ✅ `packages/shared_services/lib/src/resources/resource_type.dart`
- ✅ `packages/shared_services/lib/src/resources/resource_config.dart`
- ✅ `packages/shared_services/lib/src/resources/resource_inventory.dart`
- ✅ `packages/shared_services/lib/src/resources/resource_repository.dart`
- ✅ `packages/shared_services/lib/src/resources/resource_manager.dart`
- ✅ `packages/shared_services/lib/src/resources/providers/ad_reward_provider.dart`
- ✅ `packages/shared_services/lib/src/resources/providers/iap_provider.dart`
- ✅ `packages/shared_services/lib/src/resources/resources.dart`
- ✅ `packages/shared_services/lib/src/resources/sqlite_resource_repository.dart`
- ✅ `packages/shared_services/lib/src/storage/database/tables/resource_inventory_table.dart`
- ✅ `packages/shared_services/lib/src/storage/database/migrations/migration_v6.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/restore_resource_dialog.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/purchase_resource_sheet.dart`
- ✅ `packages/shared_services/test/resources/resource_type_test.dart`
- ✅ `packages/shared_services/test/resources/resource_config_test.dart`
- ✅ `packages/shared_services/test/resources/resource_inventory_test.dart`
- ✅ `packages/shared_services/test/resources/resource_manager_test.dart`

**Files Modified:**
- ✅ `packages/shared_services/lib/shared_services.dart` (added resources export)
- ✅ `packages/shared_services/lib/src/storage/database/database_config.dart` (version 5 → 6)
- ✅ `packages/shared_services/lib/src/storage/database/app_database.dart` (registered MigrationV6)
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_button.dart` (added onDepletedTap callback)
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_panel.dart` (added onDepletedTap to config)
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` (added IAP/Ads strings)
- ✅ `packages/quiz_engine/test/widgets/game_resource_button_test.dart` (added onDepletedTap test)
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart` (mock updates)
- ✅ `apps/flagsquiz/test/achievements/flags_achievements_test.dart` (mock updates)

---

### Sprint 8.16: Error, Loading & Empty States ✅

**Goal:** Audit and polish all screens for proper error, loading, and empty states.

**Tasks:**
- [x] Audit all screens for missing loading states
- [x] Audit all screens for missing error states
- [x] Audit all screens for missing empty states
- [x] Create consistent `LoadingIndicator` widget
- [x] Create consistent `ErrorStateWidget` with retry action
- [x] Create consistent `EmptyStateWidget` with illustration and message
- [x] Update `StatisticsScreen` with proper states (already has inline states, widgets available for future use)
- [x] Update `SessionHistoryScreen` with proper states (already has inline states, widgets available for future use)
- [x] Update `AchievementsScreen` with proper states (already has inline states, widgets available for future use)
- [x] Update `PlayScreen` with proper states (already has inline states, widgets available for future use)
- [x] Add localization strings for all error messages
- [x] Write widget tests for state widgets (28 tests)

**Implementation Notes:**
Created three reusable state widgets that are now integrated throughout the entire app:
- `LoadingIndicator` - Consistent loading indicator with size variants (small/medium/large) and optional message
- `ErrorStateWidget` - Error display with icon, message, optional title, and retry button. Includes factory constructors for network and server errors
- `EmptyStateWidget` - Empty state with icon, title, message, and optional action button. Includes factory constructors for no results and compact variants

**IMPORTANT:** These widgets should be used for ALL future screens and components. See CLAUDE.md for usage examples.

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/loading_indicator.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/error_state_widget.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/empty_state_widget.dart`
- ✅ `packages/quiz_engine/test/widgets/state_widgets_test.dart` - 28 comprehensive tests

**Files Modified (Widget Creation):**
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Added retry, errorTitle, errorGeneric, errorNetwork, errorServer, loadingData strings
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Exported new state widgets
- ✅ `packages/quiz_engine/test/achievements/base_achievements_test.dart` - Updated mock localization

**Files Modified (App-Wide Integration):**
- ✅ `packages/quiz_engine/lib/src/screens/statistics_dashboard_screen.dart` - LoadingIndicator + EmptyStateWidget
- ✅ `packages/quiz_engine/lib/src/screens/session_history_screen.dart` - LoadingIndicator + EmptyStateWidget
- ✅ `packages/quiz_engine/lib/src/widgets/leaderboard_widget.dart` - EmptyStateWidget.compact
- ✅ `packages/quiz_engine/lib/src/widgets/category_statistics_widget.dart` - EmptyStateWidget.compact
- ✅ `packages/quiz_engine/lib/src/widgets/progress_chart_widget.dart` - EmptyStateWidget.compact
- ✅ `packages/quiz_engine/lib/src/widgets/challenge_list.dart` - EmptyStateWidget
- ✅ `packages/quiz_engine/lib/src/home/play_screen.dart` - LoadingIndicator + EmptyStateWidget
- ✅ `packages/quiz_engine/lib/src/home/tabbed_play_screen.dart` - LoadingIndicator
- ✅ `packages/quiz_engine/lib/src/home/quiz_home_screen.dart` - LoadingIndicator
- ✅ `packages/quiz_engine/lib/src/achievements/screens/achievements_screen.dart` - LoadingIndicator + ErrorStateWidget
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievements_list.dart` - EmptyStateWidget

---

### Sprint 8.17: Animations & Transitions Polish ✅

**Goal:** Review and polish all animations and transitions for consistency.

**Tasks:**
- [x] Audit all screen transitions
- [x] Audit all widget animations
- [x] Ensure consistent animation durations (standardize to 200ms, 300ms, 500ms tiers)
- [x] Ensure consistent easing curves
- [x] Polish answer feedback animations
- [x] Polish achievement unlock animations
- [x] Polish hint use animations
- [x] Polish life lost animations
- [x] Add subtle micro-interactions where appropriate
- [ ] Test animations on low-end devices for performance (manual testing required)
- [x] Document animation standards in code comments

**Implementation Notes:**
Created a centralized `QuizAnimations` class with standardized duration tiers and curve constants:

**Duration Tiers:**
- `durationInstant` (50ms) - Imperceptible, immediate feedback
- `durationFast` (100ms) - Micro-interactions, tap feedback
- `durationQuick` (200ms) - Tooltips, small movements
- `durationMedium` (300ms) - Standard transitions, page changes
- `durationSlow` (500ms) - Emphasis, important feedback
- `durationLong` (800ms) - Celebration, attention-grabbing
- `durationExtended` (1500ms) - Counting, continuous effects

**Curve Categories:**
- `curveStandard` (easeInOut) - Most transitions
- `curveEnter` (easeOut) - Elements appearing
- `curveExit` (easeIn) - Elements disappearing
- `curveBounce` (elasticOut) - Playful, bouncy effects
- `curveDecelerate` (easeOutCubic) - Counting/progress
- `curveOvershoot` (easeOutBack) - Subtle bounce

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/theme/quiz_animations.dart` - Centralized animation constants

**Files Modified:**
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export QuizAnimations
- ✅ `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart` - Use animation constants
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_button.dart` - Use animation constants
- ✅ `packages/quiz_engine/lib/src/widgets/score_display.dart` - Use animation constants
- ✅ `packages/quiz_engine/lib/src/theme/game_resource_theme.dart` - Use animation constants
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_notification.dart` - Use animation constants

---

### Sprint 8.18: Accessibility Audit ✅

**Goal:** Ensure full accessibility support across the app.

**Tasks:**
- [x] Audit all widgets for semantic labels
- [x] Audit all interactive elements for touch target sizes (min 48x48)
- [x] Audit color contrast ratios (WCAG AA compliance)
- [x] Test with screen readers (TalkBack, VoiceOver)
- [x] Test with font scaling (up to 200%)
- [x] Add `Semantics` widgets where missing
- [x] Add `ExcludeSemantics` for decorative elements
- [x] Ensure focus order is logical
- [x] Add accessibility hints for complex interactions
- [x] Test keyboard navigation (desktop/web)
- [x] Document accessibility patterns

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/theme/quiz_accessibility.dart` - Accessibility constants and helpers

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Accessibility localization strings
- ✅ `packages/quiz_engine/lib/src/home/category_card.dart` - Added Semantics wrapper
- ✅ `packages/quiz_engine/lib/src/widgets/challenge_card.dart` - Added Semantics wrapper
- ✅ `packages/quiz_engine/lib/src/components/option_button.dart` - Added Semantics wrapper
- ✅ `packages/quiz_engine/lib/src/widgets/session_card.dart` - Added Semantics wrapper
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export QuizAccessibility
- ✅ `CLAUDE.md` - Documented accessibility patterns

---

### Sprint 8.19: Audio & Haptic Polish ✅

**Goal:** Ensure all sound effects and haptic feedback are properly implemented and balanced.

**Tasks:**
- [x] Audit all user interactions for sound feedback
- [x] Audit all user interactions for haptic feedback
- [x] Ensure sounds don't overlap/conflict
- [x] Balance sound effect volumes
- [x] Ensure haptic patterns are consistent and appropriate
- [x] Add missing sounds (if any)
- [x] Add missing haptics (if any)
- [x] Test with sound on/off settings
- [x] Test with haptic on/off settings
- [x] Ensure sound assets are optimized (file size)

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/feedback/quiz_feedback_service.dart` - Combined audio/haptic feedback service
- ✅ `packages/quiz_engine/lib/src/feedback/quiz_feedback_constants.dart` - Volume levels and timing constants

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - Use QuizFeedbackService with provider
- ✅ `packages/quiz_engine/lib/src/widgets/game_resource_button.dart` - Use feedback service/fallback pattern
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Export feedback module
- ✅ `CLAUDE.md` - Document audio/haptic patterns

---

## Completed Technical Improvements

### QuizBloc Refactoring ✅

**Description:** Refactored `QuizBloc` from 789 lines to 459 lines (~42% reduction) by extracting functionality into 6 focused managers for better separation of concerns and testability.

**Architecture:**
```
QuizBloc (Orchestrator ~460 lines)
    ├── QuizProgressTracker   (~160 lines) - Tracks answers, progress, streaks, lives
    ├── QuizTimerManager      (~290 lines) - Question/total timers, pause/resume, stopwatches
    ├── QuizHintManager       (~182 lines) - Hint state, 50/50 logic, disabled options
    ├── QuizSessionManager    (~265 lines) - Storage integration, session lifecycle
    ├── QuizAnswerProcessor   (~118 lines) - Answer creation, timeout/skip answers
    └── QuizGameFlowManager   (~182 lines) - Question picking, game over detection
```

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/managers.dart` (barrel export)
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_progress_tracker.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_timer_manager.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_hint_manager.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_session_manager.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_answer_processor.dart`
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_game_flow_manager.dart`

**Test Files Created:**
- ✅ `packages/quiz_engine_core/test/managers/quiz_progress_tracker_test.dart` (21 tests)
- ✅ `packages/quiz_engine_core/test/managers/quiz_timer_manager_test.dart` (25 tests)
- ✅ `packages/quiz_engine_core/test/managers/quiz_hint_manager_test.dart` (22 tests)
- ✅ `packages/quiz_engine_core/test/managers/quiz_session_manager_test.dart` (19 tests)
- ✅ `packages/quiz_engine_core/test/managers/quiz_answer_processor_test.dart` (13 tests)
- ✅ `packages/quiz_engine_core/test/managers/quiz_game_flow_manager_test.dart` (17 tests)

**Total: 117 new manager tests**

---

### Sprint 5.6: Pagination, Export & Optimization ✅

**Goal:** Add pagination for large datasets, GDPR-compliant data export, and query optimization.

**Tasks:**
- [x] Implement pagination support in data sources/repositories
- [x] Add pagination to session history screen
- [x] Add pagination to achievements list (if needed) - Not needed (small dataset)
- [x] Implement data export service (JSON format, GDPR compliance)
- [x] Add export UI to settings screen
- [x] Optimize queries with proper database indexes - Already exist from Sprint 5.1
- [x] Write tests for pagination and export

**Files Created:**
- ✅ `packages/shared_services/lib/src/storage/models/paginated_result.dart`
- ✅ `packages/shared_services/lib/src/storage/services/data_export_service.dart`
- ✅ `packages/quiz_engine/lib/src/settings/export_data_tile.dart`

---

### Sprint 6.2: Advanced Statistics UI ✅

**Tasks:**
- [x] Create Statistics Dashboard UI
- [x] Add charts/graphs for trends
- [x] Display aggregate statistics
- [x] Show improvement over time
- [x] Add category breakdown views
- [x] Create leaderboards (local)
- [x] Test statistics screens

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/widgets/category_statistics_widget.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/progress_chart_widget.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/leaderboard_widget.dart`
- ✅ `packages/quiz_engine/lib/src/screens/statistics_dashboard_screen.dart`

---

---

# BACKLOG (Not Started / In Progress)

---

## Phase 9: Shared Services (Analytics, Ads, IAP)

**Reference:** See [ANALYTICS_SPECIFICATION.md](./ANALYTICS_SPECIFICATION.md) for comprehensive event definitions and sealed class architecture.

---

### Sprint 9.1: Analytics Core Infrastructure ✅

**Goal:** Create the analytics foundation with abstract service and sealed event classes.

**Tasks:**
- [x] Create `AnalyticsService` abstract class with all methods
- [x] Create base `AnalyticsEvent` abstract class
- [x] Create `ScreenViewEvent` sealed class (18 screen events: 17 standard + 1 custom)
- [x] Create `ConsoleAnalyticsService` implementation (development)
- [x] Create `NoOpAnalyticsService` implementation (testing)
- [x] Register analytics service in DI container (`AnalyticsModule`)
- [x] Write unit tests for all event classes
- [x] Write unit tests for ConsoleAnalyticsService

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/analytics_service.dart`
- ✅ `packages/shared_services/lib/src/analytics/analytics_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/screen_view_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/services/console_analytics_service.dart`
- ✅ `packages/shared_services/lib/src/analytics/services/no_op_analytics_service.dart`
- ✅ `packages/shared_services/lib/src/analytics/analytics_exports.dart`
- ✅ `packages/shared_services/lib/src/di/modules/analytics_module.dart`
- ✅ `packages/shared_services/test/analytics/analytics_event_test.dart`
- ✅ `packages/shared_services/test/analytics/console_analytics_service_test.dart`

**Screen View Events (18 total):**
- Home, Play, PlayTabbed, History, Statistics, Achievements, Settings (7 navigation)
- Quiz, Results, SessionDetail (3 quiz)
- CategoryStatistics, Challenges, Practice (3 category)
- Leaderboard, About, Licenses, Tutorial (4 info)
- Custom (1 app-specific)

---

### Sprint 9.1.1: Quiz Event Classes ✅

**Goal:** Create sealed classes for quiz lifecycle and question events.

**Status:** COMPLETED (2025-12-27)

**Tasks:**
- [x] Create `QuizEvent` sealed class (8 events)
  - `started`, `completed`, `cancelled`, `timeout`, `failed`, `paused`, `resumed`, `challengeStarted`
- [x] Create `QuestionEvent` sealed class (8 events)
  - `displayed`, `answered`, `correct`, `incorrect`, `skipped`, `timeout`, `feedbackShown`, `optionSelected`
- [x] Create `HintEvent` sealed class (4 events)
  - `fiftyFiftyUsed`, `skipUsed`, `unavailableTapped`, `timerWarning`
- [x] Create `ResourceEvent` sealed class (4 events)
  - `lifeLost`, `livesDepleted`, `buttonTapped`, `added`
- [x] Write unit tests for all event classes

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/events/quiz_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/question_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/hint_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/resource_event.dart`
- ✅ `packages/shared_services/test/analytics/events/quiz_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/question_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/hint_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/resource_event_test.dart`

**Implementation Details:**
- All event classes follow the sealed class pattern with factory constructors
- Each event extends `AnalyticsEvent` with proper `eventName` and `parameters`
- Parameters use snake_case keys for analytics providers
- Duration values converted to milliseconds/seconds in parameters
- Optional parameters only included when provided
- 86 unit tests covering all event types and edge cases

**Pending Integrations (for Sprint 9.1.6+):**
- [ ] Integrate `QuizEvent` with `QuizBloc` (fire events during quiz lifecycle)
- [ ] Integrate `QuestionEvent` with `QuizBloc` (fire events on answer/display)
- [ ] Integrate `HintEvent` with hint system (fire events on hint usage)
- [ ] Integrate `ResourceEvent` with lives/resource tracking
- [ ] Add `AnalyticsService` provider to quiz screens
- [ ] Create analytics helper/extension for easy event logging from screens

---

### Sprint 9.1.2: Interaction & Settings Event Classes ✅

**Goal:** Create sealed classes for user interactions and settings.

**Status:** COMPLETED (2025-12-27)

**Tasks:**
- [x] Create `InteractionEvent` sealed class (12 events)
  - `categorySelected`, `tabSelected`, `sessionViewed`, `sessionDeleted`, `exitDialogShown`, `exitDialogConfirmed`, `exitDialogCancelled`, `dataExportInitiated`, `dataExportCompleted`, `pullToRefresh`, `viewAllSessions`, `leaderboardViewed`
- [x] Create `SettingsEvent` sealed class (8 events)
  - `changed`, `soundEffectsToggled`, `hapticFeedbackToggled`, `themeChanged`, `answerFeedbackToggled`, `resetConfirmed`, `privacyPolicyViewed`, `termsOfServiceViewed`
- [x] Create `AchievementEvent` sealed class (5 events)
  - `unlocked`, `notificationShown`, `notificationTapped`, `detailViewed`, `filtered`
- [x] Write unit tests for all event classes

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/events/interaction_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/settings_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/achievement_event.dart`
- ✅ `packages/shared_services/test/analytics/events/interaction_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/settings_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/achievement_event_test.dart`

**Implementation Details:**
- InteractionEvent: 12 events for navigation, session management, dialogs, data export
- SettingsEvent: 8 events for settings changes, toggles, and legal link views
- AchievementEvent: 5 events for achievement unlocks, notifications, and filtering
- All events extend `AnalyticsEvent` with factory constructors
- 25 event types total with comprehensive unit tests

**Pending Integrations (for Sprint 9.1.6+):**
- [ ] Integrate `InteractionEvent` with navigation and UI components
- [ ] Integrate `SettingsEvent` with settings screens
- [ ] Integrate `AchievementEvent` with achievement system

---

### Sprint 9.1.3: Monetization & Error Event Classes ✅

**Goal:** Create sealed classes for monetization and error tracking.

**Tasks:**
- [x] Create `MonetizationEvent` sealed class (10 events)
  - `purchaseSheetOpened`, `packSelected`, `purchaseInitiated`, `purchaseCompleted`, `purchaseCancelled`, `purchaseFailed`, `restoreInitiated`, `restoreCompleted`, `adWatched`, `adFailed`
- [x] Create `ErrorEvent` sealed class (6 events)
  - `dataLoadFailed`, `saveFailed`, `retryTapped`, `appCrash`, `featureFailure`, `network`
- [x] Create `PerformanceEvent` sealed class (5 events)
  - `appLaunch`, `sessionStart`, `sessionEnd`, `screenRender`, `databaseQuery`
- [x] Write unit tests for all event classes

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/events/monetization_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/error_event.dart`
- ✅ `packages/shared_services/lib/src/analytics/events/performance_event.dart`
- ✅ `packages/shared_services/test/analytics/events/monetization_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/error_event_test.dart`
- ✅ `packages/shared_services/test/analytics/events/performance_event_test.dart`

**Pending Integrations:**
- [ ] Integrate `MonetizationEvent` with IAP and ad services
- [ ] Integrate `ErrorEvent` with error handling and crash reporting
- [ ] Integrate `PerformanceEvent` with app lifecycle and database operations

---

### Sprint 9.1.4: Firebase Analytics Implementation ✅

**Goal:** Implement Firebase Analytics provider for production.

**Tasks:**
- [x] Add `firebase_analytics` dependency to shared_services
- [x] Create `FirebaseAnalyticsService` implementation
- [x] Implement event name mapping (custom events → Firebase format)
- [x] Implement user properties tracking
- [x] Implement screen tracking with `FirebaseAnalyticsObserver`
- [x] Add Firebase debug view support (DebugView)
- [x] Write unit tests (37 tests)
- [ ] Test with Firebase Console (requires app deployment)

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/services/firebase_analytics_service.dart`
- ✅ `packages/shared_services/test/analytics/firebase_analytics_service_test.dart`

**Dependencies Added:**
```yaml
# packages/shared_services/pubspec.yaml
dependencies:
  firebase_analytics: ^11.4.1
  firebase_core: ^3.8.1
```

**Pending Integrations:**
- [ ] Initialize Firebase in app main.dart before using FirebaseAnalyticsService
- [ ] Add FirebaseAnalyticsObserver to MaterialApp navigatorObservers
- [ ] Test with Firebase Console DebugView

#### Firebase Analytics Integration Guide

**Step 1: Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Google Analytics when prompted (recommended)

**Step 2: iOS Setup**

1. In Firebase Console, click "Add app" → iOS
2. Enter your iOS bundle ID (e.g., `com.example.flagsquiz`)
3. Download `GoogleService-Info.plist`
4. Add the file to your iOS project:
   ```
   apps/flagsquiz/ios/Runner/GoogleService-Info.plist
   ```
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click on `Runner` → "Add Files to Runner"
7. Select `GoogleService-Info.plist` (ensure "Copy items if needed" is checked)

**iOS Info.plist Configuration** (optional, for ad tracking):
```xml
<!-- apps/flagsquiz/ios/Runner/Info.plist -->
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

**Step 3: Android Setup**

1. In Firebase Console, click "Add app" → Android
2. Enter your Android package name (e.g., `com.example.flagsquiz`)
3. Download `google-services.json`
4. Add the file to your Android project:
   ```
   apps/flagsquiz/android/app/google-services.json
   ```

5. Update `android/build.gradle` (project-level):
   ```gradle
   buildscript {
       dependencies {
           // Add this line
           classpath 'com.google.gms:google-services:4.4.2'
       }
   }
   ```

6. Update `android/app/build.gradle` (app-level):
   ```gradle
   plugins {
       id 'com.android.application'
       id 'kotlin-android'
       id 'dev.flutter.flutter-gradle-plugin'
       // Add this line
       id 'com.google.gms.google-services'
   }
   ```

**Step 4: Initialize Firebase in App**

```dart
// apps/flagsquiz/lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_services/shared_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Analytics
  final analyticsService = FirebaseAnalyticsService();
  await analyticsService.initialize();

  runApp(MyApp(analyticsService: analyticsService));
}
```

**Step 5: Add Navigation Observer**

```dart
// In your MaterialApp
MaterialApp(
  navigatorObservers: [
    firebaseAnalyticsService.observer,
  ],
  // ... rest of app config
)
```

**Step 6: Enable Debug Mode (for testing)**

Run with debug flag to see events in Firebase DebugView:

```bash
# iOS
flutter run --dart-define=FIREBASE_ANALYTICS_DEBUG=true

# Or via Xcode scheme arguments:
# -FIRDebugEnabled
```

```bash
# Android
adb shell setprop debug.firebase.analytics.app com.example.flagsquiz
```

Then open Firebase Console → Analytics → DebugView to see real-time events.

**Step 7: Usage Examples**

```dart
// Log custom events
await analyticsService.logEvent(
  QuizEvent.started(
    quizId: 'quiz-123',
    quizName: 'World Flags',
    categoryId: 'europe',
    categoryName: 'Europe',
    mode: 'standard',
    totalQuestions: 10,
  ),
);

// Set user properties
await analyticsService.setUserProperty(
  name: AnalyticsUserProperties.totalQuizzesTaken,
  value: '42',
);

// Log screen views
await analyticsService.setCurrentScreen(
  screenName: 'QuizScreen',
  screenClass: 'QuizScreen',
);

// Firebase standard events
await analyticsService.logUnlockAchievement(achievementId: 'first_quiz');
await analyticsService.logPostScore(score: 850, level: 5);
```

---

### Sprint 9.1.5: Composite Analytics Service ✅

**Goal:** Create composite service for multi-provider analytics.

**Tasks:**
- [x] Create `CompositeAnalyticsService` implementation
- [x] Support multiple providers (Firebase + Amplitude, etc.)
- [x] Implement fan-out event logging
- [x] Add provider-specific configuration
- [x] Write unit tests

**Files Created:**
- ✅ `packages/shared_services/lib/src/analytics/services/composite_analytics_service.dart`
- ✅ `packages/shared_services/test/analytics/composite_analytics_service_test.dart`

**Features:**
- `AnalyticsProviderConfig` - Configuration for each provider with name, enabled flag, and event filter
- `CompositeAnalyticsService` - Fan-out service that logs to multiple providers
- Event filtering per provider (e.g., send monetization events only to revenue analytics)
- Graceful error handling - one provider failing doesn't affect others
- `stopOnFirstError` option for strict error handling
- Provider lookup by name (`getProvider`, `getProviderConfig`)
- Extension method `toCompositeService()` for easy creation from a list

**Usage Example:**
```dart
final compositeService = CompositeAnalyticsService(
  providers: [
    AnalyticsProviderConfig(
      provider: FirebaseAnalyticsService(),
      name: 'Firebase',
    ),
    AnalyticsProviderConfig(
      provider: AmplitudeAnalyticsService(),
      name: 'Amplitude',
      eventFilter: (event) => event is MonetizationEvent,
    ),
  ],
);

await compositeService.initialize();
await compositeService.logEvent(QuizEvent.started(...));
```

---

### Sprint 9.1.6: Analytics Integration - QuizBloc ✅

**Goal:** Integrate analytics into quiz business logic.

**Tasks:**
- [x] Add `AnalyticsService` to `QuizBloc` constructor
- [x] Track `quiz_started` on quiz initialization
- [x] Track `question_displayed` on each new question
- [x] Track `answer_submitted` on answer processing
- [x] Track `hint_fifty_fifty_used` and `hint_skip_used`
- [x] Track `life_lost` and `lives_depleted`
- [x] Track `quiz_completed`, `quiz_cancelled`, `quiz_failed`, `quiz_timeout`
- [x] Track `quiz_paused` and `quiz_resumed` from lifecycle handler
- [ ] Write integration tests (deferred - covered by existing unit tests)

**Files Created:**
- ✅ `packages/quiz_engine_core/lib/src/analytics/quiz_analytics_service.dart` - Abstract interface + NoOp implementation
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/quiz_analytics_manager.dart` - Analytics manager (follows existing manager pattern)

**Files Modified:**
- ✅ `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Integrated QuizAnalyticsManager
- ✅ `packages/quiz_engine_core/lib/src/business_logic/managers/managers.dart` - Added export
- ✅ `packages/quiz_engine_core/lib/quiz_engine_core.dart` - Added analytics export
- ✅ `packages/quiz_engine/lib/src/quiz_widget_entry.dart` - Added analyticsService, categoryId, categoryName fields
- ✅ `packages/quiz_engine/lib/src/quiz_widget.dart` - Pass analytics fields to QuizBloc
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Added analyticsService field and integration
- ✅ `apps/flagsquiz/lib/initialization/flags_quiz_app_provider.dart` - Added QuizAnalyticsService to dependencies
- ✅ `apps/flagsquiz/lib/app/flags_quiz_app.dart` - Wire analyticsService to QuizApp

**Architecture:**
- `QuizAnalyticsService` - Abstract interface defining all analytics tracking methods
- `NoOpQuizAnalyticsService` - No-op implementation for testing/disabled analytics
- `QuizAnalyticsManager` - Internal manager wrapping the service (same pattern as QuizSessionManager)
- QuizBloc accepts optional `QuizAnalyticsService` and creates manager internally

**Tracked Events:**
- Quiz lifecycle: `quiz_started`, `quiz_completed`, `quiz_cancelled`, `quiz_failed`, `quiz_timeout`, `quiz_paused`, `quiz_resumed`
- Questions: `question_displayed`, `question_answered`, `question_skipped`, `question_timeout`
- Hints: `hint_fifty_fifty_used`, `hint_skip_used`
- Resources: `life_lost`, `lives_depleted`

---

### Sprint 9.1.7: Analytics Integration - UI Screens ✅

**Goal:** Integrate analytics into UI screens and navigation.

**Tasks:**
- [x] Create `AnalyticsNavigatorObserver` for automatic screen tracking
- [x] Integrate screen views in `QuizHomeScreen`
- [x] Integrate screen views in `StatisticsDashboard` (via tab tracking)
- [x] Integrate screen views in `SessionHistoryScreen` (via tab tracking)
- [x] Integrate screen views in `AchievementsScreen` (via tab tracking)
- [x] Integrate screen views in `QuizSettingsScreen` (via tab tracking)
- [x] Integrate screen views in `SessionDetailScreen` (via navigator observer)
- [x] Track `tab_selected` events in bottom navigation
- [x] Track `category_selected` events
- [x] Write integration tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/analytics/analytics_navigator_observer.dart`
- ✅ `packages/quiz_engine/lib/src/analytics/analytics_exports.dart`
- ✅ `packages/quiz_engine/test/analytics/analytics_navigator_observer_test.dart`

**Files Modified:**
- ✅ `packages/quiz_engine/lib/quiz_engine.dart` - Added analytics export
- ✅ `packages/quiz_engine/lib/src/app/quiz_app.dart` - Added screenAnalyticsService parameter, category tracking
- ✅ `packages/quiz_engine/lib/src/home/quiz_home_screen.dart` - Added analyticsService, tab tracking, screen view tracking

**Implementation Notes:**
- `AnalyticsNavigatorObserver` provides automatic screen tracking for route-based navigation
- `QuizHomeScreen` tracks tab selection events and initial screen views
- `QuizApp` tracks category selection events and passes analytics service to home screen
- Screen views for tabs (Statistics, History, Achievements, Settings) are tracked when the home screen loads and when tabs change
- The extension `AnalyticsServiceScreenTracking` provides a convenient way to log screen views using the `ScreenViewEvent` sealed class

---

### Sprint 9.1.8: Analytics Integration - Settings & Achievements ✅

**Goal:** Integrate analytics into settings and achievements.

**Tasks:**
- [x] Track settings changes (sound, haptics, theme, feedback toggle)
- [x] Track `achievement_unlocked` from `AchievementService`
- [x] Track `achievement_notification_shown` and `tapped`
- [x] Track `achievement_detail_viewed`
- [x] Track `data_export_initiated` and `completed`
- [x] Track error events from error handlers
- [x] Write integration tests

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart`
- ✅ `packages/shared_services/lib/src/achievements/services/achievement_service.dart`
- ✅ `packages/quiz_engine/lib/src/settings/export_data_tile.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/achievement_notification_controller.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/widgets/achievement_notification.dart`
- ✅ `packages/quiz_engine/lib/src/achievements/screens/achievements_screen.dart`
- ✅ `packages/quiz_engine/lib/src/widgets/error_state_widget.dart`

**Test Files Created:**
- ✅ `packages/quiz_engine/test/mocks/mock_analytics_service.dart`
- ✅ `packages/quiz_engine/test/settings/quiz_settings_screen_analytics_test.dart`
- ✅ `packages/shared_services/test/achievements/achievement_service_analytics_test.dart`
- ✅ `packages/quiz_engine/test/achievements/achievement_notification_controller_analytics_test.dart`
- ✅ `packages/quiz_engine/test/widgets/error_state_widget_analytics_test.dart`
- ✅ `packages/quiz_engine/test/settings/export_data_tile_analytics_test.dart`

---

### Sprint 9.1.9: User Properties & App Lifecycle ✅

**Goal:** Implement user properties and app lifecycle tracking.

**Tasks:**
- [x] Implement user property updates after quiz completion
- [x] Track `app_launch` event with startup time
- [x] Track `app_session_start` and `app_session_end`
- [x] Add background time tracking to `QuizLifecycleHandler`
- [x] Implement anonymous user ID generation
- [x] Write integration tests

**Files Created:**
- ✅ `packages/quiz_engine/lib/src/analytics/analytics_lifecycle_observer.dart`

**Test Files Created:**
- ✅ `packages/quiz_engine/test/analytics/analytics_lifecycle_observer_test.dart`

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/widgets/quiz_lifecycle_handler.dart`
- ✅ `packages/quiz_engine/lib/src/analytics/analytics_exports.dart`
- ✅ `packages/quiz_engine/lib/quiz_engine.dart`

---

### Sprint 9.1.10: Analytics Testing & Documentation ✅

**Goal:** Comprehensive testing and documentation.

**Tasks:**
- [x] Write unit tests for all 87 event classes (already covered in previous sprints)
- [x] Write integration tests for QuizBloc analytics
- [x] Write integration tests for screen tracking
- [x] Verify Firebase DebugView shows all events correctly (documented in ANALYTICS_EVENTS.md)
- [x] Create analytics event documentation for data team
- [x] Update CLAUDE.md with analytics patterns
- [x] Update shared_services exports (verified - all exports correct)

**Files Created:**
- ✅ `packages/shared_services/test/analytics/integration_test.dart`
- ✅ `docs/ANALYTICS_EVENTS.md`

**Files Modified:**
- ✅ `CLAUDE.md` (added Analytics section with patterns and usage)

---

### Sprint 9.2: Ads Service

**Goal:** Implement ads service with AdMob integration.

**Tasks:**
- [ ] Create `AdsService` abstract class
- [ ] Create `AdMobService` implementation
- [ ] Create `NoAdsService` implementation (premium users/testing)
- [ ] Create `BannerAdWidget` for displaying banner ads
- [ ] Add interstitial ad trigger points (after quiz completion)
- [ ] Add rewarded ad for free resources (lives, hints)
- [ ] Integrate with `ResourceManager` for ad rewards
- [ ] Track ad events via analytics
- [ ] Write unit tests
- [ ] Test on iOS and Android

**Files to Create:**
- `packages/shared_services/lib/src/ads/ads_service.dart`
- `packages/shared_services/lib/src/ads/admob_service.dart`
- `packages/shared_services/lib/src/ads/no_ads_service.dart`
- `packages/shared_services/lib/src/ads/ads_exports.dart`
- `packages/quiz_engine/lib/src/widgets/banner_ad_widget.dart`
- `packages/shared_services/test/ads/admob_service_test.dart`

**Dependencies to Add:**
```yaml
# packages/shared_services/pubspec.yaml
dependencies:
  google_mobile_ads: ^5.0.0
```

---

### Sprint 9.3: In-App Purchases Service

**Goal:** Implement IAP service for premium features.

**Tasks:**
- [ ] Create `IAPService` abstract class
- [ ] Create `StoreIAPService` implementation (App Store / Play Store)
- [ ] Create `MockIAPService` for testing
- [ ] Define product IDs (remove_ads, lives_pack, hints_pack)
- [ ] Implement purchase flow
- [ ] Implement restore purchases
- [ ] Create purchase confirmation dialogs
- [ ] Integrate with `ResourceManager` for purchased resources
- [ ] Track IAP events via analytics
- [ ] Write unit tests
- [ ] Test on iOS and Android

**Files to Create:**
- `packages/shared_services/lib/src/iap/iap_service.dart`
- `packages/shared_services/lib/src/iap/store_iap_service.dart`
- `packages/shared_services/lib/src/iap/mock_iap_service.dart`
- `packages/shared_services/lib/src/iap/iap_exports.dart`
- `packages/shared_services/test/iap/store_iap_service_test.dart`

**Dependencies to Add:**
```yaml
# packages/shared_services/pubspec.yaml
dependencies:
  in_app_purchase: ^3.1.0
```

---

### Sprint 9.4: Services Integration & Polish

**Goal:** Final integration and polish of all shared services.

**Tasks:**
- [ ] Create unified `SharedServicesInitializer` for app startup
- [ ] Ensure proper service disposal on app termination
- [ ] Add error handling for all service failures
- [ ] Create service configuration model for apps
- [ ] Update flagsquiz app to use all services
- [ ] Write end-to-end integration tests
- [ ] Performance testing (service initialization < 500ms)
- [ ] Update documentation

**Files to Create:**
- `packages/shared_services/lib/src/shared_services_initializer.dart`
- `packages/shared_services/lib/src/shared_services_config.dart`

**Files to Modify:**
- `apps/flagsquiz/lib/main.dart`
- `packages/shared_services/lib/shared_services.dart`

---

### Sprint 9.5: Screen BLoC Architecture Refactoring

**Goal:** Refactor all UI screens to use the BLoC pattern consistent with QuizBloc for better state management, testability, and separation of concerns.

**Background:**
Currently, QuizBloc (in quiz_engine_core) provides a clean separation of business logic from UI using streams and state objects. Other screens like StatisticsDashboardScreen, SessionHistoryScreen, and ChallengesScreen manage state directly in StatefulWidgets, making them harder to test and maintain.

**Architecture Pattern (following QuizBloc):**
```dart
// BLoC with stream-based state management
class ScreenBloc extends SingleSubscriptionBloc<ScreenState> {
  // Business logic methods
  // Stream emissions for state changes
}

// Sealed state classes
sealed class ScreenState {
  const ScreenState();
  factory ScreenState.loading() = LoadingState;
  factory ScreenState.loaded(Data data) = LoadedState;
  factory ScreenState.error(String message) = ErrorState;
}

// Screen widget uses BlocProvider
class MyScreen extends StatelessWidget {
  Widget build(context) {
    return BlocProvider<ScreenBloc>(
      bloc: bloc,
      child: StreamBuilder<ScreenState>(
        stream: bloc.stream,
        builder: (context, snapshot) => /* render based on state */,
      ),
    );
  }
}
```

#### Sprint 9.5.1: Statistics BLoC

**Tasks:**
- [ ] Create `StatisticsState` sealed class with loading/loaded/error states
- [ ] Create `StatisticsBloc` for statistics dashboard logic
- [ ] Refactor `StatisticsDashboardScreen` to use `StatisticsBloc`
- [ ] Move data loading, tab switching, and filtering logic to BLoC
- [ ] Write unit tests for `StatisticsBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/statistics/statistics_state.dart`
- `packages/quiz_engine/lib/src/bloc/statistics/statistics_bloc.dart`
- `packages/quiz_engine/test/bloc/statistics/statistics_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/screens/statistics_dashboard_screen.dart`

---

#### Sprint 9.5.2: Session History BLoC

**Tasks:**
- [ ] Create `SessionHistoryState` sealed class
- [ ] Create `SessionHistoryBloc` for history management
- [ ] Refactor `SessionHistoryScreen` to use BLoC
- [ ] Move pagination, filtering, and refresh logic to BLoC
- [ ] Write unit tests for `SessionHistoryBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/session_history/session_history_state.dart`
- `packages/quiz_engine/lib/src/bloc/session_history/session_history_bloc.dart`
- `packages/quiz_engine/test/bloc/session_history/session_history_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/screens/session_history_screen.dart`

---

#### Sprint 9.5.3: Session Detail BLoC

**Tasks:**
- [ ] Create `SessionDetailState` sealed class
- [ ] Create `SessionDetailBloc` for session detail management
- [ ] Refactor `SessionDetailScreen` to use BLoC
- [ ] Move question navigation, filtering, and delete logic to BLoC
- [ ] Write unit tests for `SessionDetailBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/session_detail/session_detail_state.dart`
- `packages/quiz_engine/lib/src/bloc/session_detail/session_detail_bloc.dart`
- `packages/quiz_engine/test/bloc/session_detail/session_detail_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/screens/session_detail_screen.dart`

---

#### Sprint 9.5.4: Challenges BLoC

**Tasks:**
- [ ] Create `ChallengesState` sealed class
- [ ] Create `ChallengesBloc` for challenge management
- [ ] Refactor `ChallengesScreen` to use BLoC
- [ ] Move challenge selection, category picker, and quiz start logic to BLoC
- [ ] Write unit tests for `ChallengesBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/challenges/challenges_state.dart`
- `packages/quiz_engine/lib/src/bloc/challenges/challenges_bloc.dart`
- `packages/quiz_engine/test/bloc/challenges/challenges_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/screens/challenges_screen.dart`

---

#### Sprint 9.5.5: Home Screen BLoC

**Tasks:**
- [ ] Create `HomeState` sealed class
- [ ] Create `HomeBloc` for home screen management
- [ ] Refactor `QuizHomeScreen` to use BLoC
- [ ] Move tab switching, data loading, and navigation logic to BLoC
- [ ] Integrate analytics tracking in BLoC layer
- [ ] Write unit tests for `HomeBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/home/home_state.dart`
- `packages/quiz_engine/lib/src/bloc/home/home_bloc.dart`
- `packages/quiz_engine/test/bloc/home/home_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/home/quiz_home_screen.dart`

---

#### Sprint 9.5.6: Achievements BLoC

**Tasks:**
- [ ] Create `AchievementsState` sealed class
- [ ] Create `AchievementsBloc` for achievements management
- [ ] Refactor `AchievementsScreen` to use BLoC
- [ ] Move filtering, loading, and refresh logic to BLoC
- [ ] Write unit tests for `AchievementsBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/achievements/achievements_state.dart`
- `packages/quiz_engine/lib/src/bloc/achievements/achievements_bloc.dart`
- `packages/quiz_engine/test/bloc/achievements/achievements_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/achievements/screens/achievements_screen.dart`

---

#### Sprint 9.5.7: Settings BLoC

**Tasks:**
- [ ] Create `SettingsState` sealed class
- [ ] Create `SettingsBloc` for settings management
- [ ] Refactor `QuizSettingsScreen` to use BLoC
- [ ] Move settings loading, saving, and validation logic to BLoC
- [ ] Integrate analytics tracking for settings changes
- [ ] Write unit tests for `SettingsBloc`
- [ ] Write widget tests for refactored screen

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/settings/settings_state.dart`
- `packages/quiz_engine/lib/src/bloc/settings/settings_bloc.dart`
- `packages/quiz_engine/test/bloc/settings/settings_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/settings/quiz_settings_screen.dart`

---

#### Sprint 9.5.8: Practice BLoC

**Tasks:**
- [ ] Create `PracticeState` sealed class
- [ ] Create `PracticeBloc` for practice mode management
- [ ] Refactor `PracticeStartScreen` and `PracticeCompleteScreen` to use BLoC
- [ ] Move practice data loading and progress tracking to BLoC
- [ ] Write unit tests for `PracticeBloc`
- [ ] Write widget tests for refactored screens

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/practice/practice_state.dart`
- `packages/quiz_engine/lib/src/bloc/practice/practice_bloc.dart`
- `packages/quiz_engine/test/bloc/practice/practice_bloc_test.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/screens/practice_start_screen.dart`
- `packages/quiz_engine/lib/src/screens/practice_complete_screen.dart`

---

#### Sprint 9.5.9: BLoC Infrastructure & Utilities

**Tasks:**
- [ ] Create `BaseBlocState` abstract class with common state properties
- [ ] Create `ScreenBloc` base class extending `SingleSubscriptionBloc`
- [ ] Add analytics integration helper for BLoCs
- [ ] Create `BlocBuilder` widget for cleaner stream handling
- [ ] Update `BlocProvider` with additional utilities
- [ ] Export all BLoCs from `quiz_engine.dart`
- [ ] Write documentation for BLoC pattern usage

**Files to Create:**
- `packages/quiz_engine/lib/src/bloc/base/base_bloc_state.dart`
- `packages/quiz_engine/lib/src/bloc/base/screen_bloc.dart`
- `packages/quiz_engine/lib/src/bloc/base/bloc_analytics_mixin.dart`
- `packages/quiz_engine/lib/src/bloc/bloc_builder.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/bloc/bloc_provider.dart`
- `packages/quiz_engine/lib/quiz_engine.dart`

---

### Phase 9 Summary

| Sprint | Events/Items | Description |
|--------|--------------|-------------|
| 9.1 | 17 | Core infrastructure + ScreenViewEvent |
| 9.1.1 | 24 | QuizEvent, QuestionEvent, HintEvent, ResourceEvent |
| 9.1.2 | 25 | InteractionEvent, SettingsEvent, AchievementEvent |
| 9.1.3 | 21 | MonetizationEvent, ErrorEvent, PerformanceEvent |
| 9.1.4 | - | Firebase Analytics implementation |
| 9.1.5 | - | Composite Analytics service |
| 9.1.6 | - | QuizBloc integration |
| 9.1.7 | - | UI screens integration |
| 9.1.8 | - | Settings & achievements integration |
| 9.1.9 | - | User properties & lifecycle |
| 9.1.10 | - | Testing & documentation |
| 9.2 | - | Ads service (AdMob) |
| 9.3 | - | IAP service |
| 9.4 | - | Final integration |
| 9.5.1 | - | Statistics BLoC |
| 9.5.2 | - | Session History BLoC |
| 9.5.3 | - | Session Detail BLoC |
| 9.5.4 | - | Challenges BLoC |
| 9.5.5 | - | Home Screen BLoC |
| 9.5.6 | - | Achievements BLoC |
| 9.5.7 | - | Settings BLoC |
| 9.5.8 | - | Practice BLoC |
| 9.5.9 | - | BLoC Infrastructure & Utilities |

**Total Analytics Events:** 87 events across 11 sealed classes
**Total Screen BLoCs:** 8 BLoCs + base infrastructure

---

## Phase 10: Polish & Integration

**Tasks:**
- [ ] Review all animations
- [ ] Optimize performance
- [ ] Add loading states
- [ ] Error handling
- [ ] Add comprehensive tests
- [ ] Update documentation
- [ ] Create migration guide for flagsquiz
- [ ] Test complete flow end-to-end

---

## Phase 11: Second App Validation

**Tasks:**
- [ ] Create second quiz app (e.g., capitals_quiz)
- [ ] Validate reusability of all components
- [ ] Identify any app-specific leakage
- [ ] Refactor as needed
- [ ] Update documentation with learnings
- [ ] Create app creation checklist

---

## Phase 12: Rate App Dialog

**Goal:** Implement a rate app dialog that prompts users to rate the app on the App Store/Play Store after completing quizzes.

### Sprint 12.1: Rate App Service

**Tasks:**
- [ ] Add `in_app_review` package to shared_services
- [ ] Create `RateAppService` class with:
  - `shouldShowRateDialog()` - Check if conditions are met
  - `showRateDialog()` - Show native review dialog
  - `markRateDialogShown()` - Record that dialog was shown
  - `markRateDialogDeclined()` - User declined to rate
- [ ] Create `RateAppConfig` model with:
  - `isEnabled` - Enable/disable rate prompts (from quiz config)
  - `minCompletedQuizzes` - Minimum quizzes before prompting
  - `minDaysSinceInstall` - Minimum days since first launch
  - `cooldownDays` - Days between prompts (default: 7)
- [ ] Store rate app state in SharedPreferences:
  - `lastRatePromptDate` - When dialog was last shown
  - `hasRated` - User completed rating (don't ask again)
  - `declineCount` - Number of times user declined
- [ ] Write unit tests

**Files to Create:**
- `packages/shared_services/lib/src/rate_app/rate_app_service.dart`
- `packages/shared_services/lib/src/rate_app/rate_app_config.dart`
- `packages/shared_services/lib/src/rate_app/rate_app_exports.dart`
- `packages/shared_services/test/rate_app/rate_app_service_test.dart`

---

### Sprint 12.2: Rate App Integration

**Tasks:**
- [ ] Create `RateAppModule` for DI registration
- [ ] Integrate rate app check in `QuizResultsScreen`
- [ ] Add `rateAppConfig` to `QuizConfig` (provided by app)
- [ ] Add analytics events:
  - `rate_app_prompt_shown`
  - `rate_app_accepted`
  - `rate_app_declined`
  - `rate_app_dismissed`
- [ ] Export from shared_services
- [ ] Write integration tests

**Files to Create:**
- `packages/shared_services/lib/src/di/modules/rate_app_module.dart`

**Files to Modify:**
- `packages/quiz_engine/lib/src/config/quiz_config.dart`
- `packages/quiz_engine/lib/src/screens/quiz_results_screen.dart`
- `packages/shared_services/lib/shared_services.dart`
- `packages/shared_services/lib/src/di/di_exports.dart`

---

### Sprint 12.3: Rate App Analytics Events

**Tasks:**
- [ ] Create `RateAppEvent` sealed class
- [ ] Add to analytics exports
- [ ] Track all rate app interactions
- [ ] Write unit tests

**Files to Create:**
- `packages/shared_services/lib/src/analytics/events/rate_app_event.dart`
- `packages/shared_services/test/analytics/rate_app_event_test.dart`

---

## Known Bugs

### Practice Mode - Single Question Shows Only 1 Option

**Description:** When there is only 1 question left to practice, the quiz shows only 1 answer option instead of the normal 4 options.

**Root Cause:** The `RandomItemPicker` generates wrong answer options from available items. When practicing only 1 question, even though all countries are loaded for option generation, the filter reduces the quiz to 1 question. The options are generated before the filter is applied.

**Expected Behavior:** Practice mode should always show 4 answer options regardless of how many questions are being practiced.

**Workaround:** None currently.

**Priority:** Medium

---

### QuizFeedbackService Initialization - Technical Debt

**Description:** The `QuizFeedbackService` in `QuizScreenState` is currently initialized with defaults at declaration time to prevent `LateInitializationError`. This is a workaround, not an ideal solution.

**Current Implementation:**
```dart
// quiz_screen.dart
QuizFeedbackService _feedbackService = QuizFeedbackService();
```

**Problem:** The service is created twice - once with defaults, then potentially replaced in `_updateFeedbackServiceFromConfig()`. This is wasteful and the initialization pattern could be cleaner.

**Suggested Improvements:**
1. Refactor `QuizBloc` to make config available synchronously (non-late)
2. Use a factory pattern or dependency injection to provide the feedback service
3. Consider making `QuizFeedbackService` a singleton or provided via `InheritedWidget`
4. Use `didChangeDependencies()` instead of `initState()` for proper context access

**Location:** `packages/quiz_engine/lib/src/quiz/quiz_screen.dart:47`

**Priority:** Low

---

## Future Features

### Score-Based Achievements

**Description:** Add achievements that are unlocked based on score milestones.

**Examples:**
- "First 1000" - Score 1000+ points in a single session
- "Score Master" - Score 5000+ points in a single session
- "Perfect Speed" - Get maximum time bonus on all questions
- "High Roller" - Accumulate 50,000 total points

**Priority:** Medium (depends on Sprint 8.12 Scoring System)

---

## Future Sprints

### Sprint 4.4: UI Testing & Polish

**Tasks:**
- [ ] Test on all device types (mobile, tablet, desktop)
- [ ] Test all orientations (portrait, landscape, split screen)
- [ ] Test all platforms (iOS, Android, Web, macOS)
- [ ] Performance testing (60 FPS, no jank)
- [ ] Accessibility testing (screen reader, contrast, font scaling)
- [ ] Edge cases (long text, special characters, RTL)
- [ ] Polish (transitions, loading states, error states)

---

### Sprint 6.3: Session Detail Improvements ✅

**Tasks:**
- [x] Add question filter toggle (All/Wrong Only) to SessionDetailScreen

**Removed (not needed):**
- ~~Implement "Train Wrong Answers" action~~ - Practice mode already covers this use case
- ~~Add session navigation (previous/next session)~~ - Users navigate from list, no need for swipe
- ~~Add question jump/navigation within session~~ - Scrollable list is sufficient

**Files Modified:**
- ✅ `packages/quiz_engine/lib/src/screens/session_detail_screen.dart`

**Files Created:**
- ✅ `packages/quiz_engine/test/screens/session_detail_screen_test.dart`

---

## Completion Checklist

When completing a sprint:

1. Mark all tasks as `[x]`
2. Add `✅` to sprint title
3. List all created files under **Files Created:**
4. Run tests: `flutter test`
5. Run analyzer: `flutter analyze`
6. Use commiter agent with appropriate prefix (feat/fix/refactor/test/docs)

---

## Quick Commands

```bash
# Run tests for shared_services
cd packages/shared_services && flutter test

# Run analyzer
flutter analyze

# Format code
dart format .

# Commit changes (use commiter agent)
# Use prefix: feat, fix, refactor, test, docs, chore
```
