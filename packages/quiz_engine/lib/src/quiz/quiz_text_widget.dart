import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// A widget that displays a text-based question.
///
/// The `QuizTextWidget` class is a stateless widget that renders text content
/// for quiz questions. It displays the text with responsive typography that
/// adapts to different screen sizes and orientations.
///
/// The text is styled with appropriate font sizes based on the device type
/// (mobile, tablet, desktop, watch) to ensure readability across all platforms.
///
/// The widget can display text from two sources:
/// - If [displayText] is provided, it is displayed directly (used for template substitution)
/// - Otherwise, the text from the [TextQuestion] type is used
class QuizTextWidget extends StatelessWidget {
  /// The question entry containing the text to display.
  final QuestionEntry entry;

  /// The width constraint for the text container.
  final double width;

  /// The height constraint for the text container.
  final double height;

  /// Optional text to display instead of the entry's text.
  ///
  /// When provided, this text is displayed regardless of the entry type.
  /// This is useful for text question layouts where the question text
  /// comes from a template (e.g., "Select the flag of {name}").
  final String? displayText;

  /// Creates a `QuizTextWidget` with the specified question entry and dimensions.
  ///
  /// [key] is the unique key for this widget.
  /// [entry] is the `QuestionEntry` object containing the text question.
  /// [width] is the width constraint for the text container.
  /// [height] is the height constraint for the text container.
  /// [displayText] optionally overrides the entry's text (for template substitution).
  const QuizTextWidget({
    required Key key,
    required this.entry,
    required this.width,
    required this.height,
    this.displayText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final code = (entry.otherOptions["id"] as String).toLowerCase();

    // Use displayText if provided, otherwise extract from TextQuestion
    final text = displayText ?? _extractTextFromEntry();

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            text,
            key: Key("text_$code"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getTextSize(context),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  /// Extracts text from the entry based on its type.
  ///
  /// For [TextQuestion], returns the question text.
  /// For other types, returns the name from otherOptions or an empty string.
  String _extractTextFromEntry() {
    final type = entry.type;
    if (type is TextQuestion) {
      return type.text;
    }
    // Fallback for non-text questions (e.g., when used in text layouts)
    return entry.otherOptions['name'] as String? ?? '';
  }

  /// Returns the font size for the text based on the screen size.
  ///
  /// This method uses `getValueForScreenType` to adjust the font size for different
  /// device types, ensuring readability on all screens.
  ///
  /// [context] is the `BuildContext` used to determine the screen size.
  ///
  /// Returns the font size for the text.
  double _getTextSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 24,
      tablet: 36,
      desktop: 40,
      watch: 16,
    );
  }
}
