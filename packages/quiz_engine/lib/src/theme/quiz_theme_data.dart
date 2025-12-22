import 'package:flutter/material.dart';

/// Theme configuration for quiz UI components
///
/// Provides customization options for all visual elements in the quiz interface,
/// including buttons, feedback colors, progress indicators, result displays,
/// spacing, and layout dimensions.
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

  /// Maximum number of lines for button text
  final int buttonMaxLines;

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

  // Spacing & Layout
  /// Default bottom margin for answer buttons
  final EdgeInsets buttonBottomMargin;

  /// Bottom margin for answer buttons on watch devices
  final EdgeInsets buttonBottomMarginWatch;

  /// Grid axis spacing for mobile devices
  final double gridAxisSpacingMobile;

  /// Grid axis spacing for tablet devices
  final double gridAxisSpacingTablet;

  /// Grid axis spacing for desktop devices
  final double gridAxisSpacingDesktop;

  /// Grid axis spacing for watch devices
  final double gridAxisSpacingWatch;

  /// Spacing between question widget and answer options
  final double questionAnswerSpacing;

  /// Spacing between progress text and progress bar
  final double progressIndicatorSpacing;

  /// Screen padding for mobile devices
  final double screenPaddingMobile;

  /// Screen padding for tablet devices
  final double screenPaddingTablet;

  /// Screen padding for desktop devices
  final double screenPaddingDesktop;

  /// Screen padding for watch devices
  final double screenPaddingWatch;

  // Responsive Sizes
  /// Button height for mobile devices
  final double buttonHeightMobile;

  /// Button height for tablet devices
  final double buttonHeightTablet;

  /// Button height for desktop devices
  final double buttonHeightDesktop;

  /// Button height for watch devices
  final double buttonHeightWatch;

  /// Button font size for mobile devices
  final double buttonFontSizeMobile;

  /// Button font size for tablet devices
  final double buttonFontSizeTablet;

  /// Button font size for desktop devices
  final double buttonFontSizeDesktop;

  /// Button font size for watch devices
  final double buttonFontSizeWatch;

  /// Progress text font size for mobile devices
  final double progressFontSizeMobile;

  /// Progress text font size for tablet devices
  final double progressFontSizeTablet;

  /// Progress text font size for desktop devices
  final double progressFontSizeDesktop;

  /// Progress text font size for watch devices
  final double progressFontSizeWatch;

  /// Threshold to determine very small screens
  final double verySmallScreenThreshold;

  /// Image size coefficient for watch devices
  final double imageSizeCoefficientWatch;

  /// Image size coefficient for normal devices
  final double imageSizeCoefficientNormal;

  const QuizThemeData({
    this.buttonColor = Colors.black,
    this.buttonTextColor = Colors.white,
    this.buttonBorderColor = Colors.transparent,
    this.buttonBorderWidth = 0,
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.buttonTextStyle = const TextStyle(fontSize: 18),
    this.buttonMaxLines = 2,
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
    // Spacing & Layout
    this.buttonBottomMargin = const EdgeInsets.only(bottom: 8),
    this.buttonBottomMarginWatch = const EdgeInsets.only(bottom: 4),
    this.gridAxisSpacingMobile = 8,
    this.gridAxisSpacingTablet = 16,
    this.gridAxisSpacingDesktop = 16,
    this.gridAxisSpacingWatch = 0,
    this.questionAnswerSpacing = 16,
    this.progressIndicatorSpacing = 8,
    this.screenPaddingMobile = 16,
    this.screenPaddingTablet = 16,
    this.screenPaddingDesktop = 16,
    this.screenPaddingWatch = 8,
    // Responsive Sizes
    this.buttonHeightMobile = 56,
    this.buttonHeightTablet = 92,
    this.buttonHeightDesktop = 92,
    this.buttonHeightWatch = 36,
    this.buttonFontSizeMobile = 16,
    this.buttonFontSizeTablet = 24,
    this.buttonFontSizeDesktop = 24,
    this.buttonFontSizeWatch = 12,
    this.progressFontSizeMobile = 12,
    this.progressFontSizeTablet = 24,
    this.progressFontSizeDesktop = 24,
    this.progressFontSizeWatch = 8,
    this.verySmallScreenThreshold = 300,
    this.imageSizeCoefficientWatch = 0.7,
    this.imageSizeCoefficientNormal = 0.62,
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
    int? buttonMaxLines,
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
    EdgeInsets? buttonBottomMargin,
    EdgeInsets? buttonBottomMarginWatch,
    double? gridAxisSpacingMobile,
    double? gridAxisSpacingTablet,
    double? gridAxisSpacingDesktop,
    double? gridAxisSpacingWatch,
    double? questionAnswerSpacing,
    double? progressIndicatorSpacing,
    double? screenPaddingMobile,
    double? screenPaddingTablet,
    double? screenPaddingDesktop,
    double? screenPaddingWatch,
    double? buttonHeightMobile,
    double? buttonHeightTablet,
    double? buttonHeightDesktop,
    double? buttonHeightWatch,
    double? buttonFontSizeMobile,
    double? buttonFontSizeTablet,
    double? buttonFontSizeDesktop,
    double? buttonFontSizeWatch,
    double? progressFontSizeMobile,
    double? progressFontSizeTablet,
    double? progressFontSizeDesktop,
    double? progressFontSizeWatch,
    double? verySmallScreenThreshold,
    double? imageSizeCoefficientWatch,
    double? imageSizeCoefficientNormal,
  }) {
    return QuizThemeData(
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderWidth: buttonBorderWidth ?? this.buttonBorderWidth,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      buttonMaxLines: buttonMaxLines ?? this.buttonMaxLines,
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
      buttonBottomMargin: buttonBottomMargin ?? this.buttonBottomMargin,
      buttonBottomMarginWatch:
          buttonBottomMarginWatch ?? this.buttonBottomMarginWatch,
      gridAxisSpacingMobile:
          gridAxisSpacingMobile ?? this.gridAxisSpacingMobile,
      gridAxisSpacingTablet:
          gridAxisSpacingTablet ?? this.gridAxisSpacingTablet,
      gridAxisSpacingDesktop:
          gridAxisSpacingDesktop ?? this.gridAxisSpacingDesktop,
      gridAxisSpacingWatch: gridAxisSpacingWatch ?? this.gridAxisSpacingWatch,
      questionAnswerSpacing:
          questionAnswerSpacing ?? this.questionAnswerSpacing,
      progressIndicatorSpacing:
          progressIndicatorSpacing ?? this.progressIndicatorSpacing,
      screenPaddingMobile: screenPaddingMobile ?? this.screenPaddingMobile,
      screenPaddingTablet: screenPaddingTablet ?? this.screenPaddingTablet,
      screenPaddingDesktop: screenPaddingDesktop ?? this.screenPaddingDesktop,
      screenPaddingWatch: screenPaddingWatch ?? this.screenPaddingWatch,
      buttonHeightMobile: buttonHeightMobile ?? this.buttonHeightMobile,
      buttonHeightTablet: buttonHeightTablet ?? this.buttonHeightTablet,
      buttonHeightDesktop: buttonHeightDesktop ?? this.buttonHeightDesktop,
      buttonHeightWatch: buttonHeightWatch ?? this.buttonHeightWatch,
      buttonFontSizeMobile: buttonFontSizeMobile ?? this.buttonFontSizeMobile,
      buttonFontSizeTablet: buttonFontSizeTablet ?? this.buttonFontSizeTablet,
      buttonFontSizeDesktop:
          buttonFontSizeDesktop ?? this.buttonFontSizeDesktop,
      buttonFontSizeWatch: buttonFontSizeWatch ?? this.buttonFontSizeWatch,
      progressFontSizeMobile:
          progressFontSizeMobile ?? this.progressFontSizeMobile,
      progressFontSizeTablet:
          progressFontSizeTablet ?? this.progressFontSizeTablet,
      progressFontSizeDesktop:
          progressFontSizeDesktop ?? this.progressFontSizeDesktop,
      progressFontSizeWatch:
          progressFontSizeWatch ?? this.progressFontSizeWatch,
      verySmallScreenThreshold:
          verySmallScreenThreshold ?? this.verySmallScreenThreshold,
      imageSizeCoefficientWatch:
          imageSizeCoefficientWatch ?? this.imageSizeCoefficientWatch,
      imageSizeCoefficientNormal:
          imageSizeCoefficientNormal ?? this.imageSizeCoefficientNormal,
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
        other.buttonMaxLines == buttonMaxLines &&
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
        other.starEmptyColor == starEmptyColor &&
        other.buttonBottomMargin == buttonBottomMargin &&
        other.buttonBottomMarginWatch == buttonBottomMarginWatch &&
        other.gridAxisSpacingMobile == gridAxisSpacingMobile &&
        other.gridAxisSpacingTablet == gridAxisSpacingTablet &&
        other.gridAxisSpacingDesktop == gridAxisSpacingDesktop &&
        other.gridAxisSpacingWatch == gridAxisSpacingWatch &&
        other.questionAnswerSpacing == questionAnswerSpacing &&
        other.progressIndicatorSpacing == progressIndicatorSpacing &&
        other.screenPaddingMobile == screenPaddingMobile &&
        other.screenPaddingTablet == screenPaddingTablet &&
        other.screenPaddingDesktop == screenPaddingDesktop &&
        other.screenPaddingWatch == screenPaddingWatch &&
        other.buttonHeightMobile == buttonHeightMobile &&
        other.buttonHeightTablet == buttonHeightTablet &&
        other.buttonHeightDesktop == buttonHeightDesktop &&
        other.buttonHeightWatch == buttonHeightWatch &&
        other.buttonFontSizeMobile == buttonFontSizeMobile &&
        other.buttonFontSizeTablet == buttonFontSizeTablet &&
        other.buttonFontSizeDesktop == buttonFontSizeDesktop &&
        other.buttonFontSizeWatch == buttonFontSizeWatch &&
        other.progressFontSizeMobile == progressFontSizeMobile &&
        other.progressFontSizeTablet == progressFontSizeTablet &&
        other.progressFontSizeDesktop == progressFontSizeDesktop &&
        other.progressFontSizeWatch == progressFontSizeWatch &&
        other.verySmallScreenThreshold == verySmallScreenThreshold &&
        other.imageSizeCoefficientWatch == imageSizeCoefficientWatch &&
        other.imageSizeCoefficientNormal == imageSizeCoefficientNormal;
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
      buttonMaxLines,
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
      buttonBottomMargin,
      buttonBottomMarginWatch,
      gridAxisSpacingMobile,
      gridAxisSpacingTablet,
      gridAxisSpacingDesktop,
      gridAxisSpacingWatch,
      questionAnswerSpacing,
      progressIndicatorSpacing,
      screenPaddingMobile,
      screenPaddingTablet,
      screenPaddingDesktop,
      screenPaddingWatch,
      buttonHeightMobile,
      buttonHeightTablet,
      buttonHeightDesktop,
      buttonHeightWatch,
      buttonFontSizeMobile,
      buttonFontSizeTablet,
      buttonFontSizeDesktop,
      buttonFontSizeWatch,
      progressFontSizeMobile,
      progressFontSizeTablet,
      progressFontSizeDesktop,
      progressFontSizeWatch,
      verySmallScreenThreshold,
      imageSizeCoefficientWatch,
      imageSizeCoefficientNormal,
    ]);
  }
}