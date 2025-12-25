/// Enum representing the types of tabs available in the Play screen.
///
/// Use this to configure which tabs appear in the Play screen's
/// internal tab bar. Each type corresponds to a specific feature:
///
/// - [quiz]: Standard category-based quiz selection
/// - [challenges]: Challenge modes with special rules
/// - [practice]: Practice mode for reviewing wrong answers
///
/// Example:
/// ```dart
/// QuizApp(
///   playTabTypes: {PlayTabType.quiz, PlayTabType.challenges},
///   // ...
/// )
/// ```
enum PlayTabType {
  /// Standard quiz mode with category selection.
  ///
  /// Displays a list of quiz categories for the user to choose from.
  /// Each category can have its own configuration (hints, lives, timer, etc.).
  quiz,

  /// Challenge modes with special game rules.
  ///
  /// Displays available challenges like Survival, Time Attack, etc.
  /// Each challenge has unique constraints and scoring rules.
  challenges,

  /// Practice mode for reviewing incorrect answers.
  ///
  /// Allows users to practice questions they previously answered wrong.
  /// Questions are loaded from recent quiz sessions.
  practice,
}
