import 'dart:typed_data';
import 'dart:ui';

import '../analytics/analytics_exports.dart';
import 'share_config.dart';
import 'share_result.dart';
import 'share_service.dart';

/// A [ShareService] decorator that adds analytics tracking.
///
/// Wraps any [ShareService] implementation and logs [ShareEvent] analytics
/// for all share operations.
///
/// Example:
/// ```dart
/// final shareService = AnalyticsShareService(
///   shareService: PlatformShareService(config: config),
///   analyticsService: myAnalyticsService,
///   sourceScreen: 'results_screen',
/// );
///
/// // Analytics events are logged automatically
/// await shareService.shareText(result);
/// ```
class AnalyticsShareService implements ShareService {
  /// Creates an [AnalyticsShareService].
  AnalyticsShareService({
    required ShareService shareService,
    required AnalyticsService analyticsService,
    required String sourceScreen,
    String contentType = 'quiz_result',
  })  : _shareService = shareService,
        _analyticsService = analyticsService,
        _sourceScreen = sourceScreen,
        _contentType = contentType;

  final ShareService _shareService;
  final AnalyticsService _analyticsService;
  final String _sourceScreen;
  final String _contentType;

  @override
  ShareConfig get config => _shareService.config;

  @override
  bool canShare() => _shareService.canShare();

  @override
  bool canShareImage() => _shareService.canShareImage();

  @override
  Future<ShareOperationResult> shareText(
    ShareResult result, {
    Rect? sharePositionOrigin,
  }) async {
    // Log type selected
    _analyticsService.logEvent(
      ShareEvent.typeSelected(
        shareType: 'text',
        contentType: _contentType,
        sourceScreen: _sourceScreen,
      ),
    );

    // Perform share
    final shareResult = await _shareService.shareText(
      result,
      sharePositionOrigin: sharePositionOrigin,
    );

    // Log result
    _logShareResult(shareResult, 'text');

    return shareResult;
  }

  @override
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    // Log type selected
    _analyticsService.logEvent(
      ShareEvent.typeSelected(
        shareType: 'image',
        contentType: _contentType,
        sourceScreen: _sourceScreen,
      ),
    );

    // Perform share
    final shareResult = await _shareService.shareImage(
      result,
      imageData: imageData,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );

    // Log result
    _logShareResult(shareResult, 'image');

    return shareResult;
  }

  /// Logs the appropriate analytics event based on share result.
  void _logShareResult(ShareOperationResult result, String shareType) {
    switch (result) {
      case ShareOperationSuccess(:final sharedTo):
        _analyticsService.logEvent(
          ShareEvent.completed(
            shareType: shareType,
            contentType: _contentType,
            sourceScreen: _sourceScreen,
            sharedTo: sharedTo,
          ),
        );

      case ShareOperationCancelled():
        _analyticsService.logEvent(
          ShareEvent.cancelled(
            shareType: shareType,
            contentType: _contentType,
            sourceScreen: _sourceScreen,
          ),
        );

      case ShareOperationFailed(:final message):
        _analyticsService.logEvent(
          ShareEvent.failed(
            shareType: shareType,
            contentType: _contentType,
            sourceScreen: _sourceScreen,
            errorMessage: message,
          ),
        );

      case ShareOperationUnavailable(:final reason):
        _analyticsService.logEvent(
          ShareEvent.failed(
            shareType: shareType,
            contentType: _contentType,
            sourceScreen: _sourceScreen,
            errorMessage: reason ?? 'unavailable',
          ),
        );
    }
  }

  /// Logs share initiated event.
  ///
  /// Call this when the user taps the share button, before they select
  /// a share type (text vs image).
  void logShareInitiated({
    String? categoryId,
    String? categoryName,
  }) {
    _analyticsService.logEvent(
      ShareEvent.initiated(
        contentType: _contentType,
        sourceScreen: _sourceScreen,
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }

  @override
  String generateShareText(ShareResult result) =>
      _shareService.generateShareText(result);

  @override
  String generateShortShareText(ShareResult result) =>
      _shareService.generateShortShareText(result);

  @override
  void dispose() => _shareService.dispose();
}
