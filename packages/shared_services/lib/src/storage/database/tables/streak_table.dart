/// SQL schema definition for the streak table.
library;

/// Table name constant.
const String streakTable = 'streak';

/// SQL statement to create the streak table.
///
/// Uses singleton pattern (id = 1) since there's only one streak
/// record per user.
const String createStreakTable = '''
CREATE TABLE $streakTable (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_play_date INTEGER,
  streak_start_date INTEGER,
  total_days_played INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// SQL statement to insert the singleton row for streak data.
const String insertStreakRow = '''
INSERT OR IGNORE INTO $streakTable (
  id, current_streak, longest_streak, total_days_played, created_at, updated_at
) VALUES (1, 0, 0, 0, ?, ?)
''';

/// Column names for the streak table.
class StreakColumns {
  StreakColumns._();

  static const String id = 'id';
  static const String currentStreak = 'current_streak';
  static const String longestStreak = 'longest_streak';
  static const String lastPlayDate = 'last_play_date';
  static const String streakStartDate = 'streak_start_date';
  static const String totalDaysPlayed = 'total_days_played';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
