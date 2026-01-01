import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';
import '../share/share_bottom_sheet.dart';
import '../widgets/question_review_widget.dart';
import 'session_detail_data.dart';
import 'session_detail_texts.dart';

/// Screen displaying session details with question review.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
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
    this.shareService,
    this.shareConfig,
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

  /// Optional share service for sharing session results.
  final ShareService? shareService;

  /// Optional configuration for share UI.
  final ShareBottomSheetConfig? shareConfig;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  QuestionFilterMode _filterMode = QuestionFilterMode.all;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void initState() {
    super.initState();
    // Log screen view after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logScreenView();
    });
  }

  void _logScreenView() {
    final daysAgo = DateTime.now().difference(widget.session.startTime).inDays;

    // Screen view event
    _analyticsService.logEvent(
      ScreenViewEvent.sessionDetail(
        sessionId: widget.session.id,
        quizName: widget.session.quizName,
        scorePercentage: widget.session.scorePercentage,
        daysAgo: daysAgo,
      ),
    );

    // Interaction event for session viewed
    _analyticsService.logEvent(
      InteractionEvent.sessionViewed(
        sessionId: widget.session.id,
        quizName: widget.session.quizName,
        scorePercentage: widget.session.scorePercentage,
        daysAgo: daysAgo,
      ),
    );
  }

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
    final l10n = QuizL10n.of(context);
    final hasShare = widget.shareService != null;
    final hasExport = widget.onExport != null;
    final hasDelete = widget.onDelete != null;

    // Count number of buttons to show
    final buttonCount = (hasShare ? 1 : 0) + (hasExport ? 1 : 0) + (hasDelete ? 1 : 0);
    if (buttonCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Share button (social media share with image)
          if (hasShare)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showShareSheet(context, l10n),
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (hasShare && (hasExport || hasDelete))
            const SizedBox(width: 12),
          // Export button (file export)
          if (hasExport)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.download),
                label: Text(widget.texts.exportLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (hasExport && hasDelete)
            const SizedBox(width: 12),
          // Delete button
          if (hasDelete)
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

  void _showShareSheet(BuildContext context, QuizEngineLocalizations l10n) {
    final shareResult = ShareResult.fromQuizCompletion(
      correctCount: widget.session.totalCorrect,
      totalCount: widget.session.totalQuestions,
      categoryName: widget.session.quizName,
      mode: 'standard',
      timeTaken: widget.session.durationSeconds != null
          ? Duration(seconds: widget.session.durationSeconds!)
          : null,
    );

    ShareBottomSheet.show(
      context: context,
      result: shareResult,
      shareService: widget.shareService!,
      config: widget.shareConfig ?? const ShareBottomSheetConfig(),
      onShareComplete: (type, result) {
        if (result is ShareOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.shareSuccess)),
          );
        }
      },
      onShareError: (type, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shareError)),
        );
      },
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

/// BLoC-compatible content widget for session detail.
///
/// This widget receives all state and callbacks externally, making it
/// suitable for use with [SessionDetailBloc] via [SessionDetailBuilder].
class SessionDetailContent extends StatelessWidget {
  /// Creates a [SessionDetailContent].
  const SessionDetailContent({
    super.key,
    required this.session,
    required this.texts,
    this.filterMode = QuestionFilterMode.all,
    this.isDeleting = false,
    this.onFilterModeChanged,
    this.onPracticeWrongAnswers,
    this.onExport,
    this.onDelete,
    this.onShare,
    this.imageBuilder,
  });

  /// Session data to display.
  final SessionDetailData session;

  /// Localization texts.
  final SessionDetailTexts texts;

  /// Current filter mode for questions.
  final QuestionFilterMode filterMode;

  /// Whether the session is being deleted.
  final bool isDeleting;

  /// Callback when filter mode changes.
  final void Function(QuestionFilterMode mode)? onFilterModeChanged;

  /// Callback to practice wrong answers.
  final VoidCallback? onPracticeWrongAnswers;

  /// Callback to export session.
  final VoidCallback? onExport;

  /// Callback to delete session.
  final VoidCallback? onDelete;

  /// Callback to share session via social media.
  final VoidCallback? onShare;

  /// Optional image builder for question images.
  final Widget Function(String path)? imageBuilder;

  List<ReviewedQuestion> get _filteredQuestions {
    if (filterMode == QuestionFilterMode.wrongOnly) {
      return session.questions
          .where((q) => !q.isCorrect && !q.isSkipped)
          .toList();
    }
    return session.questions;
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(context)),
        if (session.wrongAnswersCount > 0 && onPracticeWrongAnswers != null)
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
                questionLabel: texts.questionLabel,
                yourAnswerLabel: texts.yourAnswerLabel,
                correctAnswerLabel: texts.correctAnswerLabel,
                skippedLabel: texts.skippedLabel,
                imageBuilder: imageBuilder,
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
    final hasWrongAnswers = session.wrongAnswersCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texts.reviewAnswersLabel,
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
    final l10n = QuizL10n.of(context);

    return Semantics(
      label: l10n.accessibilityFilterQuestions,
      hint: l10n.accessibilityFilterHint,
      child: SegmentedButton<QuestionFilterMode>(
        segments: [
          ButtonSegment<QuestionFilterMode>(
            value: QuestionFilterMode.all,
            label: Text(texts.showAllLabel),
          ),
          ButtonSegment<QuestionFilterMode>(
            value: QuestionFilterMode.wrongOnly,
            label: Text(texts.showWrongOnlyLabel),
          ),
        ],
        selected: {filterMode},
        onSelectionChanged: (Set<QuestionFilterMode> newSelection) {
          onFilterModeChanged?.call(newSelection.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) =
        texts.formatStatus(session.completionStatus, session.isPerfectScore);

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
                        session.quizName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        texts.formatDate(session.startTime),
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
    final scoreColor = _getScoreColor(session.scorePercentage);

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
                value: session.scorePercentage / 100,
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
                  '${session.scorePercentage.round()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  texts.scoreLabel,
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
          value: session.totalCorrect.toString(),
          label: texts.correctLabel,
        ),
        _buildStatItem(
          context,
          icon: Icons.cancel,
          color: Colors.red,
          value: session.totalIncorrect.toString(),
          label: texts.incorrectLabel,
        ),
        if (session.totalSkipped > 0)
          _buildStatItem(
            context,
            icon: Icons.skip_next,
            color: Colors.orange,
            value: session.totalSkipped.toString(),
            label: texts.skippedLabel,
          ),
        if (session.durationSeconds != null)
          _buildStatItem(
            context,
            icon: Icons.timer,
            color: Colors.blue,
            value: _formatDuration(session.durationSeconds!),
            label: texts.durationLabel,
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
        onPressed: onPracticeWrongAnswers,
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
          '${texts.practiceWrongAnswersLabel} (${session.wrongAnswersCount})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final hasShare = onShare != null;
    final hasExport = onExport != null;
    final hasDelete = onDelete != null;

    // Count number of buttons
    final buttonCount = (hasShare ? 1 : 0) + (hasExport ? 1 : 0) + (hasDelete ? 1 : 0);
    if (buttonCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Share button (social media share)
          if (hasShare)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : onShare,
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (hasShare && (hasExport || hasDelete))
            const SizedBox(width: 12),
          // Export button (file export)
          if (hasExport)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : onExport,
                icon: const Icon(Icons.download),
                label: Text(texts.exportLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (hasExport && hasDelete) const SizedBox(width: 12),
          // Delete button
          if (hasDelete)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isDeleting ? null : () => _showDeleteDialog(context),
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  texts.deleteLabel,
                  style: TextStyle(color: isDeleting ? null : Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: isDeleting ? Colors.grey : Colors.red),
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
        title: Text(texts.deleteDialogTitle),
        content: Text(texts.deleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(texts.cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(texts.deleteLabel),
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
