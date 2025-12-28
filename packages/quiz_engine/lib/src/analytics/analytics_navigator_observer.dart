import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

/// A [NavigatorObserver] that automatically tracks screen views.
///
/// This observer integrates with [AnalyticsService] to log screen view events
/// whenever the user navigates to a new screen.
///
/// ## Usage
///
/// Add the observer to your [MaterialApp]:
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     AnalyticsNavigatorObserver(
///       analyticsService: myAnalyticsService,
///     ),
///   ],
/// )
/// ```
///
/// ## Screen Name Resolution
///
/// The observer determines screen names in the following priority:
/// 1. [RouteSettings.name] if provided
/// 2. Custom [screenNameExtractor] if provided
/// 3. Route's runtime type name as fallback
///
/// ## Custom Screen Name Extraction
///
/// ```dart
/// AnalyticsNavigatorObserver(
///   analyticsService: myAnalyticsService,
///   screenNameExtractor: (route) {
///     if (route is MaterialPageRoute) {
///       // Extract from your route structure
///       return 'custom_screen_name';
///     }
///     return null;
///   },
/// )
/// ```
class AnalyticsNavigatorObserver extends NavigatorObserver {
  /// Creates an [AnalyticsNavigatorObserver].
  ///
  /// [analyticsService] - The analytics service to use for logging events.
  ///   If not provided, screen tracking will be skipped.
  /// [screenNameExtractor] - Optional custom function to extract screen names.
  /// [excludedRoutes] - Set of route names to exclude from tracking.
  /// [trackScreenClass] - Whether to include screen class in events.
  AnalyticsNavigatorObserver({
    this.analyticsService,
    this.screenNameExtractor,
    this.excludedRoutes = const {},
    this.trackScreenClass = true,
  });

  /// The analytics service for logging screen views.
  ///
  /// If null, screen tracking will be skipped silently.
  final AnalyticsService? analyticsService;

  /// Optional custom function to extract screen names from routes.
  ///
  /// If this returns null, the default extraction logic is used.
  final String? Function(Route<dynamic> route)? screenNameExtractor;

  /// Set of route names to exclude from tracking.
  ///
  /// Routes with names in this set will not trigger screen view events.
  final Set<String> excludedRoutes;

  /// Whether to include screen class in analytics events.
  final bool trackScreenClass;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Track the screen we're returning to
    if (previousRoute != null) {
      _trackScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreenView(newRoute);
    }
  }

  /// Tracks a screen view for the given route.
  void _trackScreenView(Route<dynamic> route) {
    // Skip if no analytics service
    final service = analyticsService;
    if (service == null) return;

    final screenName = _extractScreenName(route);

    // Skip if no screen name or excluded
    if (screenName == null || excludedRoutes.contains(screenName)) {
      return;
    }

    final screenClass = trackScreenClass ? _extractScreenClass(route) : null;

    service.setCurrentScreen(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Extracts the screen name from a route.
  String? _extractScreenName(Route<dynamic> route) {
    // Try custom extractor first
    if (screenNameExtractor != null) {
      final customName = screenNameExtractor!(route);
      if (customName != null) {
        return customName;
      }
    }

    // Use route settings name if available
    final routeName = route.settings.name;
    if (routeName != null && routeName.isNotEmpty && routeName != '/') {
      return _formatRouteName(routeName);
    }

    // Fall back to route type name
    return _extractRouteTypeName(route);
  }

  /// Formats a route name for analytics.
  ///
  /// Converts '/my-screen' to 'my_screen'.
  String _formatRouteName(String routeName) {
    // Remove leading slash
    var name = routeName.startsWith('/') ? routeName.substring(1) : routeName;

    // Convert dashes to underscores
    name = name.replaceAll('-', '_');

    // Convert slashes to underscores (for nested routes)
    name = name.replaceAll('/', '_');

    return name;
  }

  /// Extracts a type-based name from the route.
  String? _extractRouteTypeName(Route<dynamic> route) {
    // For page routes, try to get the page type
    if (route is PageRoute) {
      final typeName = route.runtimeType.toString();
      // Convert CamelCase to snake_case
      return _camelToSnake(typeName);
    }

    return null;
  }

  /// Extracts the screen class name from a route.
  String? _extractScreenClass(Route<dynamic> route) {
    if (route is PageRoute) {
      return route.runtimeType.toString();
    }
    return null;
  }

  /// Converts CamelCase to snake_case.
  String _camelToSnake(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        if (i > 0) {
          buffer.write('_');
        }
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

/// Extension to help create screen view events for manual tracking.
extension AnalyticsServiceScreenTracking on AnalyticsService {
  /// Logs a screen view event using the [ScreenViewEvent] sealed class.
  ///
  /// This provides type-safe screen tracking with predefined screen types.
  ///
  /// ```dart
  /// analyticsService.logScreenView(
  ///   ScreenViewEvent.home(activeTab: 'play'),
  /// );
  /// ```
  Future<void> logScreenView(ScreenViewEvent event) async {
    await logEvent(event);
    await setCurrentScreen(
      screenName: event.screenName,
      screenClass: event.screenClass,
    );
  }
}
