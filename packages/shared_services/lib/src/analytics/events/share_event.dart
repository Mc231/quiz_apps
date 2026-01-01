import '../analytics_event.dart';

/// Sealed class for share-related analytics events.
///
/// Tracks user interactions with sharing functionality including:
/// - Share initiation
/// - Share type selection (text vs image)
/// - Share completion/cancellation/failure
///
/// Total: 5 events.
sealed class ShareEvent extends AnalyticsEvent {
  const ShareEvent();

  /// User initiated a share action.
  factory ShareEvent.initiated({
    required String contentType,
    required String sourceScreen,
    String? categoryId,
    String? categoryName,
  }) = ShareInitiatedEvent;

  /// User selected share type (text or image).
  factory ShareEvent.typeSelected({
    required String shareType,
    required String contentType,
    required String sourceScreen,
  }) = ShareTypeSelectedEvent;

  /// Share completed successfully.
  factory ShareEvent.completed({
    required String shareType,
    required String contentType,
    required String sourceScreen,
    String? sharedTo,
  }) = ShareCompletedEvent;

  /// User cancelled the share operation.
  factory ShareEvent.cancelled({
    required String shareType,
    required String contentType,
    required String sourceScreen,
  }) = ShareCancelledEvent;

  /// Share operation failed.
  factory ShareEvent.failed({
    required String shareType,
    required String contentType,
    required String sourceScreen,
    required String errorMessage,
  }) = ShareFailedEvent;
}

/// User initiated a share action.
final class ShareInitiatedEvent extends ShareEvent {
  const ShareInitiatedEvent({
    required this.contentType,
    required this.sourceScreen,
    this.categoryId,
    this.categoryName,
  });

  /// Type of content being shared: 'quiz_result', 'achievement', 'challenge'.
  final String contentType;

  /// Screen from which share was initiated.
  final String sourceScreen;

  /// Optional category ID for quiz results.
  final String? categoryId;

  /// Optional category name for quiz results.
  final String? categoryName;

  @override
  String get eventName => 'share_initiated';

  @override
  Map<String, dynamic> get parameters => {
        'content_type': contentType,
        'source_screen': sourceScreen,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryName != null) 'category_name': categoryName,
      };
}

/// User selected share type (text or image).
final class ShareTypeSelectedEvent extends ShareEvent {
  const ShareTypeSelectedEvent({
    required this.shareType,
    required this.contentType,
    required this.sourceScreen,
  });

  /// Type of share selected: 'text', 'image'.
  final String shareType;

  /// Type of content being shared.
  final String contentType;

  /// Screen from which share was initiated.
  final String sourceScreen;

  @override
  String get eventName => 'share_type_selected';

  @override
  Map<String, dynamic> get parameters => {
        'share_type': shareType,
        'content_type': contentType,
        'source_screen': sourceScreen,
      };
}

/// Share completed successfully.
final class ShareCompletedEvent extends ShareEvent {
  const ShareCompletedEvent({
    required this.shareType,
    required this.contentType,
    required this.sourceScreen,
    this.sharedTo,
  });

  /// Type of share completed: 'text', 'image'.
  final String shareType;

  /// Type of content shared.
  final String contentType;

  /// Screen from which share was initiated.
  final String sourceScreen;

  /// Optional platform/app where content was shared.
  final String? sharedTo;

  @override
  String get eventName => 'share_completed';

  @override
  Map<String, dynamic> get parameters => {
        'share_type': shareType,
        'content_type': contentType,
        'source_screen': sourceScreen,
        if (sharedTo != null) 'shared_to': sharedTo,
      };
}

/// User cancelled the share operation.
final class ShareCancelledEvent extends ShareEvent {
  const ShareCancelledEvent({
    required this.shareType,
    required this.contentType,
    required this.sourceScreen,
  });

  /// Type of share that was cancelled.
  final String shareType;

  /// Type of content that was being shared.
  final String contentType;

  /// Screen from which share was initiated.
  final String sourceScreen;

  @override
  String get eventName => 'share_cancelled';

  @override
  Map<String, dynamic> get parameters => {
        'share_type': shareType,
        'content_type': contentType,
        'source_screen': sourceScreen,
      };
}

/// Share operation failed.
final class ShareFailedEvent extends ShareEvent {
  const ShareFailedEvent({
    required this.shareType,
    required this.contentType,
    required this.sourceScreen,
    required this.errorMessage,
  });

  /// Type of share that failed.
  final String shareType;

  /// Type of content that was being shared.
  final String contentType;

  /// Screen from which share was initiated.
  final String sourceScreen;

  /// Error message describing the failure.
  final String errorMessage;

  @override
  String get eventName => 'share_failed';

  @override
  Map<String, dynamic> get parameters => {
        'share_type': shareType,
        'content_type': contentType,
        'source_screen': sourceScreen,
        'error_message': errorMessage,
      };
}
