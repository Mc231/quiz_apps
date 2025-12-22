/// Shared services for quiz apps
///
/// This package contains platform-specific service implementations
/// that can be reused across multiple quiz apps.
library;

// Data Providers (HTTP-based quiz data fetching)
export 'src/data_providers/data_providers_exports.dart';

// Infrastructure (Asset loading, platform services)
export 'src/infrastructure/asset_provider.dart';

// Audio (Sound effects)
export 'src/audio/audio_service.dart';
export 'src/audio/quiz_sound_effect.dart';

// Haptic (Haptic feedback)
export 'src/haptic/haptic_service.dart';

// Settings (User preferences and configuration)
export 'src/settings/quiz_settings.dart';
export 'src/settings/settings_service.dart';
