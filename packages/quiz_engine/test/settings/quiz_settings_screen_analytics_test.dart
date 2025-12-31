import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuizSettingsScreen Analytics Integration', () {
    late SettingsService settingsService;
    late MockAnalyticsService analyticsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
      await settingsService.initialize();
      analyticsService = MockAnalyticsService();
      await analyticsService.initialize();
    });

    tearDown(() {
      settingsService.dispose();
      analyticsService.dispose();
    });

    testWidgets('tracks sound effects toggle', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false, // Disable to avoid service locator
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Find and tap sound effects toggle
      final soundToggle = find.widgetWithText(SwitchListTile, 'Sound Effects');
      expect(soundToggle, findsOneWidget);

      await tester.tap(soundToggle);
      await tester.pumpAndSettle();

      // Verify event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as SettingsEvent;
      expect(event.eventName, 'sound_effects_toggled');
      // Analytics events convert booleans to integers (0/1) for Firebase compatibility
      expect(event.parameters['enabled'], 0);
      expect(event.parameters['source'], 'settings_screen');
    });

    testWidgets('tracks haptic feedback toggle', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Find and tap haptic feedback toggle
      final hapticToggle =
          find.widgetWithText(SwitchListTile, 'Haptic Feedback');
      expect(hapticToggle, findsOneWidget);

      await tester.tap(hapticToggle);
      await tester.pumpAndSettle();

      // Verify event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as SettingsEvent;
      expect(event.eventName, 'haptic_feedback_toggled');
      // Analytics events convert booleans to integers (0/1) for Firebase compatibility
      expect(event.parameters['enabled'], 0);
      expect(event.parameters['source'], 'settings_screen');
    });

    testWidgets('tracks theme change', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Open theme dialog
      final themeTile = find.widgetWithText(ListTile, 'Theme');
      expect(themeTile, findsOneWidget);

      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Select dark theme (use find.text since RadioListTile is generic)
      final darkThemeOption = find.text('Dark');
      expect(darkThemeOption, findsOneWidget);

      await tester.tap(darkThemeOption);
      await tester.pumpAndSettle();

      // Verify event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as SettingsEvent;
      expect(event.eventName, 'theme_changed');
      expect(event.parameters['new_theme'], 'dark');
      expect(event.parameters['previous_theme'], 'system');
      expect(event.parameters['source'], 'settings_screen');
    });

    testWidgets('tracks settings reset', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Scroll to find reset to defaults at the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Find and tap reset to defaults
      final resetTile = find.widgetWithText(ListTile, 'Reset to Defaults');
      expect(resetTile, findsOneWidget);

      await tester.tap(resetTile);
      await tester.pumpAndSettle();

      // Confirm reset in dialog
      final resetButton = find.widgetWithText(TextButton, 'Reset');
      expect(resetButton, findsOneWidget);

      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as SettingsEvent;
      expect(event.eventName, 'reset_confirmed');
      expect(event.parameters['reset_type'], 'settings_only');
      expect(event.parameters['sessions_deleted'], 0);
      expect(event.parameters['achievements_reset'], 0);
    });

    testWidgets('tracks background music toggle', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Find and tap background music toggle
      final musicToggle =
          find.widgetWithText(SwitchListTile, 'Background Music');
      expect(musicToggle, findsOneWidget);

      await tester.tap(musicToggle);
      await tester.pumpAndSettle();

      // Verify event was logged (uses generic SettingsEvent.changed)
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as SettingsEvent;
      expect(event.eventName, 'settings_changed');
      expect(event.parameters['setting_name'], 'background_music');
      expect(event.parameters['old_value'], 'true');
      expect(event.parameters['new_value'], 'false');
      expect(event.parameters['setting_category'], 'audio');
    });

    testWidgets('does not track events when NoOp analytics service is used',
        (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: NoOpAnalyticsService(),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle sound effects
      final soundToggle = find.widgetWithText(SwitchListTile, 'Sound Effects');
      await tester.tap(soundToggle);
      await tester.pumpAndSettle();

      // Verify no events were logged to our mock
      // (This is a safety test - the widget should handle null gracefully)
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks multiple settings changes', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const QuizSettingsScreen(
            config: QuizSettingsConfig(
              showAppBar: false,
              showDataExport: false,
            ),
          ),
          settingsService: settingsService,
          screenAnalyticsService: analyticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Reset analytics after screen view event is logged
      analyticsService.reset();

      // Toggle sound effects
      await tester.tap(find.widgetWithText(SwitchListTile, 'Sound Effects'));
      await tester.pumpAndSettle();

      // Toggle haptic feedback
      await tester.tap(find.widgetWithText(SwitchListTile, 'Haptic Feedback'));
      await tester.pumpAndSettle();

      // Verify both events were logged
      expect(analyticsService.loggedEvents.length, 2);

      final soundEvent = analyticsService.loggedEvents[0] as SettingsEvent;
      expect(soundEvent.eventName, 'sound_effects_toggled');

      final hapticEvent = analyticsService.loggedEvents[1] as SettingsEvent;
      expect(hapticEvent.eventName, 'haptic_feedback_toggled');
    });
  });
}
