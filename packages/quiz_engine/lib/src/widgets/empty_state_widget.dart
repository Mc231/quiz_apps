import 'package:flutter/material.dart';

/// A consistent empty state widget used throughout the app.
///
/// Displays an icon, title, message, and optional action button.
/// Adapts to the current theme's color scheme.
///
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.history,
///   title: 'No History Yet',
///   message: 'Complete some quizzes to see your history here.',
///   actionLabel: 'Start Quiz',
///   onAction: () => navigateToQuiz(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Creates an [EmptyStateWidget].
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.iconSize = 64,
    this.iconColor,
    this.padding = const EdgeInsets.all(32),
    this.compact = false,
  });

  /// Creates an [EmptyStateWidget] for search results.
  factory EmptyStateWidget.noResults({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onClear,
    String? clearLabel,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.search_off_rounded,
      title: title ?? 'No Results Found',
      message: message ?? 'Try adjusting your search or filters.',
      onAction: onClear,
      actionLabel: clearLabel ?? 'Clear Filters',
      actionIcon: Icons.clear,
    );
  }

  /// Creates an [EmptyStateWidget] for empty lists.
  factory EmptyStateWidget.noData({
    Key? key,
    required IconData icon,
    required String title,
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
    IconData? actionIcon,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: icon,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
    );
  }

  /// Creates a compact [EmptyStateWidget] for inline use.
  factory EmptyStateWidget.compact({
    Key? key,
    required IconData icon,
    required String title,
    String? message,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: icon,
      title: title,
      message: message,
      iconSize: 48,
      padding: const EdgeInsets.all(24),
      compact: true,
    );
  }

  /// The icon to display.
  final IconData icon;

  /// The title text.
  final String title;

  /// Optional message text below the title.
  final String? message;

  /// Callback when the action button is tapped.
  ///
  /// If null, the action button is hidden.
  final VoidCallback? onAction;

  /// Label for the action button.
  final String? actionLabel;

  /// Optional icon for the action button.
  final IconData? actionIcon;

  /// The size of the icon.
  final double iconSize;

  /// Custom color for the icon.
  ///
  /// If null, uses a muted version of the surface variant color.
  final Color? iconColor;

  /// Padding around the widget.
  final EdgeInsets padding;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    final titleStyle = compact
        ? theme.textTheme.titleMedium
        : theme.textTheme.titleLarge;

    final messageStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodyMedium;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background
            Container(
              width: iconSize + 24,
              height: iconSize + 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor,
              ),
            ),
            SizedBox(height: compact ? 16 : 24),

            // Title
            Text(
              title,
              style: titleStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              SizedBox(height: compact ? 4 : 8),
              Text(
                message!,
                style: messageStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: compact ? 16 : 24),
              if (actionIcon != null)
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                )
              else
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
