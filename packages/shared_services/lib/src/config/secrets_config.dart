/// Configuration for app secrets loaded from external JSON file.
///
/// This class provides type-safe access to secrets that should never
/// be committed to source control (API keys, credentials, etc.).
///
/// Usage:
/// ```dart
/// final secrets = await SecretsLoader.load('config/secrets.json');
/// final firebaseApiKey = secrets.firebase.apiKey;
/// ```
class SecretsConfig {
  /// Firebase configuration
  final FirebaseSecrets firebase;

  /// API configuration for backend services
  final ApiSecrets api;

  /// Feature flags for conditional features
  final FeatureFlags features;

  /// Custom key-value pairs for app-specific secrets
  final Map<String, String> custom;

  const SecretsConfig({
    this.firebase = const FirebaseSecrets(),
    this.api = const ApiSecrets(),
    this.features = const FeatureFlags(),
    this.custom = const {},
  });

  /// Creates an empty config with default values.
  /// Used when secrets file is missing or invalid.
  const SecretsConfig.empty()
      : firebase = const FirebaseSecrets(),
        api = const ApiSecrets(),
        features = const FeatureFlags(),
        custom = const {};

  /// Creates config from JSON map.
  factory SecretsConfig.fromJson(Map<String, dynamic> json) {
    return SecretsConfig(
      firebase: json['firebase'] != null
          ? FirebaseSecrets.fromJson(json['firebase'] as Map<String, dynamic>)
          : const FirebaseSecrets(),
      api: json['api'] != null
          ? ApiSecrets.fromJson(json['api'] as Map<String, dynamic>)
          : const ApiSecrets(),
      features: json['features'] != null
          ? FeatureFlags.fromJson(json['features'] as Map<String, dynamic>)
          : const FeatureFlags(),
      custom: json['custom'] != null
          ? Map<String, String>.from(json['custom'] as Map)
          : const {},
    );
  }

  /// Converts config to JSON map.
  Map<String, dynamic> toJson() => {
        'firebase': firebase.toJson(),
        'api': api.toJson(),
        'features': features.toJson(),
        'custom': custom,
      };

  /// Returns true if all required secrets are configured.
  bool get isConfigured => firebase.isConfigured || api.isConfigured;

  /// Returns list of missing required secrets.
  List<String> get missingSecrets {
    final missing = <String>[];
    if (!firebase.isConfigured) missing.add('firebase');
    if (!api.isConfigured) missing.add('api');
    return missing;
  }

  SecretsConfig copyWith({
    FirebaseSecrets? firebase,
    ApiSecrets? api,
    FeatureFlags? features,
    Map<String, String>? custom,
  }) {
    return SecretsConfig(
      firebase: firebase ?? this.firebase,
      api: api ?? this.api,
      features: features ?? this.features,
      custom: custom ?? this.custom,
    );
  }
}

/// Firebase configuration secrets.
class FirebaseSecrets {
  /// Firebase project ID
  final String projectId;

  /// Firebase API key (Web API Key)
  final String apiKey;

  /// Firebase App ID
  final String appId;

  /// Firebase messaging sender ID
  final String messagingSenderId;

  /// Firebase storage bucket
  final String storageBucket;

  /// iOS-specific configuration
  final FirebasePlatformSecrets ios;

  /// Android-specific configuration
  final FirebasePlatformSecrets android;

  const FirebaseSecrets({
    this.projectId = '',
    this.apiKey = '',
    this.appId = '',
    this.messagingSenderId = '',
    this.storageBucket = '',
    this.ios = const FirebasePlatformSecrets(),
    this.android = const FirebasePlatformSecrets(),
  });

  factory FirebaseSecrets.fromJson(Map<String, dynamic> json) {
    return FirebaseSecrets(
      projectId: json['projectId'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      appId: json['appId'] as String? ?? '',
      messagingSenderId: json['messagingSenderId'] as String? ?? '',
      storageBucket: json['storageBucket'] as String? ?? '',
      ios: json['ios'] != null
          ? FirebasePlatformSecrets.fromJson(json['ios'] as Map<String, dynamic>)
          : const FirebasePlatformSecrets(),
      android: json['android'] != null
          ? FirebasePlatformSecrets.fromJson(
              json['android'] as Map<String, dynamic>)
          : const FirebasePlatformSecrets(),
    );
  }

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
        'apiKey': apiKey,
        'appId': appId,
        'messagingSenderId': messagingSenderId,
        'storageBucket': storageBucket,
        'ios': ios.toJson(),
        'android': android.toJson(),
      };

  bool get isConfigured => projectId.isNotEmpty && apiKey.isNotEmpty;
}

/// Platform-specific Firebase configuration.
class FirebasePlatformSecrets {
  /// Platform-specific App ID
  final String appId;

  /// Platform-specific API key
  final String apiKey;

  /// Bundle ID (iOS) or Package name (Android)
  final String bundleId;

  const FirebasePlatformSecrets({
    this.appId = '',
    this.apiKey = '',
    this.bundleId = '',
  });

  factory FirebasePlatformSecrets.fromJson(Map<String, dynamic> json) {
    return FirebasePlatformSecrets(
      appId: json['appId'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      bundleId: json['bundleId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'apiKey': apiKey,
        'bundleId': bundleId,
      };
}

/// API configuration secrets.
class ApiSecrets {
  /// Base URL for API requests
  final String baseUrl;

  /// API key for authentication
  final String apiKey;

  /// API version
  final String version;

  /// Environment-specific URLs
  final ApiEnvironmentSecrets environments;

  const ApiSecrets({
    this.baseUrl = '',
    this.apiKey = '',
    this.version = 'v1',
    this.environments = const ApiEnvironmentSecrets(),
  });

  factory ApiSecrets.fromJson(Map<String, dynamic> json) {
    return ApiSecrets(
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      version: json['version'] as String? ?? 'v1',
      environments: json['environments'] != null
          ? ApiEnvironmentSecrets.fromJson(
              json['environments'] as Map<String, dynamic>)
          : const ApiEnvironmentSecrets(),
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'version': version,
        'environments': environments.toJson(),
      };

  bool get isConfigured => baseUrl.isNotEmpty;
}

/// Environment-specific API URLs.
class ApiEnvironmentSecrets {
  final String development;
  final String staging;
  final String production;

  const ApiEnvironmentSecrets({
    this.development = '',
    this.staging = '',
    this.production = '',
  });

  factory ApiEnvironmentSecrets.fromJson(Map<String, dynamic> json) {
    return ApiEnvironmentSecrets(
      development: json['development'] as String? ?? '',
      staging: json['staging'] as String? ?? '',
      production: json['production'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'development': development,
        'staging': staging,
        'production': production,
      };
}

/// Feature flags for conditional features.
class FeatureFlags {
  /// Enable ads in the app
  final bool enableAds;

  /// Enable in-app purchases
  final bool enableIap;

  /// Enable analytics tracking
  final bool enableAnalytics;

  /// Enable crash reporting
  final bool enableCrashReporting;

  /// Enable remote config
  final bool enableRemoteConfig;

  /// Enable debug mode features
  final bool debugMode;

  /// Custom feature flags
  final Map<String, bool> custom;

  const FeatureFlags({
    this.enableAds = false,
    this.enableIap = false,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enableRemoteConfig = false,
    this.debugMode = false,
    this.custom = const {},
  });

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      enableAds: json['enableAds'] as bool? ?? false,
      enableIap: json['enableIap'] as bool? ?? false,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? true,
      enableRemoteConfig: json['enableRemoteConfig'] as bool? ?? false,
      debugMode: json['debugMode'] as bool? ?? false,
      custom: json['custom'] != null
          ? Map<String, bool>.from(json['custom'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'enableAds': enableAds,
        'enableIap': enableIap,
        'enableAnalytics': enableAnalytics,
        'enableCrashReporting': enableCrashReporting,
        'enableRemoteConfig': enableRemoteConfig,
        'debugMode': debugMode,
        'custom': custom,
      };

  /// Check if a custom feature flag is enabled.
  bool isEnabled(String flag) => custom[flag] ?? false;
}