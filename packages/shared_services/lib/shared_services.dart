/// Shared services for quiz apps
///
/// This package contains platform-specific service implementations
/// that can be reused across multiple quiz apps.
library;

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
