import 'package:flutter/foundation.dart';

/// Configuration for the share service.
///
/// Contains app store URLs, default hashtags, and feature toggles
/// for social sharing functionality.
///
/// Example:
/// ```dart
/// final config = ShareConfig(
///   appName: 'Flags Quiz',
///   appStoreUrl: 'https://apps.apple.com/app/flags-quiz/id123456789',
///   playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example.flagsquiz',
///   hashtags: ['FlagsQuiz', 'Quiz', 'Trivia'],
/// );
/// ```
@immutable
class ShareConfig {
  /// Creates a [ShareConfig].
  const ShareConfig({
    required this.appName,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.hashtags = const [],
    this.enableImageSharing = true,
    this.enableTextSharing = true,
    this.includeAppLink = true,
    this.includeHashtags = true,
    this.defaultShareMessage,
  });

  /// Creates a minimal config for testing.
  const ShareConfig.test({
    this.appName = 'Test App',
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.hashtags = const [],
    this.enableImageSharing = true,
    this.enableTextSharing = true,
    this.includeAppLink = false,
    this.includeHashtags = false,
    this.defaultShareMessage,
  });

  /// Creates a config with no sharing enabled (for restricted regions).
  const ShareConfig.disabled({
    this.appName = '',
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.hashtags = const [],
    this.enableImageSharing = false,
    this.enableTextSharing = false,
    this.includeAppLink = false,
    this.includeHashtags = false,
    this.defaultShareMessage,
  });

  /// Name of the app to display in share messages.
  final String appName;

  /// iOS App Store URL for the app.
  ///
  /// Used in share messages to direct users to download.
  final String? appStoreUrl;

  /// Google Play Store URL for the app.
  ///
  /// Used in share messages to direct users to download.
  final String? playStoreUrl;

  /// Web URL for the app (if available).
  ///
  /// Fallback for platforms without app stores.
  final String? webUrl;

  /// Default hashtags to include in share messages.
  ///
  /// Example: ['FlagsQuiz', 'Quiz', 'Trivia']
  final List<String> hashtags;

  /// Whether image sharing is enabled.
  ///
  /// When disabled, only text sharing is available.
  final bool enableImageSharing;

  /// Whether text sharing is enabled.
  ///
  /// When disabled, sharing is completely disabled.
  final bool enableTextSharing;

  /// Whether to include app download link in share messages.
  final bool includeAppLink;

  /// Whether to include hashtags in share messages.
  final bool includeHashtags;

  /// Optional default share message template.
  ///
  /// Supports placeholders:
  /// - {score} - Score percentage
  /// - {category} - Category name
  /// - {correct} - Correct count
  /// - {total} - Total count
  /// - {mode} - Game mode
  /// - {appName} - App name
  /// - {link} - Download link
  /// - {hashtags} - Formatted hashtags
  final String? defaultShareMessage;

  /// Whether any sharing is enabled.
  bool get isEnabled => enableTextSharing || enableImageSharing;

  /// Whether app download links are available.
  bool get hasAppLinks =>
      appStoreUrl != null || playStoreUrl != null || webUrl != null;

  /// Formatted hashtags string (e.g., "#FlagsQuiz #Quiz").
  String get formattedHashtags =>
      hashtags.map((tag) => '#$tag').join(' ');

  /// Get the appropriate app link for the current platform.
  ///
  /// Returns the platform-specific store URL or web URL as fallback.
  String? getAppLinkForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return appStoreUrl ?? webUrl;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return playStoreUrl ?? webUrl;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return webUrl ?? appStoreUrl ?? playStoreUrl;
    }
  }

  /// Creates a copy with the given fields replaced.
  ShareConfig copyWith({
    String? appName,
    String? appStoreUrl,
    String? playStoreUrl,
    String? webUrl,
    List<String>? hashtags,
    bool? enableImageSharing,
    bool? enableTextSharing,
    bool? includeAppLink,
    bool? includeHashtags,
    String? defaultShareMessage,
  }) {
    return ShareConfig(
      appName: appName ?? this.appName,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      webUrl: webUrl ?? this.webUrl,
      hashtags: hashtags ?? this.hashtags,
      enableImageSharing: enableImageSharing ?? this.enableImageSharing,
      enableTextSharing: enableTextSharing ?? this.enableTextSharing,
      includeAppLink: includeAppLink ?? this.includeAppLink,
      includeHashtags: includeHashtags ?? this.includeHashtags,
      defaultShareMessage: defaultShareMessage ?? this.defaultShareMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareConfig &&
        other.appName == appName &&
        other.appStoreUrl == appStoreUrl &&
        other.playStoreUrl == playStoreUrl &&
        other.webUrl == webUrl &&
        listEquals(other.hashtags, hashtags) &&
        other.enableImageSharing == enableImageSharing &&
        other.enableTextSharing == enableTextSharing &&
        other.includeAppLink == includeAppLink &&
        other.includeHashtags == includeHashtags &&
        other.defaultShareMessage == defaultShareMessage;
  }

  @override
  int get hashCode => Object.hash(
        appName,
        appStoreUrl,
        playStoreUrl,
        webUrl,
        Object.hashAll(hashtags),
        enableImageSharing,
        enableTextSharing,
        includeAppLink,
        includeHashtags,
        defaultShareMessage,
      );

  @override
  String toString() {
    return 'ShareConfig('
        'appName: $appName, '
        'imageSharing: $enableImageSharing, '
        'textSharing: $enableTextSharing'
        ')';
  }
}
