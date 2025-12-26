import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Data model for session card display.
class SessionCardData {
  /// Creates a [SessionCardData].
  const SessionCardData({
    required this.id,
    required this.quizName,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.scorePercentage,
    required this.completionStatus,
    required this.startTime,
    this.durationSeconds,
    this.quizCategory,
  });

  /// Unique session ID.
  final String id;

  /// Display name of the quiz.
  final String quizName;

  /// Total questions in the session.
  final int totalQuestions;

  /// Number of correct answers.
  final int totalCorrect;

  /// Score as percentage.
  final double scorePercentage;

  /// Completion status (completed, cancelled, timeout, failed).
  final String completionStatus;

  /// When the session started.
  final DateTime startTime;

  /// Duration in seconds.
  final int? durationSeconds;

  /// Optional quiz category.
  final String? quizCategory;

  /// Whether this is a perfect score.
  bool get isPerfectScore => scorePercentage >= 100.0;
}

/// Callback to format dates for display.
typedef DateFormatter = String Function(DateTime date);

/// Callback to get status label and color.
typedef StatusFormatter = (String label, Color color) Function(
  String status,
  bool isPerfect,
);

/// A card widget displaying quiz session summary.
///
/// Shows quiz name, score, date, and completion status with visual
/// indicators for performance.
class SessionCard extends StatelessWidget {
  /// Creates a [SessionCard].
  const SessionCard({
    super.key,
    required this.data,
    required this.questionsLabel,
    required this.formatDate,
    required this.formatStatus,
    this.onTap,
  });

  /// Session data to display.
  final SessionCardData data;

  /// Label for questions (e.g., "questions").
  final String questionsLabel;

  /// Callback to format dates.
  final DateFormatter formatDate;

  /// Callback to format status.
  final StatusFormatter formatStatus;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = QuizL10n.of(context);

    final semanticLabel = l10n.accessibilitySessionCard(
      formatDate(data.startTime),
      data.totalCorrect,
      data.totalQuestions,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: onTap != null,
      child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        excludeFromSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 12),
              _buildScoreRow(context),
              const SizedBox(height: 8),
              _buildFooter(context),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final (label, color) = formatStatus(
      data.completionStatus,
      data.isPerfectScore,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.quizName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (data.quizCategory != null) ...[
                const SizedBox(height: 4),
                Text(
                  data.quizCategory!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
        _buildStatusBadge(label, color),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context) {
    final scoreColor = _getScoreColor(data.scorePercentage);

    return Row(
      children: [
        // Score circle
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: data.scorePercentage / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${data.scorePercentage.round()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Score details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.totalCorrect}/${data.totalQuestions} $questionsLabel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (data.durationSeconds != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDuration(data.durationSeconds!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
        // Arrow indicator
        if (onTap != null)
          ExcludeSemantics(
            child: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      formatDate(data.startTime),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}