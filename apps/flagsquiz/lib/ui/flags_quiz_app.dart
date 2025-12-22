import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

/// The root widget for the Flags Quiz application.
///
/// The `FlagsQuizApp` class is a stateful widget that sets up the main
/// configuration for the Flutter application. It specifies the app's theme,
/// localization settings, and navigation observers. This class acts as the
/// entry point for the app, defining its core appearance and behavior.
///
/// The application supports multiple languages and adapts its locale based
/// on user settings or system preferences. It also provides options for
/// customizing the navigation stack through observers.
///
class FlagsQuizApp extends StatefulWidget {
  /// The widget displayed as the home screen of the application.
  final Widget homeWidget;

  /// The initial locale for the application, if specified.
  final Locale? locale;

  /// A list of navigation observers to monitor navigation changes.
  final List<NavigatorObserver> navigationObservers;

  /// Settings service for managing app preferences
  final SettingsService settingsService;

  /// Creates a `FlagsQuizApp` instance with the specified home widget,
  /// locale, and navigation observers.
  ///
  /// [key] is the unique key for this widget.
  /// [homeWidget] is the widget displayed as the home screen.
  /// [settingsService] manages app settings and preferences.
  /// [locale] specifies the initial locale for the application.
  /// [navigationObservers] are observers used to monitor navigation changes.
  const FlagsQuizApp({
    super.key,
    required this.homeWidget,
    required this.settingsService,
    this.locale,
    this.navigationObservers = const [],
  });

  @override
  State<FlagsQuizApp> createState() => _FlagsQuizAppState();
}

class _FlagsQuizAppState extends State<FlagsQuizApp> {
  late QuizSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settingsService.currentSettings;

    // Listen to settings changes
    widget.settingsService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _currentSettings = settings;
        });
      }
    });
  }

  // Builds the MaterialApp for the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(useMaterial3: false),
      themeMode: _currentSettings.flutterThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: widget.locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return supportedLocales.contains(locale) ? locale : const Locale('en');
      },
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: widget.navigationObservers,
      home: widget.homeWidget,
    );
  }
}
