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
  final String gameOverTitle;
  final QuizThemeData themeData;

  const QuizScreen({
    super.key,
    required this.title,
    required this.gameOverTitle,
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

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<QuizBloc>(context);
    _initializeServices();
    _bloc.performInitialLoad();
    _bloc.gameOverCallback = (String result) {
      _showQuizOverDialog(result);
    };
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
      }
    });
  }

  /// Provide audio and haptic feedback based on answer correctness
  Future<void> _provideFeedback(AnswerFeedbackState state) async {
    if (!mounted) return;

    final config = _bloc.config.uiBehaviorConfig;

    // Play sound effect
    if (config.playSounds) {
      final sound = state.isCorrect
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: getContainerPadding(context),
        child: SafeArea(
          child: StreamBuilder<QuizState>(
            initialData: _bloc.initialState,
            stream: _bloc.stream,
            builder: (context, snapshot) {
              var state = snapshot.data;

              if (state is LoadingState) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is AnswerFeedbackState) {
                // Show feedback with the answered question
                return ResponsiveBuilder(
                  builder: (context, information) {
                    return AnswerFeedbackWidget(
                      feedbackState: state,
                      processAnswer: _bloc.processAnswer,
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
                    themeData: widget.themeData,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Displays a dialog indicating the quiz is over, showing the final score.
  ///
  /// This method is called when the quiz is completed, presenting a dialog
  /// with the user's score. The dialog is non-dismissible, requiring the user
  /// to tap the OK button to close it.
  ///
  /// [message] is the score message to display in the dialog.
  void _showQuizOverDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.gameOverTitle),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
                key: QuizScreen.okButtonKey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
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
