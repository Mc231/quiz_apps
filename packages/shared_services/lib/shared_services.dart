/// Shared services for quiz apps
///
/// This package contains platform-specific service implementations
/// that can be reused across multiple quiz apps.
library;

// Analytics (Event tracking and analytics)
export 'src/analytics/analytics_exports.dart';

// Dependency Injection
export 'src/di/di_exports.dart';

// Data Providers (HTTP-based quiz data fetching)
export 'src/data_providers/data_providers_exports.dart';

// Infrastructure (Asset loading, platform services)
export 'src/infrastructure/asset_provider.dart';

// Audio (Sound effects)
export 'src/audio/audio_service.dart';
export 'src/audio/quiz_sound_effect.dart';

// Haptic (Haptic feedback)
export 'src/haptic/haptic_service.dart';

// Logger (Application logging)
export 'src/logger/logger_service.dart';
export 'package:logger/logger.dart' show Level;

// Settings (User preferences and configuration)
export 'src/settings/quiz_settings.dart';
export 'src/settings/settings_service.dart';

// Storage (Database and persistence)
export 'src/storage/storage_exports.dart';

// Achievements (Achievement system models)
export 'src/achievements/achievements_exports.dart';

// Resources (Lives, hints, skips management with IAP/Ads support)
export 'src/resources/resources.dart';

// Config (Secrets and configuration loading)
export 'src/config/config_exports.dart';

// Ads (AdMob integration)
export 'src/ads/ads_exports.dart';

// In-App Purchases (IAP)
export 'src/iap/iap_exports.dart';

// Rate App (In-app review prompts)
export 'src/rate_app/rate_app_exports.dart';

// Share (Social sharing of quiz results)
export 'src/share/share_exports.dart';

// Deep Links (App URL scheme handling)
export 'src/deeplink/deeplink_exports.dart';
