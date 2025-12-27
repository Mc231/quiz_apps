/// Platform-specific database initialization.
///
/// This file handles setting up the correct database factory for
/// different platforms (web vs native).
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

/// Initializes the database factory for the current platform.
///
/// Must be called before any database operations.
/// This is automatically called by [SharedServicesInitializer].
///
/// Example:
/// ```dart
/// await DatabaseInitializer.initialize();
/// // Now you can use AppDatabase
/// ```
class DatabaseInitializer {
  static bool _initialized = false;

  /// Whether the database factory has been initialized.
  static bool get isInitialized => _initialized;

  /// Initializes the database factory for the current platform.
  ///
  /// On web: Uses IndexedDB via sqflite_common_ffi_web
  /// On native: Uses the default sqflite factory
  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Initialize web database factory
      databaseFactory = databaseFactoryFfiWeb;
    }
    // On native platforms, sqflite uses the default factory

    _initialized = true;
  }

  /// Resets the initialization state.
  ///
  /// This is primarily for testing purposes.
  static void reset() {
    _initialized = false;
  }
}
