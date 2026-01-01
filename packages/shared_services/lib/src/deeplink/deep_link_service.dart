/// Abstract service for handling deep links.
///
/// Provides a platform-agnostic interface for receiving and handling
/// deep links. App-specific implementations should handle their own
/// URL schemes and routing logic.
///
/// Example implementation:
/// ```dart
/// class MyAppDeepLinkService implements DeepLinkService {
///   final _linkController = StreamController<Uri>.broadcast();
///   Uri? _initialLink;
///
///   @override
///   Stream<Uri> get linkStream => _linkController.stream;
///
///   @override
///   Uri? get initialLink => _initialLink;
///
///   @override
///   Future<void> initialize() async {
///     // Get initial link that launched the app
///     _initialLink = await getInitialUri();
///     // Listen for subsequent links
///     uriLinkStream.listen(_linkController.add);
///   }
///
///   @override
///   void dispose() {
///     _linkController.close();
///   }
/// }
/// ```
abstract class DeepLinkService {
  /// Stream of incoming deep links.
  ///
  /// Emits a new [Uri] whenever the app receives a deep link
  /// while running (warm start).
  Stream<Uri> get linkStream;

  /// The initial deep link that launched the app.
  ///
  /// Returns `null` if:
  /// - The app was not launched via a deep link
  /// - [initialize] has not been called yet
  /// - The initial link has already been consumed
  Uri? get initialLink;

  /// Initialize the deep link service.
  ///
  /// Should be called once during app startup.
  /// After initialization:
  /// - [initialLink] will be available if the app was launched via deep link
  /// - [linkStream] will emit subsequent deep links
  Future<void> initialize();

  /// Dispose the service and release resources.
  void dispose();
}

/// No-op implementation of [DeepLinkService] for when deep linking is disabled.
class NoOpDeepLinkService implements DeepLinkService {
  /// Creates a [NoOpDeepLinkService].
  const NoOpDeepLinkService();

  @override
  Stream<Uri> get linkStream => const Stream.empty();

  @override
  Uri? get initialLink => null;

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}
}
