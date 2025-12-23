import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_services/shared_services.dart';

/// Page displaying session details with question review.
class SessionDetailPage extends StatefulWidget {
  /// Creates a [SessionDetailPage].
  const SessionDetailPage({
    super.key,
    required this.session,
    required this.storageService,
    this.onDeleted,
  });

  /// The session to display.
  final QuizSession session;

  /// Storage service for operations.
  final StorageService storageService;

  /// Callback when session is deleted.
  final VoidCallback? onDeleted;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  List<QuestionAnswer> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    final result =
        await widget.storageService.getSessionWithAnswers(widget.session.id);
    result.ifSuccess((sessionWithAnswers) {
      if (sessionWithAnswers != null) {
        setState(() {
          _answers = sessionWithAnswers.answers;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
    result.ifFailure((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final detailData = _convertToDetailData(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetails),
      ),
      body: SessionDetailScreen(
        session: detailData,
        texts: SessionDetailTexts(
          title: l10n.sessionDetails,
          reviewAnswersLabel: l10n.reviewAnswers,
          practiceWrongAnswersLabel: l10n.practiceWrongAnswers,
          exportLabel: l10n.share,
          deleteLabel: l10n.delete,
          scoreLabel: l10n.score,
          correctLabel: l10n.correct,
          incorrectLabel: l10n.incorrect,
          skippedLabel: l10n.skipped,
          durationLabel: l10n.duration,
          questionLabel: (n) => l10n.questionNumber(n),
          yourAnswerLabel: l10n.yourAnswer,
          correctAnswerLabel: l10n.correctAnswer,
          formatDate: (date) => _formatDate(context, date),
          formatStatus: (status, isPerfect) =>
              _formatStatus(context, status, isPerfect),
          deleteDialogTitle: l10n.deleteSession,
          deleteDialogMessage: l10n.deleteSessionMessage,
          cancelLabel: l10n.cancel,
        ),
        onPracticeWrongAnswers: detailData.wrongAnswersCount > 0
            ? () => _onPracticeWrongAnswers(context)
            : null,
        onExport: () => _onExport(context),
        onDelete: () => _onDelete(context),
        imageBuilder: (path) => _buildFlagImage(path),
      ),
    );
  }

  SessionDetailData _convertToDetailData(BuildContext context) {
    return SessionDetailData(
      id: widget.session.id,
      quizName: _getQuizName(context, widget.session.quizId),
      totalQuestions: widget.session.totalQuestions,
      totalCorrect: widget.session.totalCorrect,
      totalIncorrect: widget.session.totalFailed,
      totalSkipped: widget.session.totalSkipped,
      scorePercentage: widget.session.scorePercentage,
      completionStatus: widget.session.completionStatus.name,
      startTime: widget.session.startTime,
      durationSeconds: widget.session.durationSeconds,
      quizCategory: widget.session.quizCategory,
      questions: _answers.map((answer) {
        return ReviewedQuestion(
          questionNumber: answer.questionNumber,
          questionText: _getCountryName(context, answer.questionId),
          correctAnswer: answer.correctAnswer.text,
          userAnswer: answer.userAnswer?.text,
          isCorrect: answer.isCorrect,
          isSkipped: answer.answerStatus == AnswerStatus.skipped,
          questionImagePath: answer.questionId,
          explanation: answer.explanation,
        );
      }).toList(),
    );
  }

  String _getQuizName(BuildContext context, String? quizId) {
    final l10n = AppLocalizations.of(context)!;
    if (quizId == null) return 'Flags Quiz';

    switch (quizId.toLowerCase()) {
      case 'all':
        return l10n.all;
      case 'europe':
        return l10n.europe;
      case 'asia':
        return l10n.asia;
      case 'africa':
        return l10n.africa;
      case 'north_america':
      case 'northamerica':
        return l10n.northAmerica;
      case 'south_america':
      case 'southamerica':
        return l10n.southAmerica;
      case 'oceania':
        return l10n.oceania;
      default:
        return quizId;
    }
  }

  String _getCountryName(BuildContext context, String countryCode) {
    // Return the country code as-is for now
    // The actual country name is in the question content or can be looked up
    return countryCode.toUpperCase();
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${l10n.today} ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return '${l10n.yesterday} ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return l10n.daysAgo(diff.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  (String, Color) _formatStatus(
    BuildContext context,
    String status,
    bool isPerfect,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case 'completed':
        return isPerfect
            ? (l10n.perfectScore, Colors.amber)
            : (l10n.sessionCompleted, Colors.green);
      case 'cancelled':
        return (l10n.sessionCancelled, Colors.orange);
      case 'timeout':
        return (l10n.sessionTimeout, Colors.red);
      case 'failed':
        return (l10n.sessionFailed, Colors.red);
      default:
        return (status, Colors.grey);
    }
  }

  Widget _buildFlagImage(String countryCode) {
    return Image.asset(
      'assets/images/${countryCode.toUpperCase()}.png',
      width: double.infinity,
      height: 100,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 100,
          color: Colors.grey[200],
          child: const Icon(Icons.flag, size: 50),
        );
      },
    );
  }

  void _onPracticeWrongAnswers(BuildContext context) {
    // TODO: Implement practice wrong answers mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Practice mode coming soon!'),
      ),
    );
  }

  Future<void> _onExport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final exportService = const SessionExportService();

    final text = exportService.exportToShareableText(
      session: widget.session,
      quizName: _getQuizName(context, widget.session.quizId),
      scoreLabel: l10n.score,
      correctLabel: l10n.correct,
      incorrectLabel: l10n.incorrect,
      skippedLabel: l10n.skipped,
      durationLabel: l10n.duration,
      dateLabel: l10n.today,
    );

    await Share.share(text);
  }

  Future<void> _onDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await widget.storageService.deleteSession(widget.session.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sessionDeleted)),
      );
      widget.onDeleted?.call();
      Navigator.of(context).pop();
    }
  }
}
