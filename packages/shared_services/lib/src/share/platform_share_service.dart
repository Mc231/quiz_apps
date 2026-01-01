import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

import 'share_config.dart';
import 'share_result.dart';
import 'share_service.dart';

/// Platform-specific implementation of [ShareService] using native share sheets.
///
/// Uses [share_plus] package to integrate with:
/// - iOS: UIActivityViewController
/// - Android: Intent.ACTION_SEND
/// - Web: Web Share API (with clipboard fallback)
///
/// Example:
/// ```dart
/// final shareService = PlatformShareService(
///   config: ShareConfig(
///     appName: 'Flags Quiz',
///     appStoreUrl: 'https://apps.apple.com/app/id123',
///     playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
///     hashtags: ['FlagsQuiz', 'Quiz'],
///   ),
/// );
///
/// final result = ShareResult.fromQuizCompletion(
///   correctCount: 17,
///   totalCount: 20,
///   categoryName: 'Europe',
///   mode: 'standard',
/// );
///
/// // Share as text
/// await shareService.shareText(result);
///
/// // Share as image
/// final imageBytes = await generateImage();
/// await shareService.shareImage(result, imageData: imageBytes);
/// ```
class PlatformShareService implements ShareService {
  /// Creates a [PlatformShareService].
  PlatformShareService({
    required ShareConfig config,
  }) : _config = config;

  final ShareConfig _config;

  @override
  ShareConfig get config => _config;

  @override
  bool canShare() {
    // share_plus works on all platforms
    return _config.enableTextSharing;
  }

  @override
  bool canShareImage() {
    // Image sharing is supported on mobile platforms
    // Web has limited support via file sharing
    if (!_config.enableImageSharing) return false;

    // On web, image sharing may be limited
    if (kIsWeb) return false;

    return true;
  }

  @override
  Future<ShareOperationResult> shareText(ShareResult result) async {
    if (!canShare()) {
      return const ShareOperationUnavailable(reason: 'Text sharing is disabled');
    }

    try {
      final text = generateShareText(result);

      final shareResult = await share_plus.Share.share(
        text,
        subject: _getShareSubject(result),
      );

      return _mapShareResult(shareResult);
    } catch (e) {
      return ShareOperationFailed(
        message: 'Failed to share text',
        error: e,
      );
    }
  }

  @override
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
  }) async {
    if (!canShareImage()) {
      return const ShareOperationUnavailable(reason: 'Image sharing is not available');
    }

    try {
      // Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/share_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageData);

      // Create XFile for sharing
      final xFile = share_plus.XFile(filePath, mimeType: 'image/png');

      // Share with optional text
      final shareText = text ?? generateShortShareText(result);

      final shareResult = await share_plus.Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: _getShareSubject(result),
      );

      // Clean up temp file (with delay to ensure sharing completes)
      Future.delayed(const Duration(seconds: 30), () {
        file.delete().catchError((_) => file);
      });

      return _mapShareResult(shareResult);
    } catch (e) {
      return ShareOperationFailed(
        message: 'Failed to share image',
        error: e,
      );
    }
  }

  @override
  String generateShareText(ShareResult result) {
    // Check for custom template
    if (_config.defaultShareMessage != null) {
      return _applyTemplate(_config.defaultShareMessage!, result);
    }

    final buffer = StringBuffer();

    // Main score message
    if (result.isPerfect) {
      buffer.writeln(
        '🏆 Perfect score on ${result.categoryName}! '
        '${result.correctCount}/${result.totalCount} (${result.scorePercent}%)',
      );
    } else {
      buffer.writeln(
        '🎯 I scored ${result.scorePercent}% on ${result.categoryName}! '
        '(${result.correctCount}/${result.totalCount})',
      );
    }

    // Achievement if unlocked
    if (result.hasAchievement) {
      buffer.writeln('🏅 Achievement unlocked: ${result.achievementUnlocked}');
    }

    // New personal best
    if (result.isNewBest) {
      buffer.writeln('⭐ New personal best!');
    }

    // App download link
    if (_config.includeAppLink && _config.hasAppLinks) {
      buffer.writeln();
      final appLink = _config.playStoreUrl ??
          _config.appStoreUrl ??
          _config.webUrl;
      buffer.writeln('Play ${_config.appName}: $appLink');
    }

    // Hashtags
    if (_config.includeHashtags && _config.hashtags.isNotEmpty) {
      buffer.writeln();
      buffer.write(_config.formattedHashtags);
    }

    return buffer.toString().trim();
  }

  @override
  String generateShortShareText(ShareResult result) {
    final buffer = StringBuffer();

    // Compact score message
    if (result.isPerfect) {
      buffer.write('🏆 Perfect on ${result.categoryName}!');
    } else {
      buffer.write('🎯 ${result.scorePercent}% on ${result.categoryName}');
    }

    // Hashtags
    if (_config.includeHashtags && _config.hashtags.isNotEmpty) {
      buffer.write(' ${_config.formattedHashtags}');
    }

    return buffer.toString();
  }

  /// Generates share subject for email/messaging apps.
  String _getShareSubject(ShareResult result) {
    if (result.isPerfect) {
      return 'Perfect Score on ${_config.appName}!';
    }
    return 'My ${_config.appName} Score: ${result.scorePercent}%';
  }

  /// Applies template placeholders to a custom message template.
  String _applyTemplate(String template, ShareResult result) {
    return template
        .replaceAll('{score}', '${result.scorePercent}')
        .replaceAll('{category}', result.categoryName)
        .replaceAll('{correct}', '${result.correctCount}')
        .replaceAll('{total}', '${result.totalCount}')
        .replaceAll('{mode}', result.mode)
        .replaceAll('{appName}', _config.appName)
        .replaceAll(
          '{link}',
          _config.playStoreUrl ?? _config.appStoreUrl ?? _config.webUrl ?? '',
        )
        .replaceAll('{hashtags}', _config.formattedHashtags);
  }

  /// Maps share_plus result to our ShareOperationResult.
  ShareOperationResult _mapShareResult(share_plus.ShareResult shareResult) {
    switch (shareResult.status) {
      case share_plus.ShareResultStatus.success:
        return ShareOperationSuccess(sharedTo: shareResult.raw);
      case share_plus.ShareResultStatus.dismissed:
        return const ShareOperationCancelled();
      case share_plus.ShareResultStatus.unavailable:
        return const ShareOperationUnavailable(
          reason: 'Share is not available on this platform',
        );
    }
  }

  @override
  void dispose() {
    // No resources to clean up
  }
}
