import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../l10n/quiz_localizations.dart';

/// Represents a layout mode option for the selector.
///
/// Each option has an icon, label, and the actual [QuizLayoutConfig]
/// that will be used when this option is selected.
///
/// Example:
/// ```dart
/// LayoutModeOption(
///   id: 'standard',
///   icon: Icons.image,
///   label: 'Standard',
///   layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(),
/// )
/// ```
class LayoutModeOption {
  /// Unique identifier for this option.
  final String id;

  /// Icon to display in the selector.
  final IconData icon;

  /// Label text for this option.
  final String label;

  /// Optional short label for compact display.
  final String? shortLabel;

  /// Optional description explaining what this mode does.
  final String? description;

  /// The layout configuration this option represents.
  final QuizLayoutConfig layoutConfig;

  /// Creates a [LayoutModeOption].
  const LayoutModeOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.layoutConfig,
    this.shortLabel,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutModeOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A reusable segmented control for selecting quiz layout modes.
///
/// Displays a horizontal row of options that the user can select from.
/// Commonly used to switch between Standard, Reverse, and Mixed layouts.
///
/// Example:
/// ```dart
/// LayoutModeSelector(
///   options: [
///     LayoutModeOption(
///       id: 'standard',
///       icon: Icons.image,
///       label: 'Standard',
///       layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(),
///     ),
///     LayoutModeOption(
///       id: 'reverse',
///       icon: Icons.text_fields,
///       label: 'Reverse',
///       layoutConfig: QuizLayoutConfig.textQuestionImageAnswers(),
///     ),
///   ],
///   selectedOption: selectedOption,
///   onOptionSelected: (option) => setState(() => selectedOption = option),
/// )
/// ```
class LayoutModeSelector extends StatelessWidget {
  /// Available layout mode options.
  final List<LayoutModeOption> options;

  /// Currently selected option.
  final LayoutModeOption selectedOption;

  /// Callback when an option is selected.
  final ValueChanged<LayoutModeOption> onOptionSelected;

  /// Whether to use compact mode (icon only on small screens).
  final bool compact;

  /// Whether to use large mode with bigger buttons.
  final bool large;

  /// Padding around the selector.
  final EdgeInsetsGeometry padding;

  /// Creates a [LayoutModeSelector].
  const LayoutModeSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    this.compact = false,
    this.large = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    return Semantics(
      label: l10n.accessibilityLayoutModeSelector,
      hint: l10n.accessibilityLayoutModeSelectorHint,
      child: Padding(
        padding: padding,
        child: SegmentedButton<LayoutModeOption>(
        segments: options.map((option) {
          return ButtonSegment<LayoutModeOption>(
            value: option,
            icon: Icon(option.icon, size: large ? 24 : null),
            label: compact
                ? null
                : Text(
                    option.shortLabel ?? option.label,
                    overflow: TextOverflow.ellipsis,
                  ),
            tooltip: option.label,
          );
        }).toList(),
        selected: {selectedOption},
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            onOptionSelected(selected.first);
          }
        },
        style: ButtonStyle(
          visualDensity: large ? VisualDensity.standard : VisualDensity.compact,
          tapTargetSize: large
              ? MaterialTapTargetSize.padded
              : MaterialTapTargetSize.shrinkWrap,
          minimumSize: large
              ? const WidgetStatePropertyAll(Size(0, 48))
              : null,
          textStyle: WidgetStatePropertyAll(
            large ? theme.textTheme.titleSmall : theme.textTheme.labelMedium,
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// A card variant of the layout mode selector with a title.
///
/// Displays a styled card with segmented buttons for selecting quiz modes.
/// Each mode shows its icon and label, with a description of the selected mode.
///
/// Example:
/// ```dart
/// LayoutModeSelectorCard(
///   title: 'Quiz Mode',
///   options: layoutOptions,
///   selectedOption: selectedOption,
///   onOptionSelected: (option) => setState(() => selectedOption = option),
/// )
/// ```
class LayoutModeSelectorCard extends StatelessWidget {
  /// Title displayed above the selector.
  final String? title;

  /// Optional subtitle/description.
  final String? subtitle;

  /// Available layout mode options.
  final List<LayoutModeOption> options;

  /// Currently selected option.
  final LayoutModeOption selectedOption;

  /// Callback when an option is selected.
  final ValueChanged<LayoutModeOption> onOptionSelected;

  /// Creates a [LayoutModeSelectorCard].
  const LayoutModeSelectorCard({
    super.key,
    this.title,
    this.subtitle,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = selectedOption.description;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : Colors.grey.shade400,
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
            _buildModeButtons(context),
            if (description != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Expanded(
            child: GestureDetector(
              onTap: () => onOptionSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      size: 28,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.shortLabel ?? option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
