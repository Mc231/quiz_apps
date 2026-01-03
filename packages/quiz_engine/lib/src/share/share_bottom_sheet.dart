import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../widgets/loading_indicator.dart';
import 'share_image_generator.dart';
import 'share_image_template.dart';

/// Type of share to perform.
enum ShareType {
  /// Share as plain text message.
  text,

  /// Share as image with text overlay.
  image,
}

/// Configuration for the share bottom sheet.
class ShareBottomSheetConfig {
  /// Creates a [ShareBottomSheetConfig].
  const ShareBottomSheetConfig({
    this.appName,
    this.appLogoAsset,
    this.categoryIcon,
    this.useDarkTheme,
    this.showTextOption = true,
    this.showImageOption = true,
  });

  /// App name to display on share image.
  final String? appName;

  /// Asset path for app logo.
  final String? appLogoAsset;

  /// Icon widget for the quiz category.
  final Widget? categoryIcon;

  /// Whether to use dark theme for share image.
  final bool? useDarkTheme;

  /// Whether to show the "Share as Text" option.
  final bool showTextOption;

  /// Whether to show the "Share as Image" option.
  final bool showImageOption;
}

/// A bottom sheet for sharing quiz results.
///
/// Displays a preview of the share content and options for:
/// - Share as Text: Plain text message with score and optional link
/// - Share as Image: Generated image with score visualization
///
/// Example:
/// ```dart
/// await showModalBottomSheet(
///   context: context,
///   builder: (context) => ShareBottomSheet(
///     result: myShareResult,
///     shareService: myShareService,
///     config: ShareBottomSheetConfig(
///       appName: 'Flags Quiz',
///       appLogoAsset: 'assets/logo.png',
///     ),
///   ),
/// );
/// ```
class ShareBottomSheet extends StatefulWidget {
  /// Creates a [ShareBottomSheet].
  const ShareBottomSheet({
    super.key,
    required this.result,
    required this.shareService,
    this.config = const ShareBottomSheetConfig(),
    this.onShareComplete,
    this.onShareError,
  });

  /// The quiz result to share.
  final ShareResult result;

  /// The share service to use.
  final ShareService shareService;

  /// Configuration for the bottom sheet.
  final ShareBottomSheetConfig config;

  /// Callback when share completes successfully.
  final void Function(ShareType type, ShareOperationResult result)? onShareComplete;

  /// Callback when share fails.
  final void Function(ShareType type, String message)? onShareError;

  /// Shows the share bottom sheet.
  ///
  /// Returns the [ShareOperationResult] if sharing was initiated,
  /// or `null` if the sheet was dismissed without sharing.
  static Future<ShareOperationResult?> show({
    required BuildContext context,
    required ShareResult result,
    required ShareService shareService,
    ShareBottomSheetConfig config = const ShareBottomSheetConfig(),
    void Function(ShareType type, ShareOperationResult result)? onShareComplete,
    void Function(ShareType type, String message)? onShareError,
  }) {
    return showModalBottomSheet<ShareOperationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        result: result,
        shareService: shareService,
        config: config,
        onShareComplete: onShareComplete,
        onShareError: onShareError,
      ),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final ShareImageGenerator _imageGenerator = const ShareImageGenerator();
  bool _isSharing = false;
  bool _isGeneratingImage = false;

  ShareImageTemplateType get _templateType {
    if (widget.result.isPerfect) {
      return ShareImageTemplateType.perfectScore();
    }
    if (widget.result.hasAchievement) {
      return ShareImageTemplateType.achievement(
        achievementName: widget.result.achievementUnlocked!,
      );
    }
    return ShareImageTemplateType.standard();
  }

  ShareImageConfig get _imageConfig => ShareImageConfig(
        appName: widget.config.appName,
        appLogoAsset: widget.config.appLogoAsset,
        categoryIcon: widget.config.categoryIcon,
        useDarkTheme: widget.config.useDarkTheme,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxHeight = mediaQuery.size.height * (isLandscape ? 0.9 : 0.8);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar (fixed at top)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      l10n.share,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Preview (only if image sharing is available)
                    if (widget.shareService.canShareImage() &&
                        widget.config.showImageOption) ...[
                      _buildImagePreview(context),
                      const SizedBox(height: 24),
                    ],

                    // Share options
                    _buildShareOptions(context, l10n),

                    const SizedBox(height: 16),

                    // Cancel button
                    TextButton(
                      onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ShareImagePreview(
          generator: _imageGenerator,
          result: widget.result,
          templateType: _templateType,
          config: _imageConfig,
          previewScale: 0.25,
        ),
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context, QuizEngineLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Share as Image (if available)
        if (widget.shareService.canShareImage() &&
            widget.config.showImageOption) ...[
          _ShareOptionTile(
            icon: Icons.image_outlined,
            title: l10n.shareAsImage,
            subtitle: l10n.shareAsImageDescription,
            isLoading: _isGeneratingImage,
            enabled: !_isSharing,
            onTap: _shareAsImage,
          ),
          const SizedBox(height: 12),
        ],

        // Share as Text
        if (widget.shareService.canShare() &&
            widget.config.showTextOption) ...[
          _ShareOptionTile(
            icon: Icons.text_fields,
            title: l10n.shareAsText,
            subtitle: l10n.shareAsTextDescription,
            isLoading: _isSharing && !_isGeneratingImage,
            enabled: !_isSharing,
            onTap: _shareAsText,
          ),
        ],

        // Show unavailable message if neither option is available
        if (!widget.shareService.canShare() &&
            !widget.shareService.canShareImage())
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.shareUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Future<void> _shareAsText() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final result = await widget.shareService.shareText(widget.result);

      if (!mounted) return;

      widget.onShareComplete?.call(ShareType.text, result);

      switch (result) {
        case ShareOperationSuccess():
          Navigator.of(context).pop(result);
        case ShareOperationCancelled():
          setState(() => _isSharing = false);
        case ShareOperationFailed(:final message):
          widget.onShareError?.call(ShareType.text, message);
          setState(() => _isSharing = false);
        case ShareOperationUnavailable(:final reason):
          widget.onShareError?.call(ShareType.text, reason ?? 'Unavailable');
          setState(() => _isSharing = false);
      }
    } catch (e) {
      if (!mounted) return;
      widget.onShareError?.call(ShareType.text, e.toString());
      setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
      _isGeneratingImage = true;
    });

    try {
      // Generate the image
      final imageResult = await _imageGenerator.generateImage(
        context: context,
        shareResult: widget.result,
        templateType: _templateType,
        config: _imageConfig,
      );

      if (!mounted) return;

      setState(() => _isGeneratingImage = false);

      switch (imageResult) {
        case ShareImageSuccess(:final imageData):
          // Share the generated image
          final shareResult = await widget.shareService.shareImage(
            widget.result,
            imageData: imageData,
          );

          if (!mounted) return;

          widget.onShareComplete?.call(ShareType.image, shareResult);

          switch (shareResult) {
            case ShareOperationSuccess():
              Navigator.of(context).pop(shareResult);
            case ShareOperationCancelled():
              setState(() => _isSharing = false);
            case ShareOperationFailed(:final message):
              widget.onShareError?.call(ShareType.image, message);
              setState(() => _isSharing = false);
            case ShareOperationUnavailable(:final reason):
              widget.onShareError?.call(ShareType.image, reason ?? 'Unavailable');
              setState(() => _isSharing = false);
          }

        case ShareImageFailed(:final message):
          widget.onShareError?.call(ShareType.image, message);
          setState(() => _isSharing = false);
      }
    } catch (e) {
      if (!mounted) return;
      widget.onShareError?.call(ShareType.image, e.toString());
      setState(() {
        _isSharing = false;
        _isGeneratingImage = false;
      });
    }
  }
}

/// A tile representing a share option.
class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const LoadingIndicator.small()
                    : Icon(
                        icon,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? null : theme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
