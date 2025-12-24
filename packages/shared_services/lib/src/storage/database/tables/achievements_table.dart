/// SQL schema definition for the unlocked_achievements table.
library;

/// Table name constant.
const String unlockedAchievementsTable = 'unlocked_achievements';

/// SQL statement to create the unlocked_achievements table.
///
/// This table stores only unlocked achievements.
/// Achievement definitions (name, description, trigger, etc.) are kept in code.
/// Progress is computed from statistics when needed.
const String createUnlockedAchievementsTable = '''
CREATE TABLE $unlockedAchievementsTable (
  id TEXT PRIMARY KEY,
  achievement_id TEXT NOT NULL UNIQUE,
  unlocked_at INTEGER NOT NULL,
  progress INTEGER DEFAULT 0,
  notified INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
)
''';

/// SQL statements to create indexes for the unlocked_achievements table.
const List<String> createUnlockedAchievementsIndexes = [
  'CREATE INDEX idx_achievements_achievement_id ON $unlockedAchievementsTable(achievement_id)',
  'CREATE INDEX idx_achievements_unlocked_at ON $unlockedAchievementsTable(unlocked_at DESC)',
  'CREATE INDEX idx_achievements_notified ON $unlockedAchievementsTable(notified)',
];

/// Column names for the unlocked_achievements table.
class UnlockedAchievementsColumns {
  UnlockedAchievementsColumns._();

  static const String id = 'id';
  static const String achievementId = 'achievement_id';
  static const String unlockedAt = 'unlocked_at';
  static const String progress = 'progress';
  static const String notified = 'notified';
  static const String createdAt = 'created_at';
}