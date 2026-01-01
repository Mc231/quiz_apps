import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_services/shared_services.dart';

/// Implementation of [DeepLinkService] for Flags Quiz app.
///
/// Handles `flagsquiz://` URL scheme using the `app_links` package.
///
/// Usage:
/// ```dart
/// final deepLinkService = FlagsQuizDeepLinkService();
/// await deepLinkService.initialize();
///
/// // Check for initial link (cold start)
/// final initialLink = deepLinkService.initialLink;
/// if (initialLink != null) {
///   handleDeepLink(initialLink);
/// }
///
/// // Listen for subsequent links (warm start)
/// deepLinkService.linkStream.listen((uri) {
///   handleDeepLink(uri);
/// });
/// ```
class FlagsQuizDeepLinkService implements DeepLinkService {
  /// Creates a [FlagsQuizDeepLinkService].
  FlagsQuizDeepLinkService({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  final _linkController = StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _initialLink;
  bool _initialized = false;

  @override
  Stream<Uri> get linkStream => _linkController.stream;

  @override
  Uri? get initialLink => _initialLink;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      // Get the initial link that launched the app (cold start)
      _initialLink = await _appLinks.getInitialLink();

      if (_initialLink != null) {
        debugPrint(
          'FlagsQuizDeepLinkService: Initial link received: $_initialLink',
        );
      }

      // Listen for subsequent links (warm start)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint(
            'FlagsQuizDeepLinkService: Link received while running: $uri',
          );
          _linkController.add(uri);
        },
        onError: (Object error) {
          debugPrint('FlagsQuizDeepLinkService: Error receiving link: $error');
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('FlagsQuizDeepLinkService: Failed to initialize: $e');
      // Don't throw - deep linking is not critical functionality
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
    _initialized = false;
  }
}
