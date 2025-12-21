/// Defines where to load configuration from
///
/// For MVP, only Default source is supported.
/// Local storage and remote configuration will be added in future releases.
sealed class ConfigSource {
  const ConfigSource();

  /// Factory method: Use default configuration only
  factory ConfigSource.defaultOnly() => const DefaultSource();
}

/// Use default configuration only (no loading from storage or remote)
class DefaultSource extends ConfigSource {
  const DefaultSource();
}