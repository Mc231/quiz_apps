/// Rate App UI widgets and controller exports.
///
/// Provides the UI components and orchestration for the rate app system:
/// - [RateAppController] - Orchestrates the complete rate app flow with analytics
/// - [LoveDialog] - Two-step "Are you enjoying?" dialog
/// - [FeedbackDialog] - Feedback collection for unhappy users
///
/// These widgets work with [RateAppService] from shared_services
/// to implement intelligent app rating prompts.
///
/// ## Recommended Usage (with RateAppController)
///
/// ```dart
/// import 'package:quiz_engine/quiz_engine.dart';
///
/// // Create controller (typically once in your app)
/// final controller = RateAppController(
///   rateAppService: rateAppService,
///   analyticsService: analyticsService,
///   appName: 'Flags Quiz',
///   feedbackEmail: 'support@myapp.com',
/// );
///
/// // Call after quiz completion
/// final result = await controller.maybeShowRateApp(
///   context: context,
///   quizScore: 85,
///   completedQuizzes: 10,
/// );
///
/// // Result indicates what happened
/// switch (result) {
///   case RateAppFlowResult.rated:
///     // User rated the app
///     break;
///   case RateAppFlowResult.feedback:
///     // User provided feedback
///     break;
///   case RateAppFlowResult.conditionsNotMet:
///     // Conditions not met, nothing shown
///     break;
///   // ... other cases
/// }
/// ```
///
/// ## Manual Usage (for custom flows)
///
/// You can also use the dialogs directly for custom flows:
///
/// ```dart
/// final result = await LoveDialog.show(
///   context: context,
///   appName: 'Flags Quiz',
/// );
///
/// if (result == LoveDialogResult.positive) {
///   await rateAppService.showNativeRatingDialog();
/// }
/// ```
library;

export 'feedback_dialog.dart';
export 'love_dialog.dart';
export 'rate_app_config_provider.dart';
export 'rate_app_controller.dart';
