/// Utility for mapping layout mode strings to localized labels.
library;

import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Gets the localized label for a layout mode string.
///
/// Maps storage layout mode values to user-friendly localized labels.
///
/// Returns null if [layoutMode] is null.
String? getLayoutModeLabel(BuildContext context, String? layoutMode) {
  if (layoutMode == null) return null;

  final l10n = QuizL10n.of(context);
  return switch (layoutMode) {
    'imageQuestionTextAnswers' => l10n.layoutImageQuestionTextAnswers,
    'textQuestionImageAnswers' => l10n.layoutTextQuestionImageAnswers,
    'textQuestionTextAnswers' => l10n.layoutTextQuestionTextAnswers,
    'audioQuestionTextAnswers' => l10n.layoutAudioQuestionTextAnswers,
    'mixed' => l10n.layoutMixed,
    _ => layoutMode, // Return as-is if unknown
  };
}

/// Gets a short layout mode label for badges/chips.
///
/// Returns more concise labels suitable for badges.
String? getLayoutModeShortLabel(BuildContext context, String? layoutMode) {
  if (layoutMode == null) return null;

  final l10n = QuizL10n.of(context);
  return switch (layoutMode) {
    'imageQuestionTextAnswers' => l10n.layoutStandard,
    'textQuestionImageAnswers' => l10n.layoutReverse,
    'textQuestionTextAnswers' => l10n.layoutText,
    'audioQuestionTextAnswers' => l10n.layoutAudio,
    'mixed' => l10n.layoutMixed,
    _ => layoutMode,
  };
}

/// Gets an icon for a layout mode.
///
/// Returns an appropriate icon for the layout mode.
IconData getLayoutModeIcon(String? layoutMode) {
  return switch (layoutMode) {
    'imageQuestionTextAnswers' => Icons.image_outlined,
    'textQuestionImageAnswers' => Icons.text_fields_outlined,
    'textQuestionTextAnswers' => Icons.article_outlined,
    'audioQuestionTextAnswers' => Icons.audiotrack_outlined,
    'mixed' => Icons.shuffle_outlined,
    _ => Icons.grid_view_outlined,
  };
}

/// Widget that displays a layout mode badge/chip.
class LayoutModeBadge extends StatelessWidget {
  /// Creates a [LayoutModeBadge].
  const LayoutModeBadge({
    super.key,
    required this.layoutMode,
    this.showIcon = true,
    this.compact = false,
  });

  /// The layout mode string from storage.
  final String? layoutMode;

  /// Whether to show an icon.
  final bool showIcon;

  /// Whether to use compact styling.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (layoutMode == null) return const SizedBox.shrink();

    final label = compact
        ? getLayoutModeShortLabel(context, layoutMode)
        : getLayoutModeLabel(context, layoutMode);

    if (label == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final icon = getLayoutModeIcon(layoutMode);
    final l10n = QuizL10n.of(context);

    return Semantics(
      label: l10n.accessibilityLayoutModeBadge(label),
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(compact ? 4 : 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                icon,
                size: compact ? 12 : 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: compact ? 2 : 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: compact ? 10 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
