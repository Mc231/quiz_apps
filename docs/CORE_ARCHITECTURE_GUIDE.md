# Quiz Engine Core Architecture Guide

**Purpose:** This document defines how to implement all quiz features at the core package level (quiz_engine_core, quiz_engine, shared_services) to maximize reusability across multiple quiz apps.

**Implementation Tracking:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for phase/sprint progress and task tracking.

**Last Updated:** 2026-01-01

---

## Table of Contents

1. [Architecture Principles](#architecture-principles)
2. [Dependency Injection Pattern](#dependency-injection-pattern)
3. [Package Responsibilities](#package-responsibilities)
4. [Core Features Implementation](#core-features-implementation)
5. [Configuration System](#configuration-system)
6. [App-Specific vs Core Code](#app-specific-vs-core-code)
7. [Implementation Roadmap](#implementation-roadmap)
8. [Phase 11: QuizApp Refactoring](#phase-11-quizapp-refactoring)

---

## Architecture Principles

### Separation of Concerns

```
┌─────────────────────────────────────────────────────────┐
│  App Layer (flagsquiz, capitalquiz, etc.)               │
│  - Domain models (Country, Capital, etc.)               │
│  - Data sources (JSON, API)                             │
│  - App-specific screens (home, settings)                │
│  - Theme customization                                  │
│  - Localization                                         │
│  - Configuration (QuizConfig, QuizTheme)                │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │ uses
                         │
┌─────────────────────────────────────────────────────────┐
│  quiz_engine (UI Package)                               │
│  - Generic quiz screens                                 │
│  - Question widgets (image, text, audio, video)         │
│  - Answer widgets                                       │
│  - Results screen                                       │
│  - Achievements UI                                      │
│  - Statistics UI                                        │
│  - Configurable themes                                  │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │ uses
                         │
┌─────────────────────────────────────────────────────────┐
│  quiz_engine_core (Business Logic Package)              │
│  - QuizBloc (state management)                          │
│  - Domain models (Question, Answer, QuizState)          │
│  - Quiz modes (Standard, Timed, Lives, Endless)         │
│  - Scoring system                                       │
│  - Achievements engine                                  │
│  - Statistics tracking                                  │
│  - Hint system                                          │
│  - Repository interfaces                                │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │ uses
                         │
┌─────────────────────────────────────────────────────────┐
│  shared_services (Infrastructure Package)               │
│  - Analytics service (abstract + Firebase impl)         │
│  - Ads service (abstract + AdMob impl)                  │
│  - IAP service (abstract + Store impl)                  │
│  - Remote config service                                │
│  - Audio service                                        │
│  - Persistence service (Hive/SharedPreferences)         │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Core is UI-Agnostic**: Business logic has no Flutter dependencies
2. **UI is Business-Agnostic**: Widgets receive data/callbacks, no business logic
3. **Apps are Thin**: Apps provide domain models, data, and configuration
4. **Configuration over Hardcoding**: Everything is configurable
5. **Composition over Inheritance**: Use builders and strategies
6. **Services are Abstract**: Define interfaces in core, implement in shared_services
7. **Context-Based DI**: Access services via `BuildContext` extensions, not constructor injection

---

## Dependency Injection Pattern

### QuizServices Architecture

The codebase uses **context-based dependency injection** via `QuizServicesProvider`, eliminating the need for service locators like `get_it`.

```
┌───────────────────────────────────────────────────────┐
│  QuizServicesProvider (InheritedWidget)               │
│  ┌─────────────────────────────────────────────────┐  │
│  │  QuizServices (Immutable Container)             │  │
│  │  ├── settingsService: SettingsService           │  │
│  │  ├── storageService: StorageService             │  │
│  │  ├── achievementService: AchievementService     │  │
│  │  ├── screenAnalyticsService: AnalyticsService   │  │
│  │  └── quizAnalyticsService: QuizAnalyticsService │  │
│  └─────────────────────────────────────────────────┘  │
│                                                       │
│  Child Widgets access via:                            │
│    context.settingsService                            │
│    context.storageService                             │
│    context.screenAnalyticsService                     │
│    etc.                                               │
└───────────────────────────────────────────────────────┘
```

### Core Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `QuizServices` | `quiz_engine/src/services/` | Immutable container for all services |
| `QuizServicesProvider` | `quiz_engine/src/services/` | InheritedWidget to provide services |
| `QuizServicesContext` | `quiz_engine/src/services/` | Extension methods for context access |
| `QuizServicesScope` | `quiz_engine/src/services/` | Widget for scoped service overrides |

### Usage Pattern

**App Setup:**
```dart
// In app initialization
QuizServicesProvider(
  services: QuizServices(
    settingsService: settingsService,
    storageService: storageService,
    achievementService: achievementService,
    screenAnalyticsService: analyticsService,
    quizAnalyticsService: quizAnalyticsAdapter,
  ),
  child: QuizApp(...),
)
```

**Widget Access:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Direct access via context extension
    final analytics = context.screenAnalyticsService;

    analytics.logEvent(
      ScreenViewEvent.home(tabName: 'play'),
    );

    return ...;
  }
}
```

**StatefulWidget Pattern:**
```dart
class _MyScreenState extends State<MyScreen> {
  // Use getter for deferred access
  AnalyticsService get _analytics => context.screenAnalyticsService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Context is available here
    _logScreenView();
  }
}
```

### Testing Support

**Test Helpers:**
```dart
await tester.pumpWidget(
  wrapWithQuizServices(
    screenAnalyticsService: MockAnalyticsService(),
    child: MyWidget(),
  ),
);
```

**Scoped Overrides:**
```dart
// Override only specific services for a subtree
QuizServicesScope(
  screenAnalyticsService: NoOpAnalyticsService(),
  child: MyWidget(),  // Inherits other services from parent
)
```

### Why Context-Based DI?

| Approach | Pros | Cons |
|----------|------|------|
| Service Locator (`get_it`) | Simple, global access | Hidden dependencies, harder to test |
| Constructor Injection | Explicit dependencies | Verbose, prop drilling |
| **Context-Based (chosen)** | Type-safe, testable, Flutter-native | Requires widget tree |

The context-based approach:
- Uses Flutter's `InheritedWidget` for efficient rebuilds
- Makes dependencies explicit and discoverable
- Enables easy mocking in tests via `wrapWithQuizServices()`
- Avoids global state and hidden dependencies
- Supports scoped overrides via `QuizServicesScope`

---

## Package Responsibilities

### quiz_engine_core

**Owns:**
- Business logic (BLoC pattern)
- Domain models (Question, Answer, QuizState)
- Quiz modes and behaviors
- Scoring algorithms
- Achievement engine logic
- Statistics calculation
- Hint system logic
- Repository interfaces (no implementation)

**Does NOT own:**
- UI widgets
- Theme/styling
- Service implementations (analytics, ads, etc.)
- Platform-specific code
- App-specific domain models

### quiz_engine

**Owns:**
- Generic quiz UI screens
- Question display widgets
- Answer selection widgets
- Results screen
- Achievement UI components
- Statistics UI components
- Theme configuration system
- Animation and feedback widgets
- **QuizServices DI system** (QuizServicesProvider, QuizServicesScope, QuizServicesContext)

**Does NOT own:**
- Business logic
- State management (uses BLoC from core)
- Service implementations
- Data loading

### shared_services

**Owns:**
- Service interfaces (abstract classes)
- Service implementations (Firebase, AdMob, etc.)
- Platform-specific integrations
- Audio playback
- Persistence (local database, preferences)

**Does NOT own:**
- Business logic
- UI components
- App-specific configuration

### App Layer (flagsquiz, etc.)

**Owns:**
- Domain models (Country, Capital, etc.)
- Data sources and loading
- App-specific screens (home, about)
- Main navigation
- Configuration instances (QuizConfig, QuizTheme)
- Localization
- App-level theme

**Does NOT own:**
- Generic quiz UI (reuses from quiz_engine)
- Quiz business logic (uses quiz_engine_core)

---

## Core Features Implementation

### 1. Answer Feedback System

### 2. Quiz Modes System

### 3. Hints System

### 4. Statistics & Progress Tracking

### 5. Achievements System

### 6. Scoring System

### 7. Theme Configuration System

**Location:** `quiz_engine`

```dart
// lib/src/theme/quiz_theme_data.dart

class QuizThemeData {
  // Button styling
  final Color buttonColor;
  final Color buttonTextColor;
  final Color buttonBorderColor;
  final double buttonBorderWidth;
  final BorderRadius buttonBorderRadius;
  final EdgeInsets buttonPadding;
  final TextStyle buttonTextStyle;

  // Answer feedback colors
  final Color correctAnswerColor;
  final Color incorrectAnswerColor;
  final Color selectedAnswerColor;

  // Progress indicators
  final Color progressBackgroundColor;
  final Color progressForegroundColor;

  // Lives/hints display
  final Color livesColor;
  final Color hintsColor;

  // Timer colors
  final Color timerNormalColor;
  final Color timerWarningColor; // < 10 seconds
  final Color timerCriticalColor; // < 5 seconds

  // Results screen
  final Color starFilledColor;
  final Color starEmptyColor;

  const QuizThemeData({
    this.buttonColor = Colors.black,
    this.buttonTextColor = Colors.white,
    this.buttonBorderColor = Colors.transparent,
    this.buttonBorderWidth = 0,
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.buttonPadding = const EdgeInsets.all(16),
    this.buttonTextStyle = const TextStyle(fontSize: 18),
    this.correctAnswerColor = Colors.green,
    this.incorrectAnswerColor = Colors.red,
    this.selectedAnswerColor = Colors.blue,
    this.progressBackgroundColor = Colors.grey,
    this.progressForegroundColor = Colors.blue,
    this.livesColor = Colors.red,
    this.hintsColor = Colors.orange,
    this.timerNormalColor = Colors.blue,
    this.timerWarningColor = Colors.orange,
    this.timerCriticalColor = Colors.red,
    this.starFilledColor = Colors.amber,
    this.starEmptyColor = Colors.grey,
  });

  // Factory constructors for common themes
  factory QuizThemeData.light() => const QuizThemeData();

  factory QuizThemeData.dark() => const QuizThemeData(
        buttonColor: Colors.white,
        buttonTextColor: Colors.black,
        // ... etc
      );
}
```

---

### 8. Quiz Layout Configuration System

**Location:** `quiz_engine_core` (models) + `quiz_engine` (UI)

The layout system allows configuring how questions and answers are displayed, supporting different visual styles like image questions with text answers, text questions with image answers, or mixed modes.

#### QuizLayoutConfig (Sealed Class)

```dart
// packages/quiz_engine_core/lib/src/models/quiz_layout_config.dart

sealed class QuizLayoutConfig {
  const QuizLayoutConfig();

  // Factory constructors for all layout variants
  factory QuizLayoutConfig.imageQuestionTextAnswers() = ImageQuestionTextAnswersLayout;
  factory QuizLayoutConfig.textQuestionImageAnswers({String? questionTemplate}) = TextQuestionImageAnswersLayout;
  factory QuizLayoutConfig.textQuestionTextAnswers() = TextQuestionTextAnswersLayout;
  factory QuizLayoutConfig.imageQuestionImageAnswers() = ImageQuestionImageAnswersLayout;
  factory QuizLayoutConfig.mixed({double imageProbability = 0.5}) = MixedLayout;
}

// Layout variants
class ImageQuestionTextAnswersLayout extends QuizLayoutConfig {
  const ImageQuestionTextAnswersLayout();
}

class TextQuestionImageAnswersLayout extends QuizLayoutConfig {
  final String? questionTemplate; // e.g., "Which flag belongs to {country}?"
  const TextQuestionImageAnswersLayout({this.questionTemplate});
}

class MixedLayout extends QuizLayoutConfig {
  final double imageProbability; // 0.5 = 50% each type
  const MixedLayout({this.imageProbability = 0.5});
}
```

#### Layout Modes

| Layout Mode | Question Display | Answer Display | Use Case |
|-------------|-----------------|----------------|----------|
| `imageQuestionTextAnswers` | Image (flag) | Text buttons | Standard flags quiz |
| `textQuestionImageAnswers` | Text (country name) | Image grid | Reverse mode |
| `textQuestionTextAnswers` | Text | Text buttons | Capital cities quiz |
| `imageQuestionImageAnswers` | Image | Image grid | Visual matching |
| `mixed` | Random | Matches question | Variety/challenge |

#### Category Configuration

```dart
// Set layout at category level
final europeCategory = QuizCategory(
  id: 'europe',
  name: 'Europe',
  layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(), // Standard
);

final reverseCategory = QuizCategory(
  id: 'europe_reverse',
  name: 'Europe (Reverse)',
  layoutConfig: QuizLayoutConfig.textQuestionImageAnswers(
    questionTemplate: 'Which flag belongs to {country}?',
  ),
);

final mixedCategory = QuizCategory(
  id: 'europe_mixed',
  name: 'Europe (Mixed)',
  layoutConfig: QuizLayoutConfig.mixed(imageProbability: 0.5),
);
```

#### Play Tab Layout Mode Selector

The `LayoutModeSelector` widget allows users to switch between layout modes on the Play tab:

```dart
// Layout options for the selector
final layoutOptions = [
  LayoutModeOption(
    id: 'standard',
    icon: Icons.image,
    label: 'Standard',
    layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(),
  ),
  LayoutModeOption(
    id: 'reverse',
    icon: Icons.text_fields,
    label: 'Reverse',
    layoutConfig: QuizLayoutConfig.textQuestionImageAnswers(),
  ),
  LayoutModeOption(
    id: 'mixed',
    icon: Icons.shuffle,
    label: 'Mixed',
    layoutConfig: QuizLayoutConfig.mixed(),
  ),
];

// In QuizApp configuration
QuizApp(
  playLayoutModeOptionsBuilder: (context) => layoutOptions,
  playLayoutModeSelectorTitleBuilder: (context) => 'Quiz Mode',
)
```

#### Persistence

The user's preferred layout mode is saved in settings:

```dart
// QuizSettings stores the preference
class QuizSettings {
  final String? preferredLayoutModeId; // 'standard', 'reverse', 'mixed'
}

// SettingsService methods
await settingsService.setPreferredLayoutMode('reverse');
final layoutId = settingsService.settings.preferredLayoutModeId;
```

#### UI Components

| Widget | Location | Purpose |
|--------|----------|---------|
| `QuizLayout` | `quiz_engine/lib/src/quiz/quiz_layout.dart` | Main layout container |
| `ImageAnswerOptionWidget` | `quiz_engine/lib/src/quiz/widgets/` | Image answer grid item |
| `ImageAnswersGrid` | `quiz_engine/lib/src/quiz/widgets/` | Grid of image answers |
| `LayoutModeSelector` | `quiz_engine/lib/src/widgets/` | Mode selector chip group |
| `LayoutModeSelectorCard` | `quiz_engine/lib/src/widgets/` | Selector with title |

---

### 9. Shared Services Implementation

**Location:** `shared_services`

#### Analytics Service

```dart
// lib/src/analytics/analytics_service.dart

abstract class AnalyticsService {
  /// Initialize the analytics service
  Future<void> initialize();

  /// Log quiz started
  void logQuizStarted(String quizId, QuizMode mode);

  /// Log quiz completed
  void logQuizCompleted(String quizId, QuizResults results);

  /// Log answer submitted
  void logAnswerSubmitted(String quizId, bool isCorrect, Duration timeTaken);

  /// Log hint used
  void logHintUsed(String quizId, HintType hintType);

  /// Log achievement unlocked
  void logAchievementUnlocked(String achievementId);

  /// Log screen view
  void logScreenView(String screenName);

  /// Set user properties
  void setUserProperty(String name, String value);

  /// Log custom event
  void logEvent(String name, Map<String, dynamic>? parameters);
}

// lib/src/analytics/firebase_analytics_service.dart

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  void logQuizStarted(String quizId, QuizMode mode) {
    _analytics.logEvent(
      name: 'quiz_started',
      parameters: {
        'quiz_id': quizId,
        'mode': mode.name,
      },
    );
  }

  @override
  void logQuizCompleted(String quizId, QuizResults results) {
    _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'quiz_id': quizId,
        'score': results.score,
        'accuracy': results.accuracyPercentage,
        'time_taken': results.timeTaken.inSeconds,
        'mode': results.mode.name,
      },
    );
  }

  // ... etc
}

// lib/src/analytics/console_analytics_service.dart (for development)

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  Future<void> initialize() async {
    print('[Analytics] Initialized (Console Mode)');
  }

  @override
  void logQuizStarted(String quizId, QuizMode mode) {
    print('[Analytics] Quiz Started: $quizId (mode: $mode)');
  }

  // ... etc
}
```

#### Ads Service

```dart
// lib/src/ads/ads_service.dart

abstract class AdsService {
  /// Initialize ads
  Future<void> initialize(String appId);

  /// Load banner ad
  Future<void> loadBanner(String adUnitId);

  /// Show banner ad
  void showBanner();

  /// Hide banner ad
  void hideBanner();

  /// Load interstitial ad
  Future<void> loadInterstitial(String adUnitId);

  /// Show interstitial ad
  Future<bool> showInterstitial();

  /// Load rewarded ad
  Future<void> loadRewarded(String adUnitId);

  /// Show rewarded ad, returns true if user watched completely
  Future<bool> showRewarded();

  /// Check if ads are disabled (via IAP)
  bool get areAdsDisabled;

  /// Disable ads (after purchase)
  void disableAds();
}

// lib/src/ads/admob_service.dart

class AdMobService implements AdsService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _adsDisabled = false;

  @override
  Future<void> initialize(String appId) async {
    await MobileAds.instance.initialize();
  }

  @override
  Future<void> loadBanner(String adUnitId) async {
    if (_adsDisabled) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('[Ads] Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          print('[Ads] Banner failed: $error');
          ad.dispose();
        },
      ),
    );

    await _bannerAd!.load();
  }

  // ... etc
}

// lib/src/ads/no_ads_service.dart (for testing or premium users)

class NoAdsService implements AdsService {
  @override
  bool get areAdsDisabled => true;

  @override
  Future<void> initialize(String appId) async {}

  @override
  Future<void> loadBanner(String adUnitId) async {}

  @override
  void showBanner() {}

  // ... all methods are no-ops
}
```

#### IAP Service

```dart
// lib/src/iap/iap_service.dart

abstract class IAPService {
  /// Initialize IAP
  Future<void> initialize();

  /// Get available products
  Future<List<ProductDetails>> getProducts(Set<String> productIds);

  /// Purchase a product
  Future<bool> purchase(ProductDetails product);

  /// Restore purchases
  Future<void> restorePurchases();

  /// Check if product is purchased
  Future<bool> isPurchased(String productId);

  /// Stream of purchase updates
  Stream<PurchaseDetails> get purchaseStream;
}

// lib/src/iap/store_iap_service.dart

class StoreIAPService implements IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Set<String> _purchasedProducts = {};

  @override
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('IAP not available');
    }

    // Listen to purchase stream
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('[IAP] Error: $error'),
    );

    // Restore previous purchases
    await restorePurchases();
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _purchasedProducts.add(purchase.productID);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  @override
  Future<bool> isPurchased(String productId) async {
    return _purchasedProducts.contains(productId);
  }

  // ... etc
}
```

#### Audio Service

```dart
// lib/src/audio/audio_service.dart

enum SoundEffect {
  correct,
  incorrect,
  buttonTap,
  achievement,
  gameOver,
  timeWarning,
}

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;

  AudioService._();

  final Map<SoundEffect, AudioPlayer> _players = {};
  bool _soundsEnabled = true;

  Future<void> initialize() async {
    // Preload sound effects
    for (final effect in SoundEffect.values) {
      final player = AudioPlayer();
      await player.setSource(AssetSource(_getSoundPath(effect)));
      _players[effect] = player;
    }
  }

  String _getSoundPath(SoundEffect effect) {
    return switch (effect) {
      SoundEffect.correct => 'sounds/correct.mp3',
      SoundEffect.incorrect => 'sounds/incorrect.mp3',
      SoundEffect.buttonTap => 'sounds/tap.mp3',
      SoundEffect.achievement => 'sounds/achievement.mp3',
      SoundEffect.gameOver => 'sounds/game_over.mp3',
      SoundEffect.timeWarning => 'sounds/time_warning.mp3',
    };
  }

  Future<void> play(SoundEffect effect) async {
    if (!_soundsEnabled) return;

    final player = _players[effect];
    if (player == null) return;

    await player.seek(Duration.zero);
    await player.resume();
  }

  void setSoundsEnabled(bool enabled) {
    _soundsEnabled = enabled;
  }

  bool get soundsEnabled => _soundsEnabled;

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}
```

---

## Configuration System

### Complete QuizConfig

```dart
// packages/quiz_engine_core/lib/src/model/quiz_config.dart

class QuizConfig {
  // Core settings
  final String quizId;
  final QuizModeConfig modeConfig;
  final ScoringStrategy scoringStrategy;

  // UI behavior
  final bool showAnswerFeedback;
  final int answerFeedbackDuration; // milliseconds
  final bool playSounds;
  final bool hapticFeedback;

  // Hints
  final HintConfig hintConfig;

  // Question settings
  final int optionCount; // 2, 4, 6, etc.
  final bool shuffleQuestions;
  final bool shuffleOptions;

  // Persistence
  final StatisticsRepository? statisticsRepository;
  final AchievementRepository? achievementRepository;

  // Services
  final AnalyticsService analyticsService;
  final AdsService? adsService;

  const QuizConfig({
    required this.quizId,
    this.modeConfig = const QuizModeConfig.standard(),
    this.scoringStrategy = const SimpleScoring(),
    this.showAnswerFeedback = true,
    this.answerFeedbackDuration = 1500,
    this.playSounds = true,
    this.hapticFeedback = true,
    this.hintConfig = const HintConfig(),
    this.optionCount = 4,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
    this.statisticsRepository,
    this.achievementRepository,
    this.analyticsService,
    this.adsService,
  });
}
```

### App Usage Example

```dart
// apps/flagsquiz/lib/ui/continents/continents_screen.dart

void _startQuiz(Continent continent) {
  final config = QuizConfig(
    quizId: 'flags_${continent.name}',

    // Mode configuration
    modeConfig: const QuizModeConfig.standard(),
    // OR: QuizModeConfig.timed(timePerQuestion: 30),
    // OR: QuizModeConfig.lives(lives: 3),

    // Scoring
    scoringStrategy: const SimpleScoring(),

    // UI settings
    showAnswerFeedback: true,
    answerFeedbackDuration: 1500,
    playSounds: true,
    hapticFeedback: true,

    // Hints
    hintConfig: const HintConfig(
      initialHints: {
        HintType.fiftyFifty: 3,
        HintType.skip: 2,
      },
    ),

    // Persistence
    statisticsRepository: AppDependencies.statisticsRepository,
    achievementRepository: AppDependencies.achievementRepository,

    // Services
    analyticsService: AppDependencies.analytics,
    adsService: AppDependencies.ads,
  );

  final themeData = QuizThemeData(
    buttonColor: Colors.indigo,
    buttonTextColor: Colors.white,
    correctAnswerColor: Colors.green,
    incorrectAnswerColor: Colors.red,
    // ... etc
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizWidget(
        config: config,
        themeData: themeData,
        dataProvider: () => _loadCountries(continent),
      ),
    ),
  );
}
```

---

## App-Specific vs Core Code

### What Goes in Core Packages

**quiz_engine_core:**
- [ ] Quiz state management (BLoC)
- [ ] Quiz modes logic
- [ ] Scoring algorithms
- [ ] Hint system logic
- [ ] Achievement engine
- [ ] Statistics calculation
- [ ] Repository interfaces
- [ ] Domain models (Question, Answer, etc.)

**quiz_engine:**
- [ ] Generic quiz screen
- [ ] Question display widgets
- [ ] Answer selection widgets
- [ ] Feedback animations
- [ ] Results screen
- [ ] Achievement notification UI
- [ ] Statistics screen (generic)
- [ ] Theme configuration
- [ ] Timer displays
- [ ] Lives displays

**shared_services:**
- [ ] Analytics service interface + implementations
- [ ] Ads service interface + implementations
- [ ] IAP service interface + implementations
- [ ] Audio service
- [ ] Remote config service
- [ ] Persistence helpers

### What Goes in App Layer

**Each quiz app (flagsquiz, capitals quiz, etc.):**
- [ ] Domain models (Country, Capital, etc.)
- [ ] Data sources (JSON files, API clients)
- [ ] Data loading functions
- [ ] Conversion to QuestionEntry
- [ ] App-specific home screen
- [ ] App-specific navigation
- [ ] QuizConfig instances
- [ ] QuizThemeData instances
- [ ] Achievement definitions
- [ ] Localization (l10n)
- [ ] App-level MaterialApp theme
- [ ] Repository implementations (using Hive/SQLite)
- [ ] Service initialization
- [ ] Ad unit IDs, product IDs

### Home Screen Pattern

Each app should have its own home screen that:
1. Shows app branding
2. Displays categories/modes
3. Shows statistics overview
4. Navigates to quiz with configuration


Then apps compose these:

```dart
// App just provides the data
StatsOverviewCard(
  quizzesCompleted: stats.totalQuizzesCompleted,
  averageAccuracy: stats.overallAccuracy,
  currentStreak: stats.currentStreak,
)
```

---

## Implementation Roadmap

### Phase 1: Core Infrastructure (Week 1-2)

#### Sprint 1.1: Configuration & Theme System
- [x] Create `QuizConfig` class
- [x] Create `QuizModeConfig` class
- [x] Create `QuizThemeData` class
- [x] Create `HintConfig` class
- [x] Create `ScoringStrategy` classes (SimpleScoring, TimedScoring, StreakScoring)
- [x] Create `UIBehaviorConfig` class
- [x] Create `QuestionConfig` class
- [x] Create `BaseConfig` abstract class with serialization
- [x] Create `ConfigManager` with MVP DefaultSource
- [x] Update `QuizBloc` to accept configuration (via ConfigManager)
- [x] Update `QuizWidget` to accept theme data
- [x] Create `QuizTexts` class for text organization
- [x] Refactor `QuizWidgetEntry` to accept `defaultConfig` and auto-construct `ConfigManager`
- [x] Update all tests to use new ConfigManager pattern
- [ ] Extract hard-coded values to theme
- [ ] Test with flagsquiz app

**Status:** COMPLETED (2025-12-22)
**Completed Tasks:**
- Full configuration system with ConfigManager pattern
- Complete theme system (QuizThemeData) with light/dark themes
- QuizBloc integration with ConfigManager
- QuizWidget and QuizWidgetEntry refactoring
- All tests passing (quiz_engine_core: 56/56, quiz_engine: 39/39)

**Remaining:** Extract remaining hard-coded values, end-to-end testing with flagsquiz

#### Sprint 1.2: Answer Feedback System
- [x] Add `AnswerFeedbackState` to quiz state
- [x] Update `QuizBloc` to emit feedback state with async support
- [x] Make `QuizBloc._config` non-nullable for cleaner code
- [x] Update `QuizScreen` to handle `AnswerFeedbackState`
- [x] Update tests to support async `processAnswer`
- [x] Create dedicated `AnswerFeedbackWidget` for visual feedback
- [x] Add sound effects enum to shared_services
- [x] Implement `AudioService` in shared_services
- [x] Add haptic feedback integration (`HapticService`)
- [x] Add sound asset files to quiz_engine package
- [x] Test with different UIBehaviorConfig settings

**Status:** ✅ COMPLETED (2025-12-22)

**Completed Tasks:**
- **Answer Feedback System**: Full implementation with configurable delay
- **AnswerFeedbackWidget**: Dedicated widget with animated overlays showing correct/incorrect feedback
  - Elastic scale animation for feedback card
  - Fade-in opacity animation
  - Green checkmark for correct, red X for incorrect
  - Responsive sizing for mobile/tablet/desktop/watch
- **AudioService**: Complete audio playback service in shared_services
  - Volume control and muting
  - Sound effect preloading for smooth playback
  - Graceful error handling for missing assets
  - 10 standard sound effects enum (QuizSoundEffect)
  - Integrated with QuizScreen to play sounds on answer feedback
- **HapticService**: Haptic feedback wrapper in shared_services
  - Support for light, medium, heavy, selection, vibrate
  - Convenience methods: correctAnswer(), incorrectAnswer(), buttonClick(), etc.
  - Enable/disable toggle
  - Integrated with QuizScreen to trigger haptics on answer feedback
- **Sound Assets**: Generated placeholder sounds in quiz_engine package
  - 10 MP3 sound files (~45KB total)
  - Simple sine wave tones (production-ready placeholders)
  - Comprehensive README with resources for professional sounds
  - USAGE.md with integration examples
- **Service Integration**: Services properly initialized and triggered in QuizScreen
  - AudioService and HapticService instantiated in QuizScreenState
  - Services configured based on UIBehaviorConfig (playSounds, hapticFeedback)
  - Stream listener monitors AnswerFeedbackState and triggers feedback
  - Sound effects preloaded during initialization for smooth playback
  - Proper cleanup in dispose method
- **Tests**: All tests passing (quiz_engine: 39/39, shared_services: 25/25)

**Implementation Details:**
- **Location**: `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart`
- **Audio Location**: `packages/shared_services/lib/src/audio/`
- **Haptic Location**: `packages/shared_services/lib/src/haptic/`
- **Sound Assets**: `packages/quiz_engine/assets/sounds/`
- Feedback delay controlled by `UIBehaviorConfig.answerFeedbackDuration`
- When `showAnswerFeedback=true`, bloc emits `AnswerFeedbackState` before next question
- QuizScreen renders `AnswerFeedbackWidget` during feedback state
- Tests use `UIBehaviorConfig.noFeedback()` for faster execution

**Sound Effects Available:**
1. `correctAnswer` - Positive feedback for correct answer
2. `incorrectAnswer` - Negative feedback for incorrect answer
3. `buttonClick` - UI interaction sound
4. `quizComplete` - Completion celebration
5. `achievement` - Achievement unlock
6. `timerWarning` - Low time warning
7. `timeOut` - Time expired
8. `hintUsed` - Hint activation
9. `lifeLost` - Life/chance lost
10. `quizStart` - Quiz beginning

### Phase 2: Quiz Modes (Week 3)

#### Sprint 2.1: Lives Mode
- [x] Implement lives tracking in `QuizBloc`
- [x] Create `LivesDisplay` widget
- [x] Handle game over on no lives
- [x] Test lives mode

**Status:** ✅ COMPLETED (2025-12-22)

**Completed Tasks:**
- **QuizModeConfig Refactoring**: Converted from class with nullable fields to sealed class hierarchy
  - `StandardMode` - No lives, no timer
  - `TimedMode` - Timer only (timer logic not yet implemented)
  - `LivesMode` - Lives tracking only
  - `EndlessMode` - One life (one mistake ends game)
  - `SurvivalMode` - Lives + timer (timer logic not yet implemented)
  - Added computed `lives` getter to base class for clean access
  - Full type safety with pattern matching
  - Factory methods on base class for convenient instantiation
- **Lives Tracking in QuizBloc**: Complete implementation
  - `_remainingLives` field initialized from `modeConfig.lives`
  - Life deduction on wrong answers (line 111-113)
  - Game over logic when lives reach 0 (line 170-171)
  - Lives state propagated to all QuizStates (QuestionState, AnswerFeedbackState)
- **LivesDisplay Widget**: Responsive hearts display
  - Shows filled hearts for remaining lives, empty hearts for lost lives
  - Automatically hides when lives are not tracked
  - Responsive sizing for mobile/tablet/desktop/watch
  - Customizable icons and colors
  - Location: `packages/quiz_engine/lib/src/widgets/lives_display.dart`
- **QuizAppBarActions Widget**: Flexible app bar actions container
  - Displays LivesDisplay in quiz screen app bar
  - Ready for future additions (timer, hints, score, pause button)
  - Automatically hides when no actions are needed
  - Proper spacing between multiple action items
  - Location: `packages/quiz_engine/lib/src/widgets/quiz_app_bar_actions.dart`
- **App Bar Integration**: Lives display visible in quiz screen
  - QuizScreen refactored to use StreamBuilder for entire Scaffold
  - QuizAppBarActions in app bar actions list
  - Only shows when not in LoadingState
  - Lives update in real-time as user answers
- **Tests**: All 56 tests passing in quiz_engine_core

**Working Modes:**
- ✅ **StandardMode** - Normal quiz, no lives
- ✅ **LivesMode** - Start with N lives, lose one on wrong answer, game over at 0
- ✅ **EndlessMode** - One life, game over on first mistake
- ⚠️ **SurvivalMode** - Lives work, timer NOT implemented (acts as LivesMode currently)
- ⚠️ **TimedMode** - Timer logic NOT yet implemented

**Files Modified:**
- `packages/quiz_engine_core/lib/src/model/config/quiz_mode_config.dart` - Sealed class refactoring
- `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Lives tracking logic
- `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart` - Added remainingLives to states
- `packages/quiz_engine/lib/src/widgets/lives_display.dart` - New widget
- `packages/quiz_engine/lib/src/widgets/quiz_app_bar_actions.dart` - New widget
- `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - App bar integration
- `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart` - Pass lives to feedback state
- `packages/quiz_engine/lib/quiz_engine.dart` - Export new widgets

**Next:** Sprint 3.1 (Hints System) - Implement hint functionality

#### Sprint 2.2: Timed Mode
- [x] Implement question timer in `QuizBloc`
- [x] Implement total timer in `QuizBloc`
- [x] Create `TimerDisplay` widget
- [x] Handle time expiration
- [x] Add app lifecycle handling (pause/resume)
- [x] Test timed mode

**Status:** ✅ COMPLETED (2025-12-22)

**Completed Tasks:**
- **Timer State Management**: Added timer fields to QuizState
  - `questionTimeRemaining` - Per-question countdown timer
  - `totalTimeRemaining` - Total quiz time limit
  - Both fields added to QuestionState and AnswerFeedbackState
  - Location: `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart`
- **QuizBloc Timer Logic**: Complete timer implementation
  - Question timer starts when new question appears, counts down every second
  - Total timer tracks overall quiz time limit
  - Timer cancellation when answer is submitted
  - Time expiration handling - treats timeouts as incorrect answers
  - Timer pause/resume support for app lifecycle changes
  - Proper cleanup in dispose method
  - Location: `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart`
- **Answer Timeout Tracking**: Enhanced Answer model
  - Added `isTimeout` field to distinguish timeout from user-submitted answers
  - Timeout answers always counted as incorrect (prevents bug where correct answer shown on timeout)
  - Location: `packages/quiz_engine_core/lib/src/model/answer.dart`
- **TimerDisplay Widget**: Responsive timer UI component
  - Shows remaining time in "30s" format (< 60s) or "1:30" format (≥ 60s)
  - Color-coded: blue (normal) → orange (warning < 10s) → red (critical < 5s)
  - Rounded border design with timer icon
  - Supports both question and total timers
  - Different icon for total timer (hourglass)
  - Configurable thresholds and colors
  - Location: `packages/quiz_engine/lib/src/widgets/timer_display.dart`
- **App Lifecycle Handling**: Pause/resume timers when app goes to background
  - `QuizLifecycleHandler` widget observes app lifecycle changes
  - Automatically pauses timers when app becomes inactive/paused (calls, notifications, app switch)
  - Resumes timers when app returns to foreground
  - Gets QuizBloc from BlocProvider automatically
  - Integrated into QuizWidget for all quizzes
  - Location: `packages/quiz_engine/lib/src/widgets/quiz_lifecycle_handler.dart`
- **QuizAppBarActions Integration**: Shows both timers when configured
  - Displays question timer with clock icon
  - Displays total timer with hourglass icon
  - Side-by-side layout with proper spacing
  - Auto-hides when no timers active
  - Location: `packages/quiz_engine/lib/src/widgets/quiz_app_bar_actions.dart`
- **Tests**: All 59 tests passing

**Implementation Details:**
- **Timer Initialization**: In `performInitialLoad()`, reads `TimedMode.totalTimeLimit` and starts total timer if configured
- **Question Timer**: Starts in `_pickQuestion()` for each new question, reads `TimedMode.timePerQuestion` or `SurvivalMode.timePerQuestion`
- **State Updates**: Emits new QuizState every second with updated timer values for reactive UI
- **Timeout Handling**: When question timer expires:
  - Creates Answer with `isTimeout: true`
  - Deducts life if in Lives/Survival mode
  - Auto-advances to next question
  - Timeout answers counted as incorrect
- **Total Timer Expiration**: Ends quiz immediately when total time runs out
- **Lifecycle Handling**:
  - `pauseTimers()` - Cancels both timers but preserves remaining time values
  - `resumeTimers()` - Restarts timers from preserved values
  - Handles: incoming calls, app switching, screen lock, notifications
- **UI Integration**: QuizWidget automatically wraps quiz screen with QuizLifecycleHandler

**Files Modified:**
- `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart` - Added timer fields to states
- `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Timer logic and lifecycle methods
- `packages/quiz_engine_core/lib/src/model/answer.dart` - Added isTimeout field
- `packages/quiz_engine/lib/src/widgets/timer_display.dart` - NEW: Timer display widget
- `packages/quiz_engine/lib/src/widgets/quiz_lifecycle_handler.dart` - NEW: Lifecycle observer
- `packages/quiz_engine/lib/src/widgets/quiz_app_bar_actions.dart` - Dual timer display support
- `packages/quiz_engine/lib/src/quiz_widget.dart` - Lifecycle handler integration
- `packages/quiz_engine/lib/quiz_engine.dart` - Export new widgets


**Next:** Sprint 3.1 (Hints System) - Implement hint functionality

#### Sprint 2.3: Endless Mode
- [x] Implement infinite question picking
- [x] Handle game over on first wrong answer
- [x] Test endless mode

**Status:** ✅ COMPLETED (2025-12-22)

**Completed Tasks:**
- **Infinite Question Picking**: Complete implementation with question replenishment
  - Added `replenishFromAnswered()` method to RandomItemPicker
  - QuizBloc automatically replenishes questions when items exhausted in EndlessMode
  - Questions cycle infinitely allowing unlimited gameplay
  - Location: `packages/quiz_engine_core/lib/src/random_item_picker.dart`
- **Game Over on First Wrong Answer**: Already working via lives system
  - EndlessMode returns `lives = 1` from computed property
  - First incorrect answer triggers life loss
  - Game over immediately when lives reach 0
  - Works seamlessly with existing lives tracking logic
- **Tests**: All 59 tests passing (56 original + 3 new endless mode tests)
  - Test: Questions replenish when exhausted
  - Test: Game over on first wrong answer
  - Test: Infinite gameplay with correct answers
  - Location: `packages/quiz_engine_core/test/quiz_bloc_test.dart`

**Implementation Details:**
- **Replenishment Logic**: In `QuizBloc._pickQuestion()` (line 142-145)

- **Game Over**: Leverages existing `_isGameOver()` logic with lives = 1
- **Question Cycling**: Questions move from `items` to `_answeredItems` when picked, then replenish back to `items` when exhausted

**Files Modified:**
- `packages/quiz_engine_core/lib/src/random_item_picker.dart` - Added replenishFromAnswered() method
- `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Added endless mode replenishment logic
- `packages/quiz_engine_core/test/quiz_bloc_test.dart` - Added 3 comprehensive endless mode tests

**How It Works:**
1. User starts quiz in EndlessMode
2. Questions are picked normally until items list is exhausted
3. When `items.isEmpty`, bloc calls `replenishFromAnswered()`
4. All answered items move back to items list, shuffled
5. Questions continue infinitely as long as answers are correct
6. First wrong answer loses the one life → game over

**Testing Results:**
- ✅ Questions replenish correctly when exhausted
- ✅ Game ends immediately on first wrong answer
- ✅ Can answer 3x more questions than initial pool
- ✅ All 59 tests passing

**Next:** Sprint 4.1 (Results Screen) - Implement results screen

### Phase 3: Hints System (Week 4)

- [x] Create `HintState` class
- [x] Implement hint logic in `QuizBloc`
- [x] Create `HintsPanel` widget
- [x] Implement 50/50 hint
- [x] Implement skip hint
- [x] Test hint system

**Status:** ✅ COMPLETED (2025-12-22)

**Completed Tasks:**
- **HintState Integration**: Used existing HintState from HintConfig
  - HintState initialized from QuizConfig.hintConfig in QuizBloc
  - Tracks available hints per type (fiftyFifty, skip)
  - `canUseHint()` and `useHint()` methods for hint management
  - Location: `packages/quiz_engine_core/lib/src/model/config/hint_config.dart`
- **QuizBloc Hint Logic**: Complete hint implementation
  - `use50_50Hint()` method - Disables 2 random incorrect options
  - `skipQuestion()` method - Skips current question and marks as skipped
  - Hint state properly tracked and updated
  - All state emissions include current hint state
  - Location: `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart`
- **QuizState Enhancement**: Added hint support
  - Added `hintState` field to QuestionState
  - Added `disabledOptions` set to track 50/50 disabled options
  - Both fields propagated through all quiz states
  - Location: `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart`
- **Answer Model Enhancement**: Added skip tracking
  - Added `isSkipped` field to Answer class
  - Skipped questions counted as incorrect in scoring
  - Skipped flag distinct from timeout
  - Location: `packages/quiz_engine_core/lib/src/model/answer.dart`
- **HintsPanel Widget**: Responsive hints UI component
  - Shows 50/50 and Skip hint buttons with count badges
  - Buttons auto-disable when hints depleted
  - Visual feedback: gray + disabled when used
  - Responsive sizing for mobile/tablet/desktop/watch
  - Auto-hides when no hints available
  - Location: `packages/quiz_engine/lib/src/widgets/hints_panel.dart`
- **OptionButton Enhancement**: Added disabled state support
  - `isDisabled` parameter for disabling options
  - Visual feedback: gray background + strikethrough text
  - Non-clickable when disabled
  - Location: `packages/quiz_engine/lib/src/components/option_button.dart`
- **QuizAnswersWidget Update**: Passes disabled options to buttons
  - `disabledOptions` parameter added
  - Checks each option against disabled set
  - Disabled options rendered with visual feedback
  - Location: `packages/quiz_engine/lib/src/quiz/quiz_answers_widget.dart`
- **QuizLayout Integration**: HintsPanel displayed in quiz screen
  - HintsPanel positioned at top of quiz layout
  - Receives bloc reference for hint callbacks
  - Passes disabled options to answer buttons
  - Location: `packages/quiz_engine/lib/src/quiz/quiz_layout.dart`
- **QuizScreen Integration**: Bloc passed to all components
  - QuizLayout receives bloc reference
  - AnswerFeedbackWidget receives bloc reference
  - Enables hint functionality throughout quiz flow
  - Location: `packages/quiz_engine/lib/src/quiz/quiz_screen.dart`
- **Tests**: All tests passing (59/59 in quiz_engine_core, 33/36 in quiz_engine)

**Implementation Details:**
- **50/50 Hint**:
  - Finds all incorrect options
  - Randomly selects 2 to disable
  - Adds to `disabledOptions` set
  - Options remain disabled only for current question
  - Options reset on next question
- **Skip Hint**:
  - Creates Answer with `isSkipped: true`
  - Records skipped answer in answers list
  - Moves to next question immediately
  - Counted as incorrect in final score
- **Configuration**: Hints configured via HintConfig

**Files Modified:**
- `packages/quiz_engine_core/lib/src/business_logic/quiz_state/quiz_state.dart` - Added hintState and disabledOptions
- `packages/quiz_engine_core/lib/src/business_logic/quiz_bloc.dart` - Added hint methods
- `packages/quiz_engine_core/lib/src/model/answer.dart` - Added isSkipped field
- `packages/quiz_engine/lib/src/widgets/hints_panel.dart` - NEW: Hints UI widget
- `packages/quiz_engine/lib/src/components/option_button.dart` - Added disabled state support
- `packages/quiz_engine/lib/src/quiz/quiz_answers_widget.dart` - Disabled options support
- `packages/quiz_engine/lib/src/quiz/quiz_layout.dart` - HintsPanel integration
- `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` - Bloc propagation
- `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart` - Bloc reference added
- `packages/quiz_engine/lib/quiz_engine.dart` - Export HintsPanel
- Tests updated to pass bloc reference to layouts

**Next:** Phase 4 (User Experience & Settings) - HIGH PRIORITY

---

### Phase 4: User Experience & Settings (HIGH PRIORITY - Week 5)

#### Sprint 4.1: Exit Confirmation Dialog ✅
- [x] Create `ExitConfirmationDialog` widget in quiz_engine
- [x] Add `PopScope` wrapper to QuizScreen
- [x] Implement "Are you sure?" dialog with Yes/No buttons
- [x] Configurable via UIBehaviorConfig (allow disabling confirmation)

**Implementation:**
- Location: `packages/quiz_engine/lib/src/dialogs/exit_confirmation_dialog.dart`
- Reusable dialog widget with customizable text and theme
- QuizScreen wraps content with `WillPopScope`
- Returns `false` to prevent navigation until user confirms

#### Sprint 4.2: Localization System ✅
- [x] Enhance `QuizTexts` class with all UI strings
- [x] Make all hard-coded strings in quiz_engine localizable
- [x] Add all quiz UI strings to English ARB file (intl_en.arb)

#### Sprint 4.3: Settings Screen & Preferences ✅
- [x] Create `SettingsService` in shared_services for preferences storage
- [x] Implement SharedPreferences-based storage
- [x] Create `QuizSettings` model to hold all settings
- [x] Create `SettingsScreen` widget in quiz_engine
- [x] Settings features:
  - [x] Sound effects toggle (on/off)
  - [x] Music toggle (on/off, if background music added)
  - [x] Haptic feedback toggle (on/off)
  - [x] Show answer feedback toggle (on/off)
  - [x] Theme selection (Light/Dark/System)
  - [x] About section:
    - [x] App version display
    - [x] Credits/Attributions
    - [x] Privacy Policy link
    - [x] Terms of Service link
    - [x] Open source licenses
- [x] Settings persistence across app restarts
- [x] Apply settings in real-time (no restart required)
- [x] Export settings screen from quiz_engine
- [x] Test on all platforms
- [x] **BONUS:** Integrated settings into ConfigManager (eliminating separate provider abstraction)

## Phase 5: Data Persistence & Storage (Week 5-6)

**Goal**: Implement comprehensive local storage using sqflite with Repository Pattern to persist quiz sessions, questions/answers, and advanced statistics for review and analytics.

**Reference**: See [STORAGE_REQUIREMENTS.md](./STORAGE_REQUIREMENTS.md) for detailed schema and requirements.

### Architecture

**Repository Pattern Structure:**
```
packages/shared_services/lib/src/storage/
├── database/
│   ├── app_database.dart              # Main database class
│   ├── database_config.dart           # Database configuration
│   ├── migrations/                    # Schema migrations
│   │   ├── migration_v1.dart         # Initial schema
│   │   └── migration_v2.dart         # Future migrations
│   └── tables/                        # SQL table definitions
│       ├── quiz_sessions_table.dart
│       ├── question_answers_table.dart
│       ├── statistics_tables.dart
│       └── settings_table.dart
├── models/                            # Data models (PODOs)
│   ├── quiz_session.dart
│   ├── question_answer.dart
│   ├── global_statistics.dart
│   ├── quiz_type_statistics.dart
│   ├── daily_statistics.dart         # ✅ For fast charts/trends
│   └── user_settings_model.dart
├── data_sources/                      # sqflite implementations
│   ├── quiz_session_data_source.dart
│   ├── question_answer_data_source.dart
│   ├── statistics_data_source.dart
│   └── settings_data_source.dart
├── repositories/                      # Repository layer
│   ├── quiz_session_repository.dart  # Interface + Implementation
│   ├── statistics_repository.dart    # Interface + Implementation
│   └── settings_repository.dart      # Interface + Implementation
└── storage_service.dart               # Main service facade
```

### Sprint 5.1: Database Foundation & Core Models

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress

**Database Tables:**
- `quiz_sessions` - Primary session tracking
- `question_answers` - Detailed Q&A for review
- `global_statistics` - Aggregate stats
- `quiz_type_statistics` - Stats per quiz type/category
- `daily_statistics` - Pre-aggregated daily stats for charts
- `user_settings` - App preferences

---

### Sprint 5.2: Data Sources Implementation

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress---

### Sprint 5.3: Repository Layer Implementation

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress

**StatisticsRepository Features:**
- Calculate aggregate statistics (total games, avg score, etc.)
- Track daily/weekly/monthly trends
- Identify improvement patterns
- Generate reports and insights
- Real-time statistics updates via Streams

---

### Sprint 5.3.1: Dependency Injection Setup

> **Status:** ✅ Completed - Using Context-Based DI (Phase 10)

**Context-Based DI Pattern (Chosen Approach):**

The codebase uses `QuizServicesProvider` (InheritedWidget) instead of a service locator like `get_it`. This provides:
- Type-safe access via context extensions
- Easy mocking in tests via `wrapWithQuizServices()`
- No global state or hidden dependencies
- Scoped overrides via `QuizServicesScope`

See [Dependency Injection Pattern](#dependency-injection-pattern) section for full documentation.

**App Initialization:**
```dart
// In app main.dart
final services = QuizServices(
  settingsService: settingsService,
  storageService: storageService,
  achievementService: achievementService,
  screenAnalyticsService: analyticsService,
  quizAnalyticsService: quizAnalyticsAdapter,
);

runApp(
  QuizServicesProvider(
    services: services,
    child: QuizApp(...),
  ),
);
```

---

### Sprint 5.4: Integration with Quiz Engine

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress

**QuizBloc Integration:**

---

### Sprint 5.5: Review & Statistics UI

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress

**Session History Screen:**

**Statistics Dashboard:**
- Total games played
- Total time played
- Average score
- Best score
- Current streak
- Improvement trend graph
- Category breakdown
- Question success rate

---

### Sprint 5.6: Advanced Features & Optimization

> **Status:** See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md) for progress

**Features:**
- Data archiving (auto-archive old sessions)
- Database vacuum/cleanup scheduled task
- Pagination for large datasets
- Search/filter functionality
- Data export/import (GDPR compliance)
- Query optimization with proper indexes
- Performance monitoring

**Advanced Features:**
- Smart recommendations (practice weak areas)
- Learning curve analysis
- Spaced repetition integration
- Custom study plans based on stats
- Comparison with past performance

**Files to Create:**
- `packages/shared_services/lib/src/storage/utils/database_optimizer.dart`
- `packages/shared_services/lib/src/storage/utils/data_export.dart`
- `packages/shared_services/lib/src/storage/utils/data_import.dart`
- `packages/shared_services/test/storage/performance_test.dart`

### Testing Strategy

**Unit Tests:**
- Test all model serialization (toMap/fromMap)
- Test data source CRUD operations
- Test repository logic
- Test statistics calculations

**Integration Tests:**
- Test database migrations
- Test complete session save flow
- Test statistics updates
- Test concurrent operations

**Performance Tests:**
- Test with 1000+ sessions
- Test query performance
- Test batch operations
- Test memory usage

**Files:**
- `packages/shared_services/test/storage/database_test.dart`
- `packages/shared_services/test/storage/models_test.dart`
- `packages/shared_services/test/storage/data_sources/*_test.dart`
- `packages/shared_services/test/storage/repositories/*_test.dart`
- `packages/shared_services/test/storage/integration_test.dart`
- `packages/shared_services/test/storage/performance_test.dart`

### Migration from SharedPreferences

**Tasks:**
- [ ] Migrate user settings to database
- [ ] Keep SharedPreferences as fallback
- [ ] Implement one-time migration on app update
- [ ] Test migration flow
- [ ] Update SettingsService to use new repository

**Migration Strategy:**

### Documentation

**Tasks:**
- [ ] Update STORAGE_REQUIREMENTS.md with final schema
- [ ] Document repository pattern usage
- [ ] Create database schema diagram
- [ ] Write migration guide
- [ ] Add code examples to docs
- [ ] Update CLAUDE.md with storage architecture

**Files to Create/Update:**
- `docs/STORAGE_REQUIREMENTS.md` - UPDATE with final decisions
- `docs/STORAGE_ARCHITECTURE.md` - NEW detailed architecture doc
- `docs/DATABASE_SCHEMA.md` - NEW schema documentation
- `docs/MIGRATION_GUIDE.md` - NEW migration instructions
- `CLAUDE.md` - UPDATE with storage patterns

### Success Criteria

- [ ] All quiz sessions are persisted to database
- [ ] All question/answer pairs are saved for review (with all options + explanations)
- [ ] Statistics update in real-time (global, quiz type, and daily)
- [ ] Daily statistics are pre-aggregated for fast charts
- [ ] Users can review past quiz sessions with full replay capability
- [ ] Users can see detailed statistics and trends (instant loading)
- [ ] Charts load instantly from daily_statistics table
- [ ] Database performance is acceptable (< 50ms for queries)
- [ ] No data loss on app crash/kill
- [ ] Database migrations work correctly
- [ ] All tests pass (100+ tests for storage layer)
- [ ] Memory usage is acceptable (< 50MB for 1000 sessions)

### Dependencies

**Add to `packages/shared_services/pubspec.yaml`:**
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
  uuid: ^4.1.0

dev_dependencies:
  sqflite_common_ffi: ^2.3.0  # For desktop/testing
```

---

## Phase 6: Results & Statistics UI (Week 7)

### Sprint 6.1: Enhanced Results Screen
- [ ] Create `QuizResults` model (enhanced from Phase 5 data)
- [ ] Create enhanced `QuizResultsScreen` with historical data
- [ ] Add star rating display
- [ ] Add percentage display
- [ ] Add "Review This Session" button
- [ ] Add "Review All Wrong Answers" button
- [ ] Test results screens

### Sprint 6.2: Advanced Statistics UI
- [ ] Create Statistics Dashboard UI
- [ ] Add charts/graphs for trends
- [ ] Display aggregate statistics
- [ ] Show improvement over time
- [ ] Add category breakdown views
- [ ] Create leaderboards (local)
- [ ] Test statistics screens

---

## Phase 7: Achievements (Week 8)

- [ ] Create `Achievement` model
- [ ] Create `AchievementTrigger` hierarchy
- [ ] Create `AchievementEngine`
- [ ] Create `AchievementRepository` interface
- [ ] Implement repository in app
- [ ] Create `AchievementNotification` widget
- [ ] Create `AchievementsScreen`
- [ ] Define default achievements
- [ ] Test achievement system

---

## Phase 8: Shared Services (Week 9-10)

### Sprint 8.1: Analytics
- [ ] Create `AnalyticsService` interface
- [ ] Implement `FirebaseAnalyticsService`
- [ ] Implement `ConsoleAnalyticsService`
- [ ] Add analytics calls to `QuizBloc`
- [ ] Test analytics integration

### Sprint 8.2: Ads
- [ ] Create `AdsService` interface
- [ ] Implement `AdMobService`
- [ ] Implement `NoAdsService`
- [ ] Create banner ad widget
- [ ] Add interstitial ad points
- [ ] Add rewarded ad for hints
- [ ] Test ads integration

### Sprint 8.3: IAP
- [ ] Create `IAPService` interface
- [ ] Implement `StoreIAPService`
- [ ] Add "Remove Ads" product
- [ ] Create purchase UI
- [ ] Implement restore purchases
- [ ] Test IAP flow

---

## Phase 9: Polish & Integration (Week 11)

- [ ] Review all animations
- [ ] Optimize performance
- [ ] Add loading states
- [ ] Error handling
- [ ] Add comprehensive tests
- [ ] Update documentation
- [ ] Create migration guide for flagsquiz
- [ ] Test complete flow end-to-end

---

## Phase 10: Second App Validation (Week 12)

- [ ] Create second quiz app (e.g., capitals_quiz)
- [ ] Validate reusability of all components
- [ ] Identify any app-specific leakage
- [ ] Refactor as needed
- [ ] Update documentation with learnings
- [ ] Create app creation checklist

---

## Phase 11: QuizApp Refactoring

### Goal

Refactor quiz_engine to provide a complete `QuizApp` widget that handles everything (MaterialApp, theme, navigation, localization), so apps only need to provide data and configuration.

### QuizApp Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  App Layer (flagsquiz)                                          │
│  - QuizDataProvider implementation                              │
│  - QuizCategory list (continents)                               │
│  - ThemeData (light/dark)                                       │
│  - App-specific localization (country names)                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ provides
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  QuizApp (quiz_engine)                                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  MaterialApp                                                ││
│  │  - Theme management                                         ││
│  │  - Localization (QuizLocalizations + app delegates)         ││
│  │  - Service initialization                                   ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  QuizHomeScreen                                             ││
│  │  - Bottom navigation (configurable tabs)                    ││
│  │  - PlayScreen | HistoryScreen | StatisticsScreen | Settings ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  QuizLocalizations                                          ││
│  │  - ~80 engine-owned strings                                 ││
│  │  - Navigation, Quiz UI, History, Statistics, Settings       ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

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

### Key Components

#### QuizCategory

```dart
typedef LocalizedString = String Function(BuildContext context);

class QuizCategory {
  final String id;
  final LocalizedString title;      // Supports localization
  final LocalizedString? subtitle;
  final ImageProvider? imageProvider;
  final IconData? icon;
  final Color? iconColor;
  final QuizConfig? config;
  final Map<String, dynamic>? metadata;
}
```

#### QuizDataProvider

```dart
abstract class QuizDataProvider {
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    QuizCategory category,
  );

  QuizTexts? createQuizTexts(BuildContext context, QuizCategory category);
  StorageConfig? createStorageConfig(BuildContext context, QuizCategory category);
  ConfigManager? createConfigManager(BuildContext context, QuizCategory category);
}
```

#### QuizTab

```dart
enum QuizTab { play, history, statistics, settings }
```

#### QuizLocalizations (Engine-owned strings)

- **Navigation:** play, history, statistics, settings
- **Quiz UI:** score, correct, incorrect, duration, exitDialogTitle, etc.
- **History:** noSessionsYet, sessionCompleted, today, yesterday, daysAgo(n), etc.
- **Statistics:** totalSessions, averageScore, weeklyTrend, improving, etc.
- **Settings:** soundEffects, hapticFeedback, theme, about, etc.

### Ownership Split

| quiz_engine owns | App provides |
|------------------|--------------|
| QuizApp (root widget) | QuizDataProvider implementation |
| QuizHomeScreen (tabs) | QuizCategory list |
| PlayScreen (category grid/list) | ThemeData (light/dark) |
| QuizSettingsScreen (optional) | App-specific localization |
| QuizLocalizations (~80 strings) | |

### Implementation Sprints

See [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md#phase-11-quizapp-refactoring) for detailed sprint breakdown:

- **Sprint 11.1:** Core Models (QuizCategory, QuizDataProvider, QuizTab)
- **Sprint 11.2:** QuizLocalizations system
- **Sprint 11.3:** PlayScreen and CategoryCard
- **Sprint 11.4:** QuizHomeScreen with tabs
- **Sprint 11.5:** QuizSettingsScreen (optional)
- **Sprint 11.6:** QuizApp widget
- **Sprint 11.7:** FlagsQuiz migration

---

## Success Criteria

### Architecture Quality
- [x] Zero business logic in quiz_engine (UI package)
- [x] Zero UI code in quiz_engine_core
- [x] Core is platform-agnostic (no Flutter/HTTP dependencies)
- [x] Platform-specific code in shared_services (AssetProvider, HttpProviders)
- [x] BlocProvider moved to UI package (quiz_engine)
- [ ] All hard-coded values extracted to configuration
- [ ] Services are injectable and testable
- [ ] Apps are thin (< 20% of codebase)

**Architecture Compliance Achieved (2025-12-21):**
- quiz_engine_core: 100% platform-agnostic, no violations
- quiz_engine: Only UI components and Flutter widgets
- shared_services: Platform-specific infrastructure properly isolated
- All packages compile successfully, all tests passing

### Reusability
- [ ] Can create new quiz app in < 1 day
- [ ] New app requires < 500 lines of app-specific code
- [ ] All UI screens are reusable
- [ ] No code duplication between apps

### Feature Completeness
- [ ] All modes working (standard, timed, lives, endless, survival)
- [ ] All hints working
- [ ] Statistics persist and display correctly
- [ ] Achievements unlock and display
- [ ] Ads integrate cleanly
- [ ] IAP works for removing ads
- [ ] Analytics tracks all events

### Developer Experience
- [ ] Clear separation of concerns
- [ ] Easy to understand where code goes
- [ ] Configuration is intuitive
- [ ] Good documentation
- [ ] Examples for common patterns

---

## Next Steps

1. **Review this document** with the team
2. **Start Phase 1** (Core Infrastructure)
3. **Create feature branches** for each sprint
4. **Update CLAUDE.md** with architecture decisions
5. **Create issue templates** for new quiz apps
6. **Build CI/CD** for running tests across all packages

---

**Document Version:** 1.3
**Last Updated:** 2026-01-01
**Status:** Phase 5 Completed - Phase 11 (QuizApp Refactoring) Planned