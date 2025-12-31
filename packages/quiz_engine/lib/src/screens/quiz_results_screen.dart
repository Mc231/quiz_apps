import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../rate_app/rate_app_config_provider.dart';
import '../rate_app/rate_app_controller.dart';
import '../services/quiz_services_context.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/question_review_widget.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_display.dart';
import 'session_detail_screen.dart';
import 'session_detail_data.dart';
import 'session_detail_texts.dart';

/// Screen displaying quiz results with star rating and statistics.
///
/// This screen replaces the old game over dialog and provides a comprehensive
/// view of the quiz results including:
/// - Star rating (0-5 stars based on score percentage)
/// - Score percentage
/// - Statistics (correct, incorrect, skipped, duration)
/// - Action buttons for reviewing the session and returning home
///
/// Services are obtained from [QuizServicesProvider] via context:
/// - `context.screenAnalyticsService` for analytics tracking
/// - `context.rateAppService` for in-app rating prompts (optional)
/// - `context.storageService` for getting completed quizzes count
///
/// ## Rate App Integration
///
/// When [RateAppUiConfig] is provided via [RateAppConfigProvider] and
/// [RateAppService] is configured in the services container, this screen
/// will automatically check rate app conditions and show the rating prompt
/// if appropriate after a short delay.
class QuizResultsScreen extends StatefulWidget {
  /// Creates a [QuizResultsScreen].
  const QuizResultsScreen({
    super.key,
    required this.results,
    required this.onDone,
    this.onReviewSession,
    this.onPlayAgain,
    this.imageBuilder,
  });

  /// The quiz results to display.
  final QuizResults results;

  /// Callback when user taps "Done" to return home.
  final VoidCallback onDone;

  /// Optional callback when user wants to review the session.
  /// If null, the button will navigate to the session detail screen inline.
  final VoidCallback? onReviewSession;

  /// Optional callback when user wants to play again.
  final VoidCallback? onPlayAgain;

  /// Optional image builder for question images in review.
  final Widget Function(String path)? imageBuilder;

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  // Service accessor via context
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  bool _screenViewLogged = false;
  bool _rateAppChecked = false;

  @override
  Widget build(BuildContext context) {
    // Log screen view on first build when context is available
    if (!_screenViewLogged) {
      _screenViewLogged = true;
      _logScreenView();
      _scheduleRateAppCheck();
    }

    return _buildScreen(context);
  }

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.results(
        quizId: widget.results.quizId,
        quizName: widget.results.quizName,
        scorePercentage: widget.results.scorePercentage,
        isPerfectScore: widget.results.isPerfectScore,
        starRating: widget.results.starRating,
      ),
    );
  }

  /// Schedules a rate app check after a delay.
  ///
  /// This gives the user time to see their results before potentially
  /// being prompted to rate the app.
  void _scheduleRateAppCheck() {
    // Get rate app UI config from provider
    final rateAppConfig = RateAppConfigProvider.of(context);
    if (rateAppConfig == null) return;

    // Get rate app service
    final rateAppService = context.rateAppService;
    if (rateAppService == null) return;

    // Schedule the check after a delay
    Future.delayed(
      Duration(seconds: rateAppConfig.delaySeconds),
      _checkRateApp,
    );
  }

  /// Checks if rate app should be shown and shows it if appropriate.
  Future<void> _checkRateApp() async {
    // Skip if already checked or unmounted
    if (_rateAppChecked || !mounted) return;
    _rateAppChecked = true;

    // Get rate app UI config from provider
    final rateAppConfig = RateAppConfigProvider.of(context);
    if (rateAppConfig == null) return;

    // Get rate app service
    final rateAppService = context.rateAppService;
    if (rateAppService == null) return;

    // Get completed quizzes count from storage
    final storageService = context.storageService;
    int completedQuizzes;
    try {
      final statsResult = await storageService.getGlobalStatistics();
      if (statsResult.isFailure) return;
      completedQuizzes = statsResult.value.totalCompletedSessions;
    } catch (_) {
      // If we can't get the count, skip the rate app check
      return;
    }

    // Check if still mounted after async operation
    if (!mounted) return;

    // Create controller
    final controller = RateAppController(
      rateAppService: rateAppService,
      analyticsService: _analyticsService,
      appName: rateAppConfig.appName,
      appIcon: rateAppConfig.appIcon,
      feedbackEmail: rateAppConfig.feedbackEmail,
    );

    // Check and show rate app if appropriate
    await controller.maybeShowRateApp(
      context: context,
      quizScore: widget.results.scorePercentage.round(),
      completedQuizzes: completedQuizzes,
    );
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    _buildStarRating(context),
                    const SizedBox(height: 16),
                    _buildMotivationalMessage(context, l10n),
                    const SizedBox(height: 8),
                    Text(
                      l10n.quizComplete,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildScoreCircle(context, l10n),
                    const SizedBox(height: 24),
                    // Show score points if score > 0
                    if (widget.results.score > 0) ...[
                      ScoreDisplay(score: widget.results.score),
                      if (widget.results.scoreBreakdown != null &&
                          widget.results.scoreBreakdown!.bonusPoints > 0) ...[
                        const SizedBox(height: 8),
                        ScoreBreakdownWidget(
                          breakdown: widget.results.scoreBreakdown!,
                          compact: true,
                          showTitle: false,
                        ),
                      ],
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 8),
                    _buildStatisticsGrid(context, l10n),
                    const Spacer(flex: 2),
                    _buildActionButtons(context, l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Banner ad at the bottom of the results screen
      bottomNavigationBar: const BannerAdWidget(
        placement: AdPlacement.bannerBottom,
      ),
    );
  }

  Widget _buildStarRating(BuildContext context) {
    final starCount = widget.results.starRating;
    final starColor = _getStarColor(starCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index < starCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 48,
            color: isFilled ? starColor : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Color _getStarColor(int stars) {
    switch (stars) {
      case 5:
        return Colors.amber;
      case 4:
        return Colors.amber[600]!;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.orange[700]!;
      case 1:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMotivationalMessage(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final stars = widget.results.starRating;
    final message = _getMotivationalMessage(l10n, stars);
    final color = _getStarColor(stars);

    return Text(
      message,
      style: theme.textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getMotivationalMessage(QuizEngineLocalizations l10n, int stars) {
    switch (stars) {
      case 5:
        return l10n.excellent;
      case 4:
        return l10n.greatJob;
      case 3:
        return l10n.goodWork;
      case 2:
        return l10n.keepPracticing;
      default:
        return l10n.tryAgain;
    }
  }

  Widget _buildScoreCircle(BuildContext context, QuizEngineLocalizations l10n) {
    final percentage = widget.results.scorePercentage;
    final scoreColor = _getScoreColor(percentage);

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 12,
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
                  '${percentage.round()}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  l10n.scoreOf(widget.results.correctAnswers, widget.results.totalQuestions),
                  style: TextStyle(
                    fontSize: 14,
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

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatisticsGrid(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildStatItem(
          context,
          icon: Icons.check_circle,
          color: Colors.green,
          value: widget.results.correctAnswers.toString(),
          label: l10n.correct,
        ),
        _buildStatItem(
          context,
          icon: Icons.cancel,
          color: Colors.red,
          value: widget.results.incorrectAnswers.toString(),
          label: l10n.incorrect,
        ),
        if (widget.results.skippedAnswers > 0)
          _buildStatItem(
            context,
            icon: Icons.skip_next,
            color: Colors.orange,
            value: widget.results.skippedAnswers.toString(),
            label: l10n.skipped,
          ),
        if (widget.results.timedOutAnswers > 0)
          _buildStatItem(
            context,
            icon: Icons.timer_off,
            color: Colors.purple,
            value: widget.results.timedOutAnswers.toString(),
            label: l10n.timedOut,
          ),
        _buildStatItem(
          context,
          icon: Icons.timer,
          color: Colors.blue,
          value: widget.results.formattedDuration,
          label: l10n.duration,
        ),
        if (widget.results.totalHintsUsed > 0)
          _buildStatItem(
            context,
            icon: Icons.lightbulb,
            color: Colors.amber,
            value: widget.results.totalHintsUsed.toString(),
            label: l10n.hintsUsed,
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
    return SizedBox(
      width: 80,
      child: Column(
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Review This Session button
          OutlinedButton.icon(
            onPressed: () => _navigateToSessionDetail(context, l10n),
            icon: const Icon(Icons.visibility),
            label: Text(l10n.reviewThisSession),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Done button
          ElevatedButton(
            onPressed: widget.onDone,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.done,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSessionDetail(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) {
    if (widget.onReviewSession != null) {
      widget.onReviewSession!();
      return;
    }

    // Navigate to inline session detail screen
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'session_detail'),
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.sessionDetails),
          ),
          body: SessionDetailScreen(
            session: _createSessionDetailData(l10n),
            texts: _createSessionDetailTexts(l10n),
            imageBuilder: widget.imageBuilder,
          ),
        ),
      ),
    );
  }

  SessionDetailData _createSessionDetailData(QuizEngineLocalizations l10n) {
    return SessionDetailData(
      id: widget.results.sessionId ?? '',
      quizName: widget.results.quizName,
      totalQuestions: widget.results.totalQuestions,
      totalCorrect: widget.results.correctAnswers,
      totalIncorrect: widget.results.incorrectAnswers + widget.results.timedOutAnswers,
      totalSkipped: widget.results.skippedAnswers,
      scorePercentage: widget.results.scorePercentage,
      completionStatus: _getCompletionStatus(l10n),
      startTime: widget.results.completedAt.subtract(
        Duration(seconds: widget.results.durationSeconds),
      ),
      durationSeconds: widget.results.durationSeconds,
      quizCategory: widget.results.quizId,
      questions: _createReviewedQuestions(),
    );
  }

  String _getCompletionStatus(QuizEngineLocalizations l10n) {
    if (widget.results.isPerfectScore) return l10n.perfectScore;
    return l10n.sessionCompleted;
  }

  List<ReviewedQuestion> _createReviewedQuestions() {
    return widget.results.answers.asMap().entries.map((entry) {
      final index = entry.key;
      final answer = entry.value;
      return ReviewedQuestion(
        questionNumber: index + 1,
        questionText: _getDisplayText(answer.question.answer),
        correctAnswer: _getDisplayText(answer.question.answer),
        userAnswer: answer.isSkipped || answer.isTimeout
            ? null
            : _getDisplayText(answer.selectedOption),
        isCorrect: answer.isCorrect,
        isSkipped: answer.isSkipped,
        questionImagePath: _getQuestionImagePath(answer.question),
      );
    }).toList();
  }

  /// Gets the display text for a question entry.
  ///
  /// For image-based questions (like flags quiz), the display text is stored
  /// in `otherOptions['name']`. For text-based questions, it's in the type.
  String _getDisplayText(QuestionEntry entry) {
    // First try to get name from otherOptions (used for flags quiz, etc.)
    final name = entry.otherOptions['name'];
    if (name != null && name is String && name.isNotEmpty) {
      return name;
    }

    // Fallback to extracting from the question type
    final questionType = entry.type;
    return switch (questionType) {
      TextQuestion(:final text) => text,
      ImageQuestion(:final imagePath) => imagePath,
      AudioQuestion(:final audioPath) => audioPath,
      VideoQuestion(:final videoUrl) => videoUrl,
    };
  }

  String? _getQuestionImagePath(Question question) {
    final questionType = question.answer.type;
    if (questionType is ImageQuestion) {
      return questionType.imagePath;
    }
    return null;
  }

  SessionDetailTexts _createSessionDetailTexts(QuizEngineLocalizations l10n) {
    return SessionDetailTexts(
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
      questionLabel: (number) => l10n.questionNumber(number),
      yourAnswerLabel: l10n.yourAnswer,
      correctAnswerLabel: l10n.correctAnswer,
      formatDate: (date) => _formatDate(date, l10n),
      formatStatus: (status, isPerfect) =>
          _formatStatus(status, isPerfect, l10n),
      deleteDialogTitle: l10n.deleteSession,
      deleteDialogMessage: l10n.deleteSessionMessage,
      cancelLabel: l10n.cancel,
    );
  }

  String _formatDate(DateTime date, QuizEngineLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateDay).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return l10n.daysAgo(difference);
  }

  (String, Color) _formatStatus(
    String status,
    bool isPerfect,
    QuizEngineLocalizations l10n,
  ) {
    if (isPerfect) {
      return (l10n.perfectScore, Colors.amber);
    }
    return (status, Colors.green);
  }
}
