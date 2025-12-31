import 'dart:math';

import 'base_config.dart';

/// Sealed class for mixed layout selection strategies.
///
/// Determines how layouts are selected for each question in a MixedLayout.
sealed class MixedLayoutStrategy extends BaseConfig {
  const MixedLayoutStrategy();

  /// Selects an index from available layouts for the given question.
  ///
  /// [questionIndex] - The zero-based index of the current question.
  /// [layoutCount] - The total number of available layouts.
  ///
  /// Returns the index of the layout to use (0 to layoutCount-1).
  int selectIndex(int questionIndex, int layoutCount);

  /// Factory for random strategy.
  factory MixedLayoutStrategy.random({int? seed}) = RandomStrategy;

  /// Factory for alternating strategy.
  factory MixedLayoutStrategy.alternating({int startIndex}) = AlternatingStrategy;

  /// Factory for weighted strategy.
  factory MixedLayoutStrategy.weighted({
    required List<double> weights,
    int? seed,
  }) = WeightedStrategy;

  /// Deserialize from map.
  factory MixedLayoutStrategy.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;

    return switch (type) {
      'random' => RandomStrategy.fromMap(map),
      'alternating' => AlternatingStrategy.fromMap(map),
      'weighted' => WeightedStrategy.fromMap(map),
      _ => throw ArgumentError('Unknown strategy type: $type'),
    };
  }

  @override
  int get version => 1;
}

/// Random selection strategy.
///
/// Randomly selects a layout for each question.
/// Optionally uses a seed for reproducible results.
class RandomStrategy extends MixedLayoutStrategy {
  /// Optional seed for reproducible random selection.
  final int? seed;

  const RandomStrategy({this.seed});

  @override
  int selectIndex(int questionIndex, int layoutCount) {
    if (layoutCount <= 0) {
      throw ArgumentError('layoutCount must be positive');
    }

    // For seeded random, we need deterministic results per question index
    if (seed != null) {
      final seededRandom = Random(seed! + questionIndex);
      return seededRandom.nextInt(layoutCount);
    }

    // For non-seeded, create a new random each time
    return Random().nextInt(layoutCount);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'random',
      'version': version,
      if (seed != null) 'seed': seed,
    };
  }

  factory RandomStrategy.fromMap(Map<String, dynamic> map) {
    return RandomStrategy(
      seed: map['seed'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RandomStrategy && other.seed == seed;
  }

  @override
  int get hashCode => seed.hashCode;
}

/// Alternating selection strategy.
///
/// Cycles through layouts in order: 0, 1, 2, ..., n-1, 0, 1, ...
class AlternatingStrategy extends MixedLayoutStrategy {
  /// Starting index for the alternation cycle.
  final int startIndex;

  const AlternatingStrategy({this.startIndex = 0});

  @override
  int selectIndex(int questionIndex, int layoutCount) {
    if (layoutCount <= 0) {
      throw ArgumentError('layoutCount must be positive');
    }

    return (startIndex + questionIndex) % layoutCount;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'alternating',
      'version': version,
      'startIndex': startIndex,
    };
  }

  factory AlternatingStrategy.fromMap(Map<String, dynamic> map) {
    return AlternatingStrategy(
      startIndex: map['startIndex'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlternatingStrategy && other.startIndex == startIndex;
  }

  @override
  int get hashCode => startIndex.hashCode;
}

/// Weighted selection strategy.
///
/// Selects layouts based on relative weights.
/// Higher weight = higher probability of selection.
class WeightedStrategy extends MixedLayoutStrategy {
  /// Relative weights for each layout.
  ///
  /// Length must match the number of layouts.
  /// Values are relative (e.g., [2, 1] means first layout appears twice as often).
  final List<double> weights;

  /// Optional seed for reproducible random selection.
  final int? seed;

  const WeightedStrategy({
    required this.weights,
    this.seed,
  });

  @override
  int selectIndex(int questionIndex, int layoutCount) {
    if (layoutCount <= 0) {
      throw ArgumentError('layoutCount must be positive');
    }

    if (weights.isEmpty) {
      throw ArgumentError('weights must not be empty');
    }

    if (weights.length != layoutCount) {
      throw ArgumentError(
        'weights length (${weights.length}) must match layoutCount ($layoutCount)',
      );
    }

    // Calculate total weight
    final totalWeight = weights.reduce((a, b) => a + b);
    if (totalWeight <= 0) {
      throw ArgumentError('Total weight must be positive');
    }

    // Generate random value
    final random = seed != null ? Random(seed! + questionIndex) : Random();
    final target = random.nextDouble() * totalWeight;

    // Find the layout based on cumulative weight
    var cumulative = 0.0;
    for (var i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (target < cumulative) {
        return i;
      }
    }

    // Fallback to last index (shouldn't happen with valid weights)
    return weights.length - 1;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'weighted',
      'version': version,
      'weights': weights,
      if (seed != null) 'seed': seed,
    };
  }

  factory WeightedStrategy.fromMap(Map<String, dynamic> map) {
    return WeightedStrategy(
      weights: (map['weights'] as List).map((w) => (w as num).toDouble()).toList(),
      seed: map['seed'] as int?,
    );
  }

  WeightedStrategy copyWith({
    List<double>? weights,
    int? seed,
  }) {
    return WeightedStrategy(
      weights: weights ?? this.weights,
      seed: seed ?? this.seed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WeightedStrategy) return false;
    if (weights.length != other.weights.length) return false;
    for (var i = 0; i < weights.length; i++) {
      if (weights[i] != other.weights[i]) return false;
    }
    return seed == other.seed;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(weights), seed);
}