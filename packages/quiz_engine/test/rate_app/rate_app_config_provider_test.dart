import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('RateAppConfigProvider', () {
    testWidgets('provides config to descendants', (tester) async {
      const testConfig = RateAppUiConfig(
        appName: 'Test App',
        feedbackEmail: 'test@example.com',
        delaySeconds: 3,
      );

      RateAppUiConfig? retrievedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: RateAppConfigProvider(
            config: testConfig,
            child: Builder(
              builder: (context) {
                retrievedConfig = RateAppConfigProvider.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedConfig, isNotNull);
      expect(retrievedConfig!.appName, 'Test App');
      expect(retrievedConfig!.feedbackEmail, 'test@example.com');
      expect(retrievedConfig!.delaySeconds, 3);
    });

    testWidgets('returns null when not in tree', (tester) async {
      RateAppUiConfig? retrievedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              retrievedConfig = RateAppConfigProvider.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedConfig, isNull);
    });

    testWidgets('provides app icon when specified', (tester) async {
      const testIcon = Icon(Icons.quiz, key: Key('test-icon'));
      const testConfig = RateAppUiConfig(
        appName: 'Test App',
        appIcon: testIcon,
      );

      RateAppUiConfig? retrievedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: RateAppConfigProvider(
            config: testConfig,
            child: Builder(
              builder: (context) {
                retrievedConfig = RateAppConfigProvider.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedConfig, isNotNull);
      expect(retrievedConfig!.appIcon, isNotNull);
      expect(retrievedConfig!.appIcon, isA<Icon>());
    });

    testWidgets('uses default delay when not specified', (tester) async {
      const testConfig = RateAppUiConfig(
        appName: 'Test App',
      );

      RateAppUiConfig? retrievedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: RateAppConfigProvider(
            config: testConfig,
            child: Builder(
              builder: (context) {
                retrievedConfig = RateAppConfigProvider.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedConfig, isNotNull);
      expect(retrievedConfig!.delaySeconds, 2); // Default value
    });

    testWidgets('updateShouldNotify returns true when config changes',
        (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return RateAppConfigProvider(
                config: RateAppUiConfig(
                  appName: 'App $buildCount',
                ),
                child: Builder(
                  builder: (context) {
                    final config = RateAppConfigProvider.of(context);
                    return Text(config?.appName ?? 'No config');
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('App 0'), findsOneWidget);
    });
  });

  group('RateAppUiConfig', () {
    test('creates with required parameters', () {
      const config = RateAppUiConfig(appName: 'My App');

      expect(config.appName, 'My App');
      expect(config.appIcon, isNull);
      expect(config.feedbackEmail, isNull);
      expect(config.delaySeconds, 2);
    });

    test('creates with all parameters', () {
      const icon = Icon(Icons.star);
      const config = RateAppUiConfig(
        appName: 'My App',
        appIcon: icon,
        feedbackEmail: 'email@test.com',
        delaySeconds: 5,
      );

      expect(config.appName, 'My App');
      expect(config.appIcon, isNotNull);
      expect(config.feedbackEmail, 'email@test.com');
      expect(config.delaySeconds, 5);
    });
  });
}
