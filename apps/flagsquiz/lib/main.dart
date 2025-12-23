import 'package:flags_quiz/ui/flags_quiz_app.dart';
import 'package:flags_quiz/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

/// The entry point of the Flags Quiz application.
///
/// The `main` function initializes the Flutter application and sets up
/// the root widget for the app. It uses the `FlagsQuizApp` class to
/// configure the application, specifying the home screen widget as
/// `HomeScreen` with bottom navigation for Play, History, and Statistics.
///
/// This setup launches the application with the home screen that provides
/// navigation between quiz play, session history, and statistics views.
/// The `FlagsQuizApp` provides localization, theme, and navigation settings
/// for the entire app.
///
/// To start the application, this function calls `runApp`, passing an
/// instance of `FlagsQuizApp`.
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();

  // Initialize shared services (including storage)
  await SharedServicesInitializer.initialize();

  // Get storage service from service locator
  final storageService = sl.get<StorageService>();

  runApp(
    FlagsQuizApp(
      settingsService: settingsService,
      homeWidget: HomeScreen(
        settingsService: settingsService,
        storageService: storageService,
      ),
    ),
  );
}
