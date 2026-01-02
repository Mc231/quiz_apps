/// Model for streak-based rewards.
///
/// Used for granting rewards when users reach streak milestones.
/// Supports different reward types such as bonus hints, experience points,
/// virtual currency, and achievements.
library;

/// Types of rewards that can be granted for streak achievements.
enum StreakRewardType {
  /// Bonus hints for quizzes.
  bonusHints,

  /// Experience points for leveling.
  experiencePoints,

  /// Virtual currency (coins, gems, etc.).
  virtualCurrency,

  /// Achievement unlock.
  achievement,

  /// Cosmetic item (theme, avatar, etc.).
  cosmetic,

  /// Premium feature unlock.
  premiumFeature,
}

/// A reward granted for reaching a streak milestone.
///
/// Example:
/// ```dart
/// final reward = StreakReward(
///   type: StreakRewardType.bonusHints,
///   amount: 3,
///   milestoneDay: 7,
///   title: 'Bonus Hints',
///   description: 'You earned 3 bonus hints!',
/// );
/// ```
class StreakReward {
  /// Creates a [StreakReward].
  const StreakReward({
    required this.type,
    required this.amount,
    required this.milestoneDay,
    required this.title,
    required this.description,
    this.iconName,
    this.metadata,
  });

  /// Creates a bonus hints reward.
  factory StreakReward.bonusHints({
    required int amount,
    required int milestoneDay,
    String? title,
    String? description,
  }) {
    return StreakReward(
      type: StreakRewardType.bonusHints,
      amount: amount,
      milestoneDay: milestoneDay,
      title: title ?? 'Bonus Hints',
      description: description ?? 'You earned $amount bonus hints!',
      iconName: 'lightbulb',
    );
  }

  /// Creates an experience points reward.
  factory StreakReward.experiencePoints({
    required int amount,
    required int milestoneDay,
    String? title,
    String? description,
  }) {
    return StreakReward(
      type: StreakRewardType.experiencePoints,
      amount: amount,
      milestoneDay: milestoneDay,
      title: title ?? 'Experience Points',
      description: description ?? 'You earned $amount XP!',
      iconName: 'star',
    );
  }

  /// Creates a virtual currency reward.
  factory StreakReward.virtualCurrency({
    required int amount,
    required int milestoneDay,
    String currencyName = 'coins',
    String? title,
    String? description,
  }) {
    return StreakReward(
      type: StreakRewardType.virtualCurrency,
      amount: amount,
      milestoneDay: milestoneDay,
      title: title ?? 'Bonus $currencyName',
      description: description ?? 'You earned $amount $currencyName!',
      iconName: 'monetization_on',
      metadata: {'currency_name': currencyName},
    );
  }

  /// Creates an achievement unlock reward.
  factory StreakReward.achievement({
    required String achievementId,
    required int milestoneDay,
    required String achievementName,
    String? description,
  }) {
    return StreakReward(
      type: StreakRewardType.achievement,
      amount: 1,
      milestoneDay: milestoneDay,
      title: achievementName,
      description: description ?? 'Achievement unlocked!',
      iconName: 'emoji_events',
      metadata: {'achievement_id': achievementId},
    );
  }

  /// The type of reward.
  final StreakRewardType type;

  /// The amount of the reward (e.g., 3 hints, 100 XP).
  final int amount;

  /// The milestone day this reward is granted for.
  final int milestoneDay;

  /// Display title for the reward.
  final String title;

  /// Display description for the reward.
  final String description;

  /// Optional icon name for display.
  final String? iconName;

  /// Optional metadata for additional reward details.
  final Map<String, dynamic>? metadata;

  /// Creates a copy with the given fields replaced.
  StreakReward copyWith({
    StreakRewardType? type,
    int? amount,
    int? milestoneDay,
    String? title,
    String? description,
    String? iconName,
    Map<String, dynamic>? metadata,
  }) {
    return StreakReward(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      milestoneDay: milestoneDay ?? this.milestoneDay,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreakReward) return false;

    return other.type == type &&
        other.amount == amount &&
        other.milestoneDay == milestoneDay &&
        other.title == title &&
        other.description == description &&
        other.iconName == iconName;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      amount,
      milestoneDay,
      title,
      description,
      iconName,
    );
  }

  @override
  String toString() {
    return 'StreakReward('
        'type: $type, '
        'amount: $amount, '
        'milestoneDay: $milestoneDay, '
        'title: $title)';
  }
}

/// Configuration for streak rewards at each milestone.
///
/// Example:
/// ```dart
/// final config = StreakRewardConfig(
///   rewards: {
///     7: [StreakReward.bonusHints(amount: 2, milestoneDay: 7)],
///     30: [
///       StreakReward.bonusHints(amount: 5, milestoneDay: 30),
///       StreakReward.experiencePoints(amount: 100, milestoneDay: 30),
///     ],
///   },
/// );
/// ```
class StreakRewardConfig {
  /// Creates a [StreakRewardConfig].
  const StreakRewardConfig({
    this.rewards = const {},
  });

  /// Default empty configuration.
  static const StreakRewardConfig empty = StreakRewardConfig();

  /// Map of milestone days to their rewards.
  final Map<int, List<StreakReward>> rewards;

  /// Gets the rewards for a specific milestone day.
  ///
  /// Returns an empty list if no rewards are configured for that milestone.
  List<StreakReward> getRewardsForMilestone(int milestoneDay) {
    return rewards[milestoneDay] ?? [];
  }

  /// Checks if a milestone has rewards configured.
  bool hasRewardsForMilestone(int milestoneDay) {
    return rewards.containsKey(milestoneDay) &&
        rewards[milestoneDay]!.isNotEmpty;
  }

  /// Gets all milestone days that have rewards.
  List<int> get rewardMilestones => rewards.keys.toList()..sort();

  /// Creates a copy with the given fields replaced.
  StreakRewardConfig copyWith({
    Map<int, List<StreakReward>>? rewards,
  }) {
    return StreakRewardConfig(
      rewards: rewards ?? this.rewards,
    );
  }

  @override
  String toString() {
    return 'StreakRewardConfig(milestones: ${rewards.keys.toList()})';
  }
}
