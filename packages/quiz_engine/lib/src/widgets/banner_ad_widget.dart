import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_services/shared_services.dart';

/// Widget that displays a banner ad.
///
/// This widget handles:
/// - Loading the banner ad automatically
/// - Showing a placeholder while loading
/// - Hiding when ads are not available
/// - Respecting the ad service state (enabled/disabled)
///
/// Example usage:
/// ```dart
/// BannerAdWidget(
///   adsService: adsService,
///   placement: AdPlacement.bannerBottom,
/// )
/// ```
///
/// Place this widget at the bottom of a screen:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       Expanded(child: content),
///       BannerAdWidget(adsService: adsService),
///     ],
///   ),
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  /// Creates a [BannerAdWidget].
  const BannerAdWidget({
    super.key,
    required this.adsService,
    this.placement = AdPlacement.bannerBottom,
    this.showPlaceholder = false,
    this.placeholderHeight = 50.0,
  });

  /// The ads service to use for loading and displaying ads.
  final AdsService adsService;

  /// The placement for analytics tracking.
  final AdPlacement placement;

  /// Whether to show a placeholder while the ad is loading.
  final bool showPlaceholder;

  /// Height of the placeholder when [showPlaceholder] is true.
  final double placeholderHeight;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isLoading = false;
  bool _isLoaded = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    widget.adsService.disposeBannerAd();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (!widget.adsService.isEnabled || !widget.adsService.isInitialized) {
      return;
    }

    setState(() => _isLoading = true);

    final loaded = await widget.adsService.loadBannerAd();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoaded = loaded;
        if (loaded) {
          _bannerAd = widget.adsService.getBannerAdWidget() as BannerAd?;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ads are disabled
    if (!widget.adsService.isEnabled) {
      return const SizedBox.shrink();
    }

    // Show placeholder while loading
    if (_isLoading && widget.showPlaceholder) {
      return SizedBox(
        height: widget.placeholderHeight,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Don't show anything if not loaded
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Show the banner ad
    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

/// Widget that reserves space for a banner ad at the bottom of the screen.
///
/// Use this when you want to ensure consistent layout whether or not
/// ads are displayed.
///
/// Example usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       Expanded(child: content),
///       BannerAdContainer(
///         adsService: adsService,
///         child: BannerAdWidget(adsService: adsService),
///       ),
///     ],
///   ),
/// )
/// ```
class BannerAdContainer extends StatelessWidget {
  /// Creates a [BannerAdContainer].
  const BannerAdContainer({
    super.key,
    required this.adsService,
    required this.child,
    this.height = 50.0,
    this.backgroundColor,
  });

  /// The ads service to check if ads are enabled.
  final AdsService adsService;

  /// The child widget (typically a [BannerAdWidget]).
  final Widget child;

  /// Fixed height of the container.
  final double height;

  /// Background color of the container.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Don't reserve space if ads are disabled
    if (!adsService.isEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
