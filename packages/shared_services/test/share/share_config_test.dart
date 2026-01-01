import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ShareConfig', () {
    group('constructor', () {
      test('creates config with required fields', () {
        const config = ShareConfig(appName: 'Flags Quiz');

        expect(config.appName, 'Flags Quiz');
        expect(config.appStoreUrl, isNull);
        expect(config.playStoreUrl, isNull);
        expect(config.webUrl, isNull);
        expect(config.hashtags, isEmpty);
        expect(config.enableImageSharing, isTrue);
        expect(config.enableTextSharing, isTrue);
        expect(config.includeAppLink, isTrue);
        expect(config.includeHashtags, isTrue);
        expect(config.defaultShareMessage, isNull);
      });

      test('creates config with all fields', () {
        const config = ShareConfig(
          appName: 'Flags Quiz',
          appStoreUrl: 'https://apps.apple.com/app/id123',
          playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
          webUrl: 'https://flagsquiz.example.com',
          hashtags: ['FlagsQuiz', 'Quiz', 'Trivia'],
          enableImageSharing: false,
          enableTextSharing: true,
          includeAppLink: false,
          includeHashtags: true,
          defaultShareMessage: 'Custom message',
        );

        expect(config.appName, 'Flags Quiz');
        expect(config.appStoreUrl, 'https://apps.apple.com/app/id123');
        expect(config.playStoreUrl, 'https://play.google.com/store/apps/details?id=com.example');
        expect(config.webUrl, 'https://flagsquiz.example.com');
        expect(config.hashtags, ['FlagsQuiz', 'Quiz', 'Trivia']);
        expect(config.enableImageSharing, isFalse);
        expect(config.enableTextSharing, isTrue);
        expect(config.includeAppLink, isFalse);
        expect(config.includeHashtags, isTrue);
        expect(config.defaultShareMessage, 'Custom message');
      });
    });

    group('factory ShareConfig.test', () {
      test('creates minimal test config', () {
        const config = ShareConfig.test();

        expect(config.appName, 'Test App');
        expect(config.enableImageSharing, isTrue);
        expect(config.enableTextSharing, isTrue);
        expect(config.includeAppLink, isFalse);
        expect(config.includeHashtags, isFalse);
      });

      test('allows overriding test defaults', () {
        const config = ShareConfig.test(
          appName: 'Custom Test App',
          hashtags: ['Test'],
        );

        expect(config.appName, 'Custom Test App');
        expect(config.hashtags, ['Test']);
      });
    });

    group('factory ShareConfig.disabled', () {
      test('creates disabled config', () {
        const config = ShareConfig.disabled();

        expect(config.enableImageSharing, isFalse);
        expect(config.enableTextSharing, isFalse);
        expect(config.isEnabled, isFalse);
      });
    });

    group('computed properties', () {
      test('isEnabled returns true when text sharing enabled', () {
        const config = ShareConfig(
          appName: 'Test',
          enableImageSharing: false,
          enableTextSharing: true,
        );

        expect(config.isEnabled, isTrue);
      });

      test('isEnabled returns true when image sharing enabled', () {
        const config = ShareConfig(
          appName: 'Test',
          enableImageSharing: true,
          enableTextSharing: false,
        );

        expect(config.isEnabled, isTrue);
      });

      test('isEnabled returns false when both disabled', () {
        const config = ShareConfig(
          appName: 'Test',
          enableImageSharing: false,
          enableTextSharing: false,
        );

        expect(config.isEnabled, isFalse);
      });

      test('hasAppLinks returns true when any link available', () {
        const withAppStore = ShareConfig(
          appName: 'Test',
          appStoreUrl: 'https://apps.apple.com/app/id123',
        );
        const withPlayStore = ShareConfig(
          appName: 'Test',
          playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
        );
        const withWeb = ShareConfig(
          appName: 'Test',
          webUrl: 'https://example.com',
        );
        const withNone = ShareConfig(appName: 'Test');

        expect(withAppStore.hasAppLinks, isTrue);
        expect(withPlayStore.hasAppLinks, isTrue);
        expect(withWeb.hasAppLinks, isTrue);
        expect(withNone.hasAppLinks, isFalse);
      });

      test('formattedHashtags formats correctly', () {
        const config = ShareConfig(
          appName: 'Test',
          hashtags: ['FlagsQuiz', 'Quiz', 'Trivia'],
        );

        expect(config.formattedHashtags, '#FlagsQuiz #Quiz #Trivia');
      });

      test('formattedHashtags returns empty string for no hashtags', () {
        const config = ShareConfig(appName: 'Test');

        expect(config.formattedHashtags, isEmpty);
      });
    });

    group('getAppLinkForPlatform', () {
      const config = ShareConfig(
        appName: 'Test',
        appStoreUrl: 'https://apps.apple.com/app/id123',
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
        webUrl: 'https://example.com',
      );

      test('returns appStoreUrl for iOS', () {
        expect(
          config.getAppLinkForPlatform(TargetPlatform.iOS),
          'https://apps.apple.com/app/id123',
        );
      });

      test('returns appStoreUrl for macOS', () {
        expect(
          config.getAppLinkForPlatform(TargetPlatform.macOS),
          'https://apps.apple.com/app/id123',
        );
      });

      test('returns playStoreUrl for Android', () {
        expect(
          config.getAppLinkForPlatform(TargetPlatform.android),
          'https://play.google.com/store/apps/details?id=com.example',
        );
      });

      test('returns webUrl for Linux', () {
        expect(
          config.getAppLinkForPlatform(TargetPlatform.linux),
          'https://example.com',
        );
      });

      test('returns webUrl for Windows', () {
        expect(
          config.getAppLinkForPlatform(TargetPlatform.windows),
          'https://example.com',
        );
      });

      test('falls back to webUrl when platform URL missing', () {
        const androidOnlyConfig = ShareConfig(
          appName: 'Test',
          playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
          webUrl: 'https://example.com',
        );

        expect(
          androidOnlyConfig.getAppLinkForPlatform(TargetPlatform.iOS),
          'https://example.com',
        );
      });

      test('falls back to appStoreUrl when webUrl missing', () {
        const noWebConfig = ShareConfig(
          appName: 'Test',
          appStoreUrl: 'https://apps.apple.com/app/id123',
        );

        expect(
          noWebConfig.getAppLinkForPlatform(TargetPlatform.linux),
          'https://apps.apple.com/app/id123',
        );
      });
    });

    group('copyWith', () {
      test('copies with single field change', () {
        const original = ShareConfig(
          appName: 'Original',
          hashtags: ['Quiz'],
        );

        final copy = original.copyWith(appName: 'Updated');

        expect(copy.appName, 'Updated');
        expect(copy.hashtags, ['Quiz']);
      });

      test('copies with multiple field changes', () {
        const original = ShareConfig(
          appName: 'Original',
          enableImageSharing: true,
          enableTextSharing: true,
        );

        final copy = original.copyWith(
          appName: 'Updated',
          enableImageSharing: false,
          hashtags: ['New'],
        );

        expect(copy.appName, 'Updated');
        expect(copy.enableImageSharing, isFalse);
        expect(copy.enableTextSharing, isTrue);
        expect(copy.hashtags, ['New']);
      });
    });

    group('equality', () {
      test('equal configs are equal', () {
        const config1 = ShareConfig(
          appName: 'Test',
          hashtags: ['Quiz'],
        );
        const config2 = ShareConfig(
          appName: 'Test',
          hashtags: ['Quiz'],
        );

        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('different configs are not equal', () {
        const config1 = ShareConfig(
          appName: 'Test1',
        );
        const config2 = ShareConfig(
          appName: 'Test2',
        );

        expect(config1, isNot(equals(config2)));
      });

      test('configs with different hashtags are not equal', () {
        const config1 = ShareConfig(
          appName: 'Test',
          hashtags: ['Quiz'],
        );
        const config2 = ShareConfig(
          appName: 'Test',
          hashtags: ['Trivia'],
        );

        expect(config1, isNot(equals(config2)));
      });
    });

    group('toString', () {
      test('includes key information', () {
        const config = ShareConfig(
          appName: 'Flags Quiz',
          enableImageSharing: true,
          enableTextSharing: false,
        );

        final str = config.toString();

        expect(str, contains('Flags Quiz'));
        expect(str, contains('imageSharing: true'));
        expect(str, contains('textSharing: false'));
      });
    });
  });
}
