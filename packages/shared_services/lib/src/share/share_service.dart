import 'dart:typed_data';

import 'share_config.dart';
import 'share_result.dart';

/// Result of a share operation.
sealed class ShareOperationResult {
  const ShareOperationResult();

  /// Share was completed successfully.
  factory ShareOperationResult.success({String? sharedTo}) = ShareOperationSuccess;

  /// User cancelled the share operation.
  factory ShareOperationResult.cancelled() = ShareOperationCancelled;

  /// Share operation failed with an error.
  factory ShareOperationResult.failed({
    required String message,
    Object? error,
  }) = ShareOperationFailed;

  /// Sharing is not available on this platform.
  factory ShareOperationResult.unavailable({String? reason}) =
      ShareOperationUnavailable;
}

/// Share was completed successfully.
class ShareOperationSuccess extends ShareOperationResult {
  const ShareOperationSuccess({this.sharedTo});

  /// Optional: The app/service where content was shared.
  final String? sharedTo;
}

/// User cancelled the share operation.
class ShareOperationCancelled extends ShareOperationResult {
  const ShareOperationCancelled();
}

/// Share operation failed with an error.
class ShareOperationFailed extends ShareOperationResult {
  const ShareOperationFailed({
    required this.message,
    this.error,
  });

  /// Human-readable error message.
  final String message;

  /// Original error object for debugging.
  final Object? error;
}

/// Sharing is not available on this platform.
class ShareOperationUnavailable extends ShareOperationResult {
  const ShareOperationUnavailable({this.reason});

  /// Reason why sharing is unavailable.
  final String? reason;
}

/// Abstract service for sharing quiz results.
///
/// Provides functionality to share quiz results as:
/// - Plain text messages
/// - Images with overlaid score/stats
///
/// Implementations:
/// - [PlatformShareService] - Native share sheet integration
/// - [NoOpShareService] - When sharing is disabled
/// - [MockShareService] - For testing
///
/// Example usage:
/// ```dart
/// final shareService = PlatformShareService(
///   config: ShareConfig(
///     appName: 'Flags Quiz',
///     appStoreUrl: 'https://apps.apple.com/app/id123',
///     hashtags: ['FlagsQuiz', 'Quiz'],
///   ),
/// );
///
/// final result = ShareResult(
///   score: 85.0,
///   categoryName: 'Europe',
///   correctCount: 17,
///   totalCount: 20,
///   mode: 'standard',
///   timestamp: DateTime.now(),
/// );
///
/// // Share as text
/// final textResult = await shareService.shareText(result);
///
/// // Share as image
/// final imageResult = await shareService.shareImage(
///   result,
///   imageData: myImageBytes,
/// );
/// ```
abstract class ShareService {
  /// Configuration for the share service.
  ShareConfig get config;

  /// Whether sharing is available on this platform.
  ///
  /// Returns `false` if:
  /// - Platform doesn't support sharing
  /// - Sharing is disabled in config
  /// - Required permissions are not granted
  bool canShare();

  /// Whether image sharing is available.
  ///
  /// Image sharing may be unavailable even when text sharing works.
  bool canShareImage();

  /// Share quiz result as plain text.
  ///
  /// Generates a text message with the score, category, and optionally
  /// an app download link and hashtags.
  ///
  /// Returns a [ShareOperationResult] indicating the outcome.
  Future<ShareOperationResult> shareText(ShareResult result);

  /// Share quiz result as an image with text.
  ///
  /// The [imageData] parameter should be the PNG or JPEG bytes
  /// of the share image. Use [ShareImageGenerator] to create this.
  ///
  /// An optional [text] can be included alongside the image.
  ///
  /// Returns a [ShareOperationResult] indicating the outcome.
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
  });

  /// Generate the share text for a result.
  ///
  /// This can be used to preview the text before sharing.
  String generateShareText(ShareResult result);

  /// Generate a short share text suitable for limited character counts.
  ///
  /// Useful for platforms with character limits (e.g., Twitter/X).
  String generateShortShareText(ShareResult result);

  /// Dispose the service and release resources.
  void dispose();
}

/// No-op implementation of [ShareService] for when sharing is disabled.
class NoOpShareService implements ShareService {
  /// Creates a [NoOpShareService].
  const NoOpShareService([this._config = const ShareConfig.disabled()]);

  final ShareConfig _config;

  @override
  ShareConfig get config => _config;

  @override
  bool canShare() => false;

  @override
  bool canShareImage() => false;

  @override
  Future<ShareOperationResult> shareText(ShareResult result) async {
    return const ShareOperationUnavailable(reason: 'Sharing is disabled');
  }

  @override
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
  }) async {
    return const ShareOperationUnavailable(reason: 'Sharing is disabled');
  }

  @override
  String generateShareText(ShareResult result) => '';

  @override
  String generateShortShareText(ShareResult result) => '';

  @override
  void dispose() {}
}

/// Mock implementation of [ShareService] for testing.
class MockShareService implements ShareService {
  /// Creates a [MockShareService].
  MockShareService({
    ShareConfig? config,
    this.simulateSuccess = true,
    this.simulatedDelay = Duration.zero,
  }) : _config = config ?? const ShareConfig.test();

  final ShareConfig _config;

  /// Whether share operations should succeed.
  final bool simulateSuccess;

  /// Delay to simulate network/processing time.
  final Duration simulatedDelay;

  /// Tracks all share operations for verification in tests.
  final List<ShareResult> shareHistory = [];

  /// Last shared result.
  ShareResult? get lastSharedResult =>
      shareHistory.isNotEmpty ? shareHistory.last : null;

  @override
  ShareConfig get config => _config;

  @override
  bool canShare() => _config.enableTextSharing;

  @override
  bool canShareImage() => _config.enableImageSharing;

  @override
  Future<ShareOperationResult> shareText(ShareResult result) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    shareHistory.add(result);

    if (simulateSuccess) {
      return const ShareOperationSuccess();
    } else {
      return const ShareOperationFailed(message: 'Simulated failure');
    }
  }

  @override
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    shareHistory.add(result);

    if (simulateSuccess) {
      return const ShareOperationSuccess();
    } else {
      return const ShareOperationFailed(message: 'Simulated failure');
    }
  }

  @override
  String generateShareText(ShareResult result) {
    final buffer = StringBuffer();

    buffer.writeln(
      'I scored ${result.scorePercent}% on ${result.categoryName}! '
      '(${result.correctCount}/${result.totalCount})',
    );

    if (result.hasAchievement) {
      buffer.writeln('Achievement unlocked: ${result.achievementUnlocked}');
    }

    if (_config.includeAppLink && _config.hasAppLinks) {
      buffer.writeln();
      buffer.writeln('Play ${_config.appName}: ${_config.playStoreUrl ?? _config.appStoreUrl ?? _config.webUrl}');
    }

    if (_config.includeHashtags && _config.hashtags.isNotEmpty) {
      buffer.writeln();
      buffer.write(_config.formattedHashtags);
    }

    return buffer.toString().trim();
  }

  @override
  String generateShortShareText(ShareResult result) {
    return 'I scored ${result.scorePercent}% on ${result.categoryName}! '
        '${_config.includeHashtags ? _config.formattedHashtags : ''}';
  }

  /// Clear the share history.
  void clearHistory() => shareHistory.clear();

  @override
  void dispose() {
    shareHistory.clear();
  }
}
