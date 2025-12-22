/// Enum representing different sound effects used in quiz applications
enum QuizSoundEffect {
  /// Sound played when the user selects a correct answer
  correctAnswer,

  /// Sound played when the user selects an incorrect answer
  incorrectAnswer,

  /// Sound played when clicking a button (general UI interaction)
  buttonClick,

  /// Sound played when completing a quiz
  quizComplete,

  /// Sound played when achieving a high score or perfect score
  achievement,

  /// Sound played during countdown or timer warning
  timerWarning,

  /// Sound played when time runs out
  timeOut,

  /// Sound played when using a hint
  hintUsed,

  /// Sound played when losing a life
  lifeLost,

  /// Sound played at the start of a quiz
  quizStart;

  /// Returns the asset path for this sound effect
  ///
  /// Note: Sound assets are provided by the quiz_engine package.
  /// For package assets loaded via rootBundle, Flutter expects the format:
  /// packages/package_name/assets/path (matching the pubspec.yaml declaration)
  String get assetPath => 'packages/quiz_engine/assets/sounds/$name.mp3';

  /// Returns a default asset path with a specified format
  String assetPathWithFormat(String format) =>
      'packages/quiz_engine/assets/sounds/$name.$format';
}
