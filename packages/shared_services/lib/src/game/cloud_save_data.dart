import 'package:equatable/equatable.dart';

/// Current schema version for cloud save data.
///
/// Increment this when making breaking changes to the data structure.
/// Used for migrations when loading older data.
const int cloudSaveSchemaVersion = 1;

/// Data model for cloud-synced game progress.
///
/// Contains only essential progress data that should persist across devices:
/// - Achievement unlocks
/// - High scores per category
/// - Perfect quiz counts
/// - Overall statistics
///
/// Intentionally excludes:
/// - Full session history (too large, not needed across devices)
/// - Settings (device-specific preferences)
/// - Current streak (depends on local timezone/dates)
class CloudSaveData extends Equatable {
  const CloudSaveData({
    required this.version,
    required this.lastModified,
    required this.unlockedAchievementIds,
    required this.highScores,
    required this.perfectCounts,
    required this.totalQuizzesCompleted,
    required this.longestStreak,
  });

  /// Creates an empty CloudSaveData with default values.
  factory CloudSaveData.empty() => CloudSaveData(
        version: cloudSaveSchemaVersion,
        lastModified: DateTime.now(),
        unlockedAchievementIds: const {},
        highScores: const {},
        perfectCounts: const {},
        totalQuizzesCompleted: 0,
        longestStreak: 0,
      );

  /// Creates CloudSaveData from JSON map.
  ///
  /// Handles missing fields gracefully for forward compatibility.
  factory CloudSaveData.fromJson(Map<String, dynamic> json) {
    return CloudSaveData(
      version: json['version'] as int? ?? cloudSaveSchemaVersion,
      lastModified: json['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastModified'] as int)
          : DateTime.now(),
      unlockedAchievementIds: json['unlockedAchievementIds'] != null
          ? Set<String>.from(json['unlockedAchievementIds'] as List)
          : const {},
      highScores: json['highScores'] != null
          ? Map<String, int>.from(json['highScores'] as Map)
          : const {},
      perfectCounts: json['perfectCounts'] != null
          ? Map<String, int>.from(json['perfectCounts'] as Map)
          : const {},
      totalQuizzesCompleted: json['totalQuizzesCompleted'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  /// Schema version for data migration support.
  final int version;

  /// Last modification timestamp (UTC).
  ///
  /// Used for conflict resolution - more recent data takes precedence
  /// for non-mergeable fields.
  final DateTime lastModified;

  /// Set of unlocked achievement IDs.
  ///
  /// Merged using union - achievements are never lost.
  final Set<String> unlockedAchievementIds;

  /// Best scores per category.
  ///
  /// Key: category ID, Value: highest score achieved.
  /// Merged by taking the maximum score for each category.
  final Map<String, int> highScores;

  /// Perfect quiz counts per category.
  ///
  /// Key: category ID, Value: number of perfect quizzes.
  /// Merged by taking the maximum count for each category.
  final Map<String, int> perfectCounts;

  /// Total number of quizzes completed across all time.
  ///
  /// Merged by taking the maximum value.
  final int totalQuizzesCompleted;

  /// Longest streak ever achieved.
  ///
  /// Note: This is the historical record, NOT the current streak.
  /// Current streak is not synced because it depends on local dates.
  /// Merged by taking the maximum value.
  final int longestStreak;

  /// Converts to JSON map for serialization.
  Map<String, dynamic> toJson() => {
        'version': version,
        'lastModified': lastModified.millisecondsSinceEpoch,
        'unlockedAchievementIds': unlockedAchievementIds.toList(),
        'highScores': highScores,
        'perfectCounts': perfectCounts,
        'totalQuizzesCompleted': totalQuizzesCompleted,
        'longestStreak': longestStreak,
      };

  /// Creates a copy with updated fields.
  CloudSaveData copyWith({
    int? version,
    DateTime? lastModified,
    Set<String>? unlockedAchievementIds,
    Map<String, int>? highScores,
    Map<String, int>? perfectCounts,
    int? totalQuizzesCompleted,
    int? longestStreak,
  }) {
    return CloudSaveData(
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      highScores: highScores ?? this.highScores,
      perfectCounts: perfectCounts ?? this.perfectCounts,
      totalQuizzesCompleted:
          totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  /// Returns true if this save data has any progress.
  bool get hasProgress =>
      unlockedAchievementIds.isNotEmpty ||
      highScores.isNotEmpty ||
      perfectCounts.isNotEmpty ||
      totalQuizzesCompleted > 0 ||
      longestStreak > 0;

  /// Returns the total number of achievements unlocked.
  int get achievementCount => unlockedAchievementIds.length;

  /// Returns the total number of categories with high scores.
  int get categoriesPlayed => highScores.length;

  /// Returns the total number of perfect quizzes across all categories.
  int get totalPerfectQuizzes =>
      perfectCounts.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [
        version,
        lastModified,
        unlockedAchievementIds,
        highScores,
        perfectCounts,
        totalQuizzesCompleted,
        longestStreak,
      ];

  @override
  String toString() => 'CloudSaveData('
      'version: $version, '
      'achievements: ${unlockedAchievementIds.length}, '
      'categories: ${highScores.length}, '
      'quizzes: $totalQuizzesCompleted, '
      'longestStreak: $longestStreak)';
}
