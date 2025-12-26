import 'package:flutter/material.dart';

/// Resource types available in the quiz system.
///
/// Each resource type has associated visual properties and localization keys.
/// Using sealed class pattern for type-safe pattern matching and extensibility.
///
/// Example usage:
/// ```dart
/// final type = ResourceType.lives();
/// print(type.icon);  // Icons.favorite
/// print(type.color); // Red
///
/// // Pattern matching
/// final name = switch (type) {
///   LivesResource() => 'Lives',
///   FiftyFiftyResource() => '50/50',
///   SkipResource() => 'Skip',
/// };
/// ```
sealed class ResourceType {
  /// Icon for this resource type.
  IconData get icon;

  /// Default color for this resource type.
  Color get color;

  /// Localization key for the resource name.
  String get localizationKey;

  /// Unique identifier for database storage.
  String get id;

  const ResourceType();

  /// Lives (hearts) - lose one on wrong answer.
  factory ResourceType.lives() = LivesResource;

  /// 50/50 hint - eliminate 2 wrong answers.
  factory ResourceType.fiftyFifty() = FiftyFiftyResource;

  /// Skip hint - skip question without penalty.
  factory ResourceType.skip() = SkipResource;

  /// All available resource types.
  static List<ResourceType> get values => const [
    LivesResource(),
    FiftyFiftyResource(),
    SkipResource(),
  ];

  /// Get resource type by ID (for database lookups).
  ///
  /// Returns `null` if the ID is not recognized.
  static ResourceType? fromId(String id) {
    return switch (id) {
      'lives' => const LivesResource(),
      'fiftyFifty' => const FiftyFiftyResource(),
      'skip' => const SkipResource(),
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResourceType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ResourceType.$id';
}

/// Lives resource - hearts that are lost on wrong answers.
///
/// In lives mode, players start with a set number of lives
/// and lose one for each incorrect answer.
class LivesResource extends ResourceType {
  const LivesResource();

  @override
  IconData get icon => Icons.favorite;

  @override
  Color get color => const Color(0xFFF44336); // Colors.red

  @override
  String get localizationKey => 'lives';

  @override
  String get id => 'lives';
}

/// 50/50 hint - eliminates 2 wrong answers.
///
/// When used, this hint removes two incorrect options from the
/// current question, making it easier to guess the correct answer.
class FiftyFiftyResource extends ResourceType {
  const FiftyFiftyResource();

  @override
  IconData get icon => Icons.filter_2;

  @override
  Color get color => const Color(0xFF2196F3); // Colors.blue

  @override
  String get localizationKey => 'fiftyFifty';

  @override
  String get id => 'fiftyFifty';
}

/// Skip hint - skip question without penalty.
///
/// When used, this hint allows the player to skip the current
/// question without it counting as an incorrect answer.
class SkipResource extends ResourceType {
  const SkipResource();

  @override
  IconData get icon => Icons.skip_next;

  @override
  Color get color => const Color(0xFFFF9800); // Colors.orange

  @override
  String get localizationKey => 'skip';

  @override
  String get id => 'skip';
}
