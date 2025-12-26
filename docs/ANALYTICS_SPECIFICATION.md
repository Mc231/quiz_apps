# Analytics Specification

**Purpose:** Comprehensive analytics events specification for quiz apps with data sources, sealed event classes, and implementation architecture.

**Last Updated:** 2025-12-26

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Analytics Providers](#analytics-providers)
3. [Sealed Event Classes](#sealed-event-classes)
4. [Screen View Events](#screen-view-events)
5. [Quiz Lifecycle Events](#quiz-lifecycle-events)
6. [Question & Answer Events](#question--answer-events)
7. [User Interaction Events](#user-interaction-events)
8. [Hint Events](#hint-events)
9. [Resource Events](#resource-events)
10. [Achievement Events](#achievement-events)
11. [Settings Events](#settings-events)
12. [Monetization Events](#monetization-events)
13. [Error Events](#error-events)
14. [Performance Events](#performance-events)
15. [User Properties](#user-properties)
16. [Data Availability Matrix](#data-availability-matrix)
17. [Implementation Checklist](#implementation-checklist)

---

## Architecture Overview

### Design Principles

```
┌─────────────────────────────────────────────────────────────────────┐
│  App Layer (flagsquiz, etc.)                                        │
│  - Initialize analytics with API keys                               │
│  - Configure analytics providers                                    │
│  - Track app-specific events                                        │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  quiz_engine (UI Package)                                           │
│  - AnalyticsObserver widget for automatic screen tracking           │
│  - AnalyticsAware widgets with built-in tracking                    │
│  - No direct analytics calls - uses service from context            │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  shared_services (Analytics Package)                                │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  AnalyticsService (Abstract Interface)                       │   │
│  │  - Base contract for all analytics operations                │   │
│  │  - Event logging, screen tracking, user properties           │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│        ┌─────────────────────┼─────────────────────┐                │
│        │                     │                     │                │
│        ▼                     ▼                     ▼                │
│  ┌───────────────┐   ┌───────────────┐   ┌───────────────┐          │
│  │ Firebase      │   │ Console       │   │ Composite     │          │
│  │ Analytics     │   │ Analytics     │   │ Analytics     │          │
│  │ Service       │   │ Service       │   │ Service       │          │
│  └───────────────┘   └───────────────┘   └───────────────┘          │
│                                                │                    │
│                                    ┌───────────┴───────────┐        │
│                                    │                       │        │
│                              ┌─────▼─────┐          ┌──────▼─────┐  │
│                              │ Amplitude │          │ Mixpanel   │  │
│                              │ Service   │          │ Service    │  │
│                              └───────────┘          └────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Features

1. **Abstract Base Class**: `AnalyticsService` defines all analytics operations
2. **Sealed Event Classes**: Type-safe, exhaustive event definitions
3. **Multiple Providers**: Firebase, Amplitude, Mixpanel, Console (debug), No-op
4. **Composite Provider**: Send events to multiple providers simultaneously
5. **Automatic Tracking**: Screen views, app lifecycle, errors
6. **Privacy-First**: User consent management, GDPR compliance
7. **Offline Support**: Queue events when offline, send when connected
8. **Sampling**: Configure sampling rates for high-frequency events

---

## Analytics Providers

### 1. FirebaseAnalyticsService (Production)
- **Purpose**: Primary production analytics for Firebase ecosystem
- **Features**: Automatic session tracking, crash integration, BigQuery export
- **Dependencies**: `firebase_analytics: ^11.0.0`

### 2. ConsoleAnalyticsService (Development)
- **Purpose**: Debug analytics with readable console output
- **Features**: Formatted logs, event inspection, no external dependencies
- **Use Case**: Development and debugging

### 3. NoOpAnalyticsService (Testing)
- **Purpose**: Silent analytics for testing
- **Features**: No logging, no external calls
- **Use Case**: Unit tests, CI/CD

### 4. CompositeAnalyticsService (Multi-provider)
- **Purpose**: Send events to multiple providers
- **Features**: Fan-out to Firebase + Amplitude, etc.
- **Use Case**: Production with multiple analytics platforms

### 5. AmplitudeAnalyticsService (Optional)
- **Purpose**: Advanced product analytics
- **Features**: Cohort analysis, user journeys, A/B testing
- **Dependencies**: `amplitude_flutter: ^3.0.0`

### 6. MixpanelAnalyticsService (Optional)
- **Purpose**: User behavior analytics
- **Features**: Funnels, retention, engagement metrics
- **Dependencies**: `mixpanel_flutter: ^2.0.0`

---

## Sealed Event Classes

### Base Event Hierarchy

```dart
/// Base sealed class for all analytics events.
/// Each event category has its own sealed subtype.
sealed class AnalyticsEvent {
  const AnalyticsEvent();

  /// Event name for analytics providers (snake_case).
  String get eventName;

  /// Event parameters as a map.
  Map<String, dynamic> get parameters;

  // Factory constructors for convenience
  factory AnalyticsEvent.screenView(ScreenViewEvent event) = ScreenViewEvent;
  factory AnalyticsEvent.quiz(QuizEvent event) = QuizEvent;
  factory AnalyticsEvent.question(QuestionEvent event) = QuestionEvent;
  factory AnalyticsEvent.hint(HintEvent event) = HintEvent;
  factory AnalyticsEvent.resource(ResourceEvent event) = ResourceEvent;
  factory AnalyticsEvent.achievement(AchievementEvent event) = AchievementEvent;
  factory AnalyticsEvent.settings(SettingsEvent event) = SettingsEvent;
  factory AnalyticsEvent.monetization(MonetizationEvent event) = MonetizationEvent;
  factory AnalyticsEvent.error(ErrorEvent event) = ErrorEvent;
  factory AnalyticsEvent.performance(PerformanceEvent event) = PerformanceEvent;
  factory AnalyticsEvent.interaction(InteractionEvent event) = InteractionEvent;
}
```

### Event Categories Summary

| Category | Sealed Class | Event Count | Description |
|----------|--------------|-------------|-------------|
| Screen Views | `ScreenViewEvent` | 17 | Screen navigation tracking |
| Quiz Lifecycle | `QuizEvent` | 8 | Quiz start, complete, cancel |
| Question & Answer | `QuestionEvent` | 8 | Question display, answer submission |
| Hints | `HintEvent` | 4 | Hint usage events |
| Resources | `ResourceEvent` | 4 | Lives, timers |
| User Interactions | `InteractionEvent` | 12 | Button taps, navigation |
| Achievements | `AchievementEvent` | 5 | Achievement unlocks, views |
| Settings | `SettingsEvent` | 8 | Preference changes |
| Monetization | `MonetizationEvent` | 10 | IAP, ads, resource purchases |
| Errors | `ErrorEvent` | 6 | Error states, retries |
| Performance | `PerformanceEvent` | 5 | Timing, app lifecycle |
| **Total** | **10 categories** | **87** | |

---

## Screen View Events

### Sealed Class Definition

```dart
/// Sealed class for all screen view events.
/// Provides exhaustive tracking of all app screens.
sealed class ScreenViewEvent extends AnalyticsEvent {
  const ScreenViewEvent();

  @override
  String get eventName => 'screen_view';

  /// The screen name (required by all screen events).
  String get screenName;

  /// Optional screen class for more detailed tracking.
  String get screenClass;

  // ============ Home & Navigation Screens ============

  /// Home screen with tabs.
  factory ScreenViewEvent.home({
    required String activeTab,
  }) = HomeScreenView;

  /// Play/Categories tab.
  factory ScreenViewEvent.play({
    required int categoryCount,
  }) = PlayScreenView;

  /// Tabbed play screen variant.
  factory ScreenViewEvent.playTabbed({
    required String tabId,
    required String tabName,
  }) = PlayTabbedScreenView;

  /// Session history tab.
  factory ScreenViewEvent.history({
    required int sessionCount,
  }) = HistoryScreenView;

  /// Statistics dashboard tab.
  factory ScreenViewEvent.statistics({
    required int totalSessions,
    required double averageScore,
  }) = StatisticsScreenView;

  /// Achievements tab.
  factory ScreenViewEvent.achievements({
    required int unlockedCount,
    required int totalCount,
    required int totalPoints,
  }) = AchievementsScreenView;

  /// Settings tab.
  factory ScreenViewEvent.settings() = SettingsScreenView;

  // ============ Quiz Screens ============

  /// Quiz gameplay screen.
  factory ScreenViewEvent.quiz({
    required String quizId,
    required String quizName,
    required String mode,
    required int totalQuestions,
  }) = QuizScreenView;

  /// Quiz results screen.
  factory ScreenViewEvent.results({
    required String quizId,
    required String quizName,
    required double scorePercentage,
    required bool isPerfectScore,
    required int starRating,
  }) = ResultsScreenView;

  /// Session detail/review screen.
  factory ScreenViewEvent.sessionDetail({
    required String sessionId,
    required String quizName,
    required double scorePercentage,
    required int daysAgo,
  }) = SessionDetailScreenView;

  // ============ Category & Challenge Screens ============

  /// Category statistics screen.
  factory ScreenViewEvent.categoryStatistics({
    required String categoryId,
    required String categoryName,
    required int totalSessions,
    required double averageScore,
  }) = CategoryStatisticsScreenView;

  /// Challenges list screen.
  factory ScreenViewEvent.challenges({
    required int challengeCount,
    required int completedCount,
  }) = ChallengesScreenView;

  /// Practice mode screen.
  factory ScreenViewEvent.practice({
    required String categoryId,
    required String categoryName,
  }) = PracticeScreenView;

  // ============ Leaderboard & Social ============

  /// Leaderboard screen.
  factory ScreenViewEvent.leaderboard({
    required String leaderboardType,
    required int entryCount,
  }) = LeaderboardScreenView;

  // ============ Info Screens ============

  /// About dialog/screen.
  factory ScreenViewEvent.about({
    required String appVersion,
    required String buildNumber,
  }) = AboutScreenView;

  /// Open source licenses screen.
  factory ScreenViewEvent.licenses() = LicensesScreenView;
}
```

### Screen View Event Implementations

```dart
// ============ Home & Navigation ============

final class HomeScreenView extends ScreenViewEvent {
  const HomeScreenView({required this.activeTab});

  final String activeTab;

  @override
  String get screenName => 'home';
  @override
  String get screenClass => 'HomeScreen';

  @override
  Map<String, dynamic> get parameters => {
    'active_tab': activeTab,
  };
}

final class PlayScreenView extends ScreenViewEvent {
  const PlayScreenView({required this.categoryCount});

  final int categoryCount;

  @override
  String get screenName => 'play';
  @override
  String get screenClass => 'PlayScreen';

  @override
  Map<String, dynamic> get parameters => {
    'category_count': categoryCount,
  };
}

final class PlayTabbedScreenView extends ScreenViewEvent {
  const PlayTabbedScreenView({
    required this.tabId,
    required this.tabName,
  });

  final String tabId;
  final String tabName;

  @override
  String get screenName => 'play_tabbed';
  @override
  String get screenClass => 'PlayTabbedScreen';

  @override
  Map<String, dynamic> get parameters => {
    'tab_id': tabId,
    'tab_name': tabName,
  };
}

final class HistoryScreenView extends ScreenViewEvent {
  const HistoryScreenView({required this.sessionCount});

  final int sessionCount;

  @override
  String get screenName => 'history';
  @override
  String get screenClass => 'SessionHistoryScreen';

  @override
  Map<String, dynamic> get parameters => {
    'session_count': sessionCount,
  };
}

final class StatisticsScreenView extends ScreenViewEvent {
  const StatisticsScreenView({
    required this.totalSessions,
    required this.averageScore,
  });

  final int totalSessions;
  final double averageScore;

  @override
  String get screenName => 'statistics';
  @override
  String get screenClass => 'StatisticsDashboard';

  @override
  Map<String, dynamic> get parameters => {
    'total_sessions': totalSessions,
    'average_score': averageScore,
  };
}

final class AchievementsScreenView extends ScreenViewEvent {
  const AchievementsScreenView({
    required this.unlockedCount,
    required this.totalCount,
    required this.totalPoints,
  });

  final int unlockedCount;
  final int totalCount;
  final int totalPoints;

  @override
  String get screenName => 'achievements';
  @override
  String get screenClass => 'AchievementsScreen';

  @override
  Map<String, dynamic> get parameters => {
    'unlocked_count': unlockedCount,
    'total_count': totalCount,
    'total_points': totalPoints,
    'unlock_percentage': totalCount > 0
        ? (unlockedCount / totalCount * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class SettingsScreenView extends ScreenViewEvent {
  const SettingsScreenView();

  @override
  String get screenName => 'settings';
  @override
  String get screenClass => 'QuizSettingsScreen';

  @override
  Map<String, dynamic> get parameters => {};
}

// ============ Quiz Screens ============

final class QuizScreenView extends ScreenViewEvent {
  const QuizScreenView({
    required this.quizId,
    required this.quizName,
    required this.mode,
    required this.totalQuestions,
  });

  final String quizId;
  final String quizName;
  final String mode;
  final int totalQuestions;

  @override
  String get screenName => 'quiz';
  @override
  String get screenClass => 'QuizScreen';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'mode': mode,
    'total_questions': totalQuestions,
  };
}

final class ResultsScreenView extends ScreenViewEvent {
  const ResultsScreenView({
    required this.quizId,
    required this.quizName,
    required this.scorePercentage,
    required this.isPerfectScore,
    required this.starRating,
  });

  final String quizId;
  final String quizName;
  final double scorePercentage;
  final bool isPerfectScore;
  final int starRating;

  @override
  String get screenName => 'results';
  @override
  String get screenClass => 'QuizResultsScreen';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'score_percentage': scorePercentage,
    'is_perfect_score': isPerfectScore,
    'star_rating': starRating,
  };
}

final class SessionDetailScreenView extends ScreenViewEvent {
  const SessionDetailScreenView({
    required this.sessionId,
    required this.quizName,
    required this.scorePercentage,
    required this.daysAgo,
  });

  final String sessionId;
  final String quizName;
  final double scorePercentage;
  final int daysAgo;

  @override
  String get screenName => 'session_detail';
  @override
  String get screenClass => 'SessionDetailScreen';

  @override
  Map<String, dynamic> get parameters => {
    'session_id': sessionId,
    'quiz_name': quizName,
    'score_percentage': scorePercentage,
    'days_ago': daysAgo,
  };
}

// ============ Category & Challenge ============

final class CategoryStatisticsScreenView extends ScreenViewEvent {
  const CategoryStatisticsScreenView({
    required this.categoryId,
    required this.categoryName,
    required this.totalSessions,
    required this.averageScore,
  });

  final String categoryId;
  final String categoryName;
  final int totalSessions;
  final double averageScore;

  @override
  String get screenName => 'category_statistics';
  @override
  String get screenClass => 'CategoryStatisticsScreen';

  @override
  Map<String, dynamic> get parameters => {
    'category_id': categoryId,
    'category_name': categoryName,
    'total_sessions': totalSessions,
    'average_score': averageScore,
  };
}

final class ChallengesScreenView extends ScreenViewEvent {
  const ChallengesScreenView({
    required this.challengeCount,
    required this.completedCount,
  });

  final int challengeCount;
  final int completedCount;

  @override
  String get screenName => 'challenges';
  @override
  String get screenClass => 'ChallengesScreen';

  @override
  Map<String, dynamic> get parameters => {
    'challenge_count': challengeCount,
    'completed_count': completedCount,
    'completion_percentage': challengeCount > 0
        ? (completedCount / challengeCount * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class PracticeScreenView extends ScreenViewEvent {
  const PracticeScreenView({
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  String get screenName => 'practice';
  @override
  String get screenClass => 'PracticeScreen';

  @override
  Map<String, dynamic> get parameters => {
    'category_id': categoryId,
    'category_name': categoryName,
  };
}

// ============ Leaderboard ============

final class LeaderboardScreenView extends ScreenViewEvent {
  const LeaderboardScreenView({
    required this.leaderboardType,
    required this.entryCount,
  });

  final String leaderboardType;
  final int entryCount;

  @override
  String get screenName => 'leaderboard';
  @override
  String get screenClass => 'LeaderboardScreen';

  @override
  Map<String, dynamic> get parameters => {
    'leaderboard_type': leaderboardType,
    'entry_count': entryCount,
  };
}

// ============ Info Screens ============

final class AboutScreenView extends ScreenViewEvent {
  const AboutScreenView({
    required this.appVersion,
    required this.buildNumber,
  });

  final String appVersion;
  final String buildNumber;

  @override
  String get screenName => 'about';
  @override
  String get screenClass => 'AboutScreen';

  @override
  Map<String, dynamic> get parameters => {
    'app_version': appVersion,
    'build_number': buildNumber,
  };
}

final class LicensesScreenView extends ScreenViewEvent {
  const LicensesScreenView();

  @override
  String get screenName => 'licenses';
  @override
  String get screenClass => 'LicensesScreen';

  @override
  Map<String, dynamic> get parameters => {};
}
```

---

## Quiz Lifecycle Events

### Sealed Class Definition

```dart
/// Sealed class for quiz lifecycle events.
sealed class QuizEvent extends AnalyticsEvent {
  const QuizEvent();

  /// Quiz started - new session begins.
  factory QuizEvent.started({
    required String quizId,
    required String quizName,
    required String quizType,
    String? categoryId,
    String? categoryName,
    required int totalQuestions,
    required String mode,
    int? timeLimitSeconds,
    int? livesCount,
    int? hints5050Count,
    int? hintsSkipCount,
  }) = QuizStartedEvent;

  /// Quiz completed normally.
  factory QuizEvent.completed({
    required String quizId,
    required String quizName,
    required String quizType,
    String? categoryId,
    required int totalQuestions,
    required int totalAnswered,
    required int totalCorrect,
    required int totalIncorrect,
    required int totalSkipped,
    required double scorePercentage,
    required int scorePoints,
    required int durationSeconds,
    required String mode,
    required String completionStatus,
    required bool isPerfectScore,
    required int bestStreak,
    required int hints5050Used,
    required int hintsSkipUsed,
    required int livesUsed,
  }) = QuizCompletedEvent;

  /// Quiz cancelled by user.
  factory QuizEvent.cancelled({
    required String quizId,
    required String quizName,
    required double progressPercentage,
    required int questionsAnswered,
    required int totalQuestions,
    required int durationSeconds,
    required String exitMethod,
  }) = QuizCancelledEvent;

  /// Quiz ended due to timeout.
  factory QuizEvent.timeout({
    required String quizId,
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required int timeLimitSeconds,
    required double scorePercentage,
  }) = QuizTimeoutEvent;

  /// Quiz failed (lives depleted).
  factory QuizEvent.failed({
    required String quizId,
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required int livesInitial,
    required double scorePercentage,
  }) = QuizFailedEvent;

  /// Quiz paused (app went to background).
  factory QuizEvent.paused({
    required String quizId,
    required int questionNumber,
    required double progressPercentage,
  }) = QuizPausedEvent;

  /// Quiz resumed from background.
  factory QuizEvent.resumed({
    required String quizId,
    required int backgroundDurationSeconds,
    required int questionNumber,
  }) = QuizResumedEvent;

  /// Challenge mode started.
  factory QuizEvent.challengeStarted({
    required String challengeId,
    required String challengeName,
    required String challengeType,
    required String difficulty,
    String? categoryId,
  }) = ChallengeStartedEvent;
}
```

### Quiz Event Implementations

```dart
final class QuizStartedEvent extends QuizEvent {
  const QuizStartedEvent({
    required this.quizId,
    required this.quizName,
    required this.quizType,
    this.categoryId,
    this.categoryName,
    required this.totalQuestions,
    required this.mode,
    this.timeLimitSeconds,
    this.livesCount,
    this.hints5050Count,
    this.hintsSkipCount,
  });

  final String quizId;
  final String quizName;
  final String quizType;
  final String? categoryId;
  final String? categoryName;
  final int totalQuestions;
  final String mode;
  final int? timeLimitSeconds;
  final int? livesCount;
  final int? hints5050Count;
  final int? hintsSkipCount;

  @override
  String get eventName => 'quiz_started';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'quiz_type': quizType,
    if (categoryId != null) 'category_id': categoryId,
    if (categoryName != null) 'category_name': categoryName,
    'total_questions': totalQuestions,
    'mode': mode,
    if (timeLimitSeconds != null) 'time_limit_seconds': timeLimitSeconds,
    if (livesCount != null) 'lives_count': livesCount,
    if (hints5050Count != null) 'hints_5050_count': hints5050Count,
    if (hintsSkipCount != null) 'hints_skip_count': hintsSkipCount,
  };
}

final class QuizCompletedEvent extends QuizEvent {
  const QuizCompletedEvent({
    required this.quizId,
    required this.quizName,
    required this.quizType,
    this.categoryId,
    required this.totalQuestions,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalSkipped,
    required this.scorePercentage,
    required this.scorePoints,
    required this.durationSeconds,
    required this.mode,
    required this.completionStatus,
    required this.isPerfectScore,
    required this.bestStreak,
    required this.hints5050Used,
    required this.hintsSkipUsed,
    required this.livesUsed,
  });

  final String quizId;
  final String quizName;
  final String quizType;
  final String? categoryId;
  final int totalQuestions;
  final int totalAnswered;
  final int totalCorrect;
  final int totalIncorrect;
  final int totalSkipped;
  final double scorePercentage;
  final int scorePoints;
  final int durationSeconds;
  final String mode;
  final String completionStatus;
  final bool isPerfectScore;
  final int bestStreak;
  final int hints5050Used;
  final int hintsSkipUsed;
  final int livesUsed;

  @override
  String get eventName => 'quiz_completed';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'quiz_type': quizType,
    if (categoryId != null) 'category_id': categoryId,
    'total_questions': totalQuestions,
    'total_answered': totalAnswered,
    'total_correct': totalCorrect,
    'total_incorrect': totalIncorrect,
    'total_skipped': totalSkipped,
    'score_percentage': scorePercentage,
    'score_points': scorePoints,
    'duration_seconds': durationSeconds,
    'mode': mode,
    'completion_status': completionStatus,
    'is_perfect_score': isPerfectScore,
    'best_streak': bestStreak,
    'hints_5050_used': hints5050Used,
    'hints_skip_used': hintsSkipUsed,
    'lives_used': livesUsed,
    'accuracy': totalAnswered > 0
        ? (totalCorrect / totalAnswered * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class QuizCancelledEvent extends QuizEvent {
  const QuizCancelledEvent({
    required this.quizId,
    required this.quizName,
    required this.progressPercentage,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.exitMethod,
  });

  final String quizId;
  final String quizName;
  final double progressPercentage;
  final int questionsAnswered;
  final int totalQuestions;
  final int durationSeconds;
  final String exitMethod; // 'back_button' or 'dialog'

  @override
  String get eventName => 'quiz_cancelled';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'progress_percentage': progressPercentage,
    'questions_answered': questionsAnswered,
    'total_questions': totalQuestions,
    'duration_seconds': durationSeconds,
    'exit_method': exitMethod,
  };
}

final class QuizTimeoutEvent extends QuizEvent {
  const QuizTimeoutEvent({
    required this.quizId,
    required this.quizName,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.timeLimitSeconds,
    required this.scorePercentage,
  });

  final String quizId;
  final String quizName;
  final int questionsAnswered;
  final int totalQuestions;
  final int timeLimitSeconds;
  final double scorePercentage;

  @override
  String get eventName => 'quiz_timeout';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'questions_answered': questionsAnswered,
    'total_questions': totalQuestions,
    'time_limit_seconds': timeLimitSeconds,
    'score_percentage': scorePercentage,
    'progress_percentage': totalQuestions > 0
        ? (questionsAnswered / totalQuestions * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class QuizFailedEvent extends QuizEvent {
  const QuizFailedEvent({
    required this.quizId,
    required this.quizName,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.livesInitial,
    required this.scorePercentage,
  });

  final String quizId;
  final String quizName;
  final int questionsAnswered;
  final int totalQuestions;
  final int livesInitial;
  final double scorePercentage;

  @override
  String get eventName => 'quiz_failed';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'quiz_name': quizName,
    'questions_answered': questionsAnswered,
    'total_questions': totalQuestions,
    'lives_initial': livesInitial,
    'score_percentage': scorePercentage,
    'progress_percentage': totalQuestions > 0
        ? (questionsAnswered / totalQuestions * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class QuizPausedEvent extends QuizEvent {
  const QuizPausedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.progressPercentage,
  });

  final String quizId;
  final int questionNumber;
  final double progressPercentage;

  @override
  String get eventName => 'quiz_paused';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'progress_percentage': progressPercentage,
  };
}

final class QuizResumedEvent extends QuizEvent {
  const QuizResumedEvent({
    required this.quizId,
    required this.backgroundDurationSeconds,
    required this.questionNumber,
  });

  final String quizId;
  final int backgroundDurationSeconds;
  final int questionNumber;

  @override
  String get eventName => 'quiz_resumed';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'background_duration_seconds': backgroundDurationSeconds,
    'question_number': questionNumber,
  };
}

final class ChallengeStartedEvent extends QuizEvent {
  const ChallengeStartedEvent({
    required this.challengeId,
    required this.challengeName,
    required this.challengeType,
    required this.difficulty,
    this.categoryId,
  });

  final String challengeId;
  final String challengeName;
  final String challengeType;
  final String difficulty;
  final String? categoryId;

  @override
  String get eventName => 'challenge_started';

  @override
  Map<String, dynamic> get parameters => {
    'challenge_id': challengeId,
    'challenge_name': challengeName,
    'challenge_type': challengeType,
    'difficulty': difficulty,
    if (categoryId != null) 'category_id': categoryId,
  };
}
```

---

## Question & Answer Events

### Sealed Class Definition

```dart
/// Sealed class for question and answer events.
sealed class QuestionEvent extends AnalyticsEvent {
  const QuestionEvent();

  /// New question displayed.
  factory QuestionEvent.displayed({
    required String quizId,
    required int questionNumber,
    required int totalQuestions,
    required String questionType,
    required int optionsCount,
    int? timeLimitSeconds,
    required bool hasDisabledOptions,
  }) = QuestionDisplayedEvent;

  /// User submitted an answer.
  factory QuestionEvent.answered({
    required String quizId,
    required int questionNumber,
    required String questionId,
    required bool isCorrect,
    required String answerStatus,
    required int timeSpentSeconds,
    required String hintUsed,
    required int disabledOptionsCount,
    required int currentStreak,
    int? livesRemaining,
    int? timeRemainingSeconds,
  }) = AnswerSubmittedEvent;

  /// Correct answer submitted.
  factory QuestionEvent.correct({
    required String quizId,
    required int questionNumber,
    required int timeSpentSeconds,
    required int streakCount,
    required bool isQuickAnswer,
    int? bonusPoints,
  }) = AnswerCorrectEvent;

  /// Incorrect answer submitted.
  factory QuestionEvent.incorrect({
    required String quizId,
    required int questionNumber,
    required int timeSpentSeconds,
    required String correctAnswerId,
    String? userAnswerId,
    int? livesRemaining,
    required int streakBroken,
  }) = AnswerIncorrectEvent;

  /// Question skipped via hint.
  factory QuestionEvent.skipped({
    required String quizId,
    required int questionNumber,
    required int skipHintsRemaining,
  }) = QuestionSkippedEvent;

  /// Question timed out.
  factory QuestionEvent.timeout({
    required String quizId,
    required int questionNumber,
    required int timeLimitSeconds,
    int? livesRemaining,
  }) = QuestionTimeoutEvent;

  /// Answer feedback shown.
  factory QuestionEvent.feedbackShown({
    required String quizId,
    required int questionNumber,
    required bool isCorrect,
    required int feedbackDurationMs,
  }) = AnswerFeedbackShownEvent;

  /// Option selected (before submission).
  factory QuestionEvent.optionSelected({
    required String quizId,
    required int questionNumber,
    required int optionPosition,
  }) = OptionSelectedEvent;
}
```

### Question Event Implementations

```dart
final class QuestionDisplayedEvent extends QuestionEvent {
  const QuestionDisplayedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionType,
    required this.optionsCount,
    this.timeLimitSeconds,
    required this.hasDisabledOptions,
  });

  final String quizId;
  final int questionNumber;
  final int totalQuestions;
  final String questionType; // image, text, audio, video
  final int optionsCount;
  final int? timeLimitSeconds;
  final bool hasDisabledOptions;

  @override
  String get eventName => 'question_displayed';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'total_questions': totalQuestions,
    'question_type': questionType,
    'options_count': optionsCount,
    if (timeLimitSeconds != null) 'time_limit_seconds': timeLimitSeconds,
    'has_disabled_options': hasDisabledOptions,
    'progress_percentage': totalQuestions > 0
        ? ((questionNumber - 1) / totalQuestions * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class AnswerSubmittedEvent extends QuestionEvent {
  const AnswerSubmittedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.questionId,
    required this.isCorrect,
    required this.answerStatus,
    required this.timeSpentSeconds,
    required this.hintUsed,
    required this.disabledOptionsCount,
    required this.currentStreak,
    this.livesRemaining,
    this.timeRemainingSeconds,
  });

  final String quizId;
  final int questionNumber;
  final String questionId;
  final bool isCorrect;
  final String answerStatus; // correct, incorrect, skipped, timeout
  final int timeSpentSeconds;
  final String hintUsed; // none, fifty_fifty, skip
  final int disabledOptionsCount;
  final int currentStreak;
  final int? livesRemaining;
  final int? timeRemainingSeconds;

  @override
  String get eventName => 'answer_submitted';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'question_id': questionId,
    'is_correct': isCorrect,
    'answer_status': answerStatus,
    'time_spent_seconds': timeSpentSeconds,
    'hint_used': hintUsed,
    'disabled_options_count': disabledOptionsCount,
    'current_streak': currentStreak,
    if (livesRemaining != null) 'lives_remaining': livesRemaining,
    if (timeRemainingSeconds != null) 'time_remaining_seconds': timeRemainingSeconds,
  };
}

final class AnswerCorrectEvent extends QuestionEvent {
  const AnswerCorrectEvent({
    required this.quizId,
    required this.questionNumber,
    required this.timeSpentSeconds,
    required this.streakCount,
    required this.isQuickAnswer,
    this.bonusPoints,
  });

  final String quizId;
  final int questionNumber;
  final int timeSpentSeconds;
  final int streakCount;
  final bool isQuickAnswer; // < 2 seconds
  final int? bonusPoints;

  @override
  String get eventName => 'answer_correct';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'time_spent_seconds': timeSpentSeconds,
    'streak_count': streakCount,
    'is_quick_answer': isQuickAnswer,
    if (bonusPoints != null) 'bonus_points': bonusPoints,
  };
}

final class AnswerIncorrectEvent extends QuestionEvent {
  const AnswerIncorrectEvent({
    required this.quizId,
    required this.questionNumber,
    required this.timeSpentSeconds,
    required this.correctAnswerId,
    this.userAnswerId,
    this.livesRemaining,
    required this.streakBroken,
  });

  final String quizId;
  final int questionNumber;
  final int timeSpentSeconds;
  final String correctAnswerId;
  final String? userAnswerId;
  final int? livesRemaining;
  final int streakBroken; // Streak value before it was broken

  @override
  String get eventName => 'answer_incorrect';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'time_spent_seconds': timeSpentSeconds,
    'correct_answer_id': correctAnswerId,
    if (userAnswerId != null) 'user_answer_id': userAnswerId,
    if (livesRemaining != null) 'lives_remaining': livesRemaining,
    'streak_broken': streakBroken,
  };
}

final class QuestionSkippedEvent extends QuestionEvent {
  const QuestionSkippedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.skipHintsRemaining,
  });

  final String quizId;
  final int questionNumber;
  final int skipHintsRemaining;

  @override
  String get eventName => 'question_skipped';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'skip_hints_remaining': skipHintsRemaining,
  };
}

final class QuestionTimeoutEvent extends QuestionEvent {
  const QuestionTimeoutEvent({
    required this.quizId,
    required this.questionNumber,
    required this.timeLimitSeconds,
    this.livesRemaining,
  });

  final String quizId;
  final int questionNumber;
  final int timeLimitSeconds;
  final int? livesRemaining;

  @override
  String get eventName => 'question_timeout';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'time_limit_seconds': timeLimitSeconds,
    if (livesRemaining != null) 'lives_remaining': livesRemaining,
  };
}

final class AnswerFeedbackShownEvent extends QuestionEvent {
  const AnswerFeedbackShownEvent({
    required this.quizId,
    required this.questionNumber,
    required this.isCorrect,
    required this.feedbackDurationMs,
  });

  final String quizId;
  final int questionNumber;
  final bool isCorrect;
  final int feedbackDurationMs;

  @override
  String get eventName => 'answer_feedback_shown';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'is_correct': isCorrect,
    'feedback_duration_ms': feedbackDurationMs,
  };
}

final class OptionSelectedEvent extends QuestionEvent {
  const OptionSelectedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.optionPosition,
  });

  final String quizId;
  final int questionNumber;
  final int optionPosition; // 0-3

  @override
  String get eventName => 'option_selected';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'option_position': optionPosition,
  };
}
```

---

## Hint Events

### Sealed Class Definition

```dart
/// Sealed class for hint-related events.
sealed class HintEvent extends AnalyticsEvent {
  const HintEvent();

  /// 50/50 hint used.
  factory HintEvent.fiftyFiftyUsed({
    required String quizId,
    required int questionNumber,
    required int hintsRemainingBefore,
    required int hintsRemainingAfter,
    int optionsDisabled = 2,
  }) = HintFiftyFiftyUsedEvent;

  /// Skip hint used.
  factory HintEvent.skipUsed({
    required String quizId,
    required int questionNumber,
    required int hintsRemainingBefore,
    required int hintsRemainingAfter,
  }) = HintSkipUsedEvent;

  /// User tapped depleted hint button.
  factory HintEvent.unavailableTapped({
    required String quizId,
    required String hintType,
    required int questionNumber,
  }) = HintUnavailableTappedEvent;

  /// Timer warning shown.
  factory HintEvent.timerWarning({
    required String quizId,
    required String timerType,
    required int timeRemainingSeconds,
    required int questionNumber,
  }) = TimerWarningEvent;
}
```

### Hint Event Implementations

```dart
final class HintFiftyFiftyUsedEvent extends HintEvent {
  const HintFiftyFiftyUsedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.hintsRemainingBefore,
    required this.hintsRemainingAfter,
    this.optionsDisabled = 2,
  });

  final String quizId;
  final int questionNumber;
  final int hintsRemainingBefore;
  final int hintsRemainingAfter;
  final int optionsDisabled;

  @override
  String get eventName => 'hint_fifty_fifty_used';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'hints_remaining_before': hintsRemainingBefore,
    'hints_remaining_after': hintsRemainingAfter,
    'options_disabled': optionsDisabled,
  };
}

final class HintSkipUsedEvent extends HintEvent {
  const HintSkipUsedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.hintsRemainingBefore,
    required this.hintsRemainingAfter,
  });

  final String quizId;
  final int questionNumber;
  final int hintsRemainingBefore;
  final int hintsRemainingAfter;

  @override
  String get eventName => 'hint_skip_used';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'hints_remaining_before': hintsRemainingBefore,
    'hints_remaining_after': hintsRemainingAfter,
  };
}

final class HintUnavailableTappedEvent extends HintEvent {
  const HintUnavailableTappedEvent({
    required this.quizId,
    required this.hintType,
    required this.questionNumber,
  });

  final String quizId;
  final String hintType; // fifty_fifty, skip
  final int questionNumber;

  @override
  String get eventName => 'hint_unavailable_tapped';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'hint_type': hintType,
    'question_number': questionNumber,
  };
}

final class TimerWarningEvent extends HintEvent {
  const TimerWarningEvent({
    required this.quizId,
    required this.timerType,
    required this.timeRemainingSeconds,
    required this.questionNumber,
  });

  final String quizId;
  final String timerType; // question, total
  final int timeRemainingSeconds;
  final int questionNumber;

  @override
  String get eventName => 'timer_warning_shown';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'timer_type': timerType,
    'time_remaining_seconds': timeRemainingSeconds,
    'question_number': questionNumber,
  };
}
```

---

## Resource Events

### Sealed Class Definition

```dart
/// Sealed class for resource-related events (lives, etc.).
sealed class ResourceEvent extends AnalyticsEvent {
  const ResourceEvent();

  /// Life lost.
  factory ResourceEvent.lifeLost({
    required String quizId,
    required int questionNumber,
    required int livesRemaining,
    required String cause,
  }) = LifeLostEvent;

  /// All lives depleted.
  factory ResourceEvent.livesDepleted({
    required String quizId,
    required int questionNumber,
    required int totalLives,
    required double scorePercentage,
  }) = LivesDepletedEvent;

  /// Resource button tapped.
  factory ResourceEvent.buttonTapped({
    required String resourceType,
    required int currentCount,
    required String action,
  }) = ResourceButtonTappedEvent;

  /// Resource added (via purchase or ad).
  factory ResourceEvent.added({
    required String resourceType,
    required int amountAdded,
    required int newTotal,
    required String source,
  }) = ResourceAddedEvent;
}
```

### Resource Event Implementations

```dart
final class LifeLostEvent extends ResourceEvent {
  const LifeLostEvent({
    required this.quizId,
    required this.questionNumber,
    required this.livesRemaining,
    required this.cause,
  });

  final String quizId;
  final int questionNumber;
  final int livesRemaining;
  final String cause; // wrong_answer, timeout

  @override
  String get eventName => 'life_lost';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'lives_remaining': livesRemaining,
    'cause': cause,
  };
}

final class LivesDepletedEvent extends ResourceEvent {
  const LivesDepletedEvent({
    required this.quizId,
    required this.questionNumber,
    required this.totalLives,
    required this.scorePercentage,
  });

  final String quizId;
  final int questionNumber;
  final int totalLives;
  final double scorePercentage;

  @override
  String get eventName => 'lives_depleted';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'total_lives': totalLives,
    'score_percentage': scorePercentage,
  };
}

final class ResourceButtonTappedEvent extends ResourceEvent {
  const ResourceButtonTappedEvent({
    required this.resourceType,
    required this.currentCount,
    required this.action,
  });

  final String resourceType; // lives, hints_5050, hints_skip
  final int currentCount;
  final String action; // use, purchase_prompt

  @override
  String get eventName => 'resource_button_tapped';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'current_count': currentCount,
    'action': action,
  };
}

final class ResourceAddedEvent extends ResourceEvent {
  const ResourceAddedEvent({
    required this.resourceType,
    required this.amountAdded,
    required this.newTotal,
    required this.source,
  });

  final String resourceType;
  final int amountAdded;
  final int newTotal;
  final String source; // purchase, ad, reward

  @override
  String get eventName => 'resource_added';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'amount_added': amountAdded,
    'new_total': newTotal,
    'source': source,
  };
}
```

---

## Achievement Events

### Sealed Class Definition

```dart
/// Sealed class for achievement events.
sealed class AchievementEvent extends AnalyticsEvent {
  const AchievementEvent();

  /// Achievement unlocked.
  factory AchievementEvent.unlocked({
    required String achievementId,
    required String achievementName,
    required String achievementTier,
    required String achievementCategory,
    required int pointsEarned,
    required int totalPoints,
    required int unlockedCount,
    required int totalAchievements,
  }) = AchievementUnlockedEvent;

  /// Achievement notification shown.
  factory AchievementEvent.notificationShown({
    required String achievementId,
    required String achievementName,
    required int displayDurationMs,
  }) = AchievementNotificationShownEvent;

  /// Achievement notification tapped.
  factory AchievementEvent.notificationTapped({
    required String achievementId,
    required String navigationTarget,
  }) = AchievementNotificationTappedEvent;

  /// Achievement detail viewed.
  factory AchievementEvent.detailViewed({
    required String achievementId,
    required String achievementName,
    required bool isUnlocked,
    double? progressPercentage,
  }) = AchievementDetailViewedEvent;

  /// Achievements filtered.
  factory AchievementEvent.filtered({
    required String filterType,
    required int resultCount,
  }) = AchievementsFilteredEvent;
}
```

### Achievement Event Implementations

```dart
final class AchievementUnlockedEvent extends AchievementEvent {
  const AchievementUnlockedEvent({
    required this.achievementId,
    required this.achievementName,
    required this.achievementTier,
    required this.achievementCategory,
    required this.pointsEarned,
    required this.totalPoints,
    required this.unlockedCount,
    required this.totalAchievements,
  });

  final String achievementId;
  final String achievementName;
  final String achievementTier;
  final String achievementCategory;
  final int pointsEarned;
  final int totalPoints;
  final int unlockedCount;
  final int totalAchievements;

  @override
  String get eventName => 'achievement_unlocked';

  @override
  Map<String, dynamic> get parameters => {
    'achievement_id': achievementId,
    'achievement_name': achievementName,
    'achievement_tier': achievementTier,
    'achievement_category': achievementCategory,
    'points_earned': pointsEarned,
    'total_points': totalPoints,
    'unlocked_count': unlockedCount,
    'total_achievements': totalAchievements,
    'unlock_percentage': totalAchievements > 0
        ? (unlockedCount / totalAchievements * 100).toStringAsFixed(1)
        : '0.0',
  };
}

final class AchievementNotificationShownEvent extends AchievementEvent {
  const AchievementNotificationShownEvent({
    required this.achievementId,
    required this.achievementName,
    required this.displayDurationMs,
  });

  final String achievementId;
  final String achievementName;
  final int displayDurationMs;

  @override
  String get eventName => 'achievement_notification_shown';

  @override
  Map<String, dynamic> get parameters => {
    'achievement_id': achievementId,
    'achievement_name': achievementName,
    'display_duration_ms': displayDurationMs,
  };
}

final class AchievementNotificationTappedEvent extends AchievementEvent {
  const AchievementNotificationTappedEvent({
    required this.achievementId,
    required this.navigationTarget,
  });

  final String achievementId;
  final String navigationTarget;

  @override
  String get eventName => 'achievement_notification_tapped';

  @override
  Map<String, dynamic> get parameters => {
    'achievement_id': achievementId,
    'navigation_target': navigationTarget,
  };
}

final class AchievementDetailViewedEvent extends AchievementEvent {
  const AchievementDetailViewedEvent({
    required this.achievementId,
    required this.achievementName,
    required this.isUnlocked,
    this.progressPercentage,
  });

  final String achievementId;
  final String achievementName;
  final bool isUnlocked;
  final double? progressPercentage;

  @override
  String get eventName => 'achievement_detail_viewed';

  @override
  Map<String, dynamic> get parameters => {
    'achievement_id': achievementId,
    'achievement_name': achievementName,
    'is_unlocked': isUnlocked,
    if (progressPercentage != null) 'progress_percentage': progressPercentage,
  };
}

final class AchievementsFilteredEvent extends AchievementEvent {
  const AchievementsFilteredEvent({
    required this.filterType,
    required this.resultCount,
  });

  final String filterType; // all, unlocked, locked, in_progress
  final int resultCount;

  @override
  String get eventName => 'achievements_filtered';

  @override
  Map<String, dynamic> get parameters => {
    'filter_type': filterType,
    'result_count': resultCount,
  };
}
```

---

## Settings Events

### Sealed Class Definition

```dart
/// Sealed class for settings-related events.
sealed class SettingsEvent extends AnalyticsEvent {
  const SettingsEvent();

  /// Generic setting changed.
  factory SettingsEvent.changed({
    required String settingKey,
    required String oldValue,
    required String newValue,
  }) = SettingChangedEvent;

  /// Sound effects toggled.
  factory SettingsEvent.soundEffectsToggled({
    required bool enabled,
    required bool previousState,
  }) = SoundEffectsToggledEvent;

  /// Haptic feedback toggled.
  factory SettingsEvent.hapticFeedbackToggled({
    required bool enabled,
    required bool previousState,
  }) = HapticFeedbackToggledEvent;

  /// Theme changed.
  factory SettingsEvent.themeChanged({
    required String newTheme,
    required String previousTheme,
  }) = ThemeChangedEvent;

  /// Answer feedback toggled.
  factory SettingsEvent.answerFeedbackToggled({
    required bool enabled,
    required bool previousState,
  }) = AnswerFeedbackToggledEvent;

  /// Settings reset to defaults.
  factory SettingsEvent.resetConfirmed({
    required List<String> settingsReset,
  }) = SettingsResetEvent;

  /// Privacy policy viewed.
  factory SettingsEvent.privacyPolicyViewed({
    required String source,
  }) = PrivacyPolicyViewedEvent;

  /// Terms of service viewed.
  factory SettingsEvent.termsOfServiceViewed({
    required String source,
  }) = TermsOfServiceViewedEvent;
}
```

### Settings Event Implementations

```dart
final class SettingChangedEvent extends SettingsEvent {
  const SettingChangedEvent({
    required this.settingKey,
    required this.oldValue,
    required this.newValue,
  });

  final String settingKey;
  final String oldValue;
  final String newValue;

  @override
  String get eventName => 'setting_changed';

  @override
  Map<String, dynamic> get parameters => {
    'setting_key': settingKey,
    'old_value': oldValue,
    'new_value': newValue,
  };
}

final class SoundEffectsToggledEvent extends SettingsEvent {
  const SoundEffectsToggledEvent({
    required this.enabled,
    required this.previousState,
  });

  final bool enabled;
  final bool previousState;

  @override
  String get eventName => 'sound_effects_toggled';

  @override
  Map<String, dynamic> get parameters => {
    'enabled': enabled,
    'previous_state': previousState,
  };
}

final class HapticFeedbackToggledEvent extends SettingsEvent {
  const HapticFeedbackToggledEvent({
    required this.enabled,
    required this.previousState,
  });

  final bool enabled;
  final bool previousState;

  @override
  String get eventName => 'haptic_feedback_toggled';

  @override
  Map<String, dynamic> get parameters => {
    'enabled': enabled,
    'previous_state': previousState,
  };
}

final class ThemeChangedEvent extends SettingsEvent {
  const ThemeChangedEvent({
    required this.newTheme,
    required this.previousTheme,
  });

  final String newTheme; // light, dark, system
  final String previousTheme;

  @override
  String get eventName => 'theme_changed';

  @override
  Map<String, dynamic> get parameters => {
    'new_theme': newTheme,
    'previous_theme': previousTheme,
  };
}

final class AnswerFeedbackToggledEvent extends SettingsEvent {
  const AnswerFeedbackToggledEvent({
    required this.enabled,
    required this.previousState,
  });

  final bool enabled;
  final bool previousState;

  @override
  String get eventName => 'answer_feedback_toggled';

  @override
  Map<String, dynamic> get parameters => {
    'enabled': enabled,
    'previous_state': previousState,
  };
}

final class SettingsResetEvent extends SettingsEvent {
  const SettingsResetEvent({required this.settingsReset});

  final List<String> settingsReset;

  @override
  String get eventName => 'settings_reset';

  @override
  Map<String, dynamic> get parameters => {
    'settings_reset': settingsReset.join(','),
    'count': settingsReset.length,
  };
}

final class PrivacyPolicyViewedEvent extends SettingsEvent {
  const PrivacyPolicyViewedEvent({required this.source});

  final String source; // settings, about, other

  @override
  String get eventName => 'privacy_policy_viewed';

  @override
  Map<String, dynamic> get parameters => {
    'source': source,
  };
}

final class TermsOfServiceViewedEvent extends SettingsEvent {
  const TermsOfServiceViewedEvent({required this.source});

  final String source;

  @override
  String get eventName => 'terms_of_service_viewed';

  @override
  Map<String, dynamic> get parameters => {
    'source': source,
  };
}
```

---

## User Interaction Events

### Sealed Class Definition

```dart
/// Sealed class for general user interaction events.
sealed class InteractionEvent extends AnalyticsEvent {
  const InteractionEvent();

  /// Category selected to start quiz.
  factory InteractionEvent.categorySelected({
    required String categoryId,
    required String categoryName,
    required int categoryIndex,
    required int totalCategories,
  }) = CategorySelectedEvent;

  /// Tab selected in home screen.
  factory InteractionEvent.tabSelected({
    required String tabName,
    required int tabIndex,
    String? fromTabName,
  }) = TabSelectedEvent;

  /// Session viewed in history.
  factory InteractionEvent.sessionViewed({
    required String sessionId,
    required String quizName,
    required double scorePercentage,
    required int daysAgo,
  }) = SessionViewedEvent;

  /// Session deleted.
  factory InteractionEvent.sessionDeleted({
    required String sessionId,
    required String quizName,
    required double scorePercentage,
  }) = SessionDeletedEvent;

  /// Exit dialog shown.
  factory InteractionEvent.exitDialogShown({
    required String quizId,
    required int questionNumber,
    required double progressPercentage,
  }) = ExitDialogShownEvent;

  /// Exit dialog confirmed.
  factory InteractionEvent.exitDialogConfirmed({
    required String quizId,
    required double progressPercentage,
  }) = ExitDialogConfirmedEvent;

  /// Exit dialog cancelled.
  factory InteractionEvent.exitDialogCancelled({
    required String quizId,
  }) = ExitDialogCancelledEvent;

  /// Data export initiated.
  factory InteractionEvent.dataExportInitiated({
    required String format,
    required List<String> dataTypes,
  }) = DataExportInitiatedEvent;

  /// Data export completed.
  factory InteractionEvent.dataExportCompleted({
    required String format,
    required int fileSizeBytes,
    String? shareMethod,
  }) = DataExportCompletedEvent;

  /// Pull to refresh.
  factory InteractionEvent.pullToRefresh({
    required String screen,
  }) = PullToRefreshEvent;

  /// View all sessions tapped.
  factory InteractionEvent.viewAllSessions({
    required int visibleCount,
    required int totalCount,
  }) = ViewAllSessionsEvent;

  /// Leaderboard viewed.
  factory InteractionEvent.leaderboardViewed({
    required String leaderboardType,
    required int entryCount,
  }) = LeaderboardViewedEvent;
}
```

### Interaction Event Implementations

```dart
final class CategorySelectedEvent extends InteractionEvent {
  const CategorySelectedEvent({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIndex,
    required this.totalCategories,
  });

  final String categoryId;
  final String categoryName;
  final int categoryIndex;
  final int totalCategories;

  @override
  String get eventName => 'category_selected';

  @override
  Map<String, dynamic> get parameters => {
    'category_id': categoryId,
    'category_name': categoryName,
    'category_index': categoryIndex,
    'total_categories': totalCategories,
  };
}

final class TabSelectedEvent extends InteractionEvent {
  const TabSelectedEvent({
    required this.tabName,
    required this.tabIndex,
    this.fromTabName,
  });

  final String tabName;
  final int tabIndex;
  final String? fromTabName;

  @override
  String get eventName => 'tab_selected';

  @override
  Map<String, dynamic> get parameters => {
    'tab_name': tabName,
    'tab_index': tabIndex,
    if (fromTabName != null) 'from_tab_name': fromTabName,
  };
}

final class SessionViewedEvent extends InteractionEvent {
  const SessionViewedEvent({
    required this.sessionId,
    required this.quizName,
    required this.scorePercentage,
    required this.daysAgo,
  });

  final String sessionId;
  final String quizName;
  final double scorePercentage;
  final int daysAgo;

  @override
  String get eventName => 'session_viewed';

  @override
  Map<String, dynamic> get parameters => {
    'session_id': sessionId,
    'quiz_name': quizName,
    'score_percentage': scorePercentage,
    'days_ago': daysAgo,
  };
}

final class SessionDeletedEvent extends InteractionEvent {
  const SessionDeletedEvent({
    required this.sessionId,
    required this.quizName,
    required this.scorePercentage,
  });

  final String sessionId;
  final String quizName;
  final double scorePercentage;

  @override
  String get eventName => 'session_deleted';

  @override
  Map<String, dynamic> get parameters => {
    'session_id': sessionId,
    'quiz_name': quizName,
    'score_percentage': scorePercentage,
  };
}

final class ExitDialogShownEvent extends InteractionEvent {
  const ExitDialogShownEvent({
    required this.quizId,
    required this.questionNumber,
    required this.progressPercentage,
  });

  final String quizId;
  final int questionNumber;
  final double progressPercentage;

  @override
  String get eventName => 'exit_dialog_shown';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'question_number': questionNumber,
    'progress_percentage': progressPercentage,
  };
}

final class ExitDialogConfirmedEvent extends InteractionEvent {
  const ExitDialogConfirmedEvent({
    required this.quizId,
    required this.progressPercentage,
  });

  final String quizId;
  final double progressPercentage;

  @override
  String get eventName => 'exit_dialog_confirmed';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
    'progress_percentage': progressPercentage,
  };
}

final class ExitDialogCancelledEvent extends InteractionEvent {
  const ExitDialogCancelledEvent({required this.quizId});

  final String quizId;

  @override
  String get eventName => 'exit_dialog_cancelled';

  @override
  Map<String, dynamic> get parameters => {
    'quiz_id': quizId,
  };
}

final class DataExportInitiatedEvent extends InteractionEvent {
  const DataExportInitiatedEvent({
    required this.format,
    required this.dataTypes,
  });

  final String format;
  final List<String> dataTypes;

  @override
  String get eventName => 'data_export_initiated';

  @override
  Map<String, dynamic> get parameters => {
    'format': format,
    'data_types': dataTypes.join(','),
  };
}

final class DataExportCompletedEvent extends InteractionEvent {
  const DataExportCompletedEvent({
    required this.format,
    required this.fileSizeBytes,
    this.shareMethod,
  });

  final String format;
  final int fileSizeBytes;
  final String? shareMethod;

  @override
  String get eventName => 'data_export_completed';

  @override
  Map<String, dynamic> get parameters => {
    'format': format,
    'file_size_bytes': fileSizeBytes,
    if (shareMethod != null) 'share_method': shareMethod,
  };
}

final class PullToRefreshEvent extends InteractionEvent {
  const PullToRefreshEvent({required this.screen});

  final String screen;

  @override
  String get eventName => 'pull_to_refresh';

  @override
  Map<String, dynamic> get parameters => {
    'screen': screen,
  };
}

final class ViewAllSessionsEvent extends InteractionEvent {
  const ViewAllSessionsEvent({
    required this.visibleCount,
    required this.totalCount,
  });

  final int visibleCount;
  final int totalCount;

  @override
  String get eventName => 'view_all_sessions';

  @override
  Map<String, dynamic> get parameters => {
    'visible_count': visibleCount,
    'total_count': totalCount,
  };
}

final class LeaderboardViewedEvent extends InteractionEvent {
  const LeaderboardViewedEvent({
    required this.leaderboardType,
    required this.entryCount,
  });

  final String leaderboardType;
  final int entryCount;

  @override
  String get eventName => 'leaderboard_viewed';

  @override
  Map<String, dynamic> get parameters => {
    'leaderboard_type': leaderboardType,
    'entry_count': entryCount,
  };
}
```

---

## Monetization Events

### Sealed Class Definition

```dart
/// Sealed class for monetization events.
sealed class MonetizationEvent extends AnalyticsEvent {
  const MonetizationEvent();

  /// Purchase sheet opened.
  factory MonetizationEvent.purchaseSheetOpened({
    required String resourceType,
    required String trigger,
    required int currentCount,
  }) = PurchaseSheetOpenedEvent;

  /// Pack selected for purchase.
  factory MonetizationEvent.packSelected({
    required String resourceType,
    required String packId,
    required int packAmount,
    required String price,
  }) = PackSelectedEvent;

  /// Purchase initiated.
  factory MonetizationEvent.purchaseInitiated({
    required String resourceType,
    required String packId,
    required double priceUsd,
    required String store,
  }) = PurchaseInitiatedEvent;

  /// Purchase completed.
  factory MonetizationEvent.purchaseCompleted({
    required String resourceType,
    required String packId,
    required double priceUsd,
    required String transactionId,
    required int resourcesAdded,
  }) = PurchaseCompletedEvent;

  /// Purchase cancelled.
  factory MonetizationEvent.purchaseCancelled({
    required String resourceType,
    required String packId,
    required String stage,
  }) = PurchaseCancelledEvent;

  /// Purchase failed.
  factory MonetizationEvent.purchaseFailed({
    required String resourceType,
    required String packId,
    required String errorCode,
    String? errorMessage,
  }) = PurchaseFailedEvent;

  /// Restore purchases initiated.
  factory MonetizationEvent.restoreInitiated() = RestorePurchasesInitiatedEvent;

  /// Restore purchases completed.
  factory MonetizationEvent.restoreCompleted({
    required int restoredCount,
    required List<String> productIds,
  }) = RestorePurchasesCompletedEvent;

  /// Ad watched for resource.
  factory MonetizationEvent.adWatched({
    required String resourceType,
    required int amountEarned,
    required String adType,
    required String adNetwork,
  }) = AdWatchedEvent;

  /// Ad watch failed.
  factory MonetizationEvent.adFailed({
    required String resourceType,
    required String errorType,
    required String adNetwork,
  }) = AdFailedEvent;
}
```

### Monetization Event Implementations

```dart
final class PurchaseSheetOpenedEvent extends MonetizationEvent {
  const PurchaseSheetOpenedEvent({
    required this.resourceType,
    required this.trigger,
    required this.currentCount,
  });

  final String resourceType;
  final String trigger; // depleted, manual
  final int currentCount;

  @override
  String get eventName => 'purchase_sheet_opened';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'trigger': trigger,
    'current_count': currentCount,
  };
}

final class PackSelectedEvent extends MonetizationEvent {
  const PackSelectedEvent({
    required this.resourceType,
    required this.packId,
    required this.packAmount,
    required this.price,
  });

  final String resourceType;
  final String packId;
  final int packAmount;
  final String price;

  @override
  String get eventName => 'pack_selected';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'pack_id': packId,
    'pack_amount': packAmount,
    'price': price,
  };
}

final class PurchaseInitiatedEvent extends MonetizationEvent {
  const PurchaseInitiatedEvent({
    required this.resourceType,
    required this.packId,
    required this.priceUsd,
    required this.store,
  });

  final String resourceType;
  final String packId;
  final double priceUsd;
  final String store;

  @override
  String get eventName => 'purchase_initiated';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'pack_id': packId,
    'price_usd': priceUsd,
    'store': store,
  };
}

final class PurchaseCompletedEvent extends MonetizationEvent {
  const PurchaseCompletedEvent({
    required this.resourceType,
    required this.packId,
    required this.priceUsd,
    required this.transactionId,
    required this.resourcesAdded,
  });

  final String resourceType;
  final String packId;
  final double priceUsd;
  final String transactionId;
  final int resourcesAdded;

  @override
  String get eventName => 'purchase_completed';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'pack_id': packId,
    'price_usd': priceUsd,
    'transaction_id': transactionId,
    'resources_added': resourcesAdded,
  };
}

final class PurchaseCancelledEvent extends MonetizationEvent {
  const PurchaseCancelledEvent({
    required this.resourceType,
    required this.packId,
    required this.stage,
  });

  final String resourceType;
  final String packId;
  final String stage;

  @override
  String get eventName => 'purchase_cancelled';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'pack_id': packId,
    'stage': stage,
  };
}

final class PurchaseFailedEvent extends MonetizationEvent {
  const PurchaseFailedEvent({
    required this.resourceType,
    required this.packId,
    required this.errorCode,
    this.errorMessage,
  });

  final String resourceType;
  final String packId;
  final String errorCode;
  final String? errorMessage;

  @override
  String get eventName => 'purchase_failed';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'pack_id': packId,
    'error_code': errorCode,
    if (errorMessage != null) 'error_message': errorMessage,
  };
}

final class RestorePurchasesInitiatedEvent extends MonetizationEvent {
  const RestorePurchasesInitiatedEvent();

  @override
  String get eventName => 'restore_purchases_initiated';

  @override
  Map<String, dynamic> get parameters => {};
}

final class RestorePurchasesCompletedEvent extends MonetizationEvent {
  const RestorePurchasesCompletedEvent({
    required this.restoredCount,
    required this.productIds,
  });

  final int restoredCount;
  final List<String> productIds;

  @override
  String get eventName => 'restore_purchases_completed';

  @override
  Map<String, dynamic> get parameters => {
    'restored_count': restoredCount,
    'product_ids': productIds.join(','),
  };
}

final class AdWatchedEvent extends MonetizationEvent {
  const AdWatchedEvent({
    required this.resourceType,
    required this.amountEarned,
    required this.adType,
    required this.adNetwork,
  });

  final String resourceType;
  final int amountEarned;
  final String adType; // rewarded, interstitial
  final String adNetwork;

  @override
  String get eventName => 'ad_watched';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'amount_earned': amountEarned,
    'ad_type': adType,
    'ad_network': adNetwork,
  };
}

final class AdFailedEvent extends MonetizationEvent {
  const AdFailedEvent({
    required this.resourceType,
    required this.errorType,
    required this.adNetwork,
  });

  final String resourceType;
  final String errorType; // load_failed, incomplete, etc
  final String adNetwork;

  @override
  String get eventName => 'ad_failed';

  @override
  Map<String, dynamic> get parameters => {
    'resource_type': resourceType,
    'error_type': errorType,
    'ad_network': adNetwork,
  };
}
```

---

## Error Events

### Sealed Class Definition

```dart
/// Sealed class for error events.
sealed class ErrorEvent extends AnalyticsEvent {
  const ErrorEvent();

  /// Data load failed.
  factory ErrorEvent.dataLoadFailed({
    required String dataType,
    required String errorType,
    String? errorMessage,
    required int retryCount,
  }) = DataLoadFailedEvent;

  /// Data save failed.
  factory ErrorEvent.saveFailed({
    required String dataType,
    required String errorType,
    String? errorMessage,
  }) = SaveFailedEvent;

  /// Retry button tapped.
  factory ErrorEvent.retryTapped({
    required String errorContext,
    required int retryCount,
  }) = RetryTappedEvent;

  /// App crash.
  factory ErrorEvent.appCrash({
    required String errorType,
    required String errorMessage,
    required String stackTraceHash,
    String? screen,
  }) = AppCrashEvent;

  /// Feature failure (handled).
  factory ErrorEvent.featureFailure({
    required String feature,
    required String errorType,
    String? errorMessage,
    String? userAction,
  }) = FeatureFailureEvent;

  /// Network error.
  factory ErrorEvent.network({
    required String errorType,
    String? endpoint,
    int? statusCode,
  }) = NetworkErrorEvent;
}
```

### Error Event Implementations

```dart
final class DataLoadFailedEvent extends ErrorEvent {
  const DataLoadFailedEvent({
    required this.dataType,
    required this.errorType,
    this.errorMessage,
    required this.retryCount,
  });

  final String dataType;
  final String errorType;
  final String? errorMessage;
  final int retryCount;

  @override
  String get eventName => 'data_load_failed';

  @override
  Map<String, dynamic> get parameters => {
    'data_type': dataType,
    'error_type': errorType,
    if (errorMessage != null) 'error_message': errorMessage,
    'retry_count': retryCount,
  };
}

final class SaveFailedEvent extends ErrorEvent {
  const SaveFailedEvent({
    required this.dataType,
    required this.errorType,
    this.errorMessage,
  });

  final String dataType;
  final String errorType;
  final String? errorMessage;

  @override
  String get eventName => 'save_failed';

  @override
  Map<String, dynamic> get parameters => {
    'data_type': dataType,
    'error_type': errorType,
    if (errorMessage != null) 'error_message': errorMessage,
  };
}

final class RetryTappedEvent extends ErrorEvent {
  const RetryTappedEvent({
    required this.errorContext,
    required this.retryCount,
  });

  final String errorContext;
  final int retryCount;

  @override
  String get eventName => 'retry_tapped';

  @override
  Map<String, dynamic> get parameters => {
    'error_context': errorContext,
    'retry_count': retryCount,
  };
}

final class AppCrashEvent extends ErrorEvent {
  const AppCrashEvent({
    required this.errorType,
    required this.errorMessage,
    required this.stackTraceHash,
    this.screen,
  });

  final String errorType;
  final String errorMessage;
  final String stackTraceHash;
  final String? screen;

  @override
  String get eventName => 'app_crash';

  @override
  Map<String, dynamic> get parameters => {
    'error_type': errorType,
    'error_message': errorMessage,
    'stack_trace_hash': stackTraceHash,
    if (screen != null) 'screen': screen,
  };
}

final class FeatureFailureEvent extends ErrorEvent {
  const FeatureFailureEvent({
    required this.feature,
    required this.errorType,
    this.errorMessage,
    this.userAction,
  });

  final String feature;
  final String errorType;
  final String? errorMessage;
  final String? userAction;

  @override
  String get eventName => 'feature_failure';

  @override
  Map<String, dynamic> get parameters => {
    'feature': feature,
    'error_type': errorType,
    if (errorMessage != null) 'error_message': errorMessage,
    if (userAction != null) 'user_action': userAction,
  };
}

final class NetworkErrorEvent extends ErrorEvent {
  const NetworkErrorEvent({
    required this.errorType,
    this.endpoint,
    this.statusCode,
  });

  final String errorType;
  final String? endpoint;
  final int? statusCode;

  @override
  String get eventName => 'network_error';

  @override
  Map<String, dynamic> get parameters => {
    'error_type': errorType,
    if (endpoint != null) 'endpoint': endpoint,
    if (statusCode != null) 'status_code': statusCode,
  };
}
```

---

## Performance Events

### Sealed Class Definition

```dart
/// Sealed class for performance events.
sealed class PerformanceEvent extends AnalyticsEvent {
  const PerformanceEvent();

  /// App launch.
  factory PerformanceEvent.appLaunch({
    required String launchType,
    required int startupTimeMs,
    required String appVersion,
    required String osVersion,
    required String deviceModel,
  }) = AppLaunchEvent;

  /// App session start.
  factory PerformanceEvent.sessionStart({
    required String sessionId,
    int? timeSinceLastSessionSeconds,
  }) = AppSessionStartEvent;

  /// App session end.
  factory PerformanceEvent.sessionEnd({
    required String sessionId,
    required int sessionDurationSeconds,
    required int quizzesPlayed,
    required int screensViewed,
  }) = AppSessionEndEvent;

  /// Screen render time.
  factory PerformanceEvent.screenRender({
    required String screenName,
    required int renderTimeMs,
    int? dataLoadTimeMs,
  }) = ScreenRenderEvent;

  /// Database query time.
  factory PerformanceEvent.databaseQuery({
    required String queryType,
    required String tableName,
    required int durationMs,
    int? rowCount,
  }) = DatabaseQueryEvent;
}
```

### Performance Event Implementations

```dart
final class AppLaunchEvent extends PerformanceEvent {
  const AppLaunchEvent({
    required this.launchType,
    required this.startupTimeMs,
    required this.appVersion,
    required this.osVersion,
    required this.deviceModel,
  });

  final String launchType; // cold, warm, hot
  final int startupTimeMs;
  final String appVersion;
  final String osVersion;
  final String deviceModel;

  @override
  String get eventName => 'app_launch';

  @override
  Map<String, dynamic> get parameters => {
    'launch_type': launchType,
    'startup_time_ms': startupTimeMs,
    'app_version': appVersion,
    'os_version': osVersion,
    'device_model': deviceModel,
  };
}

final class AppSessionStartEvent extends PerformanceEvent {
  const AppSessionStartEvent({
    required this.sessionId,
    this.timeSinceLastSessionSeconds,
  });

  final String sessionId;
  final int? timeSinceLastSessionSeconds;

  @override
  String get eventName => 'app_session_start';

  @override
  Map<String, dynamic> get parameters => {
    'session_id': sessionId,
    if (timeSinceLastSessionSeconds != null)
      'time_since_last_session_seconds': timeSinceLastSessionSeconds,
  };
}

final class AppSessionEndEvent extends PerformanceEvent {
  const AppSessionEndEvent({
    required this.sessionId,
    required this.sessionDurationSeconds,
    required this.quizzesPlayed,
    required this.screensViewed,
  });

  final String sessionId;
  final int sessionDurationSeconds;
  final int quizzesPlayed;
  final int screensViewed;

  @override
  String get eventName => 'app_session_end';

  @override
  Map<String, dynamic> get parameters => {
    'session_id': sessionId,
    'session_duration_seconds': sessionDurationSeconds,
    'quizzes_played': quizzesPlayed,
    'screens_viewed': screensViewed,
  };
}

final class ScreenRenderEvent extends PerformanceEvent {
  const ScreenRenderEvent({
    required this.screenName,
    required this.renderTimeMs,
    this.dataLoadTimeMs,
  });

  final String screenName;
  final int renderTimeMs;
  final int? dataLoadTimeMs;

  @override
  String get eventName => 'screen_render';

  @override
  Map<String, dynamic> get parameters => {
    'screen_name': screenName,
    'render_time_ms': renderTimeMs,
    if (dataLoadTimeMs != null) 'data_load_time_ms': dataLoadTimeMs,
  };
}

final class DatabaseQueryEvent extends PerformanceEvent {
  const DatabaseQueryEvent({
    required this.queryType,
    required this.tableName,
    required this.durationMs,
    this.rowCount,
  });

  final String queryType; // select, insert, update, delete
  final String tableName;
  final int durationMs;
  final int? rowCount;

  @override
  String get eventName => 'database_query';

  @override
  Map<String, dynamic> get parameters => {
    'query_type': queryType,
    'table_name': tableName,
    'duration_ms': durationMs,
    if (rowCount != null) 'row_count': rowCount,
  };
}
```

---

## User Properties

User properties are set once and persist across sessions.

| Property | Type | Description | Data Source |
|----------|------|-------------|-------------|
| `user_id` | String | Anonymous user ID | Generated UUID |
| `app_version` | String | Current app version | Package info |
| `first_open_date` | String | First app open | Stored preference |
| `total_sessions` | int | Total quiz sessions | GlobalStatistics |
| `total_quizzes_completed` | int | Completed quizzes | GlobalStatistics |
| `average_score` | double | Overall average | GlobalStatistics |
| `best_score` | double | Best score ever | GlobalStatistics |
| `current_streak` | int | Current streak | GlobalStatistics |
| `best_streak` | int | Best streak ever | GlobalStatistics |
| `total_time_played_minutes` | int | Total play time | GlobalStatistics |
| `achievements_unlocked` | int | Unlocked count | GlobalStatistics |
| `theme_preference` | String | Light/dark/system | QuizSettings |
| `sounds_enabled` | bool | Sound setting | QuizSettings |
| `haptics_enabled` | bool | Haptics setting | QuizSettings |
| `is_premium` | bool | Has made purchase | IAP status |
| `preferred_mode` | String | Most played mode | Calculated |
| `preferred_category` | String | Most played category | Calculated |
| `device_type` | String | Phone/tablet | Device info |
| `device_language` | String | Device language | System locale |

---

## Data Availability Matrix

| Data Category | Source | Available | Notes |
|---------------|--------|-----------|-------|
| Quiz Configuration | `QuizConfig` | ✅ | All config data |
| Quiz Results | `QuizSession` | ✅ | Complete session data |
| Question Details | `QuestionAnswer` | ✅ | All Q&A data |
| Global Statistics | `GlobalStatistics` | ✅ | Aggregate stats |
| Daily Statistics | `DailyStatistics` | ✅ | Pre-aggregated |
| Category Statistics | `QuizTypeStatistics` | ✅ | Per-category stats |
| User Settings | `QuizSettings` | ✅ | All preferences |
| Achievements | `Achievement` models | ✅ | Full achievement data |
| Resources | `ResourceManager` | ✅ | Lives, hints, skips |
| App Lifecycle | Flutter lifecycle | ✅ | Standard Flutter |
| Device Info | Platform channels | ✅ | device_info_plus |
| Network Status | Connectivity | ✅ | connectivity_plus |
| Performance | Custom instrumentation | ⚠️ | Needs setup |
| Background Time | Custom tracking | ⚠️ | Add to QuizLifecycleHandler |

### Missing Data (To Add)

1. **Background Duration Tracking**
   - Add `_backgroundStartTime` to `QuizLifecycleHandler`
   - Calculate duration on resume

2. **Screen Render Time**
   - Add `Stopwatch` in screen `initState`
   - Stop on first frame callback

3. **Database Query Timing**
   - Add optional timing wrapper in data sources
   - Use `Stopwatch` for query duration

---

## Implementation Checklist

### Phase 1: Core Infrastructure
- [ ] Create `AnalyticsService` abstract class
- [ ] Create `AnalyticsEvent` sealed class hierarchy
- [ ] Create `ScreenViewEvent` sealed class with all screens
- [ ] Create `ConsoleAnalyticsService` implementation
- [ ] Create `NoOpAnalyticsService` implementation
- [ ] Add analytics to service locator

### Phase 2: Event Classes
- [ ] Create `QuizEvent` sealed class
- [ ] Create `QuestionEvent` sealed class
- [ ] Create `HintEvent` sealed class
- [ ] Create `ResourceEvent` sealed class
- [ ] Create `InteractionEvent` sealed class
- [ ] Create `AchievementEvent` sealed class
- [ ] Create `SettingsEvent` sealed class
- [ ] Create `MonetizationEvent` sealed class
- [ ] Create `ErrorEvent` sealed class
- [ ] Create `PerformanceEvent` sealed class

### Phase 3: Firebase Implementation
- [ ] Add Firebase Analytics dependency
- [ ] Create `FirebaseAnalyticsService` implementation
- [ ] Map custom events to Firebase format
- [ ] Implement user properties
- [ ] Add Firebase debug view support

### Phase 4: Integration
- [ ] Create `AnalyticsObserver` for navigation
- [ ] Integrate with `QuizBloc`
- [ ] Integrate with `QuizScreen`
- [ ] Integrate with `AchievementEngine`
- [ ] Integrate with `SettingsService`
- [ ] Integrate with `ResourceManager`

### Phase 5: Testing
- [ ] Unit tests for all event classes
- [ ] Unit tests for all services
- [ ] Integration tests for event firing
- [ ] Verify Firebase debug view

### Phase 6: Documentation
- [ ] Update CLAUDE.md with analytics patterns
- [ ] Create analytics usage guide
- [ ] Document event schema for data team

---

## Example Usage

### Tracking Screen Views

```dart
// Using factory constructors
final event = ScreenViewEvent.quiz(
  quizId: 'europe_flags',
  quizName: 'European Flags',
  mode: 'timed',
  totalQuestions: 20,
);
analyticsService.logEvent(event);

// Or directly
analyticsService.logEvent(QuizScreenView(
  quizId: 'europe_flags',
  quizName: 'European Flags',
  mode: 'timed',
  totalQuestions: 20,
));
```

### Tracking Quiz Events

```dart
// Quiz started
analyticsService.logEvent(QuizEvent.started(
  quizId: session.quizId,
  quizName: session.quizName,
  quizType: 'flags',
  totalQuestions: 20,
  mode: 'timed',
  timeLimitSeconds: 60,
));

// Quiz completed
analyticsService.logEvent(QuizEvent.completed(
  quizId: session.quizId,
  quizName: session.quizName,
  quizType: session.quizType,
  totalQuestions: session.totalQuestions,
  totalAnswered: session.totalAnswered,
  totalCorrect: session.totalCorrect,
  totalIncorrect: session.totalFailed,
  totalSkipped: session.totalSkipped,
  scorePercentage: session.scorePercentage,
  scorePoints: session.score,
  durationSeconds: session.durationSeconds ?? 0,
  mode: session.mode.value,
  completionStatus: session.completionStatus.value,
  isPerfectScore: session.isPerfectScore,
  bestStreak: session.bestStreak,
  hints5050Used: session.hintsUsed5050,
  hintsSkipUsed: session.hintsUsedSkip,
  livesUsed: session.livesUsed,
));
```

### Pattern Matching for Event Handling

```dart
// In ConsoleAnalyticsService
void logEvent(AnalyticsEvent event) {
  switch (event) {
    case ScreenViewEvent screenEvent:
      _logScreenView(screenEvent);
    case QuizEvent quizEvent:
      _logQuizEvent(quizEvent);
    case QuestionEvent questionEvent:
      _logQuestionEvent(questionEvent);
    case HintEvent hintEvent:
      _logHintEvent(hintEvent);
    case ResourceEvent resourceEvent:
      _logResourceEvent(resourceEvent);
    case AchievementEvent achievementEvent:
      _logAchievementEvent(achievementEvent);
    case SettingsEvent settingsEvent:
      _logSettingsEvent(settingsEvent);
    case MonetizationEvent monetizationEvent:
      _logMonetizationEvent(monetizationEvent);
    case ErrorEvent errorEvent:
      _logErrorEvent(errorEvent);
    case PerformanceEvent performanceEvent:
      _logPerformanceEvent(performanceEvent);
    case InteractionEvent interactionEvent:
      _logInteractionEvent(interactionEvent);
  }
}
```

---

**Document Version:** 1.0
**Total Events:** 87
**Sealed Classes:** 11 (1 base + 10 categories)
**Data Availability:** 95%+ (minor additions needed for performance timing)