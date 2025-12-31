/// Rate App service exports.
///
/// Provides intelligent timing for app rating prompts:
/// - Configurable thresholds (quizzes, days, scores)
/// - Two-step "Love Dialog" approach
/// - Cooldown periods and decline limits
/// - Native in-app review integration
///
/// Example usage:
/// ```dart
/// import 'package:shared_services/shared_services.dart';
///
/// // Create and initialize the service
/// final rateAppService = RateAppService(
///   config: RateAppConfig(
///     minCompletedQuizzes: 5,
///     minScorePercentage: 70,
///     cooldownDays: 90,
///   ),
/// );
/// await rateAppService.initialize();
///
/// // Check after quiz completion
/// if (rateAppService.shouldShowPrompt(
///   quizScore: 85,
///   completedQuizzes: 10,
/// )) {
///   // Show love dialog or native rating
///   await rateAppService.showNativeRatingDialog();
/// }
/// ```
library;

export 'rate_app_config.dart';
export 'rate_app_service.dart';
export 'rate_app_state.dart';
