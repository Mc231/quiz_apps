/// Service for exporting all user data (GDPR compliance).
///
/// Exports user data to JSON format for data portability and
/// regulatory compliance (GDPR Article 20 - Right to data portability).
library;

import 'dart:convert';

import '../data_sources/quiz_session_data_source.dart';
import '../data_sources/question_answer_data_source.dart';
import '../data_sources/statistics_data_source.dart';
import '../data_sources/settings_data_source.dart';
import '../models/quiz_session.dart';
import '../models/question_answer.dart';
import '../models/global_statistics.dart';
import '../models/quiz_type_statistics.dart';
import '../models/daily_statistics.dart';
import '../models/user_settings_model.dart';

/// Result of a data export operation.
class DataExportResult {
  /// Creates a [DataExportResult].
  const DataExportResult({
    required this.success,
    required this.data,
    this.errorMessage,
    required this.exportedAt,
    required this.itemCounts,
  });

  /// Whether the export was successful.
  final bool success;

  /// The exported data as JSON string.
  final String data;

  /// Error message if export failed.
  final String? errorMessage;

  /// Timestamp when data was exported.
  final DateTime exportedAt;

  /// Counts of exported items by type.
  final Map<String, int> itemCounts;

  /// Total number of exported items.
  int get totalItems => itemCounts.values.fold(0, (a, b) => a + b);
}

/// Configuration for data export.
class DataExportConfig {
  /// Creates a [DataExportConfig].
  const DataExportConfig({
    this.includeSessions = true,
    this.includeAnswers = true,
    this.includeStatistics = true,
    this.includeSettings = true,
    this.includeMetadata = true,
    this.prettyPrint = true,
    this.sessionFilter,
    this.maxSessions,
  });

  /// Default configuration exporting all data.
  static const full = DataExportConfig();

  /// Minimal configuration (sessions only, no answers).
  static const minimal = DataExportConfig(
    includeAnswers: false,
    includeStatistics: false,
  );

  /// Whether to include quiz sessions.
  final bool includeSessions;

  /// Whether to include question answers (requires includeSessions).
  final bool includeAnswers;

  /// Whether to include statistics.
  final bool includeStatistics;

  /// Whether to include user settings.
  final bool includeSettings;

  /// Whether to include export metadata.
  final bool includeMetadata;

  /// Whether to format JSON with indentation.
  final bool prettyPrint;

  /// Optional filter for sessions.
  final QuizSessionFilter? sessionFilter;

  /// Maximum number of sessions to export (null = all).
  final int? maxSessions;
}

/// Service for exporting all user data.
///
/// Supports GDPR-compliant data export by allowing users to download
/// all their data in a portable JSON format.
///
/// Example:
/// ```dart
/// final service = DataExportService(
///   sessionDataSource: sessionDataSource,
///   answerDataSource: answerDataSource,
///   statisticsDataSource: statisticsDataSource,
///   settingsDataSource: settingsDataSource,
/// );
///
/// final result = await service.exportAllData();
/// if (result.success) {
///   // Save result.data to file or share
/// }
/// ```
class DataExportService {
  /// Creates a [DataExportService].
  DataExportService({
    required QuizSessionDataSource sessionDataSource,
    required QuestionAnswerDataSource answerDataSource,
    required StatisticsDataSource statisticsDataSource,
    required SettingsDataSource settingsDataSource,
  })  : _sessionDataSource = sessionDataSource,
        _answerDataSource = answerDataSource,
        _statisticsDataSource = statisticsDataSource,
        _settingsDataSource = settingsDataSource;

  final QuizSessionDataSource _sessionDataSource;
  final QuestionAnswerDataSource _answerDataSource;
  final StatisticsDataSource _statisticsDataSource;
  final SettingsDataSource _settingsDataSource;

  /// Exports all user data according to the configuration.
  ///
  /// Returns a [DataExportResult] containing the exported JSON data
  /// and metadata about the export.
  Future<DataExportResult> exportAllData({
    DataExportConfig config = DataExportConfig.full,
  }) async {
    final exportedAt = DateTime.now();
    final itemCounts = <String, int>{};

    try {
      final exportData = <String, dynamic>{};

      // Add metadata
      if (config.includeMetadata) {
        exportData['metadata'] = _buildMetadata(exportedAt);
      }

      // Export sessions with answers
      if (config.includeSessions) {
        final sessionsData = await _exportSessions(
          config: config,
          itemCounts: itemCounts,
        );
        exportData['sessions'] = sessionsData;
      }

      // Export statistics
      if (config.includeStatistics) {
        final statsData = await _exportStatistics(itemCounts);
        exportData['statistics'] = statsData;
      }

      // Export settings
      if (config.includeSettings) {
        final settingsData = await _exportSettings(itemCounts);
        exportData['settings'] = settingsData;
      }

      // Convert to JSON
      final encoder = config.prettyPrint
          ? const JsonEncoder.withIndent('  ')
          : const JsonEncoder();
      final jsonData = encoder.convert(exportData);

      return DataExportResult(
        success: true,
        data: jsonData,
        exportedAt: exportedAt,
        itemCounts: itemCounts,
      );
    } catch (e) {
      return DataExportResult(
        success: false,
        data: '',
        errorMessage: e.toString(),
        exportedAt: exportedAt,
        itemCounts: itemCounts,
      );
    }
  }

  /// Builds export metadata.
  Map<String, dynamic> _buildMetadata(DateTime exportedAt) {
    return {
      'exportVersion': '1.0',
      'exportedAt': exportedAt.toIso8601String(),
      'format': 'quiz_app_export',
      'description':
          'User data export for GDPR compliance (Article 20 - Right to data portability)',
    };
  }

  /// Exports sessions with optional answers.
  Future<List<Map<String, dynamic>>> _exportSessions({
    required DataExportConfig config,
    required Map<String, int> itemCounts,
  }) async {
    final sessions = await _sessionDataSource.getAllSessions(
      filter: config.sessionFilter,
      limit: config.maxSessions,
    );

    itemCounts['sessions'] = sessions.length;

    final sessionsData = <Map<String, dynamic>>[];
    int totalAnswers = 0;

    for (final session in sessions) {
      final sessionMap = _sessionToMap(session);

      if (config.includeAnswers) {
        final answers =
            await _answerDataSource.getAnswersBySessionId(session.id);
        sessionMap['answers'] = answers.map(_answerToMap).toList();
        totalAnswers += answers.length;
      }

      sessionsData.add(sessionMap);
    }

    if (config.includeAnswers) {
      itemCounts['answers'] = totalAnswers;
    }

    return sessionsData;
  }

  /// Exports statistics.
  Future<Map<String, dynamic>> _exportStatistics(
    Map<String, int> itemCounts,
  ) async {
    final global = await _statisticsDataSource.getGlobalStatistics();
    final quizTypes = await _statisticsDataSource.getAllQuizTypeStatistics();
    final dailyStats = await _statisticsDataSource.getDailyStatisticsRange(
      DateTime(2000),
      DateTime.now(),
    );

    itemCounts['quizTypeStats'] = quizTypes.length;
    itemCounts['dailyStats'] = dailyStats.length;

    return {
      'global': _globalStatsToMap(global),
      'byQuizType': quizTypes.map(_quizTypeStatsToMap).toList(),
      'daily': dailyStats.map(_dailyStatsToMap).toList(),
    };
  }

  /// Exports settings.
  Future<Map<String, dynamic>> _exportSettings(
    Map<String, int> itemCounts,
  ) async {
    final settings = await _settingsDataSource.getSettings();
    itemCounts['settings'] = 1;

    return _settingsToMap(settings);
  }

  // ===========================================================================
  // Mapping Functions
  // ===========================================================================

  Map<String, dynamic> _sessionToMap(QuizSession session) {
    return {
      'id': session.id,
      'quizType': session.quizType,
      'quizId': session.quizId,
      'quizName': session.quizName,
      'quizCategory': session.quizCategory,
      'mode': session.mode.value,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'totalQuestions': session.totalQuestions,
      'totalAnswered': session.totalAnswered,
      'totalCorrect': session.totalCorrect,
      'totalFailed': session.totalFailed,
      'totalSkipped': session.totalSkipped,
      'scorePercentage': session.scorePercentage,
      'score': session.score,
      'bestStreak': session.bestStreak,
      'durationSeconds': session.durationSeconds,
      'completionStatus': session.completionStatus.value,
      'hintsUsed5050': session.hintsUsed5050,
      'hintsUsedSkip': session.hintsUsedSkip,
      'livesUsed': session.livesUsed,
      'timeLimitSeconds': session.timeLimitSeconds,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _answerToMap(QuestionAnswer answer) {
    return {
      'id': answer.id,
      'sessionId': answer.sessionId,
      'questionId': answer.questionId,
      'questionNumber': answer.questionNumber,
      'questionType': answer.questionType.value,
      'questionContent': answer.questionContent,
      'questionResourceUrl': answer.questionResourceUrl,
      'correctAnswer': {
        'id': answer.correctAnswer.id,
        'text': answer.correctAnswer.text,
      },
      'userAnswer': answer.userAnswer != null
          ? {
              'id': answer.userAnswer!.id,
              'text': answer.userAnswer!.text,
            }
          : null,
      'isCorrect': answer.isCorrect,
      'answerStatus': answer.answerStatus.value,
      'timeSpentSeconds': answer.timeSpentSeconds,
      'answeredAt': answer.answeredAt?.toIso8601String(),
      'hintUsed': answer.hintUsed.value,
      'explanation': answer.explanation,
    };
  }

  Map<String, dynamic> _globalStatsToMap(GlobalStatistics stats) {
    return {
      'totalSessions': stats.totalSessions,
      'totalCompletedSessions': stats.totalCompletedSessions,
      'totalCancelledSessions': stats.totalCancelledSessions,
      'totalQuestionsAnswered': stats.totalQuestionsAnswered,
      'totalCorrectAnswers': stats.totalCorrectAnswers,
      'totalIncorrectAnswers': stats.totalIncorrectAnswers,
      'totalSkippedQuestions': stats.totalSkippedQuestions,
      'totalTimePlayedSeconds': stats.totalTimePlayedSeconds,
      'averageScorePercentage': stats.averageScorePercentage,
      'bestScorePercentage': stats.bestScorePercentage,
      'worstScorePercentage': stats.worstScorePercentage,
      'currentStreak': stats.currentStreak,
      'bestStreak': stats.bestStreak,
      'totalPerfectScores': stats.totalPerfectScores,
      'consecutiveDaysPlayed': stats.consecutiveDaysPlayed,
      'totalAchievementsUnlocked': stats.totalAchievementsUnlocked,
      'totalAchievementPoints': stats.totalAchievementPoints,
      'firstSessionDate': stats.firstSessionDate?.toIso8601String(),
      'lastSessionDate': stats.lastSessionDate?.toIso8601String(),
      'createdAt': stats.createdAt.toIso8601String(),
      'updatedAt': stats.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _quizTypeStatsToMap(QuizTypeStatistics stats) {
    return {
      'quizType': stats.quizType,
      'quizCategory': stats.quizCategory,
      'totalSessions': stats.totalSessions,
      'totalCompletedSessions': stats.totalCompletedSessions,
      'totalQuestions': stats.totalQuestions,
      'totalCorrect': stats.totalCorrect,
      'totalIncorrect': stats.totalIncorrect,
      'totalSkipped': stats.totalSkipped,
      'totalTimePlayedSeconds': stats.totalTimePlayedSeconds,
      'averageScorePercentage': stats.averageScorePercentage,
      'bestScorePercentage': stats.bestScorePercentage,
      'totalPerfectScores': stats.totalPerfectScores,
      'lastPlayedAt': stats.lastPlayedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _dailyStatsToMap(DailyStatistics stats) {
    return {
      'date': stats.date,
      'sessionsPlayed': stats.sessionsPlayed,
      'sessionsCompleted': stats.sessionsCompleted,
      'questionsAnswered': stats.questionsAnswered,
      'correctAnswers': stats.correctAnswers,
      'incorrectAnswers': stats.incorrectAnswers,
      'skippedAnswers': stats.skippedAnswers,
      'timePlayedSeconds': stats.timePlayedSeconds,
      'averageScorePercentage': stats.averageScorePercentage,
      'bestScorePercentage': stats.bestScorePercentage,
      'perfectScores': stats.perfectScores,
    };
  }

  Map<String, dynamic> _settingsToMap(UserSettingsModel settings) {
    return {
      'soundEnabled': settings.soundEnabled,
      'hapticEnabled': settings.hapticEnabled,
      'exitConfirmationEnabled': settings.exitConfirmationEnabled,
      'themeMode': settings.themeMode.name,
      'language': settings.language,
      'hints5050Available': settings.hints5050Available,
      'hintsSkipAvailable': settings.hintsSkipAvailable,
      'lastPlayedQuizType': settings.lastPlayedQuizType,
      'lastPlayedCategory': settings.lastPlayedCategory,
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }
}

/// Extension for generating export filename.
extension DataExportResultExtension on DataExportResult {
  /// Generates a suggested filename for the export.
  String get suggestedFilename {
    final date = exportedAt.toIso8601String().split('T').first;
    return 'quiz_data_export_$date.json';
  }

  /// Returns a human-readable summary of exported data.
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('Data Export Summary');
    buffer.writeln('=' * 30);
    buffer.writeln('Exported at: ${exportedAt.toIso8601String()}');
    buffer.writeln('Total items: $totalItems');
    buffer.writeln();
    for (final entry in itemCounts.entries) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }
    return buffer.toString();
  }
}
