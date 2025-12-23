import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flags_quiz/ui/history/session_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

/// Page displaying quiz session history.
class HistoryPage extends StatefulWidget {
  /// Creates a [HistoryPage].
  const HistoryPage({
    super.key,
    required this.storageService,
  });

  /// Storage service for loading sessions.
  final StorageService storageService;

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

/// State for [HistoryPage].
class HistoryPageState extends State<HistoryPage> {
  List<QuizSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  /// Refreshes the session list.
  void refresh() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final result = await widget.storageService.getRecentSessions(limit: 100);
      result.ifSuccess((sessions) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      });
      result.ifFailure((_) {
        setState(() => _isLoading = false);
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
      ),
      body: SessionHistoryScreen(
        sessions: _sessions.map(_convertToCardData).toList(),
        texts: SessionHistoryTexts(
          title: l10n.history,
          emptyTitle: l10n.noSessionsYet,
          emptySubtitle: l10n.startPlayingToSee,
          questionsLabel: l10n.questions,
          formatDate: (date) => _formatDate(context, date),
          formatStatus: (status, isPerfect) =>
              _formatStatus(context, status, isPerfect),
        ),
        onSessionTap: (sessionData) => _onSessionTap(sessionData),
        isLoading: _isLoading,
        onRefresh: _loadSessions,
      ),
    );
  }

  SessionCardData _convertToCardData(QuizSession session) {
    return SessionCardData(
      id: session.id,
      quizName: _getQuizName(session.quizId),
      totalQuestions: session.totalQuestions,
      totalCorrect: session.totalCorrect,
      scorePercentage: session.scorePercentage,
      completionStatus: session.completionStatus.name,
      startTime: session.startTime,
      durationSeconds: session.durationSeconds,
      quizCategory: session.quizCategory,
    );
  }

  String _getQuizName(String? quizId) {
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

  void _onSessionTap(SessionCardData sessionData) {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionData.id,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionDetailPage(
          session: session,
          storageService: widget.storageService,
          onDeleted: _loadSessions,
        ),
      ),
    );
  }
}
