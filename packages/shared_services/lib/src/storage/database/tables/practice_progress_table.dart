/// SQL schema definition for the practice_progress table.
library;

/// Table name constant.
const String practiceProgressTable = 'practice_progress';

/// SQL statement to create the practice_progress table.
///
/// This table tracks questions that users got wrong and need to practice.
/// Each row represents a unique question that was answered incorrectly.
///
/// Key features:
/// - question_id is the primary key (one row per unique question)
/// - wrong_count tracks how many times the question was answered incorrectly
/// - first_wrong_at tracks when the user first got this question wrong
/// - last_wrong_at tracks the most recent incorrect answer
/// - last_practiced_correctly_at tracks when the question was last practiced correctly
///
/// A question needs practice when:
/// - last_practiced_correctly_at IS NULL, OR
/// - last_wrong_at > last_practiced_correctly_at
const String createPracticeProgressTable = '''
CREATE TABLE $practiceProgressTable (
  question_id TEXT PRIMARY KEY,
  wrong_count INTEGER NOT NULL DEFAULT 1,
  first_wrong_at INTEGER NOT NULL,
  last_wrong_at INTEGER NOT NULL,
  last_practiced_correctly_at INTEGER
)
''';

/// SQL statements to create indexes for the practice_progress table.
const List<String> createPracticeProgressIndexes = [
  // Index for finding questions that need practice
  'CREATE INDEX idx_practice_needs_practice ON $practiceProgressTable(last_wrong_at, last_practiced_correctly_at)',
  // Index for sorting by wrong count
  'CREATE INDEX idx_practice_wrong_count ON $practiceProgressTable(wrong_count DESC)',
];

/// Column names for the practice_progress table.
class PracticeProgressColumns {
  PracticeProgressColumns._();

  /// Unique question identifier (e.g., "ua" for Ukraine flag).
  static const String questionId = 'question_id';

  /// Number of times this question was answered incorrectly.
  static const String wrongCount = 'wrong_count';

  /// Timestamp when the user first got this question wrong (seconds since epoch).
  static const String firstWrongAt = 'first_wrong_at';

  /// Timestamp when the user most recently got this question wrong (seconds since epoch).
  static const String lastWrongAt = 'last_wrong_at';

  /// Timestamp when the question was last practiced correctly (seconds since epoch).
  /// NULL if never practiced correctly.
  static const String lastPracticedCorrectlyAt = 'last_practiced_correctly_at';
}
