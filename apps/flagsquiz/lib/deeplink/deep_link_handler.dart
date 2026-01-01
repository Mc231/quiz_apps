import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import 'deep_link_router.dart';
import 'flags_quiz_deep_link_route.dart';
import 'flags_quiz_deep_link_service.dart';

/// Callback type for handling parsed deep link routes.
typedef DeepLinkRouteHandler = void Function(
  BuildContext context,
  FlagsQuizDeepLinkRoute route,
);

/// Widget that listens for deep links and handles navigation.
///
/// Wraps the app widget tree and provides deep link handling functionality.
/// Routes are parsed using [DeepLinkRouter] and passed to the [onRoute] callback.
///
/// Example:
/// ```dart
/// DeepLinkHandler(
///   deepLinkService: deepLinkService,
///   analyticsService: analyticsService,
///   onRoute: (context, route) {
///     switch (route) {
///       case QuizRoute(:final categoryId):
///         Navigator.pushNamed(context, '/quiz/$categoryId');
///       case AchievementRoute(:final achievementId):
///         Navigator.pushNamed(context, '/achievement/$achievementId');
///       // ...
///     }
///   },
///   child: MyApp(),
/// )
/// ```
class DeepLinkHandler extends StatefulWidget {
  /// Creates a [DeepLinkHandler].
  const DeepLinkHandler({
    super.key,
    required this.deepLinkService,
    required this.onRoute,
    required this.child,
    this.analyticsService,
  });

  /// The deep link service to listen to.
  final FlagsQuizDeepLinkService deepLinkService;

  /// Optional analytics service for tracking deep link events.
  final AnalyticsService? analyticsService;

  /// Callback invoked when a deep link route is received.
  final DeepLinkRouteHandler onRoute;

  /// The child widget tree.
  final Widget child;

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _router = const DeepLinkRouter();
  StreamSubscription<Uri>? _linkSubscription;
  bool _initialLinkHandled = false;

  @override
  void initState() {
    super.initState();
    _setupDeepLinkHandling();
  }

  void _setupDeepLinkHandling() {
    // Listen for deep links while app is running
    _linkSubscription = widget.deepLinkService.linkStream.listen(
      (uri) => _handleDeepLink(uri, source: 'background'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle initial link after first frame is rendered
    if (!_initialLinkHandled) {
      _initialLinkHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialLink();
      });
    }
  }

  void _handleInitialLink() {
    final initialLink = widget.deepLinkService.initialLink;
    if (initialLink != null) {
      _handleDeepLink(initialLink, source: 'cold_start');
    }
  }

  void _handleDeepLink(Uri uri, {required String source}) {
    if (!mounted) return;

    debugPrint('DeepLinkHandler: Handling deep link: $uri (source: $source)');

    // Log received event
    widget.analyticsService?.logEvent(
      DeepLinkEvent.received(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        source: source,
      ),
    );

    // Parse the URI into a route
    final route = _router.parse(uri);

    // Log based on route type
    if (route is UnknownRoute) {
      widget.analyticsService?.logEvent(
        DeepLinkEvent.failed(
          scheme: uri.scheme,
          host: uri.host,
          path: uri.path,
          reason: 'unknown_route',
        ),
      );
      debugPrint('DeepLinkHandler: Unknown route for: $uri');
    } else {
      widget.analyticsService?.logEvent(
        DeepLinkEvent.handled(
          scheme: uri.scheme,
          host: uri.host,
          path: uri.path,
          routeType: route.routeType,
          routeId: route.routeId,
        ),
      );
    }

    // Invoke the route handler
    widget.onRoute(context, route);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
