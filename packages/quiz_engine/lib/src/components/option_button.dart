import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_theme_data.dart';

/// A customizable button widget used for displaying options in the app.
///
/// The `OptionButton` class is a stateless widget that represents an option
/// button with a title and a click callback. It is designed to be used
/// in various parts of the application where user interaction is required,
/// such as selecting answers in a quiz or navigating between options.
///
/// The button is styled with a consistent design, including a rounded border,
/// background color, and font size that adapts to different screen sizes
/// using the `responsive_builder` package.
///
class OptionButton extends StatelessWidget {
  /// The title displayed on the button.
  final String title;

  /// The callback function invoked when the button is clicked.
  final VoidCallback? onClickListener;

  /// Whether the button is disabled (e.g., from using 50/50 hint).
  final bool isDisabled;

  /// Theme data for customizing button appearance.
  final QuizThemeData themeData;

  /// Creates an `OptionButton` with the specified title and click listener.
  ///
  /// [key] is the unique key for this widget.
  /// [title] is the text displayed on the button.
  /// [onClickListener] is the function called when the button is pressed.
  /// [isDisabled] indicates if the button should be disabled.
  /// [themeData] provides theme customization options.
  const OptionButton({
    super.key,
    required this.title,
    required this.onClickListener,
    this.isDisabled = false,
    this.themeData = const QuizThemeData(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeData;
    final l10n = QuizL10n.of(context);

    final semanticLabel = isDisabled
        ? l10n.accessibilityAnswerDisabled(title)
        : l10n.accessibilityAnswerOption(title);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: SizedBox.expand(
        child: ElevatedButton(
          onPressed: isDisabled ? null : onClickListener,
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(color: theme.buttonTextColor),
            shape: RoundedRectangleBorder(
              borderRadius: theme.buttonBorderRadius,
              side: BorderSide(
                color: isDisabled ? Colors.grey : theme.buttonBorderColor,
                width: theme.buttonBorderWidth,
              ),
            ),
            backgroundColor: isDisabled ? Colors.grey[300] : theme.buttonColor,
            foregroundColor:
                isDisabled ? Colors.grey[600] : theme.buttonTextColor,
            padding: theme.buttonPadding,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
          ),
          child: Text(
            title,
            maxLines: theme.buttonMaxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.buttonTextStyle.copyWith(
              fontSize: _getFontSize(context, theme),
              decoration: isDisabled ? TextDecoration.lineThrough : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Returns the font size for the button's title text based on screen size and theme.
  ///
  /// This method uses `getValueForScreenType` to adjust the font size
  /// for different device types, pulling values from the theme configuration.
  ///
  /// [context] is the `BuildContext` used to determine the screen size.
  /// [theme] is the theme data containing font size values.
  ///
  /// Returns the font size for the button's title text.
  double _getFontSize(BuildContext context, QuizThemeData theme) {
    return getValueForScreenType(
      context: context,
      mobile: theme.buttonFontSizeMobile,
      tablet: theme.buttonFontSizeTablet,
      desktop: theme.buttonFontSizeDesktop,
      watch: theme.buttonFontSizeWatch,
    );
  }
}
