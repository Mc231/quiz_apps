import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SecretsConfig', () {
    test('empty constructor creates config with default values', () {
      const config = SecretsConfig.empty();

      expect(config.firebase.projectId, isEmpty);
      expect(config.firebase.apiKey, isEmpty);
      expect(config.api.baseUrl, isEmpty);
      expect(config.features.enableAds, isFalse);
      expect(config.features.enableAnalytics, isTrue);
      expect(config.custom, isEmpty);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'firebase': {
          'projectId': 'test-project',
          'apiKey': 'test-api-key',
          'appId': 'test-app-id',
        },
        'api': {
          'baseUrl': 'https://api.test.com',
          'apiKey': 'api-key-123',
          'version': 'v2',
        },
        'features': {
          'enableAds': true,
          'enableIap': false,
          'debugMode': true,
        },
        'custom': {
          'myKey': 'myValue',
        },
      };

      final config = SecretsConfig.fromJson(json);

      expect(config.firebase.projectId, 'test-project');
      expect(config.firebase.apiKey, 'test-api-key');
      expect(config.api.baseUrl, 'https://api.test.com');
      expect(config.api.version, 'v2');
      expect(config.features.enableAds, isTrue);
      expect(config.features.enableIap, isFalse);
      expect(config.features.debugMode, isTrue);
      expect(config.custom['myKey'], 'myValue');
    });

    test('toJson serializes all fields correctly', () {
      const config = SecretsConfig(
        firebase: FirebaseSecrets(
          projectId: 'my-project',
          apiKey: 'my-key',
        ),
        api: ApiSecrets(
          baseUrl: 'https://api.example.com',
        ),
        features: FeatureFlags(
          enableAds: true,
        ),
        custom: {'key': 'value'},
      );

      final json = config.toJson();

      expect(json['firebase']['projectId'], 'my-project');
      expect(json['firebase']['apiKey'], 'my-key');
      expect(json['api']['baseUrl'], 'https://api.example.com');
      expect(json['features']['enableAds'], isTrue);
      expect(json['custom']['key'], 'value');
    });

    test('isConfigured returns true when any service is configured', () {
      const emptyConfig = SecretsConfig.empty();
      expect(emptyConfig.isConfigured, isFalse);

      const configuredConfig = SecretsConfig(
        firebase: FirebaseSecrets(projectId: 'test', apiKey: 'test'),
      );
      expect(configuredConfig.isConfigured, isTrue);
    });

    test('missingSecrets returns list of unconfigured services', () {
      const config = SecretsConfig.empty();
      expect(config.missingSecrets, containsAll(['firebase', 'api']));

      const partialConfig = SecretsConfig(
        firebase: FirebaseSecrets(projectId: 'test', apiKey: 'test'),
      );
      expect(partialConfig.missingSecrets, contains('api'));
      expect(partialConfig.missingSecrets, isNot(contains('firebase')));
    });

    test('copyWith creates new instance with modified fields', () {
      const original = SecretsConfig(
        firebase: FirebaseSecrets(projectId: 'original'),
      );

      final modified = original.copyWith(
        api: const ApiSecrets(baseUrl: 'https://new-api.com'),
      );

      expect(modified.firebase.projectId, 'original');
      expect(modified.api.baseUrl, 'https://new-api.com');
    });
  });

  group('FirebaseSecrets', () {
    test('isConfigured requires both projectId and apiKey', () {
      const empty = FirebaseSecrets();
      expect(empty.isConfigured, isFalse);

      const onlyProject = FirebaseSecrets(projectId: 'test');
      expect(onlyProject.isConfigured, isFalse);

      const onlyKey = FirebaseSecrets(apiKey: 'test');
      expect(onlyKey.isConfigured, isFalse);

      const both = FirebaseSecrets(projectId: 'test', apiKey: 'test');
      expect(both.isConfigured, isTrue);
    });

    test('fromJson parses platform-specific config', () {
      final json = {
        'projectId': 'test-project',
        'ios': {
          'appId': 'ios-app-id',
          'bundleId': 'com.test.ios',
        },
        'android': {
          'appId': 'android-app-id',
          'bundleId': 'com.test.android',
        },
      };

      final secrets = FirebaseSecrets.fromJson(json);

      expect(secrets.ios.appId, 'ios-app-id');
      expect(secrets.ios.bundleId, 'com.test.ios');
      expect(secrets.android.appId, 'android-app-id');
      expect(secrets.android.bundleId, 'com.test.android');
    });
  });

  group('ApiSecrets', () {
    test('isConfigured requires baseUrl', () {
      const empty = ApiSecrets();
      expect(empty.isConfigured, isFalse);

      const withUrl = ApiSecrets(baseUrl: 'https://api.test.com');
      expect(withUrl.isConfigured, isTrue);
    });

    test('fromJson parses environment URLs', () {
      final json = {
        'baseUrl': 'https://api.prod.com',
        'environments': {
          'development': 'https://api.dev.com',
          'staging': 'https://api.staging.com',
          'production': 'https://api.prod.com',
        },
      };

      final secrets = ApiSecrets.fromJson(json);

      expect(secrets.environments.development, 'https://api.dev.com');
      expect(secrets.environments.staging, 'https://api.staging.com');
      expect(secrets.environments.production, 'https://api.prod.com');
    });

    test('defaults version to v1', () {
      final secrets = ApiSecrets.fromJson({});
      expect(secrets.version, 'v1');
    });
  });

  group('FeatureFlags', () {
    test('defaults have sensible values', () {
      const flags = FeatureFlags();

      expect(flags.enableAds, isFalse);
      expect(flags.enableIap, isFalse);
      expect(flags.enableAnalytics, isTrue);
      expect(flags.enableCrashReporting, isTrue);
      expect(flags.enableRemoteConfig, isFalse);
      expect(flags.debugMode, isFalse);
    });

    test('isEnabled returns custom flag value', () {
      const flags = FeatureFlags(
        custom: {'featureX': true, 'featureY': false},
      );

      expect(flags.isEnabled('featureX'), isTrue);
      expect(flags.isEnabled('featureY'), isFalse);
      expect(flags.isEnabled('featureZ'), isFalse); // Default for missing
    });

    test('fromJson parses custom flags', () {
      final json = {
        'enableAds': true,
        'custom': {
          'newFeature': true,
        },
      };

      final flags = FeatureFlags.fromJson(json);

      expect(flags.enableAds, isTrue);
      expect(flags.isEnabled('newFeature'), isTrue);
    });
  });

  group('SecretsLoader', () {
    test('loadFromString parses valid JSON', () {
      const jsonString = '''
      {
        "firebase": {
          "projectId": "test-project",
          "apiKey": "test-key"
        }
      }
      ''';

      final config = SecretsLoader.loadFromString(jsonString);

      expect(config.firebase.projectId, 'test-project');
      expect(config.firebase.apiKey, 'test-key');
    });

    test('loadFromString returns empty config for invalid JSON', () {
      final warnings = <String>[];
      final config = SecretsLoader.loadFromString(
        'invalid json {',
        onWarning: warnings.add,
      );

      expect(config.isConfigured, isFalse);
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('Invalid JSON'));
    });

    test('loadFromMap creates config from map', () {
      final json = {
        'api': {'baseUrl': 'https://test.com'}
      };

      final config = SecretsLoader.loadFromMap(json);

      expect(config.api.baseUrl, 'https://test.com');
    });
  });
}