import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

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

  /// The layout configuration this option represents.
  final QuizLayoutConfig layoutConfig;

  /// Creates a [LayoutModeOption].
  const LayoutModeOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.layoutConfig,
    this.shortLabel,
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

    return Padding(
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
        ),
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
      ),
    );
  }
}

/// A card variant of the layout mode selector with a title.
///
/// Useful when the selector needs a header or description.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (title != null || subtitle != null) const SizedBox(height: 8),
        LayoutModeSelector(
          options: options,
          selectedOption: selectedOption,
          onOptionSelected: onOptionSelected,
        ),
      ],
    );
  }
}
