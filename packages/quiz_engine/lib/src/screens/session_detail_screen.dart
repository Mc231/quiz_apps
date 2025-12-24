import 'package:flutter/material.dart';

import '../widgets/question_review_widget.dart';

/// Data model for session details.
class SessionDetailData {
  /// Creates a [SessionDetailData].
  const SessionDetailData({
    required this.id,
    required this.quizName,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalSkipped,
    required this.scorePercentage,
    required this.completionStatus,
    required this.startTime,
    required this.questions,
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

  /// Number of incorrect answers.
  final int totalIncorrect;

  /// Number of skipped questions.
  final int totalSkipped;

  /// Score as percentage.
  final double scorePercentage;

  /// Completion status.
  final String completionStatus;

  /// When the session started.
  final DateTime startTime;

  /// Duration in seconds.
  final int? durationSeconds;

  /// Optional quiz category.
  final String? quizCategory;

  /// List of answered questions.
  final List<ReviewedQuestion> questions;

  /// Whether this is a perfect score.
  bool get isPerfectScore => scorePercentage >= 100.0;

  /// Count of wrong answers.
  int get wrongAnswersCount =>
      questions.where((q) => !q.isCorrect && !q.isSkipped).length;
}

/// Filter mode for displaying questions.
enum QuestionFilterMode {
  /// Show all questions.
  all,

  /// Show only wrong answers.
  wrongOnly,
}

/// Localization texts for SessionDetailScreen.
class SessionDetailTexts {
  /// Creates [SessionDetailTexts].
  const SessionDetailTexts({
    required this.title,
    required this.reviewAnswersLabel,
    required this.practiceWrongAnswersLabel,
    required this.exportLabel,
    required this.deleteLabel,
    required this.scoreLabel,
    required this.correctLabel,
    required this.incorrectLabel,
    required this.skippedLabel,
    required this.durationLabel,
    required this.questionLabel,
    required this.yourAnswerLabel,
    required this.correctAnswerLabel,
    required this.formatDate,
    required this.formatStatus,
    required this.deleteDialogTitle,
    required this.deleteDialogMessage,
    required this.cancelLabel,
    this.showAllLabel = 'All',
    this.showWrongOnlyLabel = 'Wrong Only',
  });

  /// Screen title.
  final String title;

  /// Review answers section label.
  final String reviewAnswersLabel;

  /// Practice wrong answers button label.
  final String practiceWrongAnswersLabel;

  /// Export button label.
  final String exportLabel;

  /// Delete button label.
  final String deleteLabel;

  /// Score label.
  final String scoreLabel;

  /// Correct label.
  final String correctLabel;

  /// Incorrect label.
  final String incorrectLabel;

  /// Skipped label.
  final String skippedLabel;

  /// Duration label.
  final String durationLabel;

  /// Question label formatter.
  final String Function(int number) questionLabel;

  /// Your answer label.
  final String yourAnswerLabel;

  /// Correct answer label.
  final String correctAnswerLabel;

  /// Date formatter callback.
  final String Function(DateTime date) formatDate;

  /// Status formatter callback.
  final (String label, Color color) Function(String status, bool isPerfect)
      formatStatus;

  /// Delete dialog title.
  final String deleteDialogTitle;

  /// Delete dialog message.
  final String deleteDialogMessage;

  /// Cancel button label.
  final String cancelLabel;

  /// Label for showing all questions.
  final String showAllLabel;

  /// Label for showing only wrong answers.
  final String showWrongOnlyLabel;
}

/// Screen displaying session details with question review.
class SessionDetailScreen extends StatefulWidget {
  /// Creates a [SessionDetailScreen].
  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.texts,
    this.onPracticeWrongAnswers,
    this.onExport,
    this.onDelete,
    this.imageBuilder,
  });

  /// Session data to display.
  final SessionDetailData session;

  /// Localization texts.
  final SessionDetailTexts texts;

  /// Callback to practice wrong answers.
  final VoidCallback? onPracticeWrongAnswers;

  /// Callback to export session.
  final VoidCallback? onExport;

  /// Callback to delete session.
  final VoidCallback? onDelete;

  /// Optional image builder for question images.
  final Widget Function(String path)? imageBuilder;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  QuestionFilterMode _filterMode = QuestionFilterMode.all;

  List<ReviewedQuestion> get _filteredQuestions {
    if (_filterMode == QuestionFilterMode.wrongOnly) {
      return widget.session.questions
          .where((q) => !q.isCorrect && !q.isSkipped)
          .toList();
    }
    return widget.session.questions;
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(context)),
        if (widget.session.wrongAnswersCount > 0 &&
            widget.onPracticeWrongAnswers != null)
          SliverToBoxAdapter(child: _buildPracticeButton(context)),
        SliverToBoxAdapter(child: _buildActionsRow(context)),
        SliverToBoxAdapter(
          child: _buildReviewHeader(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return QuestionReviewWidget(
                question: filteredQuestions[index],
                questionLabel: widget.texts.questionLabel,
                yourAnswerLabel: widget.texts.yourAnswerLabel,
                correctAnswerLabel: widget.texts.correctAnswerLabel,
                skippedLabel: widget.texts.skippedLabel,
                imageBuilder: widget.imageBuilder,
              );
            },
            childCount: filteredQuestions.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildReviewHeader(BuildContext context) {
    final hasWrongAnswers = widget.session.wrongAnswersCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.texts.reviewAnswersLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (hasWrongAnswers) _buildFilterToggle(context),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(BuildContext context) {
    return SegmentedButton<QuestionFilterMode>(
      segments: [
        ButtonSegment<QuestionFilterMode>(
          value: QuestionFilterMode.all,
          label: Text(widget.texts.showAllLabel),
        ),
        ButtonSegment<QuestionFilterMode>(
          value: QuestionFilterMode.wrongOnly,
          label: Text(widget.texts.showWrongOnlyLabel),
        ),
      ],
      selected: {_filterMode},
      onSelectionChanged: (Set<QuestionFilterMode> newSelection) {
        setState(() {
          _filterMode = newSelection.first;
        });
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = widget.texts
        .formatStatus(widget.session.completionStatus, widget.session.isPerfectScore);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.quizName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.texts.formatDate(widget.session.startTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Score circle
            _buildScoreCircle(context),
            const SizedBox(height: 24),
            // Stats row
            _buildStatsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final scoreColor = _getScoreColor(widget.session.scorePercentage);

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: widget.session.scorePercentage / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.session.scorePercentage.round()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  widget.texts.scoreLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          icon: Icons.check_circle,
          color: Colors.green,
          value: widget.session.totalCorrect.toString(),
          label: widget.texts.correctLabel,
        ),
        _buildStatItem(
          context,
          icon: Icons.cancel,
          color: Colors.red,
          value: widget.session.totalIncorrect.toString(),
          label: widget.texts.incorrectLabel,
        ),
        if (widget.session.totalSkipped > 0)
          _buildStatItem(
            context,
            icon: Icons.skip_next,
            color: Colors.orange,
            value: widget.session.totalSkipped.toString(),
            label: widget.texts.skippedLabel,
          ),
        if (widget.session.durationSeconds != null)
          _buildStatItem(
            context,
            icon: Icons.timer,
            color: Colors.blue,
            value: _formatDuration(widget.session.durationSeconds!),
            label: widget.texts.durationLabel,
          ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: widget.onPracticeWrongAnswers,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.replay),
        label: Text(
          '${widget.texts.practiceWrongAnswersLabel} (${widget.session.wrongAnswersCount})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.onExport != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.share),
                label: Text(widget.texts.exportLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (widget.onExport != null && widget.onDelete != null)
            const SizedBox(width: 12),
          if (widget.onDelete != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  widget.texts.deleteLabel,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.texts.deleteDialogTitle),
        content: Text(widget.texts.deleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.texts.cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(widget.texts.deleteLabel),
          ),
        ],
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
