import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/src/di/modules/settings_module.dart';
import 'package:shared_services/src/di/service_locator.dart';
import 'package:shared_services/src/settings/settings_service.dart';

void main() {
  late ServiceLocator locator;

  setUp(() {
    locator = ServiceLocator.instance;
    locator.resetSync();
    // Set up SharedPreferences mock for testing
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    locator.resetSync();
  });

  group('SettingsModule', () {
    test('register() registers SettingsService as lazy singleton', () {
      final module = SettingsModule();
      module.register(locator);

      expect(locator.isRegistered<SettingsService>(), isTrue);
    });

    test('register() uses lazy singleton (no immediate instantiation)', () {
      final module = SettingsModule();
      module.register(locator);

      final debugInfo = locator.debugInfo;

      expect(debugInfo['lazySingletons'], contains('SettingsService'));
      expect(debugInfo['singletons'], isEmpty);
    });

    test('initializeAsync() registers SettingsService as singleton', () async {
      await SettingsModule.initializeAsync(locator);

      expect(locator.isRegistered<SettingsService>(), isTrue);

      final debugInfo = locator.debugInfo;
      expect(debugInfo['singletons'], contains('SettingsService'));
    });

    test('initializeAsync() provides initialized SettingsService', () async {
      await SettingsModule.initializeAsync(locator);

      final settingsService = locator.get<SettingsService>();

      // Should be able to access settings (wouldn't work if not initialized)
      expect(settingsService.currentSettings, isNotNull);
    });

    test('dispose() disposes SettingsService', () async {
      await SettingsModule.initializeAsync(locator);
      final module = SettingsModule();

      // Should not throw
      await module.dispose();
    });

    test('dispose() handles null SettingsService gracefully', () async {
      final module = SettingsModule();

      // Should not throw when SettingsService is not registered
      await module.dispose();
    });
  });

  group('SettingsModule integration', () {
    test('can update settings after initialization', () async {
      await SettingsModule.initializeAsync(locator);

      final settingsService = locator.get<SettingsService>();
      final initialSound = settingsService.currentSettings.soundEnabled;

      await settingsService.toggleSound();

      expect(
        settingsService.currentSettings.soundEnabled,
        equals(!initialSound),
      );
    });

    test('settings stream emits on changes', () async {
      await SettingsModule.initializeAsync(locator);

      final settingsService = locator.get<SettingsService>();

      // Listen for settings changes
      final settingsChanges = <bool>[];
      final subscription = settingsService.settingsStream.listen((settings) {
        settingsChanges.add(settings.soundEnabled);
      });

      await settingsService.toggleSound();
      await settingsService.toggleSound();

      // Wait for stream events
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(settingsChanges.length, greaterThanOrEqualTo(2));
    });
  });
}
