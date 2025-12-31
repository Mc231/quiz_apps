# Analytics Events Reference

This document provides a comprehensive reference for all analytics events in the quiz apps monorepo. These events are used to track user behavior, app performance, and business metrics.

---

## Table of Contents

1. [Overview](#overview)
2. [Screen View Events](#screen-view-events)
3. [Quiz Events](#quiz-events)
4. [Question Events](#question-events)
5. [Hint Events](#hint-events)
6. [Resource Events](#resource-events)
7. [Interaction Events](#interaction-events)
8. [Settings Events](#settings-events)
9. [Achievement Events](#achievement-events)
10. [Monetization Events](#monetization-events)
11. [Error Events](#error-events)
12. [Performance Events](#performance-events)
13. [Rate App Events](#rate-app-events)
14. [User Properties](#user-properties)
15. [Implementation Guide](#implementation-guide)

---

## Overview

The analytics system uses sealed classes for type-safe event tracking. All events extend the `AnalyticsEvent` base class and provide:

- `eventName`: Snake_case event name for Firebase Analytics
- `parameters`: Map of event parameters

**Total Events:** 98 events across 12 sealed classes

| Event Class | Event Count | Description |
|-------------|-------------|-------------|
| ScreenViewEvent | 18 | Screen/page tracking |
| QuizEvent | 8 | Quiz lifecycle |
| QuestionEvent | 8 | Question interactions |
| HintEvent | 4 | Hint usage |
| ResourceEvent | 4 | Lives/resources |
| InteractionEvent | 12 | UI interactions |
| SettingsEvent | 8 | Settings changes |
| AchievementEvent | 5 | Achievements |
| MonetizationEvent | 10 | Purchases/ads |
| ErrorEvent | 6 | Error tracking |
| PerformanceEvent | 5 | App performance |
| RateAppEvent | 11 | In-app review tracking |

---

## Screen View Events

Track screen/page views throughout the app.

### Event: `screen_view`

All screen view events share the event name `screen_view` but have different screen names and parameters.

#### HomeScreenView
```dart
ScreenViewEvent.home(activeTab: 'play')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `active_tab` | String | Currently selected tab |

#### PlayScreenView
```dart
ScreenViewEvent.play(categoryCount: 6)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `category_count` | int | Number of available categories |

#### PlayTabbedScreenView
```dart
ScreenViewEvent.playTabbed(tabId: 'continents', tabName: 'Continents')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `tab_id` | String | Tab identifier |
| `tab_name` | String | Tab display name |

#### HistoryScreenView
```dart
ScreenViewEvent.history(sessionCount: 10)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_count` | int | Number of past sessions |

#### StatisticsScreenView
```dart
ScreenViewEvent.statistics(totalSessions: 50, averageScore: 75.5)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `total_sessions` | int | Total quiz sessions played |
| `average_score` | double | User's average score |

#### AchievementsScreenView
```dart
ScreenViewEvent.achievements(
  unlockedCount: 5,
  totalCount: 20,
  totalPoints: 500,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `unlocked_count` | int | Achievements unlocked |
| `total_count` | int | Total achievements |
| `total_points` | int | Total achievement points |
| `unlock_percentage` | String | Percentage unlocked |

#### SettingsScreenView
```dart
ScreenViewEvent.settings()
```
No additional parameters.

#### QuizScreenView
```dart
ScreenViewEvent.quiz(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  mode: 'standard',
  totalQuestions: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `mode` | String | Quiz mode (standard, timed, lives, endless) |
| `total_questions` | int | Total questions in quiz |

#### ResultsScreenView
```dart
ScreenViewEvent.results(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  scorePercentage: 85.0,
  isPerfectScore: false,
  starRating: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `score_percentage` | double | Final score percentage |
| `is_perfect_score` | bool | Whether user got 100% |
| `star_rating` | int | Star rating (1-3) |

#### SessionDetailScreenView
```dart
ScreenViewEvent.sessionDetail(
  sessionId: 's1',
  quizName: 'Test',
  scorePercentage: 80,
  daysAgo: 1,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | String | Session identifier |
| `quiz_name` | String | Quiz display name |
| `score_percentage` | double | Session score |
| `days_ago` | int | Days since session |

#### CategoryStatisticsScreenView
```dart
ScreenViewEvent.categoryStatistics(
  categoryId: 'europe',
  categoryName: 'Europe',
  totalSessions: 10,
  averageScore: 85,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `category_id` | String | Category identifier |
| `category_name` | String | Category display name |
| `total_sessions` | int | Sessions in category |
| `average_score` | double | Average score in category |

#### ChallengesScreenView
```dart
ScreenViewEvent.challenges(challengeCount: 5, completedCount: 2)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `challenge_count` | int | Total challenges |
| `completed_count` | int | Completed challenges |
| `completion_percentage` | String | Percentage completed |

#### PracticeScreenView
```dart
ScreenViewEvent.practice(categoryId: 'europe', categoryName: 'Europe')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `category_id` | String | Category identifier |
| `category_name` | String | Category display name |

#### LeaderboardScreenView
```dart
ScreenViewEvent.leaderboard(leaderboardType: 'global', entryCount: 100)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `leaderboard_type` | String | Type of leaderboard |
| `entry_count` | int | Number of entries |

#### AboutScreenView
```dart
ScreenViewEvent.about(appVersion: '1.0.0', buildNumber: '1')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `app_version` | String | App version string |
| `build_number` | String | Build number |

#### LicensesScreenView
```dart
ScreenViewEvent.licenses()
```
No additional parameters.

#### TutorialScreenView
```dart
ScreenViewEvent.tutorial(stepIndex: 0, totalSteps: 5)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `step_index` | int | Current tutorial step |
| `total_steps` | int | Total tutorial steps |
| `progress_percentage` | String | Tutorial progress |

#### CustomScreenView
```dart
ScreenViewEvent.custom(
  name: 'continent_selection',
  className: 'ContinentSelectionScreen',
  additionalParams: {'continentCount': 7},
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| Custom | dynamic | App-specific parameters |

---

## Quiz Events

Track quiz lifecycle from start to completion.

### Event: `quiz_started`
```dart
QuizEvent.started(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  categoryName: 'Europe',
  mode: 'standard',
  totalQuestions: 20,
  initialLives: 3,      // optional
  initialHints: 5,      // optional
  timeLimit: 300,       // optional
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `category_name` | String | Category display name |
| `mode` | String | Quiz mode |
| `total_questions` | int | Total questions |
| `initial_lives` | int? | Starting lives (if applicable) |
| `initial_hints` | int? | Starting hints (if applicable) |
| `time_limit` | int? | Time limit in seconds (if applicable) |

### Event: `quiz_completed`
```dart
QuizEvent.completed(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  mode: 'standard',
  totalQuestions: 20,
  correctAnswers: 18,
  incorrectAnswers: 2,
  skippedQuestions: 0,
  scorePercentage: 90.0,
  duration: Duration(minutes: 5),
  hintsUsed: 1,
  isPerfectScore: false,
  starRating: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `mode` | String | Quiz mode |
| `total_questions` | int | Total questions |
| `correct_answers` | int | Correct answer count |
| `incorrect_answers` | int | Incorrect answer count |
| `skipped_questions` | int | Skipped question count |
| `score_percentage` | double | Final score percentage |
| `duration_seconds` | int | Quiz duration in seconds |
| `hints_used` | int | Hints used |
| `is_perfect_score` | bool | 100% score |
| `star_rating` | int? | Star rating (1-3) |

### Event: `quiz_cancelled`
```dart
QuizEvent.cancelled(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  mode: 'standard',
  questionsAnswered: 5,
  totalQuestions: 20,
  timeSpent: Duration(minutes: 2),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `mode` | String | Quiz mode |
| `questions_answered` | int | Questions answered before cancel |
| `total_questions` | int | Total questions |
| `time_spent_seconds` | int | Time spent in seconds |
| `completion_percentage` | String | Progress percentage |

### Event: `quiz_timeout`
```dart
QuizEvent.timeout(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  mode: 'timed',
  questionsAnswered: 15,
  totalQuestions: 20,
  correctAnswers: 12,
  scorePercentage: 80.0,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `mode` | String | Quiz mode |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |
| `correct_answers` | int | Correct answers |
| `score_percentage` | double | Score at timeout |

### Event: `quiz_failed`
```dart
QuizEvent.failed(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  mode: 'lives',
  questionsAnswered: 8,
  totalQuestions: 20,
  correctAnswers: 5,
  scorePercentage: 62.5,
  duration: Duration(minutes: 3),
  reason: 'lives_depleted',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `mode` | String | Quiz mode |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |
| `correct_answers` | int | Correct answers |
| `score_percentage` | double | Score at failure |
| `duration_seconds` | int | Duration in seconds |
| `reason` | String | Failure reason (lives_depleted, first_wrong_answer) |

### Event: `quiz_paused`
```dart
QuizEvent.paused(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  currentQuestion: 5,
  totalQuestions: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `current_question` | int | Current question index |
| `total_questions` | int | Total questions |

### Event: `quiz_resumed`
```dart
QuizEvent.resumed(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  currentQuestion: 5,
  totalQuestions: 20,
  pauseDuration: Duration(seconds: 30),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `current_question` | int | Current question index |
| `total_questions` | int | Total questions |
| `pause_duration_seconds` | int | Pause duration in seconds |

### Event: `quiz_challenge_started`
```dart
QuizEvent.challengeStarted(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  challengeId: 'challenge-001',
  challengeName: 'Speed Master',
  difficulty: 'hard',
  targetScore: 90,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `challenge_id` | String | Challenge identifier |
| `challenge_name` | String | Challenge display name |
| `difficulty` | String | Difficulty level |
| `target_score` | int | Target score to beat |

---

## Question Events

Track individual question interactions.

### Event: `question_displayed`
```dart
QuestionEvent.displayed(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  totalQuestions: 20,
  questionType: 'image',
  optionCount: 4,
  timeLimit: 30,  // optional
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index (0-based) |
| `total_questions` | int | Total questions |
| `question_type` | String | Question type (image, text, audio, video) |
| `option_count` | int | Number of answer options |
| `time_limit` | int? | Time limit in seconds |

### Event: `question_answered`
```dart
QuestionEvent.answered(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  isCorrect: true,
  responseTime: Duration(seconds: 3),
  selectedAnswer: 'France',
  correctAnswer: 'France',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `is_correct` | bool | Whether answer was correct |
| `response_time_ms` | int | Response time in milliseconds |
| `selected_answer` | String | User's selected answer |
| `correct_answer` | String | The correct answer |

### Event: `question_correct`
```dart
QuestionEvent.correct(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  responseTime: Duration(seconds: 3),
  currentStreak: 5,
  pointsEarned: 100,
  bonusPoints: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `response_time_ms` | int | Response time in milliseconds |
| `current_streak` | int | Current correct answer streak |
| `points_earned` | int? | Points earned |
| `bonus_points` | int? | Bonus points (speed, streak) |

### Event: `question_incorrect`
```dart
QuestionEvent.incorrect(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  responseTime: Duration(seconds: 5),
  selectedAnswer: 'Germany',
  correctAnswer: 'France',
  livesRemaining: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `response_time_ms` | int | Response time in milliseconds |
| `selected_answer` | String | User's selected answer |
| `correct_answer` | String | The correct answer |
| `lives_remaining` | int? | Lives remaining (if lives mode) |

### Event: `question_skipped`
```dart
QuestionEvent.skipped(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  timeBeforeSkip: Duration(seconds: 10),
  usedHint: true,
  hintsRemaining: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `time_before_skip_ms` | int | Time before skip in milliseconds |
| `used_hint` | bool | Whether hint was used before skip |
| `hints_remaining` | int? | Hints remaining |

### Event: `question_timeout`
```dart
QuestionEvent.timeout(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  timeLimit: 30,
  correctAnswer: 'France',
  livesRemaining: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `time_limit` | int | Time limit in seconds |
| `correct_answer` | String | The correct answer |
| `lives_remaining` | int? | Lives remaining |

### Event: `question_feedback_shown`
```dart
QuestionEvent.feedbackShown(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  wasCorrect: true,
  feedbackDuration: Duration(milliseconds: 500),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `was_correct` | bool | Whether answer was correct |
| `feedback_duration_ms` | int | Feedback display duration |

### Event: `question_option_selected`
```dart
QuestionEvent.optionSelected(
  quizId: 'quiz-123',
  questionId: 'q1',
  questionIndex: 0,
  selectedOption: 'France',
  optionIndex: 2,
  timeSinceDisplayed: Duration(seconds: 3),
  isFirstSelection: false,
  changeCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `selected_option` | String | Selected option text |
| `option_index` | int | Option index (0-based) |
| `time_since_displayed_ms` | int | Time since question displayed |
| `is_first_selection` | bool | First option selected |
| `change_count` | int? | Number of changes |

---

## Hint Events

Track hint usage during quizzes.

### Event: `hint_fifty_fifty_used`
```dart
HintEvent.fiftyFiftyUsed(
  quizId: 'quiz-123',
  questionId: 'q5',
  questionIndex: 4,
  hintsRemaining: 2,
  eliminatedOptions: ['Germany', 'Spain'],
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `hints_remaining` | int | Hints remaining after use |
| `eliminated_options` | String | Comma-separated eliminated options |
| `eliminated_count` | int | Number of options eliminated |

### Event: `hint_skip_used`
```dart
HintEvent.skipUsed(
  quizId: 'quiz-123',
  questionId: 'q6',
  questionIndex: 5,
  hintsRemaining: 1,
  timeBeforeSkip: Duration(seconds: 10),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `hints_remaining` | int | Hints remaining after use |
| `time_before_skip_ms` | int | Time before skip in milliseconds |

### Event: `hint_unavailable_tapped`
```dart
HintEvent.unavailableTapped(
  quizId: 'quiz-123',
  questionId: 'q7',
  questionIndex: 6,
  hintType: 'fifty_fifty',
  totalHintsUsed: 3,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `hint_type` | String | Type of hint tapped |
| `total_hints_used` | int? | Total hints used in quiz |

### Event: `hint_timer_warning`
```dart
HintEvent.timerWarning(
  quizId: 'quiz-123',
  questionId: 'q8',
  questionIndex: 7,
  secondsRemaining: 5,
  warningLevel: 'critical',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `seconds_remaining` | int | Seconds remaining |
| `warning_level` | String | Warning level (warning, critical) |

---

## Resource Events

Track lives and resource management.

### Event: `resource_life_lost`
```dart
ResourceEvent.lifeLost(
  quizId: 'quiz-123',
  questionId: 'q5',
  questionIndex: 4,
  livesRemaining: 2,
  livesTotal: 3,
  reason: 'incorrect_answer',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `question_id` | String | Question identifier |
| `question_index` | int | Question index |
| `lives_remaining` | int | Lives remaining |
| `lives_total` | int | Total lives |
| `reason` | String | Reason for life loss |

### Event: `resource_lives_depleted`
```dart
ResourceEvent.livesDepleted(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  questionsAnswered: 5,
  totalQuestions: 20,
  correctAnswers: 2,
  scorePercentage: 40.0,
  duration: Duration(minutes: 2),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `quiz_name` | String | Quiz display name |
| `category_id` | String | Category identifier |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |
| `correct_answers` | int | Correct answers |
| `score_percentage` | double | Final score |
| `duration_seconds` | int | Duration in seconds |
| `completion_percentage` | String | Progress percentage |

### Event: `resource_button_tapped`
```dart
ResourceEvent.buttonTapped(
  quizId: 'quiz-123',
  resourceType: 'lives',
  currentAmount: 2,
  isAvailable: true,
  context: 'quiz_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `resource_type` | String | Resource type (lives, hints) |
| `current_amount` | int | Current resource amount |
| `is_available` | bool | Whether resource is available |
| `context` | String | Where button was tapped |

### Event: `resource_added`
```dart
ResourceEvent.added(
  quizId: 'quiz-123',
  resourceType: 'lives',
  amountAdded: 3,
  newTotal: 5,
  source: 'rewarded_ad',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `resource_type` | String | Resource type |
| `amount_added` | int | Amount added |
| `new_total` | int | New total amount |
| `source` | String | Source (purchase, ad, bonus) |

---

## Interaction Events

Track user interactions with UI elements.

### Event: `category_selected`
```dart
InteractionEvent.categorySelected(
  categoryId: 'europe',
  categoryName: 'Europe',
  categoryIndex: 0,
  parentCategoryId: 'continents',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `category_id` | String | Category identifier |
| `category_name` | String | Category display name |
| `category_index` | int | Position in list |
| `parent_category_id` | String? | Parent category (if nested) |

### Event: `tab_selected`
```dart
InteractionEvent.tabSelected(
  tabId: 'history',
  tabName: 'History',
  tabIndex: 2,
  previousTabId: 'play',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `tab_id` | String | Tab identifier |
| `tab_name` | String | Tab display name |
| `tab_index` | int | Tab position |
| `previous_tab_id` | String? | Previous tab |

### Event: `session_viewed`
```dart
InteractionEvent.sessionViewed(
  sessionId: 's1',
  quizName: 'European Flags',
  scorePercentage: 85.0,
  daysAgo: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | String | Session identifier |
| `quiz_name` | String | Quiz display name |
| `score_percentage` | double | Session score |
| `days_ago` | int | Days since session |

### Event: `session_deleted`
```dart
InteractionEvent.sessionDeleted(
  sessionId: 's1',
  quizName: 'European Flags',
  daysAgo: 30,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | String | Session identifier |
| `quiz_name` | String | Quiz display name |
| `days_ago` | int | Days since session |

### Event: `view_all_sessions`
```dart
InteractionEvent.viewAllSessions(
  totalSessions: 50,
  source: 'statistics_dashboard',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `total_sessions` | int | Total session count |
| `source` | String | Navigation source |

### Event: `exit_dialog_shown`
```dart
InteractionEvent.exitDialogShown(
  quizId: 'quiz-123',
  questionsAnswered: 5,
  totalQuestions: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |
| `completion_percentage` | String | Progress percentage |

### Event: `exit_dialog_confirmed`
```dart
InteractionEvent.exitDialogConfirmed(
  quizId: 'quiz-123',
  questionsAnswered: 5,
  totalQuestions: 20,
  timeSpent: Duration(minutes: 2),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |
| `time_spent_seconds` | int | Time spent in seconds |

### Event: `exit_dialog_cancelled`
```dart
InteractionEvent.exitDialogCancelled(
  quizId: 'quiz-123',
  questionsAnswered: 5,
  totalQuestions: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `quiz_id` | String | Quiz identifier |
| `questions_answered` | int | Questions answered |
| `total_questions` | int | Total questions |

### Event: `data_export_initiated`
```dart
InteractionEvent.dataExportInitiated(
  exportFormat: 'csv',
  sessionCount: 50,
  dateRange: '2024-01-01 to 2024-12-31',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `export_format` | String | Export format (csv, json) |
| `session_count` | int | Sessions to export |
| `date_range` | String? | Date range filter |

### Event: `data_export_completed`
```dart
InteractionEvent.dataExportCompleted(
  exportFormat: 'csv',
  sessionCount: 50,
  fileSizeBytes: 10240,
  exportDuration: Duration(seconds: 2),
  success: true,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `export_format` | String | Export format |
| `session_count` | int | Sessions exported |
| `file_size_bytes` | int | File size in bytes |
| `export_duration_ms` | int | Duration in milliseconds |
| `success` | bool | Export success |
| `error_message` | String? | Error message if failed |

### Event: `pull_to_refresh`
```dart
InteractionEvent.pullToRefresh(
  screenName: 'history',
  refreshDuration: Duration(milliseconds: 500),
  success: true,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `screen_name` | String | Screen refreshed |
| `refresh_duration_ms` | int | Refresh duration |
| `success` | bool | Refresh success |

### Event: `leaderboard_viewed`
```dart
InteractionEvent.leaderboardViewed(
  leaderboardType: 'global',
  userRank: 42,
  totalEntries: 1000,
  categoryId: 'europe',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `leaderboard_type` | String | Leaderboard type |
| `user_rank` | int | User's current rank |
| `total_entries` | int | Total entries |
| `category_id` | String? | Category filter |

---

## Settings Events

Track settings changes and preferences.

### Event: `settings_changed`
```dart
SettingsEvent.changed(
  settingName: 'difficulty',
  oldValue: 'easy',
  newValue: 'hard',
  settingCategory: 'gameplay',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `setting_name` | String | Setting name |
| `old_value` | String | Previous value |
| `new_value` | String | New value |
| `setting_category` | String? | Setting category |

### Event: `sound_effects_toggled`
```dart
SettingsEvent.soundEffectsToggled(
  enabled: false,
  source: 'settings_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | bool | New state |
| `source` | String | Toggle source |

### Event: `haptic_feedback_toggled`
```dart
SettingsEvent.hapticFeedbackToggled(
  enabled: true,
  source: 'settings_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | bool | New state |
| `source` | String | Toggle source |

### Event: `theme_changed`
```dart
SettingsEvent.themeChanged(
  newTheme: 'dark',
  previousTheme: 'light',
  source: 'settings_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `new_theme` | String | New theme |
| `previous_theme` | String | Previous theme |
| `source` | String | Change source |

### Event: `answer_feedback_toggled`
```dart
SettingsEvent.answerFeedbackToggled(
  enabled: false,
  source: 'settings_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | bool | New state |
| `source` | String | Toggle source |

### Event: `reset_confirmed`
```dart
SettingsEvent.resetConfirmed(
  resetType: 'all_data',
  sessionsDeleted: 50,
  achievementsReset: 10,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `reset_type` | String | Reset type |
| `sessions_deleted` | int | Sessions deleted |
| `achievements_reset` | int | Achievements reset |

### Event: `privacy_policy_viewed`
```dart
SettingsEvent.privacyPolicyViewed(source: 'settings_screen')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | String | View source |

### Event: `terms_of_service_viewed`
```dart
SettingsEvent.termsOfServiceViewed(source: 'settings_screen')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | String | View source |

---

## Achievement Events

Track achievement unlocks and interactions.

### Event: `achievement_unlocked`
```dart
AchievementEvent.unlocked(
  achievementId: 'first_perfect',
  achievementName: 'Perfectionist',
  achievementCategory: 'score',
  pointsAwarded: 100,
  totalPoints: 500,
  unlockedCount: 5,
  totalAchievements: 20,
  triggerQuizId: 'quiz-123',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `achievement_id` | String | Achievement identifier |
| `achievement_name` | String | Achievement display name |
| `achievement_category` | String | Achievement category |
| `points_awarded` | int | Points for achievement |
| `total_points` | int | Total points |
| `unlocked_count` | int | Achievements unlocked |
| `total_achievements` | int | Total achievements |
| `unlock_percentage` | String | Unlock percentage |
| `trigger_quiz_id` | String? | Quiz that triggered unlock |

### Event: `achievement_notification_shown`
```dart
AchievementEvent.notificationShown(
  achievementId: 'first_perfect',
  achievementName: 'Perfectionist',
  pointsAwarded: 100,
  displayDuration: Duration(seconds: 3),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `achievement_id` | String | Achievement identifier |
| `achievement_name` | String | Achievement display name |
| `points_awarded` | int | Points awarded |
| `display_duration_ms` | int | Display duration |

### Event: `achievement_notification_tapped`
```dart
AchievementEvent.notificationTapped(
  achievementId: 'first_perfect',
  achievementName: 'Perfectionist',
  timeToTap: Duration(seconds: 1),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `achievement_id` | String | Achievement identifier |
| `achievement_name` | String | Achievement display name |
| `time_to_tap_ms` | int | Time to tap in milliseconds |

### Event: `achievement_detail_viewed`
```dart
AchievementEvent.detailViewed(
  achievementId: 'first_perfect',
  achievementName: 'Perfectionist',
  achievementCategory: 'score',
  isUnlocked: true,
  progress: 100.0,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `achievement_id` | String | Achievement identifier |
| `achievement_name` | String | Achievement display name |
| `achievement_category` | String | Achievement category |
| `is_unlocked` | bool | Whether unlocked |
| `progress` | double? | Progress percentage |

### Event: `achievement_filtered`
```dart
AchievementEvent.filtered(
  filterType: 'category',
  filterValue: 'score',
  resultCount: 5,
  totalCount: 20,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `filter_type` | String | Filter type |
| `filter_value` | String | Filter value |
| `result_count` | int | Filtered count |
| `total_count` | int | Total count |

---

## Monetization Events

Track in-app purchases and ad interactions.

### Event: `purchase_sheet_opened`
```dart
MonetizationEvent.purchaseSheetOpened(
  source: 'resource_button',
  availablePacksCount: 3,
  triggeredByFeature: 'extra_lives',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | String | Open source |
| `available_packs_count` | int | Available packs |
| `triggered_by_feature` | String? | Triggering feature |

### Event: `pack_selected`
```dart
MonetizationEvent.packSelected(
  packId: 'lives_small',
  packName: 'Small Lives Pack',
  price: 0.99,
  currency: 'USD',
  packIndex: 0,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `pack_id` | String | Pack identifier |
| `pack_name` | String | Pack display name |
| `price` | double | Pack price |
| `currency` | String | Currency code |
| `pack_index` | int | Pack position |

### Event: `purchase_initiated`
```dart
MonetizationEvent.purchaseInitiated(
  packId: 'lives_small',
  packName: 'Small Lives Pack',
  price: 0.99,
  currency: 'USD',
  paymentMethod: 'apple_pay',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `pack_id` | String | Pack identifier |
| `pack_name` | String | Pack display name |
| `price` | double | Pack price |
| `currency` | String | Currency code |
| `payment_method` | String | Payment method |

### Event: `purchase_completed`
```dart
MonetizationEvent.purchaseCompleted(
  packId: 'lives_small',
  packName: 'Small Lives Pack',
  price: 0.99,
  currency: 'USD',
  transactionId: 'txn-123',
  purchaseDuration: Duration(seconds: 10),
  isFirstPurchase: true,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `pack_id` | String | Pack identifier |
| `pack_name` | String | Pack display name |
| `price` | double | Pack price |
| `currency` | String | Currency code |
| `transaction_id` | String | Transaction ID |
| `purchase_duration_ms` | int | Duration in milliseconds |
| `is_first_purchase` | bool | First purchase |

### Event: `purchase_cancelled`
```dart
MonetizationEvent.purchaseCancelled(
  packId: 'lives_small',
  packName: 'Small Lives Pack',
  price: 0.99,
  currency: 'USD',
  cancelReason: 'user_cancelled',
  timeBeforeCancel: Duration(seconds: 5),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `pack_id` | String | Pack identifier |
| `pack_name` | String | Pack display name |
| `price` | double | Pack price |
| `currency` | String | Currency code |
| `cancel_reason` | String | Cancel reason |
| `time_before_cancel_ms` | int | Time before cancel |

### Event: `purchase_failed`
```dart
MonetizationEvent.purchaseFailed(
  packId: 'lives_small',
  packName: 'Small Lives Pack',
  price: 0.99,
  currency: 'USD',
  errorCode: 'PAYMENT_DECLINED',
  errorMessage: 'Payment was declined',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `pack_id` | String | Pack identifier |
| `pack_name` | String | Pack display name |
| `price` | double | Pack price |
| `currency` | String | Currency code |
| `error_code` | String | Error code |
| `error_message` | String | Error message |

### Event: `restore_initiated`
```dart
MonetizationEvent.restoreInitiated(source: 'settings_screen')
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | String | Initiation source |

### Event: `restore_completed`
```dart
MonetizationEvent.restoreCompleted(
  success: true,
  restoredCount: 2,
  restoreDuration: Duration(seconds: 3),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | bool | Restore success |
| `restored_count` | int | Items restored |
| `restore_duration_ms` | int | Duration in milliseconds |
| `error_message` | String? | Error if failed |

### Event: `ad_watched`
```dart
MonetizationEvent.adWatched(
  adType: 'rewarded',
  adPlacement: 'extra_life',
  watchDuration: Duration(seconds: 30),
  wasCompleted: true,
  rewardType: 'lives',
  rewardAmount: 1,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `ad_type` | String | Ad type (rewarded, interstitial) |
| `ad_placement` | String | Ad placement |
| `watch_duration_ms` | int | Watch duration |
| `was_completed` | bool | Whether completed |
| `reward_type` | String? | Reward type |
| `reward_amount` | int? | Reward amount |

### Event: `ad_failed`
```dart
MonetizationEvent.adFailed(
  adType: 'rewarded',
  adPlacement: 'extra_life',
  errorCode: 'NO_FILL',
  errorMessage: 'No ad available',
  failureStage: 'load',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `ad_type` | String | Ad type |
| `ad_placement` | String | Ad placement |
| `error_code` | String | Error code |
| `error_message` | String | Error message |
| `failure_stage` | String | Failure stage (load, show) |

---

## Error Events

Track application errors and failures.

### Event: `data_load_failed`
```dart
ErrorEvent.dataLoadFailed(
  dataType: 'quiz_data',
  errorCode: 'NETWORK_ERROR',
  errorMessage: 'Failed to connect',
  source: 'quiz_repository',
  retryCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `data_type` | String | Data type |
| `error_code` | String | Error code |
| `error_message` | String | Error message |
| `source` | String? | Error source |
| `retry_count` | int? | Retry attempts |

### Event: `save_failed`
```dart
ErrorEvent.saveFailed(
  dataType: 'session',
  errorCode: 'DISK_FULL',
  errorMessage: 'Not enough storage',
  operation: 'insert',
  dataSize: 1024,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `data_type` | String | Data type |
| `error_code` | String | Error code |
| `error_message` | String | Error message |
| `operation` | String? | Operation type |
| `data_size` | int? | Data size in bytes |

### Event: `retry_tapped`
```dart
ErrorEvent.retryTapped(
  errorType: 'network',
  context: 'quiz_loading',
  attemptNumber: 3,
  timeSinceError: Duration(seconds: 5),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `error_type` | String | Error type |
| `context` | String | Error context |
| `attempt_number` | int | Retry attempt |
| `time_since_error_ms` | int? | Time since error |

### Event: `app_crash`
```dart
ErrorEvent.appCrash(
  crashType: 'unhandled_exception',
  errorMessage: 'Null check operator used on null value',
  stackTrace: '...',
  screenName: 'quiz_screen',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `crash_type` | String | Crash type |
| `error_message` | String | Error message |
| `stack_trace` | String? | Stack trace |
| `screen_name` | String? | Current screen |

### Event: `feature_failure`
```dart
ErrorEvent.featureFailure(
  featureName: 'quiz_timer',
  errorCode: 'TIMER_FAILED',
  errorMessage: 'Timer stopped unexpectedly',
  userAction: 'answer_submitted',
  wasRecoverable: true,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `feature_name` | String | Feature name |
| `error_code` | String | Error code |
| `error_message` | String | Error message |
| `user_action` | String? | User action |
| `was_recoverable` | bool? | Was recoverable |

### Event: `network_error`
```dart
ErrorEvent.network(
  endpoint: '/api/quizzes',
  statusCode: 500,
  errorMessage: 'Internal server error',
  requestDuration: Duration(seconds: 30),
  requestMethod: 'GET',
  retryCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `endpoint` | String | API endpoint |
| `status_code` | int | HTTP status code |
| `error_message` | String | Error message |
| `request_duration_ms` | int | Request duration |
| `request_method` | String? | HTTP method |
| `retry_count` | int? | Retry attempts |

---

## Performance Events

Track app performance metrics.

### Event: `app_launch`
```dart
PerformanceEvent.appLaunch(
  coldStartDuration: Duration(milliseconds: 800),
  isFirstLaunch: false,
  launchType: 'cold',
  previousVersion: '1.0.0',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `cold_start_duration_ms` | int | Cold start duration |
| `is_first_launch` | bool | First launch ever |
| `launch_type` | String? | Launch type (cold, warm) |
| `previous_version` | String? | Previous app version |

### Event: `session_start`
```dart
PerformanceEvent.sessionStart(
  sessionId: 'session-123',
  startTime: DateTime.now(),
  entryPoint: 'app_icon',
  deviceInfo: {'platform': 'ios', 'version': '17.0'},
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | String | Session identifier |
| `start_time` | String | ISO8601 timestamp |
| `entry_point` | String? | App entry point |
| `device_info` | Map? | Device information |

### Event: `session_end`
```dart
PerformanceEvent.sessionEnd(
  sessionId: 'session-123',
  sessionDuration: Duration(minutes: 15),
  screenViewCount: 10,
  interactionCount: 50,
  exitReason: 'user_exit',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | String | Session identifier |
| `session_duration_ms` | int | Session duration |
| `screen_view_count` | int | Screens viewed |
| `interaction_count` | int | Interactions |
| `exit_reason` | String? | Exit reason |

### Event: `screen_render`
```dart
PerformanceEvent.screenRender(
  screenName: 'home',
  renderDuration: Duration(milliseconds: 50),
  isInitialRender: true,
  widgetCount: 100,
  dataLoadDuration: Duration(milliseconds: 200),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `screen_name` | String | Screen name |
| `render_duration_ms` | int | Render duration |
| `is_initial_render` | bool | First render |
| `widget_count` | int? | Widget count |
| `data_load_duration_ms` | int? | Data load duration |

### Event: `database_query`
```dart
PerformanceEvent.databaseQuery(
  queryType: 'select',
  tableName: 'quiz_sessions',
  queryDuration: Duration(milliseconds: 10),
  resultCount: 50,
  usedIndex: true,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `query_type` | String | Query type (select, insert, update, delete) |
| `table_name` | String | Table name |
| `query_duration_ms` | int | Query duration |
| `result_count` | int | Result count |
| `used_index` | bool? | Used index |

---

## Rate App Events

Track in-app review dialog interactions and feedback funnel. Total: 11 events.

### Event: `rate_app_conditions_checked`
Fired when conditions are evaluated to determine if rate prompt should show.
```dart
RateAppEvent.conditionsChecked(
  shouldShow: true,
  blockingReason: null,
  completedQuizzes: 10,
  quizScore: 85,
  daysSinceInstall: 14,
  promptCount: 1,
  declineCount: 0,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `should_show` | bool | Whether conditions are met |
| `blocking_reason` | String? | Reason if conditions not met |
| `completed_quizzes` | int | Total quizzes completed |
| `quiz_score` | int | Score percentage of last quiz |
| `days_since_install` | int | Days since first launch |
| `prompt_count` | int | Total prompts shown previously |
| `decline_count` | int | Times user declined previously |

### Event: `rate_app_love_dialog_shown`
Fired when the "Are you enjoying?" dialog is displayed.
```dart
RateAppEvent.loveDialogShown(
  completedQuizzes: 10,
  quizScore: 85,
  promptCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `completed_quizzes` | int | Total quizzes completed |
| `quiz_score` | int | Score percentage |
| `prompt_count` | int | Total prompts including this one |

### Event: `rate_app_love_dialog_positive`
Fired when user taps "Yes!" in the love dialog.
```dart
RateAppEvent.loveDialogPositive(
  promptCount: 2,
  timeToRespond: Duration(milliseconds: 2500),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt_count` | int | Total prompts shown |
| `time_to_respond_ms` | int | Time to respond in milliseconds |

### Event: `rate_app_love_dialog_negative`
Fired when user taps "Not Really" in the love dialog.
```dart
RateAppEvent.loveDialogNegative(
  promptCount: 2,
  declineCount: 1,
  timeToRespond: Duration(milliseconds: 1800),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt_count` | int | Total prompts shown |
| `decline_count` | int | Total declines including this one |
| `time_to_respond_ms` | int | Time to respond in milliseconds |

### Event: `rate_app_love_dialog_dismissed`
Fired when user dismisses the love dialog without action.
```dart
RateAppEvent.loveDialogDismissed(
  promptCount: 2,
  timeToRespond: Duration(milliseconds: 5000),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt_count` | int | Total prompts shown |
| `time_to_respond_ms` | int | Time before dismissal |

### Event: `rate_app_native_dialog_shown`
Fired when the native platform rating dialog is displayed.
```dart
RateAppEvent.nativeDialogShown(
  promptCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt_count` | int | Total prompts shown |

### Event: `rate_app_native_dialog_completed`
Fired when the native dialog is closed (user may or may not have rated).
```dart
RateAppEvent.nativeDialogCompleted(
  promptCount: 2,
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt_count` | int | Total prompts shown |

**Note:** Native rating dialogs don't provide feedback on whether the user actually submitted a rating. This event fires when the dialog closes, regardless of user action.

### Event: `rate_app_native_dialog_unavailable`
Fired when the native dialog is not available on this platform.
```dart
RateAppEvent.nativeDialogUnavailable(
  platform: 'web',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `platform` | String | Platform where unavailable |

### Event: `rate_app_feedback_dialog_shown`
Fired when the feedback dialog is displayed to unhappy users.
```dart
RateAppEvent.feedbackDialogShown(
  declineCount: 1,
  feedbackEmail: 'support@app.com',
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `decline_count` | int | Times user has declined |
| `has_feedback_email` | bool | Whether email option is available |

### Event: `rate_app_feedback_submitted`
Fired when user chooses to send feedback.
```dart
RateAppEvent.feedbackSubmitted(
  declineCount: 1,
  timeToRespond: Duration(milliseconds: 3000),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `decline_count` | int | Times user has declined |
| `time_to_respond_ms` | int | Time before action |

### Event: `rate_app_feedback_dismissed`
Fired when user dismisses the feedback dialog.
```dart
RateAppEvent.feedbackDismissed(
  declineCount: 1,
  timeToRespond: Duration(milliseconds: 3000),
)
```
| Parameter | Type | Description |
|-----------|------|-------------|
| `decline_count` | int | Times user has declined |
| `time_to_respond_ms` | int | Time before dismissal |

---

## User Properties

User properties are set once and persist across sessions.

| Property Name | Description | Example Value |
|---------------|-------------|---------------|
| `total_quizzes_taken` | Total quizzes completed | "50" |
| `total_correct_answers` | Total correct answers | "1000" |
| `average_score` | Average quiz score | "75.5" |
| `best_streak` | Longest answer streak | "15" |
| `achievements_unlocked` | Unlocked achievement count | "10" |
| `total_points` | Total achievement points | "500" |
| `favorite_category` | Most played category | "europe" |
| `preferred_quiz_mode` | Most used quiz mode | "standard" |
| `sound_effects_enabled` | Sound setting | "true" |
| `haptic_feedback_enabled` | Haptic setting | "true" |
| `is_premium_user` | Premium status | "false" |
| `app_version` | Current app version | "1.0.0" |
| `first_open_date` | First app open date | "2024-01-15" |
| `days_active` | Days app has been used | "30" |

### Usage
```dart
await analytics.setUserProperty(
  name: AnalyticsUserProperties.totalQuizzesTaken,
  value: '50',
);
```

---

## Implementation Guide

### Basic Usage

```dart
import 'package:shared_services/shared_services.dart';

// Initialize analytics
final analytics = FirebaseAnalyticsService();
await analytics.initialize();

// Log a quiz started event
await analytics.logEvent(QuizEvent.started(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  categoryId: 'europe',
  categoryName: 'Europe',
  mode: 'standard',
  totalQuestions: 20,
));

// Track screen view
await analytics.setCurrentScreen(
  screenName: 'quiz',
  screenClass: 'QuizScreen',
);
await analytics.logEvent(ScreenViewEvent.quiz(
  quizId: 'quiz-123',
  quizName: 'European Flags',
  mode: 'standard',
  totalQuestions: 20,
));
```

### Using Composite Analytics

```dart
final analytics = CompositeAnalyticsService(
  providers: [
    AnalyticsProviderConfig(
      provider: FirebaseAnalyticsService(),
      name: 'Firebase',
    ),
    AnalyticsProviderConfig(
      provider: ConsoleAnalyticsService(),
      name: 'Console',
      enabled: kDebugMode,
    ),
  ],
);
```

### Testing with NoOpAnalyticsService

```dart
final testAnalytics = NoOpAnalyticsService();
// Events are silently dropped
await testAnalytics.logEvent(QuizEvent.started(...));
```

---

## Firebase DebugView

To verify events in Firebase DebugView:

1. Enable debug mode in your app
2. Open Firebase Console > Analytics > DebugView
3. Perform actions in the app
4. Events should appear within seconds

### Debug Mode Setup

```dart
// In your app initialization
if (kDebugMode) {
  // Events will appear in DebugView
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
}
```

---

*Generated from quiz apps analytics system. Last updated: December 2024*
