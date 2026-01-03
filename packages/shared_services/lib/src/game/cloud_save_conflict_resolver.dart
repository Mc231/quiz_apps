import 'dart:math' as math;

import 'cloud_save_data.dart';

/// Resolves conflicts between local and remote cloud save data.
///
/// Merge strategy:
/// - Achievements: Union (never lose an unlocked achievement)
/// - High scores: Take maximum per category
/// - Perfect counts: Take maximum per category
/// - Total quizzes: Take maximum
/// - Longest streak: Take maximum
///
/// This ensures no progress is ever lost during sync.
class CloudSaveConflictResolver {
  const CloudSaveConflictResolver();

  /// Merges local and remote data, preserving best progress from both.
  ///
  /// Returns a new [CloudSaveData] containing the merged result.
  CloudSaveData resolve(CloudSaveData local, CloudSaveData remote) {
    return CloudSaveData(
      version: _resolveVersion(local.version, remote.version),
      lastModified: DateTime.now(),
      unlockedAchievementIds:
          _mergeAchievements(local.unlockedAchievementIds, remote.unlockedAchievementIds),
      highScores: _mergeScores(local.highScores, remote.highScores),
      perfectCounts: _mergeCounts(local.perfectCounts, remote.perfectCounts),
      totalQuizzesCompleted:
          math.max(local.totalQuizzesCompleted, remote.totalQuizzesCompleted),
      longestStreak: math.max(local.longestStreak, remote.longestStreak),
    );
  }

  /// Resolves version by taking the higher version.
  ///
  /// This ensures we use the latest schema version.
  int _resolveVersion(int localVersion, int remoteVersion) {
    return math.max(localVersion, remoteVersion);
  }

  /// Merges achievements using union - never lose an unlocked achievement.
  Set<String> _mergeAchievements(
    Set<String> localAchievements,
    Set<String> remoteAchievements,
  ) {
    return {...localAchievements, ...remoteAchievements};
  }

  /// Merges high scores by taking the maximum for each category.
  Map<String, int> _mergeScores(
    Map<String, int> localScores,
    Map<String, int> remoteScores,
  ) {
    final merged = <String, int>{};

    // Add all categories from both maps
    final allCategories = {...localScores.keys, ...remoteScores.keys};

    for (final category in allCategories) {
      final localScore = localScores[category] ?? 0;
      final remoteScore = remoteScores[category] ?? 0;
      merged[category] = math.max(localScore, remoteScore);
    }

    return merged;
  }

  /// Merges perfect counts by taking the maximum for each category.
  Map<String, int> _mergeCounts(
    Map<String, int> localCounts,
    Map<String, int> remoteCounts,
  ) {
    final merged = <String, int>{};

    // Add all categories from both maps
    final allCategories = {...localCounts.keys, ...remoteCounts.keys};

    for (final category in allCategories) {
      final localCount = localCounts[category] ?? 0;
      final remoteCount = remoteCounts[category] ?? 0;
      merged[category] = math.max(localCount, remoteCount);
    }

    return merged;
  }

  /// Checks if two CloudSaveData instances have conflicts.
  ///
  /// Returns true if any field differs between local and remote.
  bool hasConflicts(CloudSaveData local, CloudSaveData remote) {
    // Check achievements
    if (!_setsEqual(
        local.unlockedAchievementIds, remote.unlockedAchievementIds)) {
      return true;
    }

    // Check high scores
    if (!_mapsEqual(local.highScores, remote.highScores)) {
      return true;
    }

    // Check perfect counts
    if (!_mapsEqual(local.perfectCounts, remote.perfectCounts)) {
      return true;
    }

    // Check totals
    if (local.totalQuizzesCompleted != remote.totalQuizzesCompleted) {
      return true;
    }

    if (local.longestStreak != remote.longestStreak) {
      return true;
    }

    return false;
  }

  /// Checks if two sets are equal.
  bool _setsEqual<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  /// Checks if two maps are equal.
  bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  /// Creates a diff summary between local and remote data.
  ///
  /// Useful for logging or debugging sync operations.
  CloudSaveDiff diff(CloudSaveData local, CloudSaveData remote) {
    final newLocalAchievements =
        local.unlockedAchievementIds.difference(remote.unlockedAchievementIds);
    final newRemoteAchievements =
        remote.unlockedAchievementIds.difference(local.unlockedAchievementIds);

    final localBetterScores = <String>[];
    final remoteBetterScores = <String>[];
    final allCategories = {...local.highScores.keys, ...remote.highScores.keys};
    for (final category in allCategories) {
      final localScore = local.highScores[category] ?? 0;
      final remoteScore = remote.highScores[category] ?? 0;
      if (localScore > remoteScore) {
        localBetterScores.add(category);
      } else if (remoteScore > localScore) {
        remoteBetterScores.add(category);
      }
    }

    return CloudSaveDiff(
      newLocalAchievements: newLocalAchievements,
      newRemoteAchievements: newRemoteAchievements,
      localBetterScoreCategories: localBetterScores,
      remoteBetterScoreCategories: remoteBetterScores,
      localQuizzesCompleted: local.totalQuizzesCompleted,
      remoteQuizzesCompleted: remote.totalQuizzesCompleted,
      localLongestStreak: local.longestStreak,
      remoteLongestStreak: remote.longestStreak,
    );
  }
}

/// Summary of differences between local and remote cloud save data.
class CloudSaveDiff {
  const CloudSaveDiff({
    required this.newLocalAchievements,
    required this.newRemoteAchievements,
    required this.localBetterScoreCategories,
    required this.remoteBetterScoreCategories,
    required this.localQuizzesCompleted,
    required this.remoteQuizzesCompleted,
    required this.localLongestStreak,
    required this.remoteLongestStreak,
  });

  /// Achievements that exist locally but not remotely.
  final Set<String> newLocalAchievements;

  /// Achievements that exist remotely but not locally.
  final Set<String> newRemoteAchievements;

  /// Categories where local has a higher score.
  final List<String> localBetterScoreCategories;

  /// Categories where remote has a higher score.
  final List<String> remoteBetterScoreCategories;

  /// Local total quizzes completed.
  final int localQuizzesCompleted;

  /// Remote total quizzes completed.
  final int remoteQuizzesCompleted;

  /// Local longest streak.
  final int localLongestStreak;

  /// Remote longest streak.
  final int remoteLongestStreak;

  /// Returns true if there are no differences.
  bool get isEmpty =>
      newLocalAchievements.isEmpty &&
      newRemoteAchievements.isEmpty &&
      localBetterScoreCategories.isEmpty &&
      remoteBetterScoreCategories.isEmpty &&
      localQuizzesCompleted == remoteQuizzesCompleted &&
      localLongestStreak == remoteLongestStreak;

  @override
  String toString() {
    final buffer = StringBuffer('CloudSaveDiff:\n');
    if (newLocalAchievements.isNotEmpty) {
      buffer.writeln('  New local achievements: $newLocalAchievements');
    }
    if (newRemoteAchievements.isNotEmpty) {
      buffer.writeln('  New remote achievements: $newRemoteAchievements');
    }
    if (localBetterScoreCategories.isNotEmpty) {
      buffer.writeln('  Local better scores: $localBetterScoreCategories');
    }
    if (remoteBetterScoreCategories.isNotEmpty) {
      buffer.writeln('  Remote better scores: $remoteBetterScoreCategories');
    }
    if (localQuizzesCompleted != remoteQuizzesCompleted) {
      buffer.writeln(
          '  Quizzes: local=$localQuizzesCompleted, remote=$remoteQuizzesCompleted');
    }
    if (localLongestStreak != remoteLongestStreak) {
      buffer.writeln(
          '  Longest streak: local=$localLongestStreak, remote=$remoteLongestStreak');
    }
    return buffer.toString();
  }
}
