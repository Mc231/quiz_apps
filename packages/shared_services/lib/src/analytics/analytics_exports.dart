/// Analytics module exports.
///
/// This file exports all analytics-related classes for easy importing.
library;

// Core
export 'analytics_event.dart';
export 'analytics_service.dart';

// Events
export 'events/achievement_event.dart';
export 'events/error_event.dart';
export 'events/hint_event.dart';
export 'events/interaction_event.dart';
export 'events/monetization_event.dart';
export 'events/performance_event.dart';
export 'events/question_event.dart';
export 'events/quiz_event.dart';
export 'events/resource_event.dart';
export 'events/screen_view_event.dart';
export 'events/settings_event.dart';

// Services
export 'services/console_analytics_service.dart';
export 'services/no_op_analytics_service.dart';
