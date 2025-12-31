/// Rate App UI widgets exports.
///
/// Provides the UI components for the rate app system:
/// - [LoveDialog] - Two-step "Are you enjoying?" dialog
/// - [FeedbackDialog] - Feedback collection for unhappy users
///
/// These widgets work with [RateAppService] from shared_services
/// to implement intelligent app rating prompts.
///
/// Example usage:
/// ```dart
/// import 'package:quiz_engine/quiz_engine.dart';
/// import 'package:shared_services/shared_services.dart';
///
/// // Check if we should show the prompt
/// if (rateAppService.shouldShowPrompt(
///   quizScore: 85,
///   completedQuizzes: 10,
/// )) {
///   // Show love dialog first
///   final result = await LoveDialog.show(
///     context: context,
///     appName: 'Flags Quiz',
///   );
///
///   switch (result) {
///     case LoveDialogResult.positive:
///       await rateAppService.showNativeRatingDialog();
///       await rateAppService.recordUserRated();
///       break;
///     case LoveDialogResult.negative:
///       final feedbackResult = await FeedbackDialog.show(
///         context: context,
///         feedbackEmail: 'support@myapp.com',
///       );
///       if (feedbackResult == FeedbackDialogResult.sendFeedback) {
///         // Launch email client
///         await rateAppService.recordFeedbackSubmitted();
///       } else {
///         await rateAppService.recordUserDeclined();
///       }
///       break;
///     case LoveDialogResult.dismissed:
///       await rateAppService.recordUserDismissed();
///       break;
///   }
/// }
/// ```
library;

export 'feedback_dialog.dart';
export 'love_dialog.dart';
