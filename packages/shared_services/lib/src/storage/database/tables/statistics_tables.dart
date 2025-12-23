/// SQL schema definitions for statistics tables.
library;

import 'quiz_sessions_table.dart';

// =============================================================================
// Global Statistics Table
// =============================================================================

/// Table name constant for global statistics.
const String globalStatisticsTable = 'global_statistics';

/// SQL statement to create the global_statistics table.
const String createGlobalStatisticsTable = '''
CREATE TABLE $globalStatisticsTable (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  total_sessions INTEGER DEFAULT 0,
  total_completed_sessions INTEGER DEFAULT 0,
  total_cancelled_sessions INTEGER DEFAULT 0,
  total_questions_answered INTEGER DEFAULT 0,
  total_correct_answers INTEGER DEFAULT 0,
  total_incorrect_answers INTEGER DEFAULT 0,
  total_skipped_questions INTEGER DEFAULT 0,
  total_time_played_seconds INTEGER DEFAULT 0,
  total_hints_50_50_used INTEGER DEFAULT 0,
  total_hints_skip_used INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  worst_score_percentage REAL DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  total_perfect_scores INTEGER DEFAULT 0,
  first_session_date INTEGER,
  last_session_date INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// SQL statement to insert the singleton row for global statistics.
const String insertGlobalStatisticsRow = '''
INSERT OR IGNORE INTO $globalStatisticsTable (
  id, created_at, updated_at
) VALUES (1, ?, ?)
''';

/// Column names for the global_statistics table.
class GlobalStatisticsColumns {
  GlobalStatisticsColumns._();

  static const String id = 'id';
  static const String totalSessions = 'total_sessions';
  static const String totalCompletedSessions = 'total_completed_sessions';
  static const String totalCancelledSessions = 'total_cancelled_sessions';
  static const String totalQuestionsAnswered = 'total_questions_answered';
  static const String totalCorrectAnswers = 'total_correct_answers';
  static const String totalIncorrectAnswers = 'total_incorrect_answers';
  static const String totalSkippedQuestions = 'total_skipped_questions';
  static const String totalTimePlayedSeconds = 'total_time_played_seconds';
  static const String totalHints5050Used = 'total_hints_50_50_used';
  static const String totalHintsSkipUsed = 'total_hints_skip_used';
  static const String averageScorePercentage = 'average_score_percentage';
  static const String bestScorePercentage = 'best_score_percentage';
  static const String worstScorePercentage = 'worst_score_percentage';
  static const String currentStreak = 'current_streak';
  static const String bestStreak = 'best_streak';
  static const String totalPerfectScores = 'total_perfect_scores';
  static const String firstSessionDate = 'first_session_date';
  static const String lastSessionDate = 'last_session_date';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

// =============================================================================
// Quiz Type Statistics Table
// =============================================================================

/// Table name constant for quiz type statistics.
const String quizTypeStatisticsTable = 'quiz_type_statistics';

/// SQL statement to create the quiz_type_statistics table.
const String createQuizTypeStatisticsTable = '''
CREATE TABLE $quizTypeStatisticsTable (
  id TEXT PRIMARY KEY,
  quiz_type TEXT NOT NULL,
  quiz_category TEXT,
  total_sessions INTEGER DEFAULT 0,
  total_completed_sessions INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  total_correct INTEGER DEFAULT 0,
  total_incorrect INTEGER DEFAULT 0,
  total_skipped INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  best_session_id TEXT,
  total_time_played_seconds INTEGER DEFAULT 0,
  average_time_per_question REAL DEFAULT 0,
  total_perfect_scores INTEGER DEFAULT 0,
  last_played_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (best_session_id) REFERENCES $quizSessionsTable(id) ON DELETE SET NULL,
  UNIQUE(quiz_type, quiz_category)
)
''';

/// SQL statements to create indexes for the quiz_type_statistics table.
const List<String> createQuizTypeStatisticsIndexes = [
  'CREATE INDEX idx_type_stats_type ON $quizTypeStatisticsTable(quiz_type)',
  'CREATE INDEX idx_type_stats_category ON $quizTypeStatisticsTable(quiz_category)',
  'CREATE INDEX idx_type_stats_composite ON $quizTypeStatisticsTable(quiz_type, quiz_category)',
];

/// Column names for the quiz_type_statistics table.
class QuizTypeStatisticsColumns {
  QuizTypeStatisticsColumns._();

  static const String id = 'id';
  static const String quizType = 'quiz_type';
  static const String quizCategory = 'quiz_category';
  static const String totalSessions = 'total_sessions';
  static const String totalCompletedSessions = 'total_completed_sessions';
  static const String totalQuestions = 'total_questions';
  static const String totalCorrect = 'total_correct';
  static const String totalIncorrect = 'total_incorrect';
  static const String totalSkipped = 'total_skipped';
  static const String averageScorePercentage = 'average_score_percentage';
  static const String bestScorePercentage = 'best_score_percentage';
  static const String bestSessionId = 'best_session_id';
  static const String totalTimePlayedSeconds = 'total_time_played_seconds';
  static const String averageTimePerQuestion = 'average_time_per_question';
  static const String totalPerfectScores = 'total_perfect_scores';
  static const String lastPlayedAt = 'last_played_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}