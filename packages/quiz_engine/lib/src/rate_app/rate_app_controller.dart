import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_services/shared_services.dart';

import 'feedback_dialog.dart';
import 'love_dialog.dart';

/// Result of the rate app flow.
enum RateAppFlowResult {
  /// Rate app was not configured (service is null).
  notConfigured,

  /// Conditions were not met for showing the prompt.
  conditionsNotMet,

  /// User rated the app positively.
  rated,

  /// User declined and provided feedback.
  feedback,

  /// User declined without feedback.
  declined,

  /// User dismissed without action.
  dismissed,

  /// An error occurred.
  error,
}

/// Controller for managing the in-app rating flow.
///
/// This controller orchestrates the complete rate app experience:
/// 1. Checks conditions using [RateAppService]
/// 2. Shows [LoveDialog] to gauge user sentiment
/// 3. For positive users: shows native rating dialog
/// 4. For negative users: shows feedback dialog
/// 5. Logs all analytics events throughout the flow
///
/// Example usage:
/// ```dart
/// final controller = RateAppController(
///   rateAppService: rateAppService,
///   analyticsService: analyticsService,
///   appName: 'My Quiz App',
/// );
///
/// await controller.maybeShowRateApp(
///   context: context,
///   quizScore: 85,
///   completedQuizzes: 10,
/// );
/// ```
class RateAppController {
  /// Creates a [RateAppController].
  RateAppController({
    required this.rateAppService,
    required this.analyticsService,
    required this.appName,
    this.appIcon,
    this.feedbackEmail,
  });

  /// The rate app service for condition checking and state management.
  final RateAppService? rateAppService;

  /// The analytics service for logging events.
  final AnalyticsService analyticsService;

  /// The app name to display in dialogs.
  final String appName;

  /// Optional app icon to display in love dialog.
  final Widget? appIcon;

  /// Optional email for feedback submissions.
  final String? feedbackEmail;

  /// Stopwatch for measuring time to respond.
  final Stopwatch _responseTimer = Stopwatch();

  /// Checks conditions and shows rate app flow if appropriate.
  ///
  /// Returns the result of the flow, which can be used to update UI or
  /// trigger other actions.
  ///
  /// [context] - The BuildContext for showing dialogs.
  /// [quizScore] - The score percentage from the completed quiz (0-100).
  /// [completedQuizzes] - Total number of quizzes completed by the user.
  Future<RateAppFlowResult> maybeShowRateApp({
    required BuildContext context,
    required int quizScore,
    required int completedQuizzes,
  }) async {
    final service = rateAppService;
    if (service == null) {
      return RateAppFlowResult.notConfigured;
    }

    // Check conditions
    final shouldShow = service.shouldShowPrompt(
      quizScore: quizScore,
      completedQuizzes: completedQuizzes,
    );

    final blockingReason = service.getBlockingReason(
      quizScore: quizScore,
      completedQuizzes: completedQuizzes,
    );

    // Log conditions checked event
    await analyticsService.logEvent(
      RateAppEvent.conditionsChecked(
        shouldShow: shouldShow,
        blockingReason: blockingReason,
        completedQuizzes: completedQuizzes,
        quizScore: quizScore,
        daysSinceInstall: service.state.daysSinceInstall,
        promptCount: service.state.promptCount,
        declineCount: service.state.declineCount,
      ),
    );

    if (!shouldShow) {
      return RateAppFlowResult.conditionsNotMet;
    }

    // Check if still mounted before showing dialog
    if (!context.mounted) {
      return RateAppFlowResult.error;
    }

    // Show love dialog
    return _showLoveDialog(
      context: context,
      service: service,
      completedQuizzes: completedQuizzes,
      quizScore: quizScore,
    );
  }

  /// Shows the love dialog and handles the response.
  Future<RateAppFlowResult> _showLoveDialog({
    required BuildContext context,
    required RateAppService service,
    required int completedQuizzes,
    required int quizScore,
  }) async {
    // Log love dialog shown
    await analyticsService.logEvent(
      RateAppEvent.loveDialogShown(
        completedQuizzes: completedQuizzes,
        quizScore: quizScore,
        promptCount: service.state.promptCount + 1,
      ),
    );

    // Start timer
    _responseTimer
      ..reset()
      ..start();

    // Show dialog
    final result = await LoveDialog.show(
      context: context,
      appName: appName,
      appIcon: appIcon,
    );

    // Stop timer
    _responseTimer.stop();
    final timeToRespond = Duration(milliseconds: _responseTimer.elapsedMilliseconds);

    // Handle result
    switch (result) {
      case LoveDialogResult.positive:
        await analyticsService.logEvent(
          RateAppEvent.loveDialogPositive(
            promptCount: service.state.promptCount + 1,
            timeToRespond: timeToRespond,
          ),
        );

        // Check if still mounted
        if (!context.mounted) {
          return RateAppFlowResult.error;
        }

        // Show native rating dialog
        return _showNativeRatingDialog(context: context, service: service);

      case LoveDialogResult.negative:
        await analyticsService.logEvent(
          RateAppEvent.loveDialogNegative(
            promptCount: service.state.promptCount + 1,
            declineCount: service.state.declineCount + 1,
            timeToRespond: timeToRespond,
          ),
        );
        await service.recordUserDeclined();

        // Check if still mounted
        if (!context.mounted) {
          return RateAppFlowResult.declined;
        }

        // Show feedback dialog
        return _showFeedbackDialog(context: context, service: service);

      case LoveDialogResult.dismissed:
        await analyticsService.logEvent(
          RateAppEvent.loveDialogDismissed(
            promptCount: service.state.promptCount + 1,
            timeToRespond: timeToRespond,
          ),
        );
        await service.recordUserDismissed();
        return RateAppFlowResult.dismissed;
    }
  }

  /// Shows the native rating dialog.
  Future<RateAppFlowResult> _showNativeRatingDialog({
    required BuildContext context,
    required RateAppService service,
  }) async {
    // Log native dialog shown
    await analyticsService.logEvent(
      RateAppEvent.nativeDialogShown(
        promptCount: service.state.promptCount + 1,
      ),
    );

    // Show native dialog
    final result = await service.showNativeRatingDialog();

    // Handle result
    return switch (result) {
      RateAppResultShown() => () async {
          await analyticsService.logEvent(
            RateAppEvent.nativeDialogCompleted(
              promptCount: service.state.promptCount,
            ),
          );
          await service.recordUserRated();
          return RateAppFlowResult.rated;
        }(),
      RateAppResultNotAvailable() => () async {
          await analyticsService.logEvent(
            RateAppEvent.nativeDialogUnavailable(
              platform: _getPlatformName(),
            ),
          );
          // Fall back to store listing
          await service.openStoreListing();
          await service.recordUserRated();
          return RateAppFlowResult.rated;
        }(),
      RateAppResultConditionsNotMet(:final reason) => () async {
          if (kDebugMode) {
            debugPrint('[RateApp] Native dialog conditions not met: $reason');
          }
          return RateAppFlowResult.conditionsNotMet;
        }(),
      RateAppResultError(:final error) => () async {
          if (kDebugMode) {
            debugPrint('[RateApp] Native dialog error: $error');
          }
          return RateAppFlowResult.error;
        }(),
    };
  }

  /// Shows the feedback dialog.
  Future<RateAppFlowResult> _showFeedbackDialog({
    required BuildContext context,
    required RateAppService service,
  }) async {
    // Log feedback dialog shown
    await analyticsService.logEvent(
      RateAppEvent.feedbackDialogShown(
        declineCount: service.state.declineCount,
        feedbackEmail: feedbackEmail,
      ),
    );

    // Start timer
    _responseTimer
      ..reset()
      ..start();

    // Show dialog
    final result = await FeedbackDialog.show(
      context: context,
      feedbackEmail: feedbackEmail,
    );

    // Stop timer
    _responseTimer.stop();
    final timeToRespond = Duration(milliseconds: _responseTimer.elapsedMilliseconds);

    // Handle result
    switch (result) {
      case FeedbackDialogResult.sendFeedback:
        await analyticsService.logEvent(
          RateAppEvent.feedbackSubmitted(
            declineCount: service.state.declineCount,
            timeToRespond: timeToRespond,
          ),
        );
        await service.recordFeedbackSubmitted();
        return RateAppFlowResult.feedback;

      case FeedbackDialogResult.dismissed:
        await analyticsService.logEvent(
          RateAppEvent.feedbackDismissed(
            declineCount: service.state.declineCount,
            timeToRespond: timeToRespond,
          ),
        );
        return RateAppFlowResult.declined;
    }
  }

  /// Gets the current platform name for analytics.
  String _getPlatformName() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isWindows) return 'windows';
      if (Platform.isLinux) return 'linux';
    } catch (_) {
      // Platform not available (e.g., in tests)
    }
    return 'unknown';
  }
}
