# Practice Mistakes Mode - Design Document

## Overview

Practice Mistakes Mode allows users to review and practice questions they answered incorrectly in previous quizzes. The feature helps users learn from their mistakes and improve their knowledge over time.

## Core Behavior

1. **Load wrong answers from ALL sessions** (no session limit for simplicity and completeness)
2. **Deduplicate by question ID** - same question wrong multiple times appears once
3. **Track wrong count** - show how many times each question was answered incorrectly
4. **Clear only after practice session completes** - not during the session
5. **Only clear correctly answered questions** - wrong answers during practice stay in list
6. **Practice sessions are NOT stored** - they don't appear in history
7. **Practice has NO influence on achievements** - completely separate from achievement system

---

## Data Model

### PracticeQuestion

Represents a question that needs practice, aggregated from wrong answers.

```dart
/// A question that the user got wrong and needs to practice.
class PracticeQuestion {
  /// Unique question identifier (e.g., "ua" for Ukraine flag)
  final String questionId;

  /// Number of times this question was answered incorrectly
  final int wrongCount;

  /// First time the user got this question wrong
  final DateTime firstWrongAt;

  /// Most recent time the user got this question wrong
  final DateTime lastWrongAt;

  /// When this question was last practiced correctly (null = needs practice)
  final DateTime? lastPracticedCorrectlyAt;

  /// Whether this question currently needs practice
  bool get needsPractice {
    if (lastPracticedCorrectlyAt == null) return true;
    return lastWrongAt.isAfter(lastPracticedCorrectlyAt!);
  }
}
```

### Database Table: `practice_progress`

```sql
CREATE TABLE practice_progress (
  question_id TEXT PRIMARY KEY,
  wrong_count INTEGER NOT NULL DEFAULT 1,
  first_wrong_at INTEGER NOT NULL,
  last_wrong_at INTEGER NOT NULL,
  last_practiced_correctly_at INTEGER NULL
);
```

---

## PracticeDataProvider Interface

Following the pattern established by `AchievementsDataProvider`, we create a similar interface for practice functionality.

```dart
/// Interface for loading and managing practice data.
///
/// Implementations should handle:
/// - Loading questions that need practice
/// - Marking questions as practiced correctly
/// - Converting practice questions to quiz format
abstract interface class PracticeDataProvider {
  /// Loads all questions that need practice.
  ///
  /// Returns questions where:
  /// - User answered incorrectly at least once
  /// - Either never practiced, or got wrong again after last practice
  Future<List<PracticeQuestion>> loadPracticeQuestions();

  /// Called when a practice session completes.
  ///
  /// [correctlyAnsweredIds] - question IDs that were answered correctly
  /// during this practice session. These will be marked as practiced.
  Future<void> onPracticeSessionCompleted(List<String> correctlyAnsweredIds);

  /// Converts practice questions to a format suitable for quiz.
  ///
  /// This is app-specific - for flags quiz, converts to country questions.
  Future<List<Question>> convertToQuestions(List<PracticeQuestion> questions);
}
```

---

## Edge Cases

### 1. Same question answered wrong in multiple sessions
- **Behavior:** Appears once in practice list
- **Implementation:** Group by `questionId`, aggregate `wrongCount`
- **Display:** Show "Wrong 3 times" badge

### 2. Question was correct before, wrong later
- **Behavior:** Appears in practice list
- **Implementation:** Any wrong answer triggers inclusion
- **Logic:** `WHERE isCorrect = false` finds it regardless of previous correct answers

### 3. Practiced correctly, then wrong again in regular quiz
- **Behavior:** Reappears in practice list
- **Implementation:** Compare `lastWrongAt` with `lastPracticedCorrectlyAt`
- **Query:** `WHERE lastWrongAt > COALESCE(lastPracticedCorrectlyAt, 0)`

### 4. Practice session cancelled/abandoned
- **Behavior:** Nothing is marked as practiced
- **Implementation:** Only update on `QuizStatus.completed`
- **Effect:** Same questions appear next time

### 5. No wrong answers to practice
- **Behavior:** Show empty state with encouraging message
- **UI:** "No questions to practice. Keep playing!"
- **Tab:** Practice tab remains visible (not hidden)

### 6. Session deleted by user
- **Behavior:** Associated wrong answers removed from practice list
- **Implementation:** Recalculate `practice_progress` or use cascading delete
- **Note:** May need to rebuild aggregates if using denormalized table

### 7. Wrong during practice session
- **Behavior:** Question stays in practice list
- **Implementation:** Only `correctlyAnsweredIds` are marked as practiced
- **Update:** Optionally increment `wrongCount` (tracks practice attempts too)

### 8. Practice sessions storage
- **Behavior:** Practice sessions are NOT stored in history
- **Implementation:** Set `storageEnabled: false` in quiz config for practice mode
- **Reason:** Keeps history clean, practice is ephemeral

### 9. Achievements in practice mode
- **Behavior:** Practice sessions do NOT count toward achievements
- **Implementation:** Skip achievement processing for practice sessions
- **Logic:** Check session type before calling `onSessionCompleted`

### 10. Question removed from app
- **Behavior:** Orphaned practice entries are ignored
- **Implementation:** Join with current question bank when loading
- **Cleanup:** Optionally purge orphaned entries periodically

---

## Implementation Architecture

### Flow Diagram

```
User taps Practice tab
        │
        ▼
QuizApp calls PracticeDataProvider.loadPracticeQuestions()
        │
        ▼
Provider queries practice_progress table
        │
        ▼
Filter: lastWrongAt > lastPracticedCorrectlyAt OR lastPracticedCorrectlyAt IS NULL
        │
        ▼
Convert to Questions via convertToQuestions()
        │
        ▼
Display quiz (storageEnabled: false, achievementsEnabled: false)
        │
        ▼
User completes practice session
        │
        ▼
QuizApp collects correctly answered question IDs
        │
        ▼
QuizApp calls PracticeDataProvider.onPracticeSessionCompleted(correctIds)
        │
        ▼
Provider updates practice_progress: SET lastPracticedCorrectlyAt = NOW()
        │
        ▼
Next practice load excludes those questions (until answered wrong again)
```

### Updating practice_progress

When a regular quiz session completes:

```dart
Future<void> updatePracticeProgress(QuizSession session) async {
  final wrongAnswers = session.answers.where((a) => !a.isCorrect);

  for (final answer in wrongAnswers) {
    await db.execute('''
      INSERT INTO practice_progress (question_id, wrong_count, first_wrong_at, last_wrong_at)
      VALUES (?, 1, ?, ?)
      ON CONFLICT(question_id) DO UPDATE SET
        wrong_count = wrong_count + 1,
        last_wrong_at = ?
    ''', [answer.questionId, now, now, now]);
  }
}
```

---

## UI Requirements

### Practice Tab (in Play screen)

- **Icon:** `Icons.school` (already defined)
- **Label:** "Practice" (localized)
- **Badge:** Show count of questions needing practice (optional)

### Practice Empty State

```
┌─────────────────────────────────────┐
│                                     │
│           🎯                        │
│                                     │
│   No questions to practice          │
│                                     │
│   Great job! You've mastered all    │
│   the questions you got wrong.      │
│   Keep playing to challenge         │
│   yourself!                         │
│                                     │
│      [ Start a Quiz ]               │
│                                     │
└─────────────────────────────────────┘
```

### Practice Question Card (before starting)

```
┌─────────────────────────────────────┐
│  Practice Mode                      │
│                                     │
│  12 questions to practice           │
│                                     │
│  These are questions you've         │
│  answered incorrectly before.       │
│                                     │
│      [ Start Practice ]             │
│                                     │
└─────────────────────────────────────┘
```

### During Practice

- Same UI as regular quiz
- No timer pressure (optional: could add relaxed mode)
- No score display
- Show "Practice" in header/title

### Practice Complete

```
┌─────────────────────────────────────┐
│  Practice Complete!                 │
│                                     │
│  ✓ 8 correct                        │
│  ✗ 4 need more practice             │
│                                     │
│  Keep practicing to master          │
│  all the questions!                 │
│                                     │
│      [ Done ]                       │
│                                     │
└─────────────────────────────────────┘
```

---

## Localization Strings

```json
{
  "practiceMode": "Practice",
  "practiceEmptyTitle": "No questions to practice",
  "practiceEmptyMessage": "Great job! You've mastered all the questions you got wrong. Keep playing to challenge yourself!",
  "practiceStartTitle": "Practice Mode",
  "practiceQuestionCount": "{count} questions to practice",
  "practiceDescription": "These are questions you've answered incorrectly before.",
  "startPractice": "Start Practice",
  "practiceComplete": "Practice Complete!",
  "practiceCorrectCount": "{count} correct",
  "practiceNeedMorePractice": "{count} need more practice",
  "practiceKeepGoing": "Keep practicing to master all the questions!",
  "wrongCount": "Wrong {count} times"
}
```

---

## Configuration

Practice mode should use specific quiz configuration:

```dart
QuizConfig.practice(
  modeConfig: QuizModeConfig.endless(), // No lives limit
  storageConfig: StorageConfig.disabled(), // Don't save to history
  hintsConfig: HintsConfig.disabled(), // No hints in practice
  // No timer, no scoring
)
```

---

## Testing Strategy

### Unit Tests
- `PracticeDataProvider.loadPracticeQuestions()` returns correct questions
- `onPracticeSessionCompleted()` updates progress correctly
- Edge case: question wrong after being practiced
- Edge case: no wrong answers
- Edge case: session deleted

### Widget Tests
- Empty state displays correctly
- Practice start screen shows count
- Practice complete screen shows results

### Integration Tests
- Full flow: wrong answer → practice → correct → removed from list
- Full flow: wrong answer → practice → wrong again → stays in list
- Practice session not appearing in history
- Achievements not triggered by practice

---

## Future Enhancements (Out of Scope)

1. **Spaced Repetition:** Smart scheduling based on forgetting curve
2. **Difficulty Tracking:** Track which questions are hardest
3. **Practice Achievements:** Separate achievement category for practice
4. **Practice Streaks:** Track daily practice habits
5. **Practice Reminders:** Notify user when they have questions to practice
