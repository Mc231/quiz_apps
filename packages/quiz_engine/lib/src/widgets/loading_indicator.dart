import 'package:flutter/material.dart';

/// A consistent loading indicator widget used throughout the app.
///
/// Displays a centered circular progress indicator with an optional message.
/// The indicator adapts to the current theme's color scheme.
///
/// Example usage:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator(message: 'Loading quiz...')
/// LoadingIndicator.small()
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Creates a [LoadingIndicator].
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.padding = const EdgeInsets.all(24),
  });

  /// Creates a small loading indicator for inline use.
  const LoadingIndicator.small({
    super.key,
    this.message,
    this.color,
    this.padding = const EdgeInsets.all(8),
  }) : size = LoadingIndicatorSize.small;

  /// Creates a large loading indicator for full-screen use.
  const LoadingIndicator.large({
    super.key,
    this.message,
    this.color,
    this.padding = const EdgeInsets.all(32),
  }) : size = LoadingIndicatorSize.large;

  /// Optional message to display below the indicator.
  final String? message;

  /// The size of the loading indicator.
  final LoadingIndicatorSize size;

  /// Optional custom color for the indicator.
  ///
  /// If null, uses the theme's primary color.
  final Color? color;

  /// Padding around the indicator.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    final indicatorSize = switch (size) {
      LoadingIndicatorSize.small => 20.0,
      LoadingIndicatorSize.medium => 36.0,
      LoadingIndicatorSize.large => 48.0,
    };

    final strokeWidth = switch (size) {
      LoadingIndicatorSize.small => 2.0,
      LoadingIndicatorSize.medium => 3.0,
      LoadingIndicatorSize.large => 4.0,
    };

    final textStyle = switch (size) {
      LoadingIndicatorSize.small => theme.textTheme.bodySmall,
      LoadingIndicatorSize.medium => theme.textTheme.bodyMedium,
      LoadingIndicatorSize.large => theme.textTheme.bodyLarge,
    };

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: size == LoadingIndicatorSize.small ? 8 : 16),
              Text(
                message!,
                style: textStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The size variants for [LoadingIndicator].
enum LoadingIndicatorSize {
  /// Small indicator (20px) for inline use.
  small,

  /// Medium indicator (36px) for general use.
  medium,

  /// Large indicator (48px) for full-screen loading.
  large,
}
