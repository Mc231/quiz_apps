/// Configuration for app secrets loaded from external JSON file.
///
/// This class provides type-safe access to secrets that should never
/// be committed to source control (API keys, credentials, etc.).
///
/// Usage:
/// ```dart
/// final secrets = await SecretsLoader.load('config/secrets.json');
/// final firebaseApiKey = secrets.firebase.apiKey;
/// final adMobAppId = secrets.adMob.appId;
/// ```
class SecretsConfig {
  /// Firebase configuration
  final FirebaseSecrets firebase;

  /// AdMob configuration for ads
  final AdMobSecrets adMob;

  /// API configuration for backend services
  final ApiSecrets api;

  /// Feature flags for conditional features
  final FeatureFlags features;

  /// Custom key-value pairs for app-specific secrets
  final Map<String, String> custom;

  const SecretsConfig({
    this.firebase = const FirebaseSecrets(),
    this.adMob = const AdMobSecrets(),
    this.api = const ApiSecrets(),
    this.features = const FeatureFlags(),
    this.custom = const {},
  });

  /// Creates an empty config with default values.
  /// Used when secrets file is missing or invalid.
  const SecretsConfig.empty()
      : firebase = const FirebaseSecrets(),
        adMob = const AdMobSecrets(),
        api = const ApiSecrets(),
        features = const FeatureFlags(),
        custom = const {};

  /// Creates config from JSON map.
  factory SecretsConfig.fromJson(Map<String, dynamic> json) {
    return SecretsConfig(
      firebase: json['firebase'] != null
          ? FirebaseSecrets.fromJson(json['firebase'] as Map<String, dynamic>)
          : const FirebaseSecrets(),
      adMob: json['adMob'] != null
          ? AdMobSecrets.fromJson(json['adMob'] as Map<String, dynamic>)
          : const AdMobSecrets(),
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
        'adMob': adMob.toJson(),
        'api': api.toJson(),
        'features': features.toJson(),
        'custom': custom,
      };

  /// Returns true if all required secrets are configured.
  bool get isConfigured =>
      firebase.isConfigured || adMob.isConfigured || api.isConfigured;

  /// Returns list of missing required secrets.
  List<String> get missingSecrets {
    final missing = <String>[];
    if (!firebase.isConfigured) missing.add('firebase');
    if (!adMob.isConfigured) missing.add('adMob');
    if (!api.isConfigured) missing.add('api');
    return missing;
  }

  SecretsConfig copyWith({
    FirebaseSecrets? firebase,
    AdMobSecrets? adMob,
    ApiSecrets? api,
    FeatureFlags? features,
    Map<String, String>? custom,
  }) {
    return SecretsConfig(
      firebase: firebase ?? this.firebase,
      adMob: adMob ?? this.adMob,
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

/// AdMob configuration secrets.
class AdMobSecrets {
  /// AdMob App ID
  final String appId;

  /// Banner ad unit ID
  final String bannerId;

  /// Interstitial ad unit ID
  final String interstitialId;

  /// Rewarded ad unit ID
  final String rewardedId;

  /// Native ad unit ID
  final String nativeId;

  /// iOS-specific ad unit IDs
  final AdMobPlatformSecrets ios;

  /// Android-specific ad unit IDs
  final AdMobPlatformSecrets android;

  const AdMobSecrets({
    this.appId = '',
    this.bannerId = '',
    this.interstitialId = '',
    this.rewardedId = '',
    this.nativeId = '',
    this.ios = const AdMobPlatformSecrets(),
    this.android = const AdMobPlatformSecrets(),
  });

  factory AdMobSecrets.fromJson(Map<String, dynamic> json) {
    return AdMobSecrets(
      appId: json['appId'] as String? ?? '',
      bannerId: json['bannerId'] as String? ?? '',
      interstitialId: json['interstitialId'] as String? ?? '',
      rewardedId: json['rewardedId'] as String? ?? '',
      nativeId: json['nativeId'] as String? ?? '',
      ios: json['ios'] != null
          ? AdMobPlatformSecrets.fromJson(json['ios'] as Map<String, dynamic>)
          : const AdMobPlatformSecrets(),
      android: json['android'] != null
          ? AdMobPlatformSecrets.fromJson(
              json['android'] as Map<String, dynamic>)
          : const AdMobPlatformSecrets(),
    );
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'bannerId': bannerId,
        'interstitialId': interstitialId,
        'rewardedId': rewardedId,
        'nativeId': nativeId,
        'ios': ios.toJson(),
        'android': android.toJson(),
      };

  bool get isConfigured => appId.isNotEmpty;
}

/// Platform-specific AdMob configuration.
class AdMobPlatformSecrets {
  final String appId;
  final String bannerId;
  final String interstitialId;
  final String rewardedId;
  final String nativeId;

  const AdMobPlatformSecrets({
    this.appId = '',
    this.bannerId = '',
    this.interstitialId = '',
    this.rewardedId = '',
    this.nativeId = '',
  });

  factory AdMobPlatformSecrets.fromJson(Map<String, dynamic> json) {
    return AdMobPlatformSecrets(
      appId: json['appId'] as String? ?? '',
      bannerId: json['bannerId'] as String? ?? '',
      interstitialId: json['interstitialId'] as String? ?? '',
      rewardedId: json['rewardedId'] as String? ?? '',
      nativeId: json['nativeId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'bannerId': bannerId,
        'interstitialId': interstitialId,
        'rewardedId': rewardedId,
        'nativeId': nativeId,
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