/// Model representing a daily challenge.
///
/// Daily challenges are generated once per day with consistent questions
/// globally (using a seed based on the date).
library;

/// Represents a daily challenge configuration.
class DailyChallenge {
  /// Creates a new [DailyChallenge].
  const DailyChallenge({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.questionCount,
    this.timeLimitSeconds,
    required this.seed,
    required this.createdAt,
  });

  /// Creates a [DailyChallenge] for today with a specific category.
  factory DailyChallenge.forToday({
    required String categoryId,
    int questionCount = 10,
    int? timeLimitSeconds,
  }) {
    final today = _normalizeDate(DateTime.now());
    return DailyChallenge(
      id: _generateId(today),
      date: today,
      categoryId: categoryId,
      questionCount: questionCount,
      timeLimitSeconds: timeLimitSeconds,
      seed: _generateSeed(today),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a [DailyChallenge] for a specific date.
  factory DailyChallenge.forDate({
    required DateTime date,
    required String categoryId,
    int questionCount = 10,
    int? timeLimitSeconds,
  }) {
    final normalizedDate = _normalizeDate(date);
    return DailyChallenge(
      id: _generateId(normalizedDate),
      date: normalizedDate,
      categoryId: categoryId,
      questionCount: questionCount,
      timeLimitSeconds: timeLimitSeconds,
      seed: _generateSeed(normalizedDate),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a [DailyChallenge] from a database map.
  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(
        (map['date'] as int) * 1000,
      ),
      categoryId: map['category_id'] as String,
      questionCount: map['question_count'] as int,
      timeLimitSeconds: map['time_limit_seconds'] as int?,
      seed: map['seed'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
    );
  }

  /// Unique identifier (date-based, e.g., "daily_2024-01-15").
  final String id;

  /// The date of the challenge (normalized to midnight).
  final DateTime date;

  /// Category ID for this challenge.
  final String categoryId;

  /// Number of questions in this challenge.
  final int questionCount;

  /// Optional time limit in seconds.
  final int? timeLimitSeconds;

  /// Random seed for consistent question generation globally.
  ///
  /// All users get the same questions for the same day.
  final int seed;

  /// When this challenge was created.
  final DateTime createdAt;

  /// Whether this challenge has a time limit.
  bool get hasTimeLimit => timeLimitSeconds != null && timeLimitSeconds! > 0;

  /// Whether this challenge is for today.
  bool get isToday {
    final today = _normalizeDate(DateTime.now());
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Whether this challenge is in the past.
  bool get isPast {
    final today = _normalizeDate(DateTime.now());
    return date.isBefore(today);
  }

  /// Whether this challenge is in the future.
  bool get isFuture {
    final today = _normalizeDate(DateTime.now());
    return date.isAfter(today);
  }

  /// Converts this [DailyChallenge] to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'category_id': categoryId,
      'question_count': questionCount,
      'time_limit_seconds': timeLimitSeconds,
      'seed': seed,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy with the given fields replaced.
  DailyChallenge copyWith({
    String? id,
    DateTime? date,
    String? categoryId,
    int? questionCount,
    int? timeLimitSeconds,
    bool clearTimeLimit = false,
    int? seed,
    DateTime? createdAt,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      questionCount: questionCount ?? this.questionCount,
      timeLimitSeconds:
          clearTimeLimit ? null : (timeLimitSeconds ?? this.timeLimitSeconds),
      seed: seed ?? this.seed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Normalizes a date to midnight UTC for consistent comparison.
  static DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Generates a unique ID for a given date.
  static String _generateId(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'daily_$dateStr';
  }

  /// Generates a consistent seed for a given date.
  ///
  /// Uses the date components to create a reproducible seed.
  static int _generateSeed(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DailyChallenge(id: $id, date: $date, category: $categoryId, '
        'questions: $questionCount, seed: $seed)';
  }
}
