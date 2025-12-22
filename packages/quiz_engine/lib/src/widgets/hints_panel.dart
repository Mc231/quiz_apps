import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../quiz_widget_entry.dart';

/// A widget that displays available hint buttons for the quiz.
///
/// Shows buttons for different hint types (50/50, Skip) with their
/// remaining counts. Buttons are disabled when hints are not available.
///
/// This widget integrates with QuizBloc to trigger hint actions.
class HintsPanel extends StatelessWidget {
  /// The current hint state showing available hints
  final HintState? hintState;

  /// Callback to trigger the 50/50 hint
  final VoidCallback? onUse50_50;

  /// Callback to trigger the skip hint
  final VoidCallback? onUseSkip;

  /// Primary color for hint buttons
  final Color primaryColor;

  /// Disabled color for unavailable hints
  final Color disabledColor;

  /// Icon for 50/50 hint button
  final IconData fiftyFiftyIcon;

  /// Icon for skip hint button
  final IconData skipIcon;

  /// Text strings for the quiz UI
  final QuizTexts texts;

  const HintsPanel({
    super.key,
    required this.hintState,
    this.onUse50_50,
    this.onUseSkip,
    this.primaryColor = Colors.blue,
    this.disabledColor = Colors.grey,
    this.fiftyFiftyIcon = Icons.filter_2,
    this.skipIcon = Icons.skip_next,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show anything if hint state is not available
    if (hintState == null) {
      return const SizedBox.shrink();
    }

    // Check if any hints are available
    final hasFiftyFifty = hintState!.canUseHint(HintType.fiftyFifty);
    final hasSkip = hintState!.canUseHint(HintType.skip);

    // Don't show panel if no hints are available
    if (!hasFiftyFifty && !hasSkip) {
      return const SizedBox.shrink();
    }

    final buttonSize = getValueForScreenType<double>(
      context: context,
      mobile: 48,
      tablet: 56,
      desktop: 56,
      watch: 40,
    );

    final iconSize = getValueForScreenType<double>(
      context: context,
      mobile: 24,
      tablet: 28,
      desktop: 28,
      watch: 20,
    );

    final fontSize = getValueForScreenType<double>(
      context: context,
      mobile: 12,
      tablet: 14,
      desktop: 14,
      watch: 10,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 50/50 Hint Button
          if (hintState!.getRemainingCount(HintType.fiftyFifty) > 0)
            _buildHintButton(
              context: context,
              label: texts.hint5050Label,
              icon: fiftyFiftyIcon,
              count: hintState!.getRemainingCount(HintType.fiftyFifty),
              isEnabled: hasFiftyFifty,
              onPressed: hasFiftyFifty ? onUse50_50 : null,
              buttonSize: buttonSize,
              iconSize: iconSize,
              fontSize: fontSize,
            ),

          if (hintState!.getRemainingCount(HintType.fiftyFifty) > 0 &&
              hintState!.getRemainingCount(HintType.skip) > 0)
            const SizedBox(width: 16),

          // Skip Hint Button
          if (hintState!.getRemainingCount(HintType.skip) > 0)
            _buildHintButton(
              context: context,
              label: texts.hintSkipLabel,
              icon: skipIcon,
              count: hintState!.getRemainingCount(HintType.skip),
              isEnabled: hasSkip,
              onPressed: hasSkip ? onUseSkip : null,
              buttonSize: buttonSize,
              iconSize: iconSize,
              fontSize: fontSize,
            ),
        ],
      ),
    );
  }

  /// Builds a single hint button with icon, label, and count badge
  Widget _buildHintButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required int count,
    required bool isEnabled,
    required VoidCallback? onPressed,
    required double buttonSize,
    required double iconSize,
    required double fontSize,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main button
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? primaryColor : disabledColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: isEnabled ? 2 : 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Count badge
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.green : Colors.grey[400],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize * 0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}