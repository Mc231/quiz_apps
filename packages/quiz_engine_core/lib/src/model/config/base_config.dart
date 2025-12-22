import 'dart:convert';

/// Base configuration class for all config types
/// Provides serialization/deserialization for local storage and remote updates
abstract class BaseConfig {
  const BaseConfig();

  /// Convert config to Map for serialization
  Map<String, dynamic> toMap();

  /// Convert to JSON string
  String toJson() => jsonEncode(toMap());

  /// Config version for migration support
  int get version;
}
