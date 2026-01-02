/// Database configuration constants for the quiz app storage.
library;

/// Configuration for the SQLite database.
class DatabaseConfig {
  DatabaseConfig._();

  /// The name of the database file.
  static const String databaseName = 'quiz_app.db';

  /// Current database schema version.
  /// Increment this when making schema changes.
  static const int currentVersion = 9;

  /// Minimum supported database version for migrations.
  static const int minimumVersion = 1;

  /// Enable foreign key constraints.
  static const bool enableForeignKeys = true;

  /// Enable WAL mode for better concurrent read performance.
  static const bool enableWalMode = true;

  /// Default page size for pagination.
  static const int defaultPageSize = 50;

  /// Maximum page size for pagination.
  static const int maxPageSize = 100;
}