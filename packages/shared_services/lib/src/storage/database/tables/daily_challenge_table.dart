/// SQL schema definition for daily challenge tables.
library;

// ===========================================================================
// Daily Challenges Table
// ===========================================================================

/// Table name for daily challenges.
const String dailyChallengesTable = 'daily_challenges';

/// SQL statement to create the daily challenges table.
const String createDailyChallengesTable = '''
CREATE TABLE $dailyChallengesTable (
  id TEXT PRIMARY KEY,
  date INTEGER NOT NULL,
  category_id TEXT NOT NULL,
  question_count INTEGER NOT NULL,
  time_limit_seconds INTEGER,
  seed INTEGER NOT NULL,
  created_at INTEGER NOT NULL
)
''';

/// SQL statement to create index on date for quick lookups.
const String createDailyChallengesDateIndex = '''
CREATE INDEX idx_daily_challenges_date ON $dailyChallengesTable (date)
''';

/// Column names for the daily challenges table.
class DailyChallengesColumns {
  DailyChallengesColumns._();

  static const String id = 'id';
  static const String date = 'date';
  static const String categoryId = 'category_id';
  static const String questionCount = 'question_count';
  static const String timeLimitSeconds = 'time_limit_seconds';
  static const String seed = 'seed';
  static const String createdAt = 'created_at';
}

// ===========================================================================
// Daily Challenge Results Table
// ===========================================================================

/// Table name for daily challenge results.
const String dailyChallengeResultsTable = 'daily_challenge_results';

/// SQL statement to create the daily challenge results table.
const String createDailyChallengeResultsTable = '''
CREATE TABLE $dailyChallengeResultsTable (
  id TEXT PRIMARY KEY,
  challenge_id TEXT NOT NULL,
  score INTEGER NOT NULL,
  correct_count INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  completion_time_seconds INTEGER NOT NULL,
  completed_at INTEGER NOT NULL,
  streak_bonus INTEGER NOT NULL DEFAULT 0,
  time_bonus INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (challenge_id) REFERENCES $dailyChallengesTable (id)
    ON DELETE CASCADE
)
''';

/// SQL statement to create index on challenge_id for quick lookups.
const String createDailyChallengeResultsChallengeIndex = '''
CREATE INDEX idx_daily_challenge_results_challenge
ON $dailyChallengeResultsTable (challenge_id)
''';

/// SQL statement to create index on completed_at for history queries.
const String createDailyChallengeResultsCompletedAtIndex = '''
CREATE INDEX idx_daily_challenge_results_completed_at
ON $dailyChallengeResultsTable (completed_at DESC)
''';

/// Column names for the daily challenge results table.
class DailyChallengeResultsColumns {
  DailyChallengeResultsColumns._();

  static const String id = 'id';
  static const String challengeId = 'challenge_id';
  static const String score = 'score';
  static const String correctCount = 'correct_count';
  static const String totalQuestions = 'total_questions';
  static const String completionTimeSeconds = 'completion_time_seconds';
  static const String completedAt = 'completed_at';
  static const String streakBonus = 'streak_bonus';
  static const String timeBonus = 'time_bonus';
}
