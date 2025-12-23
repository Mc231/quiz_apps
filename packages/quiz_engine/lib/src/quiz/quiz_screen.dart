import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_services/shared_services.dart';
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
  /// The BLoC managing the quiz logic and state transitions.
  late QuizBloc _bloc;

  /// Audio service for playing sound effects
  final AudioService _audioService = AudioService();

  /// Haptic service for providing haptic feedback
  final HapticService _hapticService = HapticService();

  /// Flag to track if the quiz is over
  bool _isQuizOver = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<QuizBloc>(context);
    _initializeServices();
    _bloc.performInitialLoad();
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

  /// Initialize audio and haptic services and set up feedback listeners
  Future<void> _initializeServices() async {
    // Initialize audio service
    await _audioService.initialize();

    // Configure services based on quiz config
    final config = _bloc.config.uiBehaviorConfig;
    _audioService.setMuted(!config.playSounds);
    _hapticService.setEnabled(config.hapticFeedback);

    // Preload frequently used sounds
    if (config.playSounds) {
      await _audioService.preloadMultiple([
        QuizSoundEffect.correctAnswer,
        QuizSoundEffect.incorrectAnswer,
      ]);
    }

    // Listen to quiz states and provide feedback
    _bloc.stream.listen((state) {
      if (state is AnswerFeedbackState) {
        _provideFeedback(state);
      } else if (state is QuizCompletedState) {
        _isQuizOver = true;
      }
    });
  }

  /// Provide audio and haptic feedback based on answer correctness
  Future<void> _provideFeedback(AnswerFeedbackState state) async {
    if (!mounted) return;

    final config = _bloc.config.uiBehaviorConfig;

    // Play sound effect
    if (config.playSounds) {
      final sound =
          state.isCorrect
              ? QuizSoundEffect.correctAnswer
              : QuizSoundEffect.incorrectAnswer;
      await _audioService.playSoundEffect(sound);
    }

    // Trigger haptic feedback
    if (config.hapticFeedback) {
      if (state.isCorrect) {
        await _hapticService.correctAnswer();
      } else {
        await _hapticService.incorrectAnswer();
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return StreamBuilder<QuizState>(
      initialData: _bloc.initialState,
      stream: _bloc.stream,
      builder: (context, snapshot) {
        var state = snapshot.data;

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
              final shouldExit = await ExitConfirmationDialog.show(
                context,
                title: l10n.exitDialogTitle,
                message: l10n.exitDialogMessage,
                confirmButtonText: l10n.exitDialogConfirm,
                cancelButtonText: l10n.exitDialogCancel,
              );
              if (shouldExit && context.mounted) {
                // Cancel the quiz (deletes session if no answers given)
                await _bloc.cancelQuiz();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                // Only show actions if not loading
                if (state is! LoadingState)
                  QuizAppBarActions(
                    state: state,
                    config: _bloc.config,
                  ),
              ],
            ),
            body: Container(
              padding: getContainerPadding(context),
              child: SafeArea(child: _buildBody(state)),
            ),
          ),
        );
      },
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

  Widget _buildBody(QuizState? state) {
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
            quizBloc: _bloc,
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
          quizBloc: _bloc,
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
