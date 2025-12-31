import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_accessibility.dart';
import '../theme/quiz_animations.dart';

/// Result from the [LoveDialog].
enum LoveDialogResult {
  /// User tapped "Yes!" - they enjoy the app.
  positive,

  /// User tapped "Not Really" - they don't enjoy the app.
  negative,

  /// User dismissed the dialog without making a choice.
  dismissed,
}

/// A dialog that asks users if they're enjoying the app.
///
/// This is the first step in the two-step rating approach:
/// 1. Ask if user enjoys the app (this dialog)
/// 2. If yes -> show native rating dialog
///    If no -> show feedback dialog
///
/// Example usage:
/// ```dart
/// final result = await LoveDialog.show(
///   context: context,
///   appName: 'Flags Quiz',
///   appIcon: Image.asset('assets/icon.png'),
/// );
///
/// switch (result) {
///   case LoveDialogResult.positive:
///     // Show native rating dialog
///     break;
///   case LoveDialogResult.negative:
///     // Show feedback dialog
///     break;
///   case LoveDialogResult.dismissed:
///     // User dismissed, do nothing
///     break;
/// }
/// ```
class LoveDialog extends StatefulWidget {
  /// The name of the app to display in the dialog.
  final String appName;

  /// Optional app icon to display.
  final Widget? appIcon;

  /// Callback when user taps "Yes!".
  final VoidCallback? onPositive;

  /// Callback when user taps "Not Really".
  final VoidCallback? onNegative;

  /// Creates a new [LoveDialog].
  const LoveDialog({
    super.key,
    required this.appName,
    this.appIcon,
    this.onPositive,
    this.onNegative,
  });

  /// Shows the love dialog and returns the result.
  static Future<LoveDialogResult> show({
    required BuildContext context,
    required String appName,
    Widget? appIcon,
  }) async {
    final result = await showDialog<LoveDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoveDialog(
        appName: appName,
        appIcon: appIcon,
        onPositive: () => Navigator.of(context).pop(LoveDialogResult.positive),
        onNegative: () => Navigator.of(context).pop(LoveDialogResult.negative),
      ),
    );
    return result ?? LoveDialogResult.dismissed;
  }

  @override
  State<LoveDialog> createState() => _LoveDialogState();
}

class _LoveDialogState extends State<LoveDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuizAnimations.durationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: QuizAnimations.curveEnter),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: QuizAnimations.curveEnter),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        );
      },
      child: Semantics(
        label: l10n.accessibilityRateDialogTitle,
        container: true,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              if (widget.appIcon != null) ...[
                SizedBox(
                  width: 64,
                  height: 64,
                  child: widget.appIcon,
                ),
                const SizedBox(height: 16),
              ],

              // Title
              Text(
                l10n.rateAppLoveDialogTitle(widget.appName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Negative button
                  Expanded(
                    child: QuizAccessibility.semanticButton(
                      label: l10n.rateAppLoveDialogNo,
                      hint: l10n.accessibilityDoubleTapToSelect,
                      child: OutlinedButton(
                        onPressed: widget.onNegative,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            QuizAccessibility.minTouchTarget,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(l10n.rateAppLoveDialogNo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Positive button
                  Expanded(
                    child: QuizAccessibility.semanticButton(
                      label: l10n.rateAppLoveDialogYes,
                      hint: l10n.accessibilityDoubleTapToSelect,
                      child: FilledButton(
                        onPressed: widget.onPositive,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            QuizAccessibility.minTouchTarget,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(l10n.rateAppLoveDialogYes),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
