/// Analytics module exports.
///
/// This file exports all analytics-related classes for easy importing.
library;

// Core
export 'analytics_event.dart';
export 'analytics_service.dart';

// Events
export 'events/achievement_event.dart';
export 'events/daily_challenge_event.dart';
export 'events/deep_link_event.dart';
export 'events/error_event.dart';
export 'events/hint_event.dart';
export 'events/interaction_event.dart';
export 'events/monetization_event.dart';
export 'events/performance_event.dart';
export 'events/question_event.dart';
export 'events/quiz_event.dart';
export 'events/rate_app_event.dart';
export 'events/resource_event.dart';
export 'events/screen_view_event.dart';
export 'events/settings_event.dart';
export 'events/share_event.dart';
export 'events/streak_event.dart';

// Services
export 'services/composite_analytics_service.dart';
export 'services/console_analytics_service.dart';
export 'services/firebase_analytics_service.dart';
export 'services/no_op_analytics_service.dart';
