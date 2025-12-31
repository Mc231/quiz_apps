/// Persistent state for the Rate App service.
///
/// Tracks user interactions with rate prompts and determines
/// whether future prompts should be shown.
class RateAppState {
  /// When the rate dialog was last shown.
  final DateTime? lastPromptDate;

  /// Whether the user has completed a rating.
  ///
  /// If true, no more prompts will be shown.
  final bool hasRated;

  /// Number of times the user declined the prompt.
  final int declineCount;

  /// Total number of prompts shown.
  final int promptCount;

  /// Date of the first app launch.
  final DateTime? firstLaunchDate;

  /// Creates a new [RateAppState].
  const RateAppState({
    this.lastPromptDate,
    this.hasRated = false,
    this.declineCount = 0,
    this.promptCount = 0,
    this.firstLaunchDate,
  });

  /// Creates an initial state with the first launch date set to now.
  factory RateAppState.initial() {
    return RateAppState(
      firstLaunchDate: DateTime.now(),
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  RateAppState copyWith({
    DateTime? lastPromptDate,
    bool? hasRated,
    int? declineCount,
    int? promptCount,
    DateTime? firstLaunchDate,
  }) {
    return RateAppState(
      lastPromptDate: lastPromptDate ?? this.lastPromptDate,
      hasRated: hasRated ?? this.hasRated,
      declineCount: declineCount ?? this.declineCount,
      promptCount: promptCount ?? this.promptCount,
      firstLaunchDate: firstLaunchDate ?? this.firstLaunchDate,
    );
  }

  /// Returns the number of days since the first launch.
  ///
  /// Returns 0 if [firstLaunchDate] is null.
  int get daysSinceInstall {
    if (firstLaunchDate == null) return 0;
    return DateTime.now().difference(firstLaunchDate!).inDays;
  }

  /// Returns the number of days since the last prompt.
  ///
  /// Returns null if [lastPromptDate] is null.
  int? get daysSinceLastPrompt {
    if (lastPromptDate == null) return null;
    return DateTime.now().difference(lastPromptDate!).inDays;
  }

  /// Converts this state to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'lastPromptDate': lastPromptDate?.toIso8601String(),
      'hasRated': hasRated,
      'declineCount': declineCount,
      'promptCount': promptCount,
      'firstLaunchDate': firstLaunchDate?.toIso8601String(),
    };
  }

  /// Creates a state from a JSON map.
  factory RateAppState.fromJson(Map<String, dynamic> json) {
    return RateAppState(
      lastPromptDate: json['lastPromptDate'] != null
          ? DateTime.parse(json['lastPromptDate'] as String)
          : null,
      hasRated: json['hasRated'] as bool? ?? false,
      declineCount: json['declineCount'] as int? ?? 0,
      promptCount: json['promptCount'] as int? ?? 0,
      firstLaunchDate: json['firstLaunchDate'] != null
          ? DateTime.parse(json['firstLaunchDate'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RateAppState &&
        other.lastPromptDate == lastPromptDate &&
        other.hasRated == hasRated &&
        other.declineCount == declineCount &&
        other.promptCount == promptCount &&
        other.firstLaunchDate == firstLaunchDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      lastPromptDate,
      hasRated,
      declineCount,
      promptCount,
      firstLaunchDate,
    );
  }

  @override
  String toString() {
    return 'RateAppState('
        'lastPromptDate: $lastPromptDate, '
        'hasRated: $hasRated, '
        'declineCount: $declineCount, '
        'promptCount: $promptCount, '
        'firstLaunchDate: $firstLaunchDate)';
  }
}
