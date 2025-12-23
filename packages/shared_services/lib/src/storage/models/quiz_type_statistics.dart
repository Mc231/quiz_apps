/// Quiz type statistics data model for database persistence.
library;

import '../database/tables/statistics_tables.dart';

/// Statistics for a specific quiz type and optional category.
class QuizTypeStatistics {
  /// Creates a new [QuizTypeStatistics].
  const QuizTypeStatistics({
    required this.id,
    required this.quizType,
    this.quizCategory,
    this.totalSessions = 0,
    this.totalCompletedSessions = 0,
    this.totalQuestions = 0,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
    this.totalSkipped = 0,
    this.averageScorePercentage = 0,
    this.bestScorePercentage = 0,
    this.bestSessionId,
    this.totalTimePlayedSeconds = 0,
    this.averageTimePerQuestion = 0,
    this.totalPerfectScores = 0,
    this.lastPlayedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for this statistics record.
  final String id;

  /// The quiz type (e.g., 'flags', 'capitals').
  final String quizType;

  /// The quiz category (e.g., 'europe', 'asia'). Null for all categories.
  final String? quizCategory;

  /// Total number of sessions for this type/category.
  final int totalSessions;

  /// Total completed sessions for this type/category.
  final int totalCompletedSessions;

  /// Total questions answered for this type/category.
  final int totalQuestions;

  /// Total correct answers for this type/category.
  final int totalCorrect;

  /// Total incorrect answers for this type/category.
  final int totalIncorrect;

  /// Total skipped questions for this type/category.
  final int totalSkipped;

  /// Average score percentage for this type/category.
  final double averageScorePercentage;

  /// Best score percentage for this type/category.
  final double bestScorePercentage;

  /// ID of the session with the best score.
  final String? bestSessionId;

  /// Total time played in seconds.
  final int totalTimePlayedSeconds;

  /// Average time per question in seconds.
  final double averageTimePerQuestion;

  /// Total perfect scores for this type/category.
  final int totalPerfectScores;

  /// When this type/category was last played.
  final DateTime? lastPlayedAt;

  /// When this record was created.
  final DateTime createdAt;

  /// When this record was last updated.
  final DateTime updatedAt;

  /// Display name for this type/category combination.
  String get displayName {
    if (quizCategory != null) {
      return '$quizType - $quizCategory';
    }
    return quizType;
  }

  /// Overall accuracy percentage.
  double get accuracy {
    if (totalQuestions == 0) return 0;
    return (totalCorrect / totalQuestions) * 100;
  }

  /// Completion rate percentage.
  double get completionRate {
    if (totalSessions == 0) return 0;
    return (totalCompletedSessions / totalSessions) * 100;
  }

  /// Generates a unique ID for a type/category combination.
  static String generateId(String quizType, String? quizCategory) {
    if (quizCategory != null && quizCategory.isNotEmpty) {
      return '${quizType}_$quizCategory';
    }
    return quizType;
  }

  /// Creates an empty [QuizTypeStatistics] for a new type/category.
  factory QuizTypeStatistics.empty({
    required String quizType,
    String? quizCategory,
  }) {
    final now = DateTime.now();
    return QuizTypeStatistics(
      id: generateId(quizType, quizCategory),
      quizType: quizType,
      quizCategory: quizCategory,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a [QuizTypeStatistics] from a database map.
  factory QuizTypeStatistics.fromMap(Map<String, dynamic> map) {
    return QuizTypeStatistics(
      id: map[QuizTypeStatisticsColumns.id] as String,
      quizType: map[QuizTypeStatisticsColumns.quizType] as String,
      quizCategory: map[QuizTypeStatisticsColumns.quizCategory] as String?,
      totalSessions:
          (map[QuizTypeStatisticsColumns.totalSessions] as int?) ?? 0,
      totalCompletedSessions:
          (map[QuizTypeStatisticsColumns.totalCompletedSessions] as int?) ?? 0,
      totalQuestions:
          (map[QuizTypeStatisticsColumns.totalQuestions] as int?) ?? 0,
      totalCorrect: (map[QuizTypeStatisticsColumns.totalCorrect] as int?) ?? 0,
      totalIncorrect:
          (map[QuizTypeStatisticsColumns.totalIncorrect] as int?) ?? 0,
      totalSkipped: (map[QuizTypeStatisticsColumns.totalSkipped] as int?) ?? 0,
      averageScorePercentage:
          (map[QuizTypeStatisticsColumns.averageScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      bestScorePercentage:
          (map[QuizTypeStatisticsColumns.bestScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      bestSessionId: map[QuizTypeStatisticsColumns.bestSessionId] as String?,
      totalTimePlayedSeconds:
          (map[QuizTypeStatisticsColumns.totalTimePlayedSeconds] as int?) ?? 0,
      averageTimePerQuestion:
          (map[QuizTypeStatisticsColumns.averageTimePerQuestion] as num?)
                  ?.toDouble() ??
              0,
      totalPerfectScores:
          (map[QuizTypeStatisticsColumns.totalPerfectScores] as int?) ?? 0,
      lastPlayedAt: map[QuizTypeStatisticsColumns.lastPlayedAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[QuizTypeStatisticsColumns.lastPlayedAt] as int) * 1000,
            )
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[QuizTypeStatisticsColumns.createdAt] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[QuizTypeStatisticsColumns.updatedAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [QuizTypeStatistics] to a database map.
  Map<String, dynamic> toMap() {
    return {
      QuizTypeStatisticsColumns.id: id,
      QuizTypeStatisticsColumns.quizType: quizType,
      QuizTypeStatisticsColumns.quizCategory: quizCategory,
      QuizTypeStatisticsColumns.totalSessions: totalSessions,
      QuizTypeStatisticsColumns.totalCompletedSessions: totalCompletedSessions,
      QuizTypeStatisticsColumns.totalQuestions: totalQuestions,
      QuizTypeStatisticsColumns.totalCorrect: totalCorrect,
      QuizTypeStatisticsColumns.totalIncorrect: totalIncorrect,
      QuizTypeStatisticsColumns.totalSkipped: totalSkipped,
      QuizTypeStatisticsColumns.averageScorePercentage: averageScorePercentage,
      QuizTypeStatisticsColumns.bestScorePercentage: bestScorePercentage,
      QuizTypeStatisticsColumns.bestSessionId: bestSessionId,
      QuizTypeStatisticsColumns.totalTimePlayedSeconds: totalTimePlayedSeconds,
      QuizTypeStatisticsColumns.averageTimePerQuestion: averageTimePerQuestion,
      QuizTypeStatisticsColumns.totalPerfectScores: totalPerfectScores,
      QuizTypeStatisticsColumns.lastPlayedAt: lastPlayedAt != null
          ? lastPlayedAt!.millisecondsSinceEpoch ~/ 1000
          : null,
      QuizTypeStatisticsColumns.createdAt:
          createdAt.millisecondsSinceEpoch ~/ 1000,
      QuizTypeStatisticsColumns.updatedAt:
          updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [QuizTypeStatistics] with the given fields replaced.
  QuizTypeStatistics copyWith({
    String? id,
    String? quizType,
    String? quizCategory,
    int? totalSessions,
    int? totalCompletedSessions,
    int? totalQuestions,
    int? totalCorrect,
    int? totalIncorrect,
    int? totalSkipped,
    double? averageScorePercentage,
    double? bestScorePercentage,
    String? bestSessionId,
    int? totalTimePlayedSeconds,
    double? averageTimePerQuestion,
    int? totalPerfectScores,
    DateTime? lastPlayedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizTypeStatistics(
      id: id ?? this.id,
      quizType: quizType ?? this.quizType,
      quizCategory: quizCategory ?? this.quizCategory,
      totalSessions: totalSessions ?? this.totalSessions,
      totalCompletedSessions:
          totalCompletedSessions ?? this.totalCompletedSessions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      totalSkipped: totalSkipped ?? this.totalSkipped,
      averageScorePercentage:
          averageScorePercentage ?? this.averageScorePercentage,
      bestScorePercentage: bestScorePercentage ?? this.bestScorePercentage,
      bestSessionId: bestSessionId ?? this.bestSessionId,
      totalTimePlayedSeconds:
          totalTimePlayedSeconds ?? this.totalTimePlayedSeconds,
      averageTimePerQuestion:
          averageTimePerQuestion ?? this.averageTimePerQuestion,
      totalPerfectScores: totalPerfectScores ?? this.totalPerfectScores,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizTypeStatistics && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizTypeStatistics(type: $quizType, category: $quizCategory, avgScore: $averageScorePercentage%)';
  }
}
