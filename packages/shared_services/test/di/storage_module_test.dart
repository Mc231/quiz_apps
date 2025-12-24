import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/di/modules/storage_module.dart';
import 'package:shared_services/src/di/service_locator.dart';
import 'package:shared_services/src/achievements/data_sources/achievement_data_source.dart';
import 'package:shared_services/src/achievements/repositories/achievement_repository.dart';
import 'package:shared_services/src/storage/data_sources/data_sources_exports.dart';
import 'package:shared_services/src/storage/database/app_database.dart';
import 'package:shared_services/src/storage/repositories/repositories_exports.dart';

void main() {
  late ServiceLocator locator;

  setUp(() {
    locator = ServiceLocator.instance;
    locator.resetSync();
  });

  tearDown(() {
    locator.resetSync();
  });

  group('StorageModule', () {
    test('registers AppDatabase', () {
      final module = StorageModule();
      module.register(locator);

      expect(locator.isRegistered<AppDatabase>(), isTrue);
    });

    test('registers all data sources', () {
      final module = StorageModule();
      module.register(locator);

      expect(locator.isRegistered<QuizSessionDataSource>(), isTrue);
      expect(locator.isRegistered<QuestionAnswerDataSource>(), isTrue);
      expect(locator.isRegistered<StatisticsDataSource>(), isTrue);
      expect(locator.isRegistered<SettingsDataSource>(), isTrue);
      expect(locator.isRegistered<AchievementDataSource>(), isTrue);
    });

    test('registers all repositories', () {
      final module = StorageModule();
      module.register(locator);

      expect(locator.isRegistered<QuizSessionRepository>(), isTrue);
      expect(locator.isRegistered<StatisticsRepository>(), isTrue);
      expect(locator.isRegistered<SettingsRepository>(), isTrue);
      expect(locator.isRegistered<AchievementRepository>(), isTrue);
    });

    test('uses lazy singletons (no immediate instantiation)', () {
      final module = StorageModule();
      module.register(locator);

      // After registration, types should be in lazySingletons, not singletons
      final debugInfo = locator.debugInfo;

      expect(debugInfo['lazySingletons'], contains('AppDatabase'));
      expect(debugInfo['lazySingletons'], contains('QuizSessionDataSource'));
      expect(debugInfo['lazySingletons'], contains('QuestionAnswerDataSource'));
      expect(debugInfo['lazySingletons'], contains('StatisticsDataSource'));
      expect(debugInfo['lazySingletons'], contains('SettingsDataSource'));
      expect(debugInfo['lazySingletons'], contains('AchievementDataSource'));
      expect(debugInfo['lazySingletons'], contains('QuizSessionRepository'));
      expect(debugInfo['lazySingletons'], contains('StatisticsRepository'));
      expect(debugInfo['lazySingletons'], contains('SettingsRepository'));
      expect(debugInfo['lazySingletons'], contains('AchievementRepository'));

      // Singletons should be empty (nothing eagerly instantiated)
      expect(debugInfo['singletons'], isEmpty);
    });

    test('registrations count is correct', () {
      final module = StorageModule();
      module.register(locator);

      final debugInfo = locator.debugInfo;
      final totalRegistrations = debugInfo['singletons']!.length +
          debugInfo['lazySingletons']!.length +
          debugInfo['factories']!.length;

      // 1 database + 5 data sources + 4 repositories + 1 StorageService = 11
      expect(totalRegistrations, 11);
    });
  });

  group('StorageModule with custom locator', () {
    test('registers with different locator instance', () {
      // This test verifies the module can work with a custom locator
      // (useful for testing or scoped dependency containers)
      final module = StorageModule();

      // Reset the global instance
      locator.resetSync();

      // Register with the locator
      module.register(locator);

      // All types should be registered
      expect(locator.isRegistered<AppDatabase>(), isTrue);
      expect(locator.isRegistered<QuizSessionRepository>(), isTrue);
    });
  });
}
