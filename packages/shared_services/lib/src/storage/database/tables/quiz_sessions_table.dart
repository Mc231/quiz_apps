/// SQL schema definition for the quiz_sessions table.
library;

/// Table name constant.
const String quizSessionsTable = 'quiz_sessions';

/// SQL statement to create the quiz_sessions table.
const String createQuizSessionsTable = '''
CREATE TABLE $quizSessionsTable (
  id TEXT PRIMARY KEY,
  quiz_name TEXT NOT NULL,
  quiz_id TEXT NOT NULL,
  quiz_type TEXT NOT NULL,
  quiz_category TEXT,
  total_questions INTEGER NOT NULL,
  total_answered INTEGER NOT NULL,
  total_correct INTEGER NOT NULL,
  total_failed INTEGER NOT NULL,
  total_skipped INTEGER NOT NULL,
  score_percentage REAL NOT NULL,
  lives_used INTEGER DEFAULT 0,
  start_time INTEGER NOT NULL,
  end_time INTEGER,
  duration_seconds INTEGER,
  completion_status TEXT NOT NULL,
  mode TEXT NOT NULL,
  time_limit_seconds INTEGER,
  hints_used_50_50 INTEGER DEFAULT 0,
  hints_used_skip INTEGER DEFAULT 0,
  app_version TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// SQL statements to create indexes for the quiz_sessions table.
const List<String> createQuizSessionsIndexes = [
  'CREATE INDEX idx_sessions_quiz_type ON $quizSessionsTable(quiz_type)',
  'CREATE INDEX idx_sessions_category ON $quizSessionsTable(quiz_category)',
  'CREATE INDEX idx_sessions_completion ON $quizSessionsTable(completion_status)',
  'CREATE INDEX idx_sessions_start_time ON $quizSessionsTable(start_time DESC)',
  'CREATE INDEX idx_sessions_quiz_id ON $quizSessionsTable(quiz_id)',
  'CREATE INDEX idx_sessions_mode ON $quizSessionsTable(mode)',
];

/// Column names for the quiz_sessions table.
class QuizSessionsColumns {
  QuizSessionsColumns._();

  static const String id = 'id';
  static const String quizName = 'quiz_name';
  static const String quizId = 'quiz_id';
  static const String quizType = 'quiz_type';
  static const String quizCategory = 'quiz_category';
  static const String totalQuestions = 'total_questions';
  static const String totalAnswered = 'total_answered';
  static const String totalCorrect = 'total_correct';
  static const String totalFailed = 'total_failed';
  static const String totalSkipped = 'total_skipped';
  static const String scorePercentage = 'score_percentage';
  static const String livesUsed = 'lives_used';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String durationSeconds = 'duration_seconds';
  static const String completionStatus = 'completion_status';
  static const String mode = 'mode';
  static const String timeLimitSeconds = 'time_limit_seconds';
  static const String hintsUsed5050 = 'hints_used_50_50';
  static const String hintsUsedSkip = 'hints_used_skip';
  static const String appVersion = 'app_version';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}