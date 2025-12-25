/// Practice question model for tracking questions that need practice.
library;

import '../database/tables/practice_progress_table.dart';

/// A question that the user got wrong and needs to practice.
///
/// This model represents aggregated data from wrong answers across
/// all quiz sessions. It tracks how many times a question was answered
/// incorrectly and when it was last practiced correctly.
///
/// ## Usage
///
/// ```dart
/// final question = PracticeQuestion(
///   questionId: 'ua',
///   wrongCount: 3,
///   firstWrongAt: DateTime(2024, 1, 1),
///   lastWrongAt: DateTime(2024, 1, 15),
///   lastPracticedCorrectlyAt: null,
/// );
///
/// if (question.needsPractice) {
///   // Show in practice list
/// }
/// ```
class PracticeQuestion {
  /// Creates a [PracticeQuestion].
  const PracticeQuestion({
    required this.questionId,
    required this.wrongCount,
    required this.firstWrongAt,
    required this.lastWrongAt,
    this.lastPracticedCorrectlyAt,
  });

  /// Unique question identifier (e.g., "ua" for Ukraine flag).
  final String questionId;

  /// Number of times this question was answered incorrectly.
  final int wrongCount;

  /// First time the user got this question wrong.
  final DateTime firstWrongAt;

  /// Most recent time the user got this question wrong.
  final DateTime lastWrongAt;

  /// When this question was last practiced correctly.
  ///
  /// NULL if the question has never been practiced correctly.
  final DateTime? lastPracticedCorrectlyAt;

  /// Whether this question currently needs practice.
  ///
  /// A question needs practice when:
  /// - It has never been practiced correctly (lastPracticedCorrectlyAt is null), OR
  /// - It was answered wrong after the last successful practice
  bool get needsPractice {
    if (lastPracticedCorrectlyAt == null) return true;
    return lastWrongAt.isAfter(lastPracticedCorrectlyAt!);
  }

  /// Creates a [PracticeQuestion] from a database map.
  factory PracticeQuestion.fromMap(Map<String, dynamic> map) {
    return PracticeQuestion(
      questionId: map[PracticeProgressColumns.questionId] as String,
      wrongCount: map[PracticeProgressColumns.wrongCount] as int,
      firstWrongAt: DateTime.fromMillisecondsSinceEpoch(
        (map[PracticeProgressColumns.firstWrongAt] as int) * 1000,
      ),
      lastWrongAt: DateTime.fromMillisecondsSinceEpoch(
        (map[PracticeProgressColumns.lastWrongAt] as int) * 1000,
      ),
      lastPracticedCorrectlyAt:
          map[PracticeProgressColumns.lastPracticedCorrectlyAt] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  (map[PracticeProgressColumns.lastPracticedCorrectlyAt] as int) *
                      1000,
                )
              : null,
    );
  }

  /// Converts this [PracticeQuestion] to a database map.
  Map<String, dynamic> toMap() {
    return {
      PracticeProgressColumns.questionId: questionId,
      PracticeProgressColumns.wrongCount: wrongCount,
      PracticeProgressColumns.firstWrongAt:
          firstWrongAt.millisecondsSinceEpoch ~/ 1000,
      PracticeProgressColumns.lastWrongAt:
          lastWrongAt.millisecondsSinceEpoch ~/ 1000,
      PracticeProgressColumns.lastPracticedCorrectlyAt:
          lastPracticedCorrectlyAt != null
              ? lastPracticedCorrectlyAt!.millisecondsSinceEpoch ~/ 1000
              : null,
    };
  }

  /// Creates a copy of this [PracticeQuestion] with the given fields replaced.
  PracticeQuestion copyWith({
    String? questionId,
    int? wrongCount,
    DateTime? firstWrongAt,
    DateTime? lastWrongAt,
    DateTime? lastPracticedCorrectlyAt,
  }) {
    return PracticeQuestion(
      questionId: questionId ?? this.questionId,
      wrongCount: wrongCount ?? this.wrongCount,
      firstWrongAt: firstWrongAt ?? this.firstWrongAt,
      lastWrongAt: lastWrongAt ?? this.lastWrongAt,
      lastPracticedCorrectlyAt:
          lastPracticedCorrectlyAt ?? this.lastPracticedCorrectlyAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeQuestion && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;

  @override
  String toString() {
    return 'PracticeQuestion(questionId: $questionId, wrongCount: $wrongCount, needsPractice: $needsPractice)';
  }
}
