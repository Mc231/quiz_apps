/// Configuration for streak behavior.
///
/// Allows customization of streak rules such as grace periods
/// and freeze token support.
class StreakConfig {
  /// Creates a [StreakConfig].
  const StreakConfig({
    this.gracePeriodHours = 0,
    this.freezeTokensEnabled = false,
    this.streakMilestones = defaultMilestones,
  });

  /// Default streak configuration.
  static const StreakConfig defaults = StreakConfig();

  /// Default milestone days for celebrations.
  static const List<int> defaultMilestones = [7, 14, 30, 50, 100, 365];

  /// Hours after midnight before streak breaks.
  ///
  /// A value of 0 means the streak breaks at midnight.
  /// A value of 4 means the user has until 4 AM to play
  /// and still count as the previous day.
  ///
  /// Default: 0 (strict midnight cutoff)
  final int gracePeriodHours;

  /// Whether streak freeze tokens are enabled.
  ///
  /// When enabled, users can use freeze tokens to preserve
  /// their streak for a day without playing.
  ///
  /// Default: false
  final bool freezeTokensEnabled;

  /// Milestone days for streak celebrations.
  ///
  /// When a user reaches one of these streak counts,
  /// they receive a special celebration or reward.
  ///
  /// Default: [7, 14, 30, 50, 100, 365]
  final List<int> streakMilestones;

  /// Returns the next milestone after [currentStreak].
  ///
  /// Returns null if there are no more milestones to reach.
  int? getNextMilestone(int currentStreak) {
    for (final milestone in streakMilestones) {
      if (milestone > currentStreak) {
        return milestone;
      }
    }
    return null;
  }

  /// Returns the previous milestone that was reached.
  ///
  /// Returns null if no milestones have been reached yet.
  int? getLastReachedMilestone(int currentStreak) {
    int? lastMilestone;
    for (final milestone in streakMilestones) {
      if (milestone <= currentStreak) {
        lastMilestone = milestone;
      } else {
        break;
      }
    }
    return lastMilestone;
  }

  /// Checks if [streakCount] is a milestone.
  bool isMilestone(int streakCount) {
    return streakMilestones.contains(streakCount);
  }

  /// Returns progress to the next milestone as a value between 0.0 and 1.0.
  ///
  /// Returns 1.0 if all milestones have been reached.
  double getMilestoneProgress(int currentStreak) {
    final nextMilestone = getNextMilestone(currentStreak);
    if (nextMilestone == null) return 1.0;

    final lastMilestone = getLastReachedMilestone(currentStreak) ?? 0;
    final range = nextMilestone - lastMilestone;
    final progress = currentStreak - lastMilestone;

    return progress / range;
  }

  /// Creates a copy with the given fields replaced.
  StreakConfig copyWith({
    int? gracePeriodHours,
    bool? freezeTokensEnabled,
    List<int>? streakMilestones,
  }) {
    return StreakConfig(
      gracePeriodHours: gracePeriodHours ?? this.gracePeriodHours,
      freezeTokensEnabled: freezeTokensEnabled ?? this.freezeTokensEnabled,
      streakMilestones: streakMilestones ?? this.streakMilestones,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreakConfig) return false;

    return other.gracePeriodHours == gracePeriodHours &&
        other.freezeTokensEnabled == freezeTokensEnabled &&
        _listEquals(other.streakMilestones, streakMilestones);
  }

  @override
  int get hashCode {
    return Object.hash(
      gracePeriodHours,
      freezeTokensEnabled,
      Object.hashAll(streakMilestones),
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
