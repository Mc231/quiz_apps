import 'dart:convert';

import '../models/quiz_session.dart';
import '../models/question_answer.dart';

/// Service for exporting quiz sessions to various formats.
class SessionExportService {
  /// Creates a [SessionExportService].
  const SessionExportService();

  /// Exports a session to JSON format.
  String exportToJson({
    required QuizSession session,
    List<QuestionAnswer>? answers,
  }) {
    final data = _sessionToMap(session, answers);
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Exports a session to CSV format.
  String exportToCsv({
    required QuizSession session,
    required List<QuestionAnswer> answers,
  }) {
    final buffer = StringBuffer();

    // Header row
    buffer.writeln(
      'Question Number,Question ID,Correct Answer,User Answer,Is Correct,Time Spent (s)',
    );

    // Data rows
    for (final answer in answers) {
      buffer.writeln(
        '${answer.questionNumber},'
        '${_escapeCsv(answer.questionId)},'
        '${_escapeCsv(answer.correctAnswer.text)},'
        '${_escapeCsv(answer.userAnswer?.text ?? 'SKIPPED')},'
        '${answer.isCorrect},'
        '${answer.timeSpentSeconds ?? 0}',
      );
    }

    return buffer.toString();
  }

  /// Exports session summary to a shareable text format.
  String exportToShareableText({
    required QuizSession session,
    required String quizName,
    required String scoreLabel,
    required String correctLabel,
    required String incorrectLabel,
    required String skippedLabel,
    required String durationLabel,
    required String dateLabel,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('$quizName Results');
    buffer.writeln('=' * 30);
    buffer.writeln();
    buffer
        .writeln('$scoreLabel: ${session.scorePercentage.toStringAsFixed(1)}%');
    buffer.writeln('$correctLabel: ${session.totalCorrect}');
    buffer.writeln('$incorrectLabel: ${session.totalFailed}');

    if (session.totalSkipped > 0) {
      buffer.writeln('$skippedLabel: ${session.totalSkipped}');
    }

    if (session.durationSeconds != null) {
      buffer.writeln(
        '$durationLabel: ${_formatDuration(session.durationSeconds!)}',
      );
    }

    buffer.writeln(
      '$dateLabel: ${_formatDate(session.startTime)}',
    );

    return buffer.toString();
  }

  Map<String, dynamic> _sessionToMap(
    QuizSession session,
    List<QuestionAnswer>? answers,
  ) {
    return {
      'id': session.id,
      'quizType': session.quizType,
      'quizId': session.quizId,
      'quizName': session.quizName,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'totalQuestions': session.totalQuestions,
      'totalCorrect': session.totalCorrect,
      'totalFailed': session.totalFailed,
      'totalSkipped': session.totalSkipped,
      'scorePercentage': session.scorePercentage,
      'durationSeconds': session.durationSeconds,
      'completionStatus': session.completionStatus.name,
      if (answers != null) 'answers': answers.map(_answerToMap).toList(),
    };
  }

  Map<String, dynamic> _answerToMap(QuestionAnswer answer) {
    return {
      'questionId': answer.questionId,
      'questionNumber': answer.questionNumber,
      'correctAnswer': answer.correctAnswer.text,
      'userAnswer': answer.userAnswer?.text,
      'isCorrect': answer.isCorrect,
      'answerStatus': answer.answerStatus.value,
      'timeSpentSeconds': answer.timeSpentSeconds,
      'answeredAt': answer.answeredAt?.toIso8601String(),
    };
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
