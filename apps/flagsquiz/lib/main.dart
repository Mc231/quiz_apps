import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import 'data/flags_categories.dart';
import 'data/flags_data_provider.dart';
import 'l10n/app_localizations.dart';

/// The entry point of the Flags Quiz application.
///
/// Uses [QuizApp] from quiz_engine with [FlagsDataProvider] for loading
/// country quiz data. All navigation is handled automatically by QuizApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedServicesInitializer.initialize();
  runApp(
    QuizApp(
      settingsService: sl.get<SettingsService>(),
      categories: createFlagsCategories(),
      dataProvider: const FlagsDataProvider(),
      storageService: sl.get<StorageService>(),
      config: QuizAppConfig(
        title: 'Flags Quiz',
        appLocalizationDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      homeConfig: QuizHomeScreenConfig(
        tabConfig: QuizTabConfig.defaultConfig(),
        showSettingsInAppBar: true,
      ),
    ),
  );
}
