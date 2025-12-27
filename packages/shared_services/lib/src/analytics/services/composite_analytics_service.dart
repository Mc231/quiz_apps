import 'dart:developer' as developer;

import '../analytics_event.dart';
import '../analytics_service.dart';

/// Configuration for an analytics provider in the composite service.
class AnalyticsProviderConfig {
  /// Creates a provider configuration.
  ///
  /// [provider] - The analytics service provider.
  /// [name] - A human-readable name for logging.
  /// [enabled] - Whether this provider is enabled.
  /// [eventFilter] - Optional filter to determine which events to send.
  const AnalyticsProviderConfig({
    required this.provider,
    required this.name,
    this.enabled = true,
    this.eventFilter,
  });

  /// The analytics service provider.
  final AnalyticsService provider;

  /// A human-readable name for logging and debugging.
  final String name;

  /// Whether this provider is enabled.
  final bool enabled;

  /// Optional filter function to determine which events to send.
  ///
  /// If null, all events are sent to this provider.
  /// Return true to send the event, false to skip.
  final bool Function(AnalyticsEvent event)? eventFilter;

  /// Creates a copy with optional overrides.
  AnalyticsProviderConfig copyWith({
    AnalyticsService? provider,
    String? name,
    bool? enabled,
    bool Function(AnalyticsEvent event)? eventFilter,
  }) {
    return AnalyticsProviderConfig(
      provider: provider ?? this.provider,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      eventFilter: eventFilter ?? this.eventFilter,
    );
  }
}

/// Composite analytics service for multi-provider analytics.
///
/// Implements fan-out event logging to multiple analytics providers
/// (e.g., Firebase + Amplitude + Mixpanel).
///
/// ## Usage
/// ```dart
/// final compositeService = CompositeAnalyticsService(
///   providers: [
///     AnalyticsProviderConfig(
///       provider: FirebaseAnalyticsService(),
///       name: 'Firebase',
///     ),
///     AnalyticsProviderConfig(
///       provider: AmplitudeAnalyticsService(),
///       name: 'Amplitude',
///       eventFilter: (event) => event is MonetizationEvent,
///     ),
///   ],
/// );
///
/// await compositeService.initialize();
/// await compositeService.logEvent(QuizEvent.started(...));
/// ```
///
/// ## Error Handling
/// Individual provider failures are logged but don't affect other providers.
/// If one provider fails, events are still sent to remaining providers.
///
/// ## Provider Filtering
/// Use `eventFilter` in `AnalyticsProviderConfig` to send specific events
/// to specific providers. For example, send monetization events only to
/// a dedicated revenue analytics provider.
class CompositeAnalyticsService implements AnalyticsService {
  /// Creates a composite analytics service.
  ///
  /// [providers] - List of provider configurations.
  /// [enableDebugLogging] - Whether to log debug information.
  /// [stopOnFirstError] - Whether to stop on first provider error.
  CompositeAnalyticsService({
    required List<AnalyticsProviderConfig> providers,
    this.enableDebugLogging = false,
    this.stopOnFirstError = false,
  }) : _providers = List.unmodifiable(providers);

  final List<AnalyticsProviderConfig> _providers;

  /// Whether to log debug information.
  final bool enableDebugLogging;

  /// Whether to stop processing on first error.
  ///
  /// If false (default), errors are logged but other providers continue.
  /// If true, the first error will stop processing remaining providers.
  final bool stopOnFirstError;

  bool _isEnabled = true;
  bool _isInitialized = false;

  /// The list of configured providers.
  List<AnalyticsProviderConfig> get providers => _providers;

  /// The number of active (enabled and initialized) providers.
  int get activeProviderCount =>
      _providers.where((p) => p.enabled && p.provider.isEnabled).length;

  @override
  bool get isEnabled => _isEnabled && _isInitialized && _providers.isNotEmpty;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    final results = await _executeOnAllProviders(
      'initialize',
      (config) => config.provider.initialize(),
    );

    _isInitialized = true;

    final successCount = results.where((r) => r.success).length;
    _debugLog('Initialized $successCount/${_providers.length} providers');
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!isEnabled) return;

    await _executeOnAllProviders(
      'logEvent(${event.eventName})',
      (config) {
        // Check if this provider should receive this event
        if (config.eventFilter != null && !config.eventFilter!(event)) {
          _debugLog('Event ${event.eventName} filtered for ${config.name}');
          return Future.value();
        }
        return config.provider.logEvent(event);
      },
    );
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isEnabled) return;

    await _executeOnAllProviders(
      'setCurrentScreen($screenName)',
      (config) => config.provider.setCurrentScreen(
        screenName: screenName,
        screenClass: screenClass,
      ),
    );
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!isEnabled) return;

    await _executeOnAllProviders(
      'setUserProperty($name)',
      (config) => config.provider.setUserProperty(name: name, value: value),
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;

    await _executeOnAllProviders(
      'setUserId',
      (config) => config.provider.setUserId(userId),
    );
  }

  @override
  Future<void> resetAnalyticsData() async {
    await _executeOnAllProviders(
      'resetAnalyticsData',
      (config) => config.provider.resetAnalyticsData(),
    );
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;

    await _executeOnAllProviders(
      'setAnalyticsCollectionEnabled($enabled)',
      (config) => config.provider.setAnalyticsCollectionEnabled(enabled),
    );
  }

  @override
  void dispose() {
    for (final config in _providers) {
      try {
        config.provider.dispose();
      } catch (e) {
        _debugLog('Error disposing ${config.name}: $e');
      }
    }
    _isInitialized = false;
  }

  // ============ Provider Management ============

  /// Gets a provider by name.
  ///
  /// Returns null if no provider with the given name exists.
  AnalyticsService? getProvider(String name) {
    for (final config in _providers) {
      if (config.name == name) {
        return config.provider;
      }
    }
    return null;
  }

  /// Gets a provider configuration by name.
  AnalyticsProviderConfig? getProviderConfig(String name) {
    for (final config in _providers) {
      if (config.name == name) {
        return config;
      }
    }
    return null;
  }

  /// Gets all provider names.
  List<String> get providerNames => _providers.map((p) => p.name).toList();

  // ============ Internal Helpers ============

  /// Executes an operation on all enabled providers.
  ///
  /// Returns a list of results for each provider.
  Future<List<_ProviderResult>> _executeOnAllProviders(
    String operation,
    Future<void> Function(AnalyticsProviderConfig) action,
  ) async {
    final results = <_ProviderResult>[];

    for (final config in _providers) {
      if (!config.enabled) {
        results.add(_ProviderResult(
          providerName: config.name,
          success: true,
          skipped: true,
        ));
        continue;
      }

      try {
        await action(config);
        results.add(_ProviderResult(
          providerName: config.name,
          success: true,
        ));
      } catch (e, stackTrace) {
        _debugLog('Error in ${config.name}.$operation: $e');
        developer.log(
          'CompositeAnalytics error: ${config.name}.$operation',
          error: e,
          stackTrace: stackTrace,
          name: 'CompositeAnalyticsService',
        );

        results.add(_ProviderResult(
          providerName: config.name,
          success: false,
          error: e,
        ));

        if (stopOnFirstError) {
          break;
        }
      }
    }

    return results;
  }

  /// Logs a debug message if debug logging is enabled.
  void _debugLog(String message) {
    if (!enableDebugLogging) return;

    developer.log(
      message,
      name: 'CompositeAnalyticsService',
      time: DateTime.now(),
    );
  }
}

/// Result of an operation on a single provider.
class _ProviderResult {
  const _ProviderResult({
    required this.providerName,
    required this.success,
    this.skipped = false,
    this.error,
  });

  final String providerName;
  final bool success;
  final bool skipped;
  final Object? error;
}

/// Extension for creating composite services easily.
extension CompositeAnalyticsServiceExtension on List<AnalyticsService> {
  /// Creates a composite service from a list of providers.
  ///
  /// ```dart
  /// final composite = [
  ///   FirebaseAnalyticsService(),
  ///   ConsoleAnalyticsService(),
  /// ].toCompositeService();
  /// ```
  CompositeAnalyticsService toCompositeService({
    bool enableDebugLogging = false,
    bool stopOnFirstError = false,
  }) {
    return CompositeAnalyticsService(
      providers: asMap()
          .entries
          .map((e) => AnalyticsProviderConfig(
                provider: e.value,
                name: 'Provider${e.key}',
              ))
          .toList(),
      enableDebugLogging: enableDebugLogging,
      stopOnFirstError: stopOnFirstError,
    );
  }
}
