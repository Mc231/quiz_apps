import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_services/shared_services.dart';

import '../services/quiz_services_context.dart';

/// Widget that displays a banner ad.
///
/// This widget handles:
/// - Loading the banner ad automatically
/// - Showing a placeholder while loading
/// - Hiding when ads are not available
/// - Respecting the ad service state (enabled/disabled)
///
/// The [adsService] parameter is optional. If not provided, the widget
/// will attempt to get the service from [QuizServicesProvider] via context.
///
/// Example usage with context:
/// ```dart
/// // When QuizServicesProvider is in the widget tree
/// BannerAdWidget(
///   placement: AdPlacement.bannerBottom,
/// )
/// ```
///
/// Example usage with explicit service:
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
///       const BannerAdWidget(),
///     ],
///   ),
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  /// Creates a [BannerAdWidget].
  ///
  /// If [adsService] is not provided, it will be obtained from context.
  const BannerAdWidget({
    super.key,
    this.adsService,
    this.placement = AdPlacement.bannerBottom,
    this.showPlaceholder = false,
    this.placeholderHeight = 50.0,
  });

  /// The ads service to use for loading and displaying ads.
  ///
  /// If null, the service will be obtained from [QuizServicesProvider] via context.
  final AdsService? adsService;

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
  bool _isAdsEnabled = true;
  BannerAd? _bannerAd;
  AdsService? _resolvedAdsService;
  StreamSubscription<bool>? _adAvailabilitySubscription;

  /// Gets the ads service from widget or context.
  AdsService? get _adsService {
    if (widget.adsService != null) {
      return widget.adsService;
    }
    // Cache resolved service to avoid repeated lookups
    _resolvedAdsService ??= context.maybeServices?.adsService;
    return _resolvedAdsService;
  }

  @override
  void initState() {
    super.initState();
    // Defer loading to after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToAdAvailability();
      _loadAd();
    });
  }

  void _subscribeToAdAvailability() {
    final adsService = _adsService;
    if (adsService == null) return;

    _isAdsEnabled = adsService.isEnabled;
    _adAvailabilitySubscription?.cancel();
    _adAvailabilitySubscription =
        adsService.onAdAvailabilityChanged.listen((available) {
      if (mounted) {
        setState(() {
          _isAdsEnabled = adsService.isEnabled;
          if (!_isAdsEnabled) {
            _isLoaded = false;
            _bannerAd = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _adAvailabilitySubscription?.cancel();
    _adsService?.disposeBannerAd();
    super.dispose();
  }

  Future<void> _loadAd() async {
    final adsService = _adsService;
    if (adsService == null) {
      return;
    }

    if (!adsService.isEnabled || !adsService.isInitialized) {
      return;
    }

    setState(() => _isLoading = true);

    final loaded = await adsService.loadBannerAd();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoaded = loaded;
        if (loaded) {
          _bannerAd = adsService.getBannerAdWidget() as BannerAd?;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsService = _adsService;

    // Don't show anything if no ads service or ads are disabled
    if (adsService == null || !_isAdsEnabled) {
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
/// The [adsService] parameter is optional. If not provided, the widget
/// will attempt to get the service from [QuizServicesProvider] via context.
///
/// Example usage with context:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       Expanded(child: content),
///       const BannerAdContainer(
///         child: BannerAdWidget(),
///       ),
///     ],
///   ),
/// )
/// ```
class BannerAdContainer extends StatefulWidget {
  /// Creates a [BannerAdContainer].
  ///
  /// If [adsService] is not provided, it will be obtained from context.
  const BannerAdContainer({
    super.key,
    this.adsService,
    required this.child,
    this.height = 50.0,
    this.backgroundColor,
  });

  /// The ads service to check if ads are enabled.
  ///
  /// If null, the service will be obtained from [QuizServicesProvider] via context.
  final AdsService? adsService;

  /// The child widget (typically a [BannerAdWidget]).
  final Widget child;

  /// Fixed height of the container.
  final double height;

  /// Background color of the container.
  final Color? backgroundColor;

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  bool _isAdsEnabled = true;
  AdsService? _resolvedAdsService;
  StreamSubscription<bool>? _adAvailabilitySubscription;

  AdsService? get _adsService {
    if (widget.adsService != null) {
      return widget.adsService;
    }
    _resolvedAdsService ??= context.maybeServices?.adsService;
    return _resolvedAdsService;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToAdAvailability();
    });
  }

  void _subscribeToAdAvailability() {
    final adsService = _adsService;
    if (adsService == null) return;

    _isAdsEnabled = adsService.isEnabled;
    _adAvailabilitySubscription?.cancel();
    _adAvailabilitySubscription =
        adsService.onAdAvailabilityChanged.listen((available) {
      if (mounted) {
        setState(() {
          _isAdsEnabled = adsService.isEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _adAvailabilitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsService = _adsService;

    // Don't reserve space if no ads service or ads are disabled
    if (adsService == null || !_isAdsEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: widget.child,
    );
  }
}
