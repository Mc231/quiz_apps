import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_theme_data.dart';

/// A button widget for displaying an image-based answer option.
///
/// The `ImageOptionButton` displays an image (asset or network) that can be
/// selected as an answer option. It supports disabled state for 50/50 hints,
/// accessibility labels, and theme integration.
///
/// Example:
/// ```dart
/// ImageOptionButton(
///   imageSource: ImageSource.asset('assets/flags/fr.png'),
///   semanticLabel: 'Flag of France',
///   onTap: () => selectAnswer(option),
///   imageSize: const MediumImageSize(),
/// )
/// ```
class ImageOptionButton extends StatelessWidget {
  /// The image source (asset or network URL).
  final ImageSource imageSource;

  /// Semantic label for accessibility.
  final String semanticLabel;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Whether the button is disabled (e.g., from 50/50 hint).
  final bool isDisabled;

  /// Size configuration for the image.
  final ImageAnswerSize imageSize;

  /// Theme data for customizing button appearance.
  final QuizThemeData themeData;

  /// Optional border radius override.
  final BorderRadius? borderRadius;

  /// Creates an `ImageOptionButton`.
  ///
  /// [imageSource] is the image to display (asset or network).
  /// [semanticLabel] is the accessibility label for screen readers.
  /// [onTap] is called when the button is tapped.
  /// [isDisabled] indicates if the button should be disabled.
  /// [imageSize] controls the image dimensions and spacing.
  /// [themeData] provides theme customization options.
  const ImageOptionButton({
    super.key,
    required this.imageSource,
    required this.semanticLabel,
    required this.onTap,
    this.isDisabled = false,
    this.imageSize = const MediumImageSize(),
    this.themeData = const QuizThemeData(),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final effectiveBorderRadius =
        borderRadius ?? themeData.buttonBorderRadius;

    final accessibilityLabel = isDisabled
        ? l10n.accessibilityAnswerDisabled(semanticLabel)
        : l10n.accessibilityAnswerOption(semanticLabel);

    return Semantics(
      label: accessibilityLabel,
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: effectiveBorderRadius,
          excludeFromSemantics: true,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDisabled ? 0.4 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey
                      : themeData.buttonBorderColor,
                  width: themeData.buttonBorderWidth > 0
                      ? themeData.buttonBorderWidth
                      : 2,
                ),
                color: isDisabled
                    ? Colors.grey[200]
                    : themeData.buttonColor.withAlpha(26),
              ),
              child: ClipRRect(
                borderRadius: effectiveBorderRadius,
                child: _buildImage(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the image widget based on the source type.
  Widget _buildImage(BuildContext context) {
    final aspectRatio = imageSize.aspectRatio;

    Widget imageWidget;

    switch (imageSource) {
      case AssetImage(:final path):
        imageWidget = Image.asset(
          path,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      case NetworkImage(:final url):
        imageWidget = Image.network(
          url,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingWidget(loadingProgress);
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
    }

    // Apply aspect ratio if specified
    if (aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: aspectRatio,
        child: imageWidget,
      );
    }

    // Apply disabled overlay if needed
    if (isDisabled) {
      imageWidget = Stack(
        fit: StackFit.passthrough,
        children: [
          imageWidget,
          Positioned.fill(
            child: Container(
              color: Colors.grey.withAlpha(128),
              child: const Icon(
                Icons.block,
                color: Colors.white54,
                size: 32,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.all(imageSize.spacing / 2),
      child: imageWidget,
    );
  }

  /// Builds a loading indicator while the network image loads.
  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
        : null;

    return Center(
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 2,
      ),
    );
  }

  /// Builds an error widget when the image fails to load.
  Widget _buildErrorWidget() {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Sealed class representing image sources.
///
/// Supports both asset images bundled with the app and network images
/// loaded from URLs.
sealed class ImageSource {
  const ImageSource();

  /// Creates an asset image source.
  const factory ImageSource.asset(String path) = AssetImage;

  /// Creates a network image source.
  const factory ImageSource.network(String url) = NetworkImage;
}

/// An image loaded from app assets.
class AssetImage extends ImageSource {
  /// The asset path (e.g., 'assets/flags/fr.png').
  final String path;

  const AssetImage(this.path);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetImage && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

/// An image loaded from a network URL.
class NetworkImage extends ImageSource {
  /// The network URL.
  final String url;

  const NetworkImage(this.url);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkImage && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
