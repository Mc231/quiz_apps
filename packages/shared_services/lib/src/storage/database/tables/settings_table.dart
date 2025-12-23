/// SQL schema definition for the user_settings table.
library;

/// Table name constant.
const String userSettingsTable = 'user_settings';

/// SQL statement to create the user_settings table.
const String createUserSettingsTable = '''
CREATE TABLE $userSettingsTable (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  sound_enabled INTEGER DEFAULT 1,
  haptic_enabled INTEGER DEFAULT 1,
  exit_confirmation_enabled INTEGER DEFAULT 1,
  show_hints INTEGER DEFAULT 1,
  theme_mode TEXT DEFAULT 'light',
  language TEXT DEFAULT 'en',
  hints_50_50_available INTEGER DEFAULT 3,
  hints_skip_available INTEGER DEFAULT 3,
  last_played_quiz_type TEXT,
  last_played_category TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// SQL statement to insert the singleton row for user settings.
const String insertUserSettingsRow = '''
INSERT OR IGNORE INTO $userSettingsTable (
  id, created_at, updated_at
) VALUES (1, ?, ?)
''';

/// Column names for the user_settings table.
class UserSettingsColumns {
  UserSettingsColumns._();

  static const String id = 'id';
  static const String soundEnabled = 'sound_enabled';
  static const String hapticEnabled = 'haptic_enabled';
  static const String exitConfirmationEnabled = 'exit_confirmation_enabled';
  static const String showHints = 'show_hints';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String hints5050Available = 'hints_50_50_available';
  static const String hintsSkipAvailable = 'hints_skip_available';
  static const String lastPlayedQuizType = 'last_played_quiz_type';
  static const String lastPlayedCategory = 'last_played_category';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}