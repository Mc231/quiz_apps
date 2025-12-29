import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secrets_config.dart';

/// Callback for logging warnings during secrets loading.
typedef SecretsWarningCallback = void Function(String message);

/// Utility class for loading [SecretsConfig] from JSON files.
///
/// Provides safe loading with fallback to empty config when the
/// secrets file is missing or invalid.
///
/// Usage:
/// ```dart
/// final secrets = await SecretsLoader.load('config/secrets.json');
/// if (!secrets.isConfigured) {
///   print('Warning: Secrets not configured, using defaults');
/// }
/// ```
class SecretsLoader {
  SecretsLoader._();

  /// Loads secrets from a JSON asset file.
  ///
  /// [assetPath] - Path to the JSON file relative to assets folder.
  /// [onWarning] - Optional callback for logging warnings.
  ///
  /// Returns [SecretsConfig.empty] if:
  /// - File doesn't exist
  /// - File contains invalid JSON
  /// - Any parsing error occurs
  static Future<SecretsConfig> load(
    String assetPath, {
    SecretsWarningCallback? onWarning,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = SecretsConfig.fromJson(json);

      // Log warning if config is missing required secrets
      if (!config.isConfigured && onWarning != null) {
        final missing = config.missingSecrets.join(', ');
        onWarning('Secrets config loaded but missing: $missing');
      }

      return config;
    } on FlutterError catch (e) {
      // File not found
      onWarning?.call(
        'Secrets file not found at "$assetPath". Using empty config. '
        'Create the file from secrets.template.json. Error: ${e.message}',
      );
      return const SecretsConfig.empty();
    } on FormatException catch (e) {
      // Invalid JSON
      onWarning?.call(
        'Invalid JSON in secrets file "$assetPath": ${e.message}',
      );
      return const SecretsConfig.empty();
    } catch (e) {
      // Any other error
      onWarning?.call(
        'Failed to load secrets from "$assetPath": $e',
      );
      return const SecretsConfig.empty();
    }
  }

  /// Loads secrets from a JSON string.
  ///
  /// Useful for testing or when secrets are provided via environment.
  static SecretsConfig loadFromString(
    String jsonString, {
    SecretsWarningCallback? onWarning,
  }) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SecretsConfig.fromJson(json);
    } on FormatException catch (e) {
      onWarning?.call('Invalid JSON string: ${e.message}');
      return const SecretsConfig.empty();
    } catch (e) {
      onWarning?.call('Failed to parse secrets: $e');
      return const SecretsConfig.empty();
    }
  }

  /// Loads secrets from a Map (useful for testing).
  static SecretsConfig loadFromMap(Map<String, dynamic> json) {
    return SecretsConfig.fromJson(json);
  }
}