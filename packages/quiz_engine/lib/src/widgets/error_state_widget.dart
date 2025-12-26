import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// A consistent error state widget used throughout the app.
///
/// Displays an error icon, message, and optional retry button.
/// Adapts to the current theme's color scheme.
///
/// Example usage:
/// ```dart
/// ErrorStateWidget(
///   message: 'Failed to load data',
///   onRetry: () => loadData(),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// Creates an [ErrorStateWidget].
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
    this.iconColor,
    this.showIcon = true,
    this.padding = const EdgeInsets.all(32),
  });

  /// Creates an [ErrorStateWidget] for network errors.
  factory ErrorStateWidget.network({
    Key? key,
    String? message,
    String? title,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return ErrorStateWidget(
      key: key,
      message: message ?? 'Unable to connect. Please check your connection.',
      title: title,
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: Icons.wifi_off_rounded,
    );
  }

  /// Creates an [ErrorStateWidget] for server errors.
  factory ErrorStateWidget.server({
    Key? key,
    String? message,
    String? title,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return ErrorStateWidget(
      key: key,
      message: message ?? 'Something went wrong. Please try again later.',
      title: title,
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: Icons.cloud_off_rounded,
    );
  }

  /// The error message to display.
  final String message;

  /// Optional title above the message.
  final String? title;

  /// Callback when the retry button is tapped.
  ///
  /// If null, the retry button is hidden.
  final VoidCallback? onRetry;

  /// Custom label for the retry button.
  ///
  /// If null, uses the localized "Retry" string.
  final String? retryLabel;

  /// The icon to display.
  final IconData icon;

  /// The size of the icon.
  final double iconSize;

  /// Custom color for the icon.
  ///
  /// If null, uses the theme's error color.
  final Color? iconColor;

  /// Whether to show the icon.
  final bool showIcon;

  /// Padding around the widget.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.error.withValues(alpha: 0.7);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (showIcon) ...[
              Container(
                width: iconSize + 24,
                height: iconSize + 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
