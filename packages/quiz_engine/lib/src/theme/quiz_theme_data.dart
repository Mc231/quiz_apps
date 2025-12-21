import 'package:flutter/material.dart';

/// Theme configuration for quiz UI components
///
/// Provides customization options for all visual elements in the quiz interface,
/// including buttons, feedback colors, progress indicators, and result displays.
///
/// Example:
/// ```dart
/// final theme = QuizThemeData(
///   buttonColor: Colors.indigo,
///   buttonTextColor: Colors.white,
///   correctAnswerColor: Colors.green,
///   incorrectAnswerColor: Colors.red,
/// );
/// ```
class QuizThemeData {
  // Button styling
  /// Background color for answer buttons
  final Color buttonColor;

  /// Text color for answer buttons
  final Color buttonTextColor;

  /// Border color for answer buttons
  final Color buttonBorderColor;

  /// Border width for answer buttons
  final double buttonBorderWidth;

  /// Border radius for answer buttons
  final BorderRadius buttonBorderRadius;

  /// Padding inside answer buttons
  final EdgeInsets buttonPadding;

  /// Text style for answer buttons
  final TextStyle buttonTextStyle;

  // Answer feedback colors
  /// Color to highlight correct answers
  final Color correctAnswerColor;

  /// Color to highlight incorrect answers
  final Color incorrectAnswerColor;

  /// Color for selected answer
  final Color selectedAnswerColor;

  // Progress indicators
  /// Background color for progress bar
  final Color progressBackgroundColor;

  /// Foreground color for progress bar
  final Color progressForegroundColor;

  // Lives/hints display
  /// Color for lives indicator
  final Color livesColor;

  /// Color for hints indicator
  final Color hintsColor;

  // Timer colors
  /// Color for timer in normal state
  final Color timerNormalColor;

  /// Color for timer when warning (< 10 seconds)
  final Color timerWarningColor;

  /// Color for timer when critical (< 5 seconds)
  final Color timerCriticalColor;

  // Results screen
  /// Color for filled stars in results
  final Color starFilledColor;

  /// Color for empty stars in results
  final Color starEmptyColor;

  const QuizThemeData({
    this.buttonColor = Colors.black,
    this.buttonTextColor = Colors.white,
    this.buttonBorderColor = Colors.transparent,
    this.buttonBorderWidth = 0,
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.buttonPadding = const EdgeInsets.all(16),
    this.buttonTextStyle = const TextStyle(fontSize: 18),
    this.correctAnswerColor = Colors.green,
    this.incorrectAnswerColor = Colors.red,
    this.selectedAnswerColor = Colors.blue,
    this.progressBackgroundColor = Colors.grey,
    this.progressForegroundColor = Colors.blue,
    this.livesColor = Colors.red,
    this.hintsColor = Colors.orange,
    this.timerNormalColor = Colors.blue,
    this.timerWarningColor = Colors.orange,
    this.timerCriticalColor = Colors.red,
    this.starFilledColor = Colors.amber,
    this.starEmptyColor = Colors.grey,
  });

  /// Creates a light theme variant
  factory QuizThemeData.light() => const QuizThemeData();

  /// Creates a dark theme variant
  factory QuizThemeData.dark() => const QuizThemeData(
        buttonColor: Colors.white,
        buttonTextColor: Colors.black,
        progressBackgroundColor: Color(0xFF424242),
        progressForegroundColor: Colors.lightBlueAccent,
      );

  /// Creates a copy of this theme with the specified fields replaced
  QuizThemeData copyWith({
    Color? buttonColor,
    Color? buttonTextColor,
    Color? buttonBorderColor,
    double? buttonBorderWidth,
    BorderRadius? buttonBorderRadius,
    EdgeInsets? buttonPadding,
    TextStyle? buttonTextStyle,
    Color? correctAnswerColor,
    Color? incorrectAnswerColor,
    Color? selectedAnswerColor,
    Color? progressBackgroundColor,
    Color? progressForegroundColor,
    Color? livesColor,
    Color? hintsColor,
    Color? timerNormalColor,
    Color? timerWarningColor,
    Color? timerCriticalColor,
    Color? starFilledColor,
    Color? starEmptyColor,
  }) {
    return QuizThemeData(
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderWidth: buttonBorderWidth ?? this.buttonBorderWidth,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      correctAnswerColor: correctAnswerColor ?? this.correctAnswerColor,
      incorrectAnswerColor: incorrectAnswerColor ?? this.incorrectAnswerColor,
      selectedAnswerColor: selectedAnswerColor ?? this.selectedAnswerColor,
      progressBackgroundColor:
          progressBackgroundColor ?? this.progressBackgroundColor,
      progressForegroundColor:
          progressForegroundColor ?? this.progressForegroundColor,
      livesColor: livesColor ?? this.livesColor,
      hintsColor: hintsColor ?? this.hintsColor,
      timerNormalColor: timerNormalColor ?? this.timerNormalColor,
      timerWarningColor: timerWarningColor ?? this.timerWarningColor,
      timerCriticalColor: timerCriticalColor ?? this.timerCriticalColor,
      starFilledColor: starFilledColor ?? this.starFilledColor,
      starEmptyColor: starEmptyColor ?? this.starEmptyColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizThemeData &&
        other.buttonColor == buttonColor &&
        other.buttonTextColor == buttonTextColor &&
        other.buttonBorderColor == buttonBorderColor &&
        other.buttonBorderWidth == buttonBorderWidth &&
        other.buttonBorderRadius == buttonBorderRadius &&
        other.buttonPadding == buttonPadding &&
        other.buttonTextStyle == buttonTextStyle &&
        other.correctAnswerColor == correctAnswerColor &&
        other.incorrectAnswerColor == incorrectAnswerColor &&
        other.selectedAnswerColor == selectedAnswerColor &&
        other.progressBackgroundColor == progressBackgroundColor &&
        other.progressForegroundColor == progressForegroundColor &&
        other.livesColor == livesColor &&
        other.hintsColor == hintsColor &&
        other.timerNormalColor == timerNormalColor &&
        other.timerWarningColor == timerWarningColor &&
        other.timerCriticalColor == timerCriticalColor &&
        other.starFilledColor == starFilledColor &&
        other.starEmptyColor == starEmptyColor;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      buttonColor,
      buttonTextColor,
      buttonBorderColor,
      buttonBorderWidth,
      buttonBorderRadius,
      buttonPadding,
      buttonTextStyle,
      correctAnswerColor,
      incorrectAnswerColor,
      selectedAnswerColor,
      progressBackgroundColor,
      progressForegroundColor,
      livesColor,
      hintsColor,
      timerNormalColor,
      timerWarningColor,
      timerCriticalColor,
      starFilledColor,
      starEmptyColor,
    ]);
  }
}