/// Module for registering storage-related dependencies.
library;

import '../../achievements/data_sources/achievement_data_source.dart';
import '../../achievements/engine/achievement_engine.dart';
import '../../achievements/repositories/achievement_repository.dart';
import '../../achievements/services/achievement_service.dart';
import '../../storage/data_sources/data_sources_exports.dart';
import '../../storage/database/app_database.dart';
import '../../storage/repositories/repositories_exports.dart';
import '../../storage/storage_service.dart';
import '../dependency_module.dart';
import '../service_locator.dart';

/// Dependency module for storage-related services.
///
/// Registers database, data sources, and repositories with the
/// service locator.
///
/// Example:
/// ```dart
/// // Register storage dependencies
/// StorageModule().register(sl);
///
/// // Or with async database initialization
/// await StorageModule.initializeAsync(sl);
/// ```
class StorageModule extends DependencyModule {
  @override
  void register(ServiceLocator sl) {
    // Register database (lazy singleton - initializes on first access)
    sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

    // Register data sources (lazy singletons)
    _registerDataSources(sl);

    // Register repositories (lazy singletons)
    _registerRepositories(sl);
  }

  void _registerDataSources(ServiceLocator sl) {
    sl.registerLazySingleton<QuizSessionDataSource>(
      () => QuizSessionDataSourceImpl(database: sl.get<AppDatabase>()),
    );

    sl.registerLazySingleton<QuestionAnswerDataSource>(
      () => QuestionAnswerDataSourceImpl(database: sl.get<AppDatabase>()),
    );

    sl.registerLazySingleton<StatisticsDataSource>(
      () => StatisticsDataSourceImpl(database: sl.get<AppDatabase>()),
    );

    sl.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSourceImpl(database: sl.get<AppDatabase>()),
    );

    sl.registerLazySingleton<AchievementDataSource>(
      () => AchievementDataSourceImpl(database: sl.get<AppDatabase>()),
    );
  }

  void _registerRepositories(ServiceLocator sl) {
    sl.registerLazySingleton<QuizSessionRepository>(
      () => QuizSessionRepositoryImpl(
        sessionDataSource: sl.get<QuizSessionDataSource>(),
        answerDataSource: sl.get<QuestionAnswerDataSource>(),
        statsDataSource: sl.get<StatisticsDataSource>(),
      ),
    );

    sl.registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(
        dataSource: sl.get<StatisticsDataSource>(),
      ),
    );

    sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        dataSource: sl.get<SettingsDataSource>(),
      ),
    );

    sl.registerLazySingleton<AchievementRepository>(
      () => AchievementRepositoryImpl(
        dataSource: sl.get<AchievementDataSource>(),
        statisticsDataSource: sl.get<StatisticsDataSource>(),
      ),
    );

    sl.registerLazySingleton<AchievementEngine>(
      () => AchievementEngine(
        repository: sl.get<AchievementRepository>(),
      ),
    );

    sl.registerLazySingleton<AchievementService>(
      () => AchievementService(
        repository: sl.get<AchievementRepository>(),
        statisticsDataSource: sl.get<StatisticsDataSource>(),
        engine: sl.get<AchievementEngine>(),
      ),
    );

    // Register StorageService facade
    sl.registerLazySingleton<StorageService>(
      () => StorageServiceImpl(
        sessionRepository: sl.get<QuizSessionRepository>(),
        statisticsRepository: sl.get<StatisticsRepository>(),
        settingsRepository: sl.get<SettingsRepository>(),
      ),
    );
  }

  /// Initializes storage dependencies with async database setup.
  ///
  /// Use this method when you need to ensure the database is
  /// initialized before the app starts.
  ///
  /// Example:
  /// ```dart
  /// await StorageModule.initializeAsync(sl);
  /// ```
  static Future<void> initializeAsync(ServiceLocator sl) async {
    // Register the module
    StorageModule().register(sl);

    // Force database initialization
    final database = sl.get<AppDatabase>();
    await database.database; // Triggers async initialization
  }

  @override
  Future<void> dispose() async {
    // Close database connection if needed
    final database = sl.getOrNull<AppDatabase>();
    if (database != null && database.isInitialized) {
      await database.close();
    }
  }
}
