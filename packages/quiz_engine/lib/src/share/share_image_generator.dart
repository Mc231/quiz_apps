import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_services/shared_services.dart';

import 'share_image_template.dart';

/// Result of an image generation operation.
sealed class ShareImageResult {
  const ShareImageResult();

  /// Image was generated successfully.
  factory ShareImageResult.success({
    required Uint8List imageData,
    required String filePath,
    required int width,
    required int height,
  }) = ShareImageSuccess;

  /// Image generation failed.
  factory ShareImageResult.failed({
    required String message,
    Object? error,
  }) = ShareImageFailed;
}

/// Successful image generation.
class ShareImageSuccess extends ShareImageResult {
  const ShareImageSuccess({
    required this.imageData,
    required this.filePath,
    required this.width,
    required this.height,
  });

  /// The generated image as PNG bytes.
  final Uint8List imageData;

  /// Path to the temporary file where the image was saved.
  final String filePath;

  /// Width of the generated image in pixels.
  final int width;

  /// Height of the generated image in pixels.
  final int height;
}

/// Failed image generation.
class ShareImageFailed extends ShareImageResult {
  const ShareImageFailed({
    required this.message,
    this.error,
  });

  /// Human-readable error message.
  final String message;

  /// Original error object for debugging.
  final Object? error;
}

/// Service for generating shareable images from quiz results.
///
/// Uses Flutter's [RenderRepaintBoundary] to capture widgets as images.
/// The generated images are saved to a temporary file for sharing.
///
/// Example:
/// ```dart
/// final generator = ShareImageGenerator();
///
/// final result = await generator.generateImage(
///   context: context,
///   shareResult: myShareResult,
///   templateType: ShareImageTemplateType.standard(),
///   config: ShareImageConfig(
///     appName: 'Flags Quiz',
///   ),
/// );
///
/// if (result case ShareImageSuccess(:final imageData, :final filePath)) {
///   // Use imageData or filePath for sharing
/// }
/// ```
class ShareImageGenerator {
  /// Creates a [ShareImageGenerator].
  const ShareImageGenerator();

  /// Global key for the repaint boundary.
  static final GlobalKey _boundaryKey = GlobalKey();

  /// Get the global key for the repaint boundary.
  ///
  /// Use this key when wrapping the [ShareImageTemplate] in a
  /// [RepaintBoundary] to enable image capture.
  GlobalKey get boundaryKey => _boundaryKey;

  /// Generates an image from a [ShareResult].
  ///
  /// This method creates a temporary overlay with the [ShareImageTemplate],
  /// renders it, captures it as an image, and saves it to a temporary file.
  ///
  /// Returns [ShareImageSuccess] with the image data and file path,
  /// or [ShareImageFailed] if generation fails.
  Future<ShareImageResult> generateImage({
    required BuildContext context,
    required ShareResult shareResult,
    ShareImageTemplateType templateType = const StandardShareTemplate(),
    ShareImageConfig config = const ShareImageConfig(),
  }) async {
    try {
      // Create an overlay entry with the template widget
      final overlayState = Overlay.of(context);

      // Capture the widget as an image
      final imageData = await _captureWidget(
        overlayState: overlayState,
        shareResult: shareResult,
        templateType: templateType,
        config: config,
      );

      if (imageData == null) {
        return const ShareImageFailed(
          message: 'Failed to capture widget as image',
        );
      }

      // Save to temporary file
      final filePath = await _saveToTempFile(imageData);

      return ShareImageSuccess(
        imageData: imageData,
        filePath: filePath,
        width: config.width.toInt(),
        height: config.height.toInt(),
      );
    } catch (e) {
      return ShareImageFailed(
        message: 'Failed to generate share image',
        error: e,
      );
    }
  }

  /// Generates an image from an existing [RepaintBoundary].
  ///
  /// Use this method when you have already rendered the [ShareImageTemplate]
  /// with a [RepaintBoundary] using the [boundaryKey].
  ///
  /// This is more efficient than [generateImage] when the template
  /// is already visible on screen.
  Future<ShareImageResult> captureFromBoundary({
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        return const ShareImageFailed(
          message: 'RepaintBoundary not found. Ensure the widget is rendered.',
        );
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const ShareImageFailed(
          message: 'Failed to convert image to bytes',
        );
      }

      final imageData = byteData.buffer.asUint8List();
      final filePath = await _saveToTempFile(imageData);

      return ShareImageSuccess(
        imageData: imageData,
        filePath: filePath,
        width: image.width,
        height: image.height,
      );
    } catch (e) {
      return ShareImageFailed(
        message: 'Failed to capture image from boundary',
        error: e,
      );
    }
  }

  Future<Uint8List?> _captureWidget({
    required OverlayState overlayState,
    required ShareResult shareResult,
    required ShareImageTemplateType templateType,
    required ShareImageConfig config,
  }) async {
    final key = GlobalKey();
    Uint8List? capturedImage;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        // Position off-screen for capture
        left: -config.width * 2,
        top: -config.height * 2,
        child: RepaintBoundary(
          key: key,
          child: ShareImageTemplate(
            result: shareResult,
            templateType: templateType,
            config: config,
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    try {
      // Wait for the widget to be rendered
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      // Capture the image
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          capturedImage = byteData.buffer.asUint8List();
        }
      }
    } finally {
      entry.remove();
    }

    return capturedImage;
  }

  Future<String> _saveToTempFile(Uint8List imageData) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'share_result_$timestamp.png';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(imageData);

    return filePath;
  }

  /// Cleans up old temporary share images.
  ///
  /// Call this periodically to prevent temporary storage from growing.
  /// By default, removes files older than 1 hour.
  Future<int> cleanupTempFiles({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final dir = Directory(directory.path);
      final now = DateTime.now();
      var deletedCount = 0;

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('share_result_')) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);

          if (age > maxAge) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (_) {
      return 0;
    }
  }
}

/// A widget that wraps [ShareImageTemplate] with a [RepaintBoundary]
/// for efficient image capture.
///
/// Use this widget when you want to display the share preview
/// and then capture it as an image.
///
/// Example:
/// ```dart
/// final generator = ShareImageGenerator();
///
/// ShareImagePreview(
///   generator: generator,
///   result: shareResult,
///   config: ShareImageConfig(appName: 'Flags Quiz'),
///   builder: (context, captureImage) {
///     return Column(
///       children: [
///         // Preview is shown here
///         Expanded(
///           child: ShareImageTemplate(
///             result: shareResult,
///             config: config,
///           ),
///         ),
///         ElevatedButton(
///           onPressed: () async {
///             final result = await captureImage();
///             // Handle result
///           },
///           child: Text('Share'),
///         ),
///       ],
///     );
///   },
/// )
/// ```
class ShareImagePreview extends StatelessWidget {
  /// Creates a [ShareImagePreview].
  const ShareImagePreview({
    super.key,
    required this.generator,
    required this.result,
    this.templateType = const StandardShareTemplate(),
    this.config = const ShareImageConfig(),
    this.previewScale = 0.3,
  });

  /// The image generator to use for capture.
  final ShareImageGenerator generator;

  /// The quiz result to display.
  final ShareResult result;

  /// The template type to use.
  final ShareImageTemplateType templateType;

  /// Configuration for the template.
  final ShareImageConfig config;

  /// Scale factor for the preview (default 0.3 = 30% of full size).
  final double previewScale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: config.width * previewScale,
        height: config.height * previewScale,
        child: FittedBox(
          fit: BoxFit.contain,
          child: RepaintBoundary(
            key: generator.boundaryKey,
            child: ShareImageTemplate(
              result: result,
              templateType: templateType,
              config: config,
            ),
          ),
        ),
      ),
    );
  }
}
