# Quiz Engine Core Architecture Guide

**Purpose:** This document defines how to implement all quiz features at the core package level (quiz_engine_core, quiz_engine, shared_services) to maximize reusability across multiple quiz apps.

**Last Updated:** 2025-12-22

---

## Table of Contents

1. [Architecture Principles](#architecture-principles)
2. [Package Responsibilities](#package-responsibilities)
3. [Core Features Implementation](#core-features-implementation)
4. [Configuration System](#configuration-system)
5. [App-Specific vs Core Code](#app-specific-vs-core-code)
6. [Implementation Roadmap](#implementation-roadmap)

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

**Location:** `quiz_engine_core` + `quiz_engine`

#### Core (quiz_engine_core)

```dart
// lib/src/business_logic/quiz_state/quiz_state.dart

// Add new state for answer feedback
sealed class QuizState {
  const QuizState();
}

class LoadingState extends QuizState {
  const LoadingState();
}

class QuestionState extends QuizState {
  final Question question;
  final int currentProgress;
  final int totalQuestions;

  const QuestionState({
    required this.question,
    required this.currentProgress,
    required this.totalQuestions,
  });

  double get percentageProgress => currentProgress / totalQuestions;
}

// NEW: State for showing answer feedback
class AnswerFeedbackState extends QuizState {
  final Question question;
  final QuestionEntry selectedAnswer;
  final bool isCorrect;
  final int currentProgress;
  final int totalQuestions;

  const AnswerFeedbackState({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.currentProgress,
    required this.totalQuestions,
  });
}

class QuizCompletedState extends QuizState {
  final QuizResults results;

  const QuizCompletedState({required this.results});
}
```

```dart
// lib/src/model/quiz_config.dart

class QuizConfig {
  /// Show visual feedback after answering
  final bool showAnswerFeedback;

  /// Delay after answer before moving to next question (milliseconds)
  final int answerFeedbackDuration;

  /// Play sound on answer
  final bool playSounds;

  /// Haptic feedback on answer
  final bool hapticFeedback;

  const QuizConfig({
    this.showAnswerFeedback = true,
    this.answerFeedbackDuration = 1500,
    this.playSounds = true,
    this.hapticFeedback = true,
  });
}
```

```dart
// lib/src/business_logic/quiz_bloc.dart

class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  final QuizConfig config;

  QuizBloc({
    required this.config,
    required this.dataProvider,
    // ... other params
  });

  Future<void> processAnswer(QuestionEntry selectedEntry) async {
    final currentState = _currentState;
    if (currentState is! QuestionState) return;

    final answer = Answer(
      question: currentState.question,
      selectedOption: selectedEntry,
    );

    _answers.add(answer);

    // NEW: Show feedback before moving to next question
    if (config.showAnswerFeedback) {
      dispatchState(AnswerFeedbackState(
        question: currentState.question,
        selectedAnswer: selectedEntry,
        isCorrect: answer.isCorrect,
        currentProgress: currentState.currentProgress,
        totalQuestions: currentState.totalQuestions,
      ));

      // Wait for feedback duration
      await Future.delayed(
        Duration(milliseconds: config.answerFeedbackDuration)
      );
    }

    // Pick next question or complete quiz
    await _pickQuestion();
  }
}
```

#### UI (quiz_engine)

```dart
// lib/src/quiz/quiz_screen.dart

class QuizScreen extends StatefulWidget {
  final QuizConfig config;
  final QuizThemeData? themeData;

  // ... existing code
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuizState>(
      stream: quizBloc.stream,
      builder: (context, snapshot) {
        final state = snapshot.data;

        return switch (state) {
          LoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),

          QuestionState(:final question) => QuizLayout(
            question: question,
            onAnswer: quizBloc.processAnswer,
            themeData: widget.themeData,
          ),

          // NEW: Show feedback overlay
          AnswerFeedbackState(
            :final question,
            :final selectedAnswer,
            :final isCorrect,
          ) => AnswerFeedbackWidget(
            question: question,
            selectedAnswer: selectedAnswer,
            isCorrect: isCorrect,
            config: widget.config,
            themeData: widget.themeData,
          ),

          QuizCompletedState(:final results) => QuizResultsScreen(
            results: results,
            themeData: widget.themeData,
          ),

          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
```

```dart
// lib/src/quiz/answer_feedback_widget.dart

class AnswerFeedbackWidget extends StatefulWidget {
  final Question question;
  final QuestionEntry selectedAnswer;
  final bool isCorrect;
  final QuizConfig config;
  final QuizThemeData? themeData;

  // ... implementation
}

class _AnswerFeedbackWidgetState extends State<AnswerFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Play sound if enabled
    if (widget.config.playSounds) {
      _playSound(widget.isCorrect);
    }

    // Haptic feedback if enabled
    if (widget.config.hapticFeedback) {
      _performHaptic(widget.isCorrect);
    }

    // Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  void _playSound(bool isCorrect) {
    final audioService = AudioService.instance;
    audioService.play(
      isCorrect ? SoundEffect.correct : SoundEffect.incorrect
    );
  }

  void _performHaptic(bool isCorrect) {
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Show question with highlighted answers
        QuizLayout(
          question: widget.question,
          selectedAnswer: widget.selectedAnswer,
          highlightCorrect: !widget.isCorrect,
          highlightIncorrect: !widget.isCorrect,
          themeData: widget.themeData,
        ),

        // Feedback overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _controller.value,
                child: Center(
                  child: FeedbackIcon(
                    isCorrect: widget.isCorrect,
                    themeData: widget.themeData,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

### 2. Quiz Modes System

**Location:** `quiz_engine_core`

```dart
// lib/src/model/quiz_mode.dart

/// Defines different quiz game modes
enum QuizMode {
  /// Standard mode - answer all questions, no time limit, no lives
  standard,

  /// Timed mode - answer questions within time limit
  timed,

  /// Lives mode - lose lives on wrong answers, game over at 0
  lives,

  /// Endless mode - keep answering until wrong answer
  endless,

  /// Survival mode - timed + lives combined
  survival,
}

/// Configuration for quiz mode behavior
class QuizModeConfig {
  final QuizMode mode;

  /// Time limit per question in seconds (for timed/survival modes)
  final int? timePerQuestion;

  /// Total time limit for entire quiz in seconds (for timed/survival modes)
  final int? totalTimeLimit;

  /// Number of lives (for lives/survival modes)
  final int? lives;

  /// Allow skipping questions
  final bool allowSkip;

  /// Infinite questions (for endless mode)
  final bool infinite;

  const QuizModeConfig.standard()
      : mode = QuizMode.standard,
        timePerQuestion = null,
        totalTimeLimit = null,
        lives = null,
        allowSkip = false,
        infinite = false;

  const QuizModeConfig.timed({
    this.timePerQuestion = 30,
    this.totalTimeLimit,
    this.allowSkip = false,
  })  : mode = QuizMode.timed,
        lives = null,
        infinite = false;

  const QuizModeConfig.lives({
    this.lives = 3,
    this.allowSkip = false,
  })  : mode = QuizMode.lives,
        timePerQuestion = null,
        totalTimeLimit = null,
        infinite = false;

  const QuizModeConfig.endless()
      : mode = QuizMode.endless,
        timePerQuestion = null,
        totalTimeLimit = null,
        lives = 1, // One mistake ends the game
        allowSkip = false,
        infinite = true;

  const QuizModeConfig.survival({
    this.lives = 3,
    this.timePerQuestion = 30,
    this.totalTimeLimit,
  })  : mode = QuizMode.survival,
        allowSkip = false,
        infinite = false;
}
```

```dart
// lib/src/business_logic/quiz_state/quiz_state.dart

// Enhanced QuestionState to support modes
class QuestionState extends QuizState {
  final Question question;
  final int currentProgress;
  final int totalQuestions;

  // NEW: Mode-specific state
  final int? remainingLives;
  final int? remainingTime; // seconds
  final int? questionTimeLimit; // seconds

  const QuestionState({
    required this.question,
    required this.currentProgress,
    required this.totalQuestions,
    this.remainingLives,
    this.remainingTime,
    this.questionTimeLimit,
  });

  double get percentageProgress => currentProgress / totalQuestions;

  // Helpers for UI
  bool get hasLives => remainingLives != null;
  bool get hasTotalTimer => remainingTime != null;
  bool get hasQuestionTimer => questionTimeLimit != null;
}
```

```dart
// lib/src/business_logic/quiz_bloc.dart

class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  final QuizModeConfig modeConfig;

  int _remainingLives;
  Timer? _questionTimer;
  Timer? _totalTimer;
  int? _questionTimeRemaining;
  int? _totalTimeRemaining;

  QuizBloc({
    required this.modeConfig,
    // ... other params
  }) : _remainingLives = modeConfig.lives ?? 0 {
    // Start total timer if configured
    if (modeConfig.totalTimeLimit != null) {
      _totalTimeRemaining = modeConfig.totalTimeLimit;
      _startTotalTimer();
    }
  }

  void _startQuestionTimer() {
    if (modeConfig.timePerQuestion == null) return;

    _questionTimeRemaining = modeConfig.timePerQuestion;
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _questionTimeRemaining = _questionTimeRemaining! - 1;

        // Update UI with new time
        _emitCurrentQuestionWithUpdatedTime();

        if (_questionTimeRemaining! <= 0) {
          timer.cancel();
          _handleTimeExpired();
        }
      },
    );
  }

  void _handleTimeExpired() {
    // Treat as wrong answer
    if (modeConfig.mode == QuizMode.lives ||
        modeConfig.mode == QuizMode.survival) {
      _loseLife();
    }
    _pickQuestion();
  }

  void _loseLife() {
    _remainingLives--;

    if (_remainingLives <= 0) {
      _gameOver(reason: GameOverReason.noLivesRemaining);
    }
  }

  Future<void> processAnswer(QuestionEntry selectedEntry) async {
    // Stop question timer
    _questionTimer?.cancel();

    final currentState = _currentState;
    if (currentState is! QuestionState) return;

    final answer = Answer(
      question: currentState.question,
      selectedOption: selectedEntry,
    );

    _answers.add(answer);

    // Handle lives mode
    if (!answer.isCorrect &&
        (modeConfig.mode == QuizMode.lives ||
         modeConfig.mode == QuizMode.survival ||
         modeConfig.mode == QuizMode.endless)) {
      _loseLife();
      if (_remainingLives <= 0) return; // Game over already called
    }

    // Show feedback...
    // Then pick next question
    await _pickQuestion();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _totalTimer?.cancel();
    super.dispose();
  }
}
```

---

### 3. Hints System

**Location:** `quiz_engine_core` + `quiz_engine`

```dart
// lib/src/model/hint_system.dart

enum HintType {
  fiftyFifty,     // Remove 2 wrong answers
  skip,           // Skip question without penalty
  revealLetter,   // Show first letter of answer
  extraTime,      // Add 15 seconds (timed mode only)
}

class HintConfig {
  /// Starting hints per type
  final Map<HintType, int> initialHints;

  /// Can earn hints through achievements
  final bool canEarnHints;

  /// Watch ad to get hint (requires monetization)
  final bool allowAdForHint;

  const HintConfig({
    this.initialHints = const {
      HintType.fiftyFifty: 3,
      HintType.skip: 2,
      HintType.revealLetter: 3,
      HintType.extraTime: 2,
    },
    this.canEarnHints = true,
    this.allowAdForHint = false,
  });

  const HintConfig.noHints()
      : initialHints = const {},
        canEarnHints = false,
        allowAdForHint = false;
}

class HintState {
  final Map<HintType, int> remainingHints;

  HintState(this.remainingHints);

  HintState.fromConfig(HintConfig config)
      : remainingHints = Map.from(config.initialHints);

  bool canUseHint(HintType type) {
    return (remainingHints[type] ?? 0) > 0;
  }

  void useHint(HintType type) {
    if (!canUseHint(type)) {
      throw StateError('No hints remaining for $type');
    }
    remainingHints[type] = remainingHints[type]! - 1;
  }

  void addHint(HintType type, int count) {
    remainingHints[type] = (remainingHints[type] ?? 0) + count;
  }
}
```

```dart
// lib/src/business_logic/quiz_bloc.dart

class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  final HintConfig hintConfig;
  late final HintState _hintState;

  QuizBloc({
    required this.hintConfig,
    // ... other params
  }) : _hintState = HintState.fromConfig(hintConfig);

  // Expose current hint state
  HintState get hintState => _hintState;

  Future<void> useFiftyFifty() async {
    final currentState = _currentState;
    if (currentState is! QuestionState) return;

    _hintState.useHint(HintType.fiftyFifty);

    // Remove 2 wrong options from current question
    final modifiedQuestion = _applyFiftyFifty(currentState.question);

    // Re-emit state with modified question
    dispatchState(QuestionState(
      question: modifiedQuestion,
      currentProgress: currentState.currentProgress,
      totalQuestions: currentState.totalQuestions,
      remainingLives: currentState.remainingLives,
      remainingTime: currentState.remainingTime,
      questionTimeLimit: currentState.questionTimeLimit,
    ));
  }

  Question _applyFiftyFifty(Question question) {
    // Keep correct answer + 1 random wrong answer
    final correctAnswer = question.answer;
    final wrongOptions = question.options
        .where((opt) => opt != correctAnswer)
        .toList()
      ..shuffle();

    return Question(
      answer: correctAnswer,
      options: [correctAnswer, wrongOptions.first]..shuffle(),
    );
  }

  Future<void> skipQuestion() async {
    _hintState.useHint(HintType.skip);

    // Don't record answer, just move to next
    await _pickQuestion();
  }

  // etc...
}
```

---

### 4. Statistics & Progress Tracking

**Location:** `quiz_engine_core` + repository in app layer

```dart
// lib/src/model/quiz_results.dart

class QuizResults {
  final String quizId; // e.g., "flags_europe", "capitals_asia"
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int skippedQuestions;
  final Duration timeTaken;
  final int score; // Calculated by ScoringStrategy
  final QuizMode mode;
  final List<WrongAnswer> wrongAnswers;

  QuizResults({
    required this.quizId,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.skippedQuestions,
    required this.timeTaken,
    required this.score,
    required this.mode,
    required this.wrongAnswers,
  });

  double get accuracyPercentage =>
      (correctAnswers / totalQuestions) * 100;

  bool get isPerfectScore => correctAnswers == totalQuestions;

  int get starRating {
    if (accuracyPercentage >= 90) return 3;
    if (accuracyPercentage >= 70) return 2;
    return 1;
  }
}

class WrongAnswer {
  final QuestionEntry question;
  final QuestionEntry selectedAnswer;
  final QuestionEntry correctAnswer;

  const WrongAnswer({
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
  });
}
```

```dart
// lib/src/repository/statistics_repository.dart

/// Abstract repository for persisting statistics
/// Apps implement this using their preferred storage (Hive, SQLite, etc.)
abstract class StatisticsRepository {
  /// Save quiz results
  Future<void> saveResults(QuizResults results);

  /// Get all results for a specific quiz
  Future<List<QuizResults>> getResultsForQuiz(String quizId);

  /// Get best score for a quiz
  Future<QuizResults?> getBestScore(String quizId);

  /// Get overall statistics
  Future<OverallStatistics> getOverallStatistics();

  /// Get statistics for a specific quiz
  Future<QuizStatistics> getQuizStatistics(String quizId);
}

class OverallStatistics {
  final int totalQuizzesCompleted;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final Duration totalTimePlayed;
  final int currentStreak; // Days played consecutively
  final int longestStreak;
  final DateTime? lastPlayedDate;

  double get overallAccuracy =>
      totalQuestionsAnswered > 0
          ? (totalCorrectAnswers / totalQuestionsAnswered) * 100
          : 0;
}

class QuizStatistics {
  final String quizId;
  final int timesPlayed;
  final double averageAccuracy;
  final int bestScore;
  final int perfectScores;
  final Duration averageTime;
  final DateTime? lastPlayed;
  final List<WrongAnswer> frequentMistakes; // Top 10 most missed
}
```

```dart
// lib/src/business_logic/quiz_bloc.dart

class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  final String quizId;
  final StatisticsRepository? statisticsRepository;

  Future<void> _completeQuiz() async {
    _questionTimer?.cancel();
    _totalTimer?.cancel();

    final results = QuizResults(
      quizId: quizId,
      completedAt: DateTime.now(),
      totalQuestions: _answers.length,
      correctAnswers: _answers.where((a) => a.isCorrect).length,
      skippedQuestions: _skippedCount,
      timeTaken: _stopwatch.elapsed,
      score: _calculateScore(),
      mode: modeConfig.mode,
      wrongAnswers: _getWrongAnswers(),
    );

    // Save to repository if provided
    await statisticsRepository?.saveResults(results);

    dispatchState(QuizCompletedState(results: results));
  }
}
```

---

### 5. Achievements System

**Location:** `quiz_engine_core` + `quiz_engine` (UI)

```dart
// lib/src/model/achievement.dart

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementTrigger trigger;
  final AchievementReward? reward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.trigger,
    this.reward,
  });
}

/// Defines when an achievement unlocks
sealed class AchievementTrigger {
  const AchievementTrigger();
}

class PerfectScoreTrigger extends AchievementTrigger {
  final String? quizId; // null = any quiz
  const PerfectScoreTrigger({this.quizId});
}

class ScoreThresholdTrigger extends AchievementTrigger {
  final String quizId;
  final int minimumScore;
  const ScoreThresholdTrigger({
    required this.quizId,
    required this.minimumScore,
  });
}

class QuizCountTrigger extends AchievementTrigger {
  final int count;
  const QuizCountTrigger({required this.count});
}

class StreakTrigger extends AchievementTrigger {
  final int days;
  const StreakTrigger({required this.days});
}

class CategoryMasteryTrigger extends AchievementTrigger {
  final String category;
  final double accuracyThreshold; // e.g., 0.90 for 90%
  const CategoryMasteryTrigger({
    required this.category,
    required this.accuracyThreshold,
  });
}

/// Reward for unlocking achievement
class AchievementReward {
  final Map<HintType, int>? hints;
  final int? points;

  const AchievementReward({this.hints, this.points});
}

class UnlockedAchievement {
  final Achievement achievement;
  final DateTime unlockedAt;

  const UnlockedAchievement({
    required this.achievement,
    required this.unlockedAt,
  });
}
```

```dart
// lib/src/business_logic/achievement_engine.dart

class AchievementEngine {
  final List<Achievement> achievements;
  final StatisticsRepository statisticsRepository;
  final AchievementRepository achievementRepository;

  AchievementEngine({
    required this.achievements,
    required this.statisticsRepository,
    required this.achievementRepository,
  });

  /// Check if any achievements were unlocked by this quiz result
  Future<List<Achievement>> checkAchievements(
    QuizResults results,
  ) async {
    final unlocked = <Achievement>[];
    final alreadyUnlocked = await achievementRepository.getUnlockedIds();

    for (final achievement in achievements) {
      if (alreadyUnlocked.contains(achievement.id)) continue;

      final isUnlocked = await _checkTrigger(
        achievement.trigger,
        results,
      );

      if (isUnlocked) {
        await achievementRepository.unlock(achievement);
        unlocked.add(achievement);

        // Apply rewards
        if (achievement.reward != null) {
          await _applyReward(achievement.reward!);
        }
      }
    }

    return unlocked;
  }

  Future<bool> _checkTrigger(
    AchievementTrigger trigger,
    QuizResults results,
  ) async {
    return switch (trigger) {
      PerfectScoreTrigger(:final quizId) =>
        results.isPerfectScore &&
        (quizId == null || quizId == results.quizId),

      ScoreThresholdTrigger(:final quizId, :final minimumScore) =>
        results.quizId == quizId && results.score >= minimumScore,

      QuizCountTrigger(:final count) async {
        final stats = await statisticsRepository.getOverallStatistics();
        return stats.totalQuizzesCompleted >= count;
      },

      StreakTrigger(:final days) async {
        final stats = await statisticsRepository.getOverallStatistics();
        return stats.currentStreak >= days;
      },

      CategoryMasteryTrigger(:final category, :final accuracyThreshold) async {
        final stats = await statisticsRepository.getQuizStatistics(category);
        return stats.averageAccuracy >= (accuracyThreshold * 100);
      },
    };
  }
}
```

---

### 6. Scoring System

**Location:** `quiz_engine_core`

```dart
// lib/src/scoring/scoring_strategy.dart

/// Strategy pattern for different scoring algorithms
abstract class ScoringStrategy {
  int calculateScore(QuizResults results);
}

/// Simple scoring: 1 point per correct answer
class SimpleScoring extends ScoringStrategy {
  @override
  int calculateScore(QuizResults results) {
    return results.correctAnswers;
  }
}

/// Time-based scoring: bonus for speed
class TimedScoring extends ScoringStrategy {
  final int basePointsPerQuestion;
  final int bonusPerSecondSaved;
  final int timeThresholdSeconds;

  const TimedScoring({
    this.basePointsPerQuestion = 100,
    this.bonusPerSecondSaved = 5,
    this.timeThresholdSeconds = 30,
  });

  @override
  int calculateScore(QuizResults results) {
    int totalScore = 0;

    final avgTimePerQuestion =
        results.timeTaken.inSeconds / results.totalQuestions;

    for (int i = 0; i < results.correctAnswers; i++) {
      int questionScore = basePointsPerQuestion;

      // Bonus for answering quickly
      if (avgTimePerQuestion < timeThresholdSeconds) {
        final secondsSaved =
            (timeThresholdSeconds - avgTimePerQuestion).floor();
        questionScore += secondsSaved * bonusPerSecondSaved;
      }

      totalScore += questionScore;
    }

    return totalScore;
  }
}

/// Streak-based scoring: bonus for consecutive correct answers
class StreakScoring extends ScoringStrategy {
  final int basePointsPerQuestion;
  final double streakMultiplier;

  const StreakScoring({
    this.basePointsPerQuestion = 100,
    this.streakMultiplier = 1.5,
  });

  @override
  int calculateScore(QuizResults results) {
    // Would need Answer objects with order to calculate streaks
    // This is simplified
    return results.correctAnswers * basePointsPerQuestion;
  }
}
```

---

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

### 8. Shared Services Implementation

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
  final AnalyticsService? analyticsService;
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

**Example Structure:**

```dart
// apps/flagsquiz/lib/ui/home/home_screen.dart

class FlagsQuizHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flags Quiz')),
      body: Column(
        children: [
          // Stats overview
          StatsOverviewCard(),

          // Play modes
          PlayModeGrid(
            modes: [
              PlayMode.byContinent,
              PlayMode.timed,
              PlayMode.survival,
              PlayMode.practice,
            ],
            onModeSelected: _handleModeSelected,
          ),

          // Bottom actions
          Row(
            children: [
              TextButton(
                onPressed: () => _showAchievements(context),
                child: Text('Achievements'),
              ),
              TextButton(
                onPressed: () => _showStatistics(context),
                child: Text('Statistics'),
              ),
              TextButton(
                onPressed: () => _showSettings(context),
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleModeSelected(PlayMode mode) {
    switch (mode) {
      case PlayMode.byContinent:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContinentSelectionScreen(),
          ),
        );
      case PlayMode.timed:
        _startQuiz(
          continent: Continent.all,
          modeConfig: QuizModeConfig.timed(timePerQuestion: 30),
        );
      // ... etc
    }
  }
}
```

### Generic Home Components

You can create reusable components in `quiz_engine`:

```dart
// packages/quiz_engine/lib/src/home/stats_overview_card.dart

class StatsOverviewCard extends StatelessWidget {
  final int quizzesCompleted;
  final double averageAccuracy;
  final int currentStreak;

  // ... build UI showing stats
}

// packages/quiz_engine/lib/src/home/play_mode_grid.dart

class PlayModeGrid extends StatelessWidget {
  final List<PlayMode> modes;
  final Function(PlayMode) onModeSelected;

  // ... build grid of mode buttons
}
```

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

**Integration Example:**
```dart
// Example integration with quiz bloc

class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final audioService = AudioService();
  final hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    audioService.initialize();

    // Listen to quiz state and provide feedback
    quizBloc.stream.listen((state) {
      if (state is AnswerFeedbackState) {
        if (state.isCorrect) {
          audioService.playSoundEffect(QuizSoundEffect.correctAnswer);
          hapticService.correctAnswer();
        } else {
          audioService.playSoundEffect(QuizSoundEffect.incorrectAnswer);
          hapticService.incorrectAnswer();
        }
      }
    });
  }
}
```

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

**Usage Example:**
```dart
// Timed mode with 10 seconds per question, 100 seconds total
QuizConfig(
  modeConfig: QuizModeConfig.timed(
    timePerQuestion: 10,
    totalTimeLimit: 100,
  ),
)

// Result: Two timers shown in app bar
// - Question timer: 10s, 9s, 8s... (clock icon)
// - Total timer: 1:40, 1:39, 1:38... (hourglass icon)
// Both pause when app goes to background
```

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
  ```dart
  if (_config.modeConfig is EndlessMode && randomItemPicker.items.isEmpty) {
    randomItemPicker.replenishFromAnswered();
  }
  ```
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

**Next:** Sprint 3.1 (Hints System) - Implement hint functionality

### Phase 3: Hints System (Week 4)

- [ ] Create `HintState` class
- [ ] Implement hint logic in `QuizBloc`
- [ ] Create `HintsPanel` widget
- [ ] Implement 50/50 hint
- [ ] Implement skip hint
- [ ] Implement reveal letter hint
- [ ] Implement extra time hint (timed mode)
- [ ] Test hint system

### Phase 4: Results & Statistics (Week 5)

#### Sprint 4.1: Results Screen
- [ ] Create `QuizResults` model
- [ ] Create enhanced `QuizResultsScreen`
- [ ] Add star rating display
- [ ] Add percentage display
- [ ] Add "Review Mistakes" button
- [ ] Create `WrongAnswersReview` screen
- [ ] Test results screens

#### Sprint 4.2: Statistics
- [ ] Create `StatisticsRepository` interface
- [ ] Create `QuizStatistics` model
- [ ] Create `OverallStatistics` model
- [ ] Implement Hive-based repository in app
- [ ] Create `StatisticsScreen` UI
- [ ] Integrate with `QuizBloc`
- [ ] Test statistics tracking

### Phase 5: Achievements (Week 6)

- [ ] Create `Achievement` model
- [ ] Create `AchievementTrigger` hierarchy
- [ ] Create `AchievementEngine`
- [ ] Create `AchievementRepository` interface
- [ ] Implement repository in app
- [ ] Create `AchievementNotification` widget
- [ ] Create `AchievementsScreen`
- [ ] Define default achievements
- [ ] Test achievement system

### Phase 6: Shared Services (Week 7-8)

#### Sprint 6.1: Analytics
- [ ] Create `AnalyticsService` interface
- [ ] Implement `FirebaseAnalyticsService`
- [ ] Implement `ConsoleAnalyticsService`
- [ ] Add analytics calls to `QuizBloc`
- [ ] Test analytics integration

#### Sprint 6.2: Ads
- [ ] Create `AdsService` interface
- [ ] Implement `AdMobService`
- [ ] Implement `NoAdsService`
- [ ] Create banner ad widget
- [ ] Add interstitial ad points
- [ ] Add rewarded ad for hints
- [ ] Test ads integration

#### Sprint 6.3: IAP
- [ ] Create `IAPService` interface
- [ ] Implement `StoreIAPService`
- [ ] Add "Remove Ads" product
- [ ] Create purchase UI
- [ ] Implement restore purchases
- [ ] Test IAP flow

### Phase 7: Polish & Integration (Week 9)

- [ ] Review all animations
- [ ] Optimize performance
- [ ] Add loading states
- [ ] Error handling
- [ ] Add comprehensive tests
- [ ] Update documentation
- [ ] Create migration guide for flagsquiz
- [ ] Test complete flow end-to-end

### Phase 8: Second App Validation (Week 10)

- [ ] Create second quiz app (e.g., capitals_quiz)
- [ ] Validate reusability of all components
- [ ] Identify any app-specific leakage
- [ ] Refactor as needed
- [ ] Update documentation with learnings
- [ ] Create app creation checklist

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

**Document Version:** 1.1
**Last Updated:** 2025-12-22
**Status:** Phase 1 Sprint 1.1 Completed - Ready for Sprint 1.2