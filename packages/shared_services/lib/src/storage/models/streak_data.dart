/// Model representing user's streak data for daily play tracking.
///
/// Tracks consecutive days of play to encourage daily engagement
/// and retention through gamification.
class StreakData {
  /// Creates a new [StreakData] instance.
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastPlayDate,
    this.streakStartDate,
    required this.totalDaysPlayed,
  });

  /// Creates an empty [StreakData] for new users.
  factory StreakData.empty() => const StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastPlayDate: null,
        streakStartDate: null,
        totalDaysPlayed: 0,
      );

  /// Creates a [StreakData] from a database map.
  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      lastPlayDate: map['last_play_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['last_play_date'] as int) * 1000,
            )
          : null,
      streakStartDate: map['streak_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['streak_start_date'] as int) * 1000,
            )
          : null,
      totalDaysPlayed: map['total_days_played'] as int? ?? 0,
    );
  }

  /// Current consecutive days of play.
  ///
  /// Resets to 0 when the user misses a day.
  final int currentStreak;

  /// All-time best streak.
  ///
  /// Updated whenever [currentStreak] exceeds this value.
  final int longestStreak;

  /// The last date the user completed a quiz.
  ///
  /// Used to determine if the streak is still active.
  /// Null if the user has never played.
  final DateTime? lastPlayDate;

  /// When the current streak began.
  ///
  /// Null if there is no active streak.
  final DateTime? streakStartDate;

  /// Total lifetime days with at least one quiz completed.
  ///
  /// This is cumulative and never resets.
  final int totalDaysPlayed;

  /// Whether the user has any streak history.
  bool get hasPlayedBefore => lastPlayDate != null;

  /// Whether there is an active streak (currentStreak > 0).
  bool get hasActiveStreak => currentStreak > 0;

  /// Converts this [StreakData] to a database map.
  Map<String, dynamic> toMap() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_play_date': lastPlayDate != null
          ? lastPlayDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      'streak_start_date': streakStartDate != null
          ? streakStartDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      'total_days_played': totalDaysPlayed,
    };
  }

  /// Creates a copy with the given fields replaced.
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPlayDate,
    DateTime? streakStartDate,
    int? totalDaysPlayed,
    bool clearLastPlayDate = false,
    bool clearStreakStartDate = false,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayDate:
          clearLastPlayDate ? null : (lastPlayDate ?? this.lastPlayDate),
      streakStartDate: clearStreakStartDate
          ? null
          : (streakStartDate ?? this.streakStartDate),
      totalDaysPlayed: totalDaysPlayed ?? this.totalDaysPlayed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakData &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastPlayDate == lastPlayDate &&
        other.streakStartDate == streakStartDate &&
        other.totalDaysPlayed == totalDaysPlayed;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStreak,
      longestStreak,
      lastPlayDate,
      streakStartDate,
      totalDaysPlayed,
    );
  }

  @override
  String toString() {
    return 'StreakData('
        'currentStreak: $currentStreak, '
        'longestStreak: $longestStreak, '
        'lastPlayDate: $lastPlayDate, '
        'streakStartDate: $streakStartDate, '
        'totalDaysPlayed: $totalDaysPlayed)';
  }
}
