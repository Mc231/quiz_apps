import 'base_config.dart';

/// Types of hints available in the quiz
enum HintType {
  /// Remove 2 wrong answers (50/50)
  fiftyFifty,

  /// Skip question without penalty
  skip,

  /// Show first letter of correct answer
  revealLetter,

  /// Add extra time (timed mode only)
  extraTime,
}

/// Configuration for hint system
class HintConfig extends BaseConfig {
  /// Starting hints per type
  final Map<HintType, int> initialHints;

  /// Can earn hints through achievements
  final bool canEarnHints;

  /// Watch ad to get hint (requires monetization)
  final bool allowAdForHint;

  @override
  final int version;

  const HintConfig({
    this.initialHints = const {
      HintType.fiftyFifty: 3,
      HintType.skip: 2,
      HintType.revealLetter: 3,
      HintType.extraTime: 2,
    },
    this.canEarnHints = true,
    this.allowAdForHint = false,
    this.version = 1,
  });

  /// No hints configuration
  const HintConfig.noHints()
      : initialHints = const {},
        canEarnHints = false,
        allowAdForHint = false,
        version = 1;

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'initialHints': initialHints.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'canEarnHints': canEarnHints,
      'allowAdForHint': allowAdForHint,
    };
  }

  factory HintConfig.fromMap(Map<String, dynamic> map) {
    final version = map['version'] as int? ?? 1;
    final hintsMap = map['initialHints'] as Map<String, dynamic>? ?? {};

    final initialHints = <HintType, int>{};
    hintsMap.forEach((key, value) {
      final hintType = HintType.values.firstWhere((e) => e.name == key);
      initialHints[hintType] = value as int;
    });

    return HintConfig(
      initialHints: initialHints,
      canEarnHints: map['canEarnHints'] as bool? ?? true,
      allowAdForHint: map['allowAdForHint'] as bool? ?? false,
      version: version,
    );
  }

  HintConfig copyWith({
    Map<HintType, int>? initialHints,
    bool? canEarnHints,
    bool? allowAdForHint,
  }) {
    return HintConfig(
      initialHints: initialHints ?? this.initialHints,
      canEarnHints: canEarnHints ?? this.canEarnHints,
      allowAdForHint: allowAdForHint ?? this.allowAdForHint,
      version: version,
    );
  }
}

/// Runtime state of hints during a quiz
class HintState {
  final Map<HintType, int> remainingHints;

  HintState(this.remainingHints);

  HintState.fromConfig(HintConfig config)
      : remainingHints = Map.from(config.initialHints);

  /// Check if hint type is available
  bool canUseHint(HintType type) {
    return (remainingHints[type] ?? 0) > 0;
  }

  /// Use a hint (decrements count)
  void useHint(HintType type) {
    if (!canUseHint(type)) {
      throw StateError('No hints remaining for $type');
    }
    remainingHints[type] = remainingHints[type]! - 1;
  }

  /// Add hints (from achievements or rewards)
  void addHint(HintType type, int count) {
    remainingHints[type] = (remainingHints[type] ?? 0) + count;
  }

  /// Get remaining count for a hint type
  int getRemainingCount(HintType type) {
    return remainingHints[type] ?? 0;
  }
}