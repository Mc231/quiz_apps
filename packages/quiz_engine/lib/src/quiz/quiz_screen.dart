import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_services/shared_services.dart'
    show AnalyticsService, InteractionEvent, ScreenViewEvent;

import '../../quiz_engine.dart';
import 'quiz_layout.dart';

/// A screen that displays the quiz interface, handling questions and user interaction.
///
/// The `QuizScreen` class is a `StatefulWidget` that provides the main interface for the quiz or quiz.
/// It manages the quiz state using a BLoC (Business Logic Component) pattern and updates the UI
/// based on the current state. The screen includes a question display, answer options, and a progress indicator.
/// It also shows a quiz over dialog when the quiz is complete.
///
/// The widget relies on `QuizBloc` to manage the quiz logic and state transitions. The `BlocProvider`
/// is used to access the BLoC instance and manage its lifecycle.
///
/// The `QuizScreen` uses a responsive design to adapt to different screen sizes and orientations,
/// ensuring a consistent experience across devices.
///
///
/// Services are obtained from [QuizServicesProvider] via context:
/// - `context.screenAnalyticsService` for analytics tracking
///
class QuizScreen extends StatefulWidget {
  /// Key used for identifying the OK button in the quiz over dialog.
  static const okButtonKey = Key("ok_button");

  final String title;
  final QuizThemeData themeData;

  const QuizScreen({
    super.key,
    required this.title,
    this.themeData = const QuizThemeData(),
  });

  @override
  State<StatefulWidget> createState() {
    return QuizScreenState();
  }
}

/// The state for the `QuizScreen`, managing the quiz logic and UI updates.
class QuizScreenState extends State<QuizScreen> {
  // Service accessor via context
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  /// The BLoC managing the quiz logic and state transitions.
  late QuizBloc _bloc;

  /// Combined feedback service for audio and haptic feedback.
  /// Initialized with defaults immediately to prevent LateInitializationError.
  QuizFeedbackService _feedbackService = QuizFeedbackService();

  /// Flag to track if the quiz is over
  bool _isQuizOver = false;

  /// Flag to track if screen view has been logged
  bool _screenViewLogged = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<QuizBloc>(context);
    _updateFeedbackServiceFromConfig();
    _initializeFeedbackServiceAsync();
    _bloc.performInitialLoad();
  }

  void _logScreenView(int totalQuestions) {
    if (!mounted) return;
    _analyticsService.logEvent(
      ScreenViewEvent.quiz(
        quizId: _bloc.config.quizId,
        quizName: widget.title,
        mode: _getModeConfigName(_bloc.config.modeConfig),
        totalQuestions: totalQuestions,
      ),
    );
  }

  String _getModeConfigName(QuizModeConfig config) {
    return switch (config) {
      StandardMode() => 'standard',
      TimedMode() => 'timed',
      LivesMode() => 'lives',
      EndlessMode() => 'endless',
      SurvivalMode() => 'survival',
    };
  }

  /// Get whether exit confirmation should be shown
  bool get _showExitConfirmation {
    try {
      return _bloc.config.uiBehaviorConfig.showExitConfirmation;
    } catch (_) {
      // Default to true if config is not yet initialized
      return true;
    }
  }

  /// Update the feedback service settings from config if available.
  void _updateFeedbackServiceFromConfig() {
    try {
      final config = _bloc.config.uiBehaviorConfig;
      _feedbackService = QuizFeedbackService(
        soundsEnabled: config.playSounds,
        hapticsEnabled: config.hapticFeedback,
      );
    } catch (_) {
      // Config not yet initialized, keep default service
    }
  }

  /// Initialize the feedback service asynchronously and set up state listeners.
  Future<void> _initializeFeedbackServiceAsync() async {
    await _feedbackService.initialize();

    // Listen to quiz states and provide feedback
    _bloc.stream.listen((state) {
      // Log screen view on first QuestionState
      if (!_screenViewLogged && state is QuestionState) {
        _screenViewLogged = true;
        _logScreenView(state.total);
      }
      if (state is AnswerFeedbackState) {
        _provideFeedback(state);
      } else if (state is QuizCompletedState) {
        _isQuizOver = true;
        _feedbackService.trigger(QuizFeedbackPattern.quizComplete);
      }
    });
  }

  /// Provide audio and haptic feedback based on answer correctness.
  Future<void> _provideFeedback(AnswerFeedbackState state) async {
    if (!mounted) return;

    final pattern = state.isCorrect
        ? QuizFeedbackPattern.correctAnswer
        : QuizFeedbackPattern.incorrectAnswer;
    await _feedbackService.trigger(pattern);
  }

  @override
  void dispose() {
    _feedbackService.dispose();
    super.dispose();
  }

  /// Extracts progress information from the current quiz state.
  ///
  /// Returns a tuple of (questionsAnswered, totalQuestions).
  (int, int) _getProgressFromState(QuizState? state) {
    return switch (state) {
      QuestionState(:final progress, :final total) => (progress, total),
      AnswerFeedbackState(:final progress, :final total) => (progress, total),
      _ => (0, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return StreamBuilder<QuizState>(
      initialData: _bloc.initialState,
      stream: _bloc.stream,
      builder: (context, snapshot) {
        var state = snapshot.data;

        // Build resource data from current state
        final resourceData = _buildResourceData(state);

        return PopScope(
          canPop: _isQuizOver || !_showExitConfirmation,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            // If pop already happened (exit confirmation disabled), cancel quiz
            if (didPop) {
              if (!_isQuizOver) {
                await _bloc.cancelQuiz();
              }
              return;
            }

            // Don't show exit confirmation if quiz is over
            if (_isQuizOver) return;

            // Show exit confirmation dialog if enabled
            if (_showExitConfirmation) {
              // Get progress info for analytics
              final (questionsAnswered, totalQuestions) = _getProgressFromState(state);

              // Log exit dialog shown
              _analyticsService.logEvent(
                InteractionEvent.exitDialogShown(
                  quizId: _bloc.config.quizId,
                  questionsAnswered: questionsAnswered,
                  totalQuestions: totalQuestions,
                ),
              );

              final shouldExit = await ExitConfirmationDialog.show(
                context,
                title: l10n.exitDialogTitle,
                message: l10n.exitDialogMessage,
                confirmButtonText: l10n.exitDialogConfirm,
                cancelButtonText: l10n.exitDialogCancel,
              );

              if (shouldExit && context.mounted) {
                // Log exit dialog confirmed
                _analyticsService.logEvent(
                  InteractionEvent.exitDialogConfirmed(
                    quizId: _bloc.config.quizId,
                    questionsAnswered: questionsAnswered,
                    totalQuestions: totalQuestions,
                    timeSpent: _bloc.sessionDuration,
                  ),
                );

                // Cancel the quiz (deletes session if no answers given)
                await _bloc.cancelQuiz();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                // Log exit dialog cancelled
                _analyticsService.logEvent(
                  InteractionEvent.exitDialogCancelled(
                    quizId: _bloc.config.quizId,
                    questionsAnswered: questionsAnswered,
                    totalQuestions: totalQuestions,
                  ),
                );
              }
            }
          },
          child: QuizFeedbackProvider(
            feedbackService: _feedbackService,
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                actions: [
                  // Only show actions if not loading
                  if (state is! LoadingState)
                    QuizAppBarActions(
                      state: state,
                      config: _bloc.config,
                      resourceData: resourceData,
                    ),
                ],
              ),
              body: Container(
                padding: getContainerPadding(context),
                child: SafeArea(child: _buildBody(state, resourceData)),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the game resource panel data from the current quiz state.
  GameResourcePanelData? _buildResourceData(QuizState? state) {
    if (state == null || state is LoadingState || state is QuizCompletedState) {
      return null;
    }

    // Extract hint state and lives from state
    HintState? hintState;
    int? remainingLives;
    int? totalLives = _bloc.config.modeConfig.lives;

    if (state is QuestionState) {
      hintState = state.hintState;
      remainingLives = state.remainingLives;
    } else if (state is AnswerFeedbackState) {
      hintState = state.hintState;
      remainingLives = state.remainingLives;
    }

    // Build lives config if lives mode is enabled
    GameResourceConfig? livesConfig;
    if (remainingLives != null && totalLives != null) {
      livesConfig = GameResourceConfig(
        count: remainingLives,
        onTap: () {
          // TODO: Show "Get More Lives" dialog (Sprint 8.15)
        },
        enabled: remainingLives > 0,
      );
    }

    // Build 50/50 config only if hints are configured (initial count > 0)
    // This ensures hints don't appear in challenge modes where showHints=false
    GameResourceConfig? fiftyFiftyConfig;
    final initialFiftyFifty = _bloc.config.hintConfig.initialHints[HintType.fiftyFifty] ?? 0;
    if (hintState != null && initialFiftyFifty > 0) {
      final fiftyFiftyCount = hintState.getRemainingCount(HintType.fiftyFifty);
      fiftyFiftyConfig = GameResourceConfig(
        count: fiftyFiftyCount,
        onTap: () => _bloc.use50_50Hint(),
        enabled: hintState.canUseHint(HintType.fiftyFifty),
      );
    }

    // Build skip config only if hints are configured (initial count > 0)
    // This ensures skip doesn't appear in challenge modes where showHints=false
    GameResourceConfig? skipConfig;
    final initialSkip = _bloc.config.hintConfig.initialHints[HintType.skip] ?? 0;
    if (hintState != null && initialSkip > 0) {
      final skipCount = hintState.getRemainingCount(HintType.skip);
      skipConfig = GameResourceConfig(
        count: skipCount,
        onTap: () => _bloc.skipQuestion(),
        enabled: hintState.canUseHint(HintType.skip),
      );
    }

    // Return null if no resources configured
    if (livesConfig == null && fiftyFiftyConfig == null && skipConfig == null) {
      return null;
    }

    return GameResourcePanelData(
      lives: livesConfig,
      fiftyFifty: fiftyFiftyConfig,
      skip: skipConfig,
    );
  }

  /// Builds an image widget for question review.
  ///
  /// Handles both local assets and network images.
  Widget _buildQuestionImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        height: 120,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 120,
          child: Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      height: 120,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 120,
        child: Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }

  Widget _buildBody(QuizState? state, GameResourcePanelData? resourceData) {
    if (state is LoadingState) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is QuizCompletedState) {
      // Show results screen when quiz is completed
      return QuizResultsScreen(
        results: state.results,
        onDone: () {
          Navigator.of(context).pop();
        },
        imageBuilder: _buildQuestionImage,
      );
    }

    if (state is AnswerFeedbackState) {
      // Show feedback with the answered question
      return ResponsiveBuilder(
        builder: (context, information) {
          return AnswerFeedbackWidget(
            feedbackState: state,
            processAnswer: _bloc.processAnswer,
            resourceData: resourceData,
            themeData: widget.themeData,
            information: information,
          );
        },
      );
    }

    final questionState = state as QuestionState;
    return ResponsiveBuilder(
      builder: (context, information) {
        return QuizLayout(
          questionState: questionState,
          information: information,
          processAnswer: _bloc.processAnswer,
          resourceData: resourceData,
          themeData: widget.themeData,
        );
      },
    );
  }
}

/// Extension on `QuizScreenState` to provide responsive layout utilities.
extension QuizScreenSizes on QuizScreenState {
  /// Returns the container padding based on the screen size and theme.
  ///
  /// This method calculates padding for the quiz screen using `getValueForScreenType`,
  /// pulling padding values from the theme configuration.
  ///
  /// [context] is the `BuildContext` used to determine the screen size.
  ///
  /// Returns the `EdgeInsets` for the container padding.
  EdgeInsets getContainerPadding(BuildContext context) {
    var padding = getValueForScreenType<double>(
      context: context,
      mobile: widget.themeData.screenPaddingMobile,
      tablet: widget.themeData.screenPaddingTablet,
      desktop: widget.themeData.screenPaddingDesktop,
      watch: widget.themeData.screenPaddingWatch,
    );
    return EdgeInsets.all(padding);
  }
}
