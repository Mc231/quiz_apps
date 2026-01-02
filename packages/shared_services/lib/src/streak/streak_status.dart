/// Status of the user's current streak.
///
/// Used to determine UI state and messaging for streak features.
enum StreakStatus {
  /// User has played today, streak is maintained.
  ///
  /// Display: Active flame, celebration state.
  active,

  /// User hasn't played today yet, streak will break tomorrow if not played.
  ///
  /// Display: Warning state, "Keep your streak alive!" message.
  atRisk,

  /// User's streak was broken (missed a day).
  ///
  /// Display: Gray/inactive flame, "Streak lost" message.
  broken,

  /// User has never started a streak (no play history).
  ///
  /// Display: Empty state, "Start your streak today!" message.
  none;

  /// Whether the streak is currently active (either maintained or at risk).
  bool get isActive => this == active || this == atRisk;

  /// Whether the user needs to play today to maintain their streak.
  bool get needsActivityToday => this == atRisk;

  /// Whether there is no streak to display.
  bool get isEmpty => this == none || this == broken;

  /// Creates a [StreakStatus] from a string value.
  static StreakStatus fromString(String? value) {
    return StreakStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => StreakStatus.none,
    );
  }
}
