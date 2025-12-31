import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_accessibility.dart';
import '../theme/quiz_animations.dart';

/// Result from the [FeedbackDialog].
enum FeedbackDialogResult {
  /// User tapped "Send Feedback" button.
  sendFeedback,

  /// User tapped "Maybe Later" button.
  dismissed,
}

/// A dialog shown when users indicate they're not enjoying the app.
///
/// Provides options to:
/// - Send feedback via email
/// - Dismiss and continue using the app
///
/// Example usage:
/// ```dart
/// final result = await FeedbackDialog.show(
///   context: context,
///   feedbackEmail: 'feedback@myapp.com',
///   appName: 'Flags Quiz',
/// );
///
/// switch (result) {
///   case FeedbackDialogResult.sendFeedback:
///     // Open email client with feedback template
///     break;
///   case FeedbackDialogResult.dismissed:
///     // User dismissed, do nothing
///     break;
/// }
/// ```
class FeedbackDialog extends StatefulWidget {
  /// Email address for feedback (optional).
  ///
  /// If provided, the "Send Feedback" button will be shown.
  final String? feedbackEmail;

  /// Callback when user taps "Send Feedback".
  final VoidCallback? onSendFeedback;

  /// Callback when user taps "Maybe Later".
  final VoidCallback? onDismiss;

  /// Creates a new [FeedbackDialog].
  const FeedbackDialog({
    super.key,
    this.feedbackEmail,
    this.onSendFeedback,
    this.onDismiss,
  });

  /// Shows the feedback dialog and returns the result.
  static Future<FeedbackDialogResult> show({
    required BuildContext context,
    String? feedbackEmail,
  }) async {
    final result = await showDialog<FeedbackDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => FeedbackDialog(
        feedbackEmail: feedbackEmail,
        onSendFeedback: () =>
            Navigator.of(context).pop(FeedbackDialogResult.sendFeedback),
        onDismiss: () =>
            Navigator.of(context).pop(FeedbackDialogResult.dismissed),
      ),
    );
    return result ?? FeedbackDialogResult.dismissed;
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog>
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
    final hasFeedbackEmail = widget.feedbackEmail != null;

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
        label: l10n.accessibilityFeedbackDialogTitle,
        container: true,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                Icons.feedback_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.rateAppFeedbackTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                l10n.rateAppFeedbackMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Send Feedback button (only if email is provided)
                  if (hasFeedbackEmail) ...[
                    QuizAccessibility.semanticButton(
                      label: l10n.rateAppFeedbackEmailButton,
                      hint: l10n.accessibilityDoubleTapToSelect,
                      child: FilledButton.icon(
                        onPressed: widget.onSendFeedback,
                        icon: const Icon(Icons.email_outlined),
                        label: Text(l10n.rateAppFeedbackEmailButton),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            QuizAccessibility.minTouchTarget,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Dismiss button
                  QuizAccessibility.semanticButton(
                    label: l10n.rateAppFeedbackDismiss,
                    hint: l10n.accessibilityDoubleTapToSelect,
                    child: TextButton(
                      onPressed: widget.onDismiss,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          QuizAccessibility.minTouchTarget,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.rateAppFeedbackDismiss),
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
