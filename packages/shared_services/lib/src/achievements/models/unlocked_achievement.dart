/// Database model for storing unlocked achievements.
///
/// This is the only achievement data stored in the database.
/// Achievement definitions are kept in code (see [Achievement]).
class UnlockedAchievement {
  /// Unique identifier for this record.
  final String id;

  /// The achievement ID (references [Achievement.id]).
  final String achievementId;

  /// When the achievement was unlocked.
  final DateTime unlockedAt;

  /// The progress value when unlocked.
  final int progress;

  /// Whether the user has been notified of this achievement.
  final bool notified;

  /// When this record was created.
  final DateTime createdAt;

  /// Creates an [UnlockedAchievement].
  const UnlockedAchievement({
    required this.id,
    required this.achievementId,
    required this.unlockedAt,
    required this.progress,
    required this.notified,
    required this.createdAt,
  });

  /// Creates a new [UnlockedAchievement] for a just-unlocked achievement.
  factory UnlockedAchievement.create({
    required String id,
    required String achievementId,
    required int progress,
  }) {
    final now = DateTime.now();
    return UnlockedAchievement(
      id: id,
      achievementId: achievementId,
      unlockedAt: now,
      progress: progress,
      notified: false,
      createdAt: now,
    );
  }

  /// Creates an [UnlockedAchievement] from a database map.
  factory UnlockedAchievement.fromMap(Map<String, dynamic> map) {
    return UnlockedAchievement(
      id: map['id'] as String,
      achievementId: map['achievement_id'] as String,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['unlocked_at'] as int) * 1000,
      ),
      progress: map['progress'] as int? ?? 0,
      notified: (map['notified'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
    );
  }

  /// Converts this [UnlockedAchievement] to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.millisecondsSinceEpoch ~/ 1000,
      'progress': progress,
      'notified': notified ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy with the given fields replaced.
  UnlockedAchievement copyWith({
    String? id,
    String? achievementId,
    DateTime? unlockedAt,
    int? progress,
    bool? notified,
    DateTime? createdAt,
  }) {
    return UnlockedAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      notified: notified ?? this.notified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns a copy marked as notified.
  UnlockedAchievement markAsNotified() {
    return copyWith(notified: true);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockedAchievement && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UnlockedAchievement(id: $id, achievementId: $achievementId, unlockedAt: $unlockedAt)';
}
