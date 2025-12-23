/// SQL schema definition for the daily_statistics table.
library;

/// Table name constant.
const String dailyStatisticsTable = 'daily_statistics';

/// SQL statement to create the daily_statistics table.
const String createDailyStatisticsTable = '''
CREATE TABLE $dailyStatisticsTable (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL UNIQUE,
  sessions_played INTEGER DEFAULT 0,
  sessions_completed INTEGER DEFAULT 0,
  sessions_cancelled INTEGER DEFAULT 0,
  questions_answered INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  incorrect_answers INTEGER DEFAULT 0,
  skipped_answers INTEGER DEFAULT 0,
  time_played_seconds INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  perfect_scores INTEGER DEFAULT 0,
  hints_50_50_used INTEGER DEFAULT 0,
  hints_skip_used INTEGER DEFAULT 0,
  lives_used INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// SQL statements to create indexes for the daily_statistics table.
const List<String> createDailyStatisticsIndexes = [
  'CREATE INDEX idx_daily_date ON $dailyStatisticsTable(date DESC)',
];

/// Column names for the daily_statistics table.
class DailyStatisticsColumns {
  DailyStatisticsColumns._();

  static const String id = 'id';
  static const String date = 'date';
  static const String sessionsPlayed = 'sessions_played';
  static const String sessionsCompleted = 'sessions_completed';
  static const String sessionsCancelled = 'sessions_cancelled';
  static const String questionsAnswered = 'questions_answered';
  static const String correctAnswers = 'correct_answers';
  static const String incorrectAnswers = 'incorrect_answers';
  static const String skippedAnswers = 'skipped_answers';
  static const String timePlayedSeconds = 'time_played_seconds';
  static const String averageScorePercentage = 'average_score_percentage';
  static const String bestScorePercentage = 'best_score_percentage';
  static const String perfectScores = 'perfect_scores';
  static const String hints5050Used = 'hints_50_50_used';
  static const String hintsSkipUsed = 'hints_skip_used';
  static const String livesUsed = 'lives_used';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}