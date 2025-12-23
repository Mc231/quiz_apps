import 'package:logger/logger.dart';

/// Application-wide logger service
///
/// Provides a centralized logging interface with configurable log levels
/// and consistent formatting across all packages.
///
/// Example:
/// ```dart
/// final logger = AppLogger.instance;
/// logger.info('User started quiz');
/// logger.error('Failed to load data', error: exception, stackTrace: stackTrace);
/// ```
class AppLogger {
  static AppLogger? _instance;
  late final Logger _logger;

  AppLogger._({Level level = Level.debug}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: level,
    );
  }

  /// Gets the singleton logger instance
  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  /// Initializes the logger with custom settings
  ///
  /// [level] - Minimum log level to output (default: Level.debug)
  ///
  /// Should be called once at app startup if custom configuration is needed.
  static void initialize({Level level = Level.debug}) {
    _instance = AppLogger._(level: level);
  }

  /// Logs a debug message
  ///
  /// Use for detailed debugging information during development.
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message
  ///
  /// Use for general information about app flow and events.
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message
  ///
  /// Use for potentially problematic situations that don't prevent operation.
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message
  ///
  /// Use for errors that affect functionality but don't crash the app.
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error message
  ///
  /// Use for critical errors that may crash the app.
  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
