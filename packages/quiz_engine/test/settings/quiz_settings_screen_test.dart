import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_delegate.dart';
import 'package:quiz_engine/src/settings/quiz_settings_screen.dart';
import 'package:shared_services/shared_services.dart';

/// A mock SettingsService for testing.
class MockSettingsService implements SettingsService {
  QuizSettings _settings = QuizSettings.defaultSettings();
  final _controller = StreamController<QuizSettings>.broadcast();

  @override
  QuizSettings get currentSettings => _settings;

  @override
  Stream<QuizSettings> get settingsStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> updateSettings(QuizSettings newSettings) async {
    _settings = newSettings;
    _controller.add(_settings);
  }

  @override
  Future<bool> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    _controller.add(_settings);
    return _settings.soundEnabled;
  }

  @override
  Future<bool> toggleMusic() async {
    _settings = _settings.copyWith(musicEnabled: !_settings.musicEnabled);
    _controller.add(_settings);
    return _settings.musicEnabled;
  }

  @override
  Future<bool> toggleHaptic() async {
    _settings = _settings.copyWith(hapticEnabled: !_settings.hapticEnabled);
    _controller.add(_settings);
    return _settings.hapticEnabled;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    _controller.add(_settings);
  }

  @override
  Future<QuizSettings> resetToDefaults() async {
    _settings = QuizSettings.defaultSettings();
    _controller.add(_settings);
    return _settings;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  late MockSettingsService settingsService;

  setUp(() {
    settingsService = MockSettingsService();
  });

  tearDown(() {
    settingsService.dispose();
  });

  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        QuizLocalizationsDelegate(),
      ],
      home: child,
    );
  }

  group('QuizSettingsScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            config: const QuizSettingsConfig(showDataExport: false),
            analyticsService: NoOpAnalyticsService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays custom title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(
              title: 'My Settings',
              showDataExport: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Settings'), findsOneWidget);
    });

    testWidgets('hides app bar when showAppBar is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: QuizSettingsScreen(
              settingsService: settingsService,
              analyticsService: NoOpAnalyticsService(),
              config: const QuizSettingsConfig(
                showAppBar: false,
                showDataExport: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not find a second AppBar (the Scaffold adds one)
      expect(find.text('Settings'), findsNothing);
    });
  });

  group('Audio & Haptics Section', () {
    testWidgets('displays sound effects toggle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Play sounds for answers and interactions'),
          findsOneWidget);
    });

    testWidgets('toggles sound effects', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the switch
      final soundSwitch = find.byType(SwitchListTile).first;
      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();

      expect(settingsService.currentSettings.soundEnabled, isFalse);
    });

    testWidgets('displays haptic feedback toggle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Haptic Feedback'), findsOneWidget);
    });

    testWidgets('hides section when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(
              showAudioHapticsSection: false,
              showDataExport: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Audio & Haptics'), findsNothing);
      expect(find.text('Sound Effects'), findsNothing);
    });
  });

  // Note: Quiz Behavior Section removed - showAnswerFeedback is now per-category/per-mode

  group('Appearance Section', () {
    testWidgets('displays theme selector', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget); // Default theme
    });

    testWidgets('shows theme dialog on tap', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System default'), findsNWidgets(2)); // List + dialog
    });

    testWidgets('changes theme when selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(settingsService.currentSettings.themeMode, AppThemeMode.dark);
    });

    testWidgets('hides section when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(
              showAppearanceSection: false,
              showDataExport: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsNothing);
      expect(find.text('Theme'), findsNothing);
    });
  });

  group('About Section', () {
    testWidgets('displays about items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find items at the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('About This App'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('hides section when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(
              showAboutSection: false,
              showDataExport: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('About This App'), findsNothing);
    });
  });

  group('Advanced Section', () {
    testWidgets('displays reset to defaults', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find items at the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('shows reset dialog on tap', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(showDataExport: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find items at the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('hides section when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizSettingsConfig(
              showAdvancedSection: false,
              showDataExport: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Advanced'), findsNothing);
      expect(find.text('Reset to Defaults'), findsNothing);
    });
  });

  group('QuizSettingsConfig', () {
    test('default config has all sections enabled', () {
      const config = QuizSettingsConfig();

      expect(config.showAudioHapticsSection, isTrue);
      expect(config.showSoundEffects, isTrue);
      expect(config.showBackgroundMusic, isTrue);
      expect(config.showHapticFeedback, isTrue);
      expect(config.showAppearanceSection, isTrue);
      expect(config.showThemeSelector, isTrue);
      expect(config.showAboutSection, isTrue);
      expect(config.showAdvancedSection, isTrue);
      expect(config.showAppBar, isTrue);
    });

    test('minimal config has limited sections', () {
      const config = QuizSettingsConfig.minimal();

      expect(config.showAudioHapticsSection, isTrue);
      expect(config.showBackgroundMusic, isFalse);
      expect(config.showAboutSection, isFalse);
      expect(config.showAdvancedSection, isFalse);
    });

    test('copyWith creates modified copy', () {
      const original = QuizSettingsConfig();
      final modified = original.copyWith(
        showBackgroundMusic: false,
        showAboutSection: false,
        title: 'Custom Title',
      );

      expect(modified.showBackgroundMusic, isFalse);
      expect(modified.showAboutSection, isFalse);
      expect(modified.title, 'Custom Title');
      // Unchanged values
      expect(modified.showSoundEffects, isTrue);
      expect(modified.showThemeSelector, isTrue);
    });
  });

  group('Custom sections', () {
    testWidgets('displays custom sections at end', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            analyticsService: NoOpAnalyticsService(),
            settingsService: settingsService,
            config: QuizSettingsConfig(
              showDataExport: false,
              customSections: (context) => [
                const ListTile(
                  title: Text('Custom Item'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find custom items at the end
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Custom Item'), findsOneWidget);
    });

    testWidgets('displays custom sections before About', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizSettingsScreen(
            settingsService: settingsService,
            analyticsService: NoOpAnalyticsService(),
            config: QuizSettingsConfig(
              showDataExport: false,
              customSectionsBeforeAbout: (context) => [
                SettingsSection(
                  header: 'Custom Section',
                  children: [
                    const ListTile(title: Text('Custom Setting')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find custom sections before About
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Custom Section'), findsOneWidget);
      expect(find.text('Custom Setting'), findsOneWidget);
    });
  });

  group('SettingsSection widget', () {
    testWidgets('displays header and children', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: ListView(
              children: [
                SettingsSection(
                  header: 'Test Section',
                  children: [
                    const ListTile(title: Text('Item 1')),
                    const ListTile(title: Text('Item 2')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('hides divider when showDivider is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: ListView(
              children: [
                SettingsSection(
                  header: 'Test Section',
                  showDivider: false,
                  children: [
                    const ListTile(title: Text('Item 1')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNothing);
    });
  });
}
