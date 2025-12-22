import 'package:quiz_engine_core/src/business_logic/quiz_state/quiz_state.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';

import '../bloc/single_subscription_bloc.dart';
import '../model/answer.dart';
import '../model/question.dart';
import '../model/random_pick_result.dart';
import '../random_item_picker.dart';
import '../model/config/quiz_config.dart';
import 'config_manager/config_manager.dart';
import 'config_manager/config_source.dart';

/// A business logic component (BLoC) that manages the state of a quiz game.
///
/// The `QuizBloc` class no longer depends on a specific `QuizDataProvider`.
/// Instead, the user must provide a function that supplies quiz data.
class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  /// Function to fetch quiz data.
  ///
  /// This function should return a `Future<List<QuestionEntry>>`.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// The random item picker used to select random items for questions.
  final RandomItemPicker randomItemPicker;

  /// A filter function to apply when loading data (optional).
  final bool Function(QuestionEntry)? filter;

  /// Callback function to be invoked when the game is over.
  Function(String result)? gameOverCallback;

  /// Configuration manager for loading quiz configuration.
  final ConfigManager configManager;

  /// The loaded configuration (initialized with default, can be updated from configManager).
  late final QuizConfig _config;

  /// The list of quiz data items available for the game.
  List<QuestionEntry> _items = [];

  /// The current progress indicating how many questions have been answered.
  int _currentProgress = 0;

  /// The total number of questions in the game.
  int _totalCount = 0;

  /// The current question being asked to the player.
  late Question currentQuestion;

  /// The list of answers provided by the player.
  final List<Answer> _answers = [];

  /// Creates a `QuizBloc` with a provided data fetch function.
  ///
  /// [dataProvider] - Function to fetch quiz data
  /// [randomItemPicker] - Random item picker for selecting questions
  /// [filter] - Optional filter function for quiz data
  /// [gameOverCallback] - Optional callback when quiz ends
  /// [configManager] - Configuration manager with default config
  QuizBloc(
    this.dataProvider,
    this.randomItemPicker, {
    this.filter,
    this.gameOverCallback,
    required this.configManager,
  });

  /// The initial state of the game, set to loading.
  @override
  QuizState get initialState => QuizState.loading();

  /// Getter for the loaded configuration.
  QuizConfig get config => _config;

  /// Performs the initial data load when the screen is loaded.
  ///
  /// This method loads the configuration, retrieves quiz data using the
  /// provided `dataProvider` function, applies the optional filter,
  /// and initializes the random picker.
  Future<void> performInitialLoad() async {
    // Load configuration first
    _config = await configManager.getConfig(
      source: const DefaultSource(),
    );

    var items = await dataProvider();

    // Apply filter if provided, otherwise keep all items
    _items = filter != null ? items.where(filter!).toList() : items;

    _totalCount = _items.length;
    randomItemPicker.replaceItems(_items);
    _pickQuestion();
  }

  /// Processes the player's answer to the current question.
  ///
  /// If answer feedback is enabled in configuration, this will emit an
  /// [AnswerFeedbackState] showing whether the answer was correct/incorrect
  /// before moving to the next question.
  Future<void> processAnswer(QuestionEntry selectedItem) async {
    var answer = Answer(selectedItem, currentQuestion);
    final isCorrect = answer.isCorrect;

    // Show feedback if enabled in configuration
    if (_config.uiBehaviorConfig.showAnswerFeedback) {
      // Emit feedback state
      var feedbackState = QuizState.answerFeedback(
        currentQuestion,
        selectedItem,
        isCorrect,
        _currentProgress,
        _totalCount,
      );
      dispatchState(feedbackState);

      // Wait for feedback duration before proceeding
      await Future.delayed(
        Duration(milliseconds: _config.uiBehaviorConfig.answerFeedbackDuration),
      );
    }

    // Record the answer and move to next question
    _answers.add(answer);
    _currentProgress++;
    _pickQuestion();
  }

  /// Picks the next question or ends the game if no more items are available.
  void _pickQuestion() {
    var randomResult = randomItemPicker.pick();
    if (_isGameOver(randomResult)) {
      var state = QuizState.question(currentQuestion, _currentProgress, _totalCount);
      dispatchState(state);
      _notifyGameOver();
    } else {
      var question = Question.fromRandomResult(randomResult!);
      currentQuestion = question;
      var state = QuizState.question(question, _currentProgress, _totalCount);
      dispatchState(state);
    }
  }

  /// Determines if the game is over based on the random picker result.
  bool _isGameOver(RandomPickResult? result) => result == null;

  /// Notifies the game-over state and invokes the callback with the final result.
  void _notifyGameOver() {
    var correctAnswers = _answers.where((answer) => answer.isCorrect).length;
    var result = '$correctAnswers / $_totalCount';
    gameOverCallback?.call(result);
  }
}