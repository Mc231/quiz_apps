import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// A widget that displays the remaining lives in a quiz game.
///
/// Shows hearts (or other icons) to represent lives, with filled hearts for
/// remaining lives and empty/grayed hearts for lost lives.
///
/// This widget is only visible when the quiz mode supports lives tracking
/// (LivesMode, SurvivalMode, or EndlessMode).
///
/// @deprecated Use [GameResourcePanel] or [GameResourceButton] instead.
/// This widget will be removed in a future version. The new components provide:
/// - Single icon with count badge (more space efficient)
/// - Animations (pulse, shake, scale)
/// - Adaptive layout via [AdaptiveResourcePanel]
/// - Long-press tooltips
/// - Better theming support via [GameResourceTheme]
@Deprecated(
  'Use GameResourcePanel or GameResourceButton instead. '
  'This widget will be removed in a future version.',
)
class LivesDisplay extends StatelessWidget {
  /// The number of remaining lives (null if lives are not tracked)
  final int? remainingLives;

  /// The total number of lives at the start
  final int? totalLives;

  /// The icon to use for filled (remaining) lives
  final IconData filledIcon;

  /// The icon to use for empty (lost) lives
  final IconData emptyIcon;

  /// The color for filled (remaining) lives
  final Color filledColor;

  /// The color for empty (lost) lives
  final Color emptyColor;

  const LivesDisplay({
    super.key,
    required this.remainingLives,
    required this.totalLives,
    this.filledIcon = Icons.favorite,
    this.emptyIcon = Icons.favorite_border,
    this.filledColor = Colors.red,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show anything if lives are not tracked
    if (remainingLives == null || totalLives == null) {
      return const SizedBox.shrink();
    }

    final iconSize = getValueForScreenType<double>(
      context: context,
      mobile: 24,
      tablet: 32,
      desktop: 32,
      watch: 16,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalLives!, (index) {
        final isAlive = index < remainingLives!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            isAlive ? filledIcon : emptyIcon,
            color: isAlive ? filledColor : emptyColor,
            size: iconSize,
          ),
        );
      }),
    );
  }
}
