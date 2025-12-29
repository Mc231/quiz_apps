import 'dart:async';

import '../analytics/analytics_service.dart';
import '../analytics/events/monetization_event.dart';
import 'ads_service.dart';

/// Wrapper that adds analytics tracking to any [AdsService].
///
/// Listens to ad events and logs them to the analytics service.
///
/// Example usage:
/// ```dart
/// final adsService = AdMobService(config: config);
/// final analyticsAdsService = AnalyticsAdsService(
///   adsService: adsService,
///   analyticsService: analyticsService,
/// );
///
/// await analyticsAdsService.initialize();
/// ```
class AnalyticsAdsService implements AdsService {
  /// Creates an [AnalyticsAdsService].
  AnalyticsAdsService({
    required AdsService adsService,
    required AnalyticsService analyticsService,
  })  : _adsService = adsService,
        _analyticsService = analyticsService {
    _setupEventTracking();
  }

  final AdsService _adsService;
  final AnalyticsService _analyticsService;
  StreamSubscription<AdEvent>? _eventSubscription;

  void _setupEventTracking() {
    _eventSubscription = _adsService.onAdEvent.listen(_handleAdEvent);
  }

  void _handleAdEvent(AdEvent event) {
    switch (event) {
      case AdEventCompleted(
          :final adType,
          :final placement,
          :final watchDuration,
          :final reward
        ):
        _analyticsService.logEvent(
          MonetizationEvent.adWatched(
            adType: adType,
            adPlacement: placement.id,
            watchDuration: watchDuration ?? Duration.zero,
            wasCompleted: true,
            rewardType: reward?.type,
            rewardAmount: reward?.amount,
          ),
        );

      case AdEventDismissed(
          :final adType,
          :final placement,
          :final watchDuration
        ):
        _analyticsService.logEvent(
          MonetizationEvent.adWatched(
            adType: adType,
            adPlacement: placement.id,
            watchDuration: watchDuration ?? Duration.zero,
            wasCompleted: false,
          ),
        );

      case AdEventFailedToLoad(
          :final adType,
          :final placement,
          :final errorCode,
          :final errorMessage
        ):
        _analyticsService.logEvent(
          MonetizationEvent.adFailed(
            adType: adType,
            adPlacement: placement.id,
            errorCode: errorCode,
            errorMessage: errorMessage,
            failureStage: 'load',
          ),
        );

      case AdEventLoaded():
      case AdEventShown():
      case AdEventClicked():
      case AdEventImpression():
        // These events are not tracked in MonetizationEvent
        // Could add custom logging if needed
        break;
    }
  }

  // ============ Delegate all methods to wrapped service ============

  @override
  AdsConfig get config => _adsService.config;

  @override
  bool get isInitialized => _adsService.isInitialized;

  @override
  bool get isEnabled => _adsService.isEnabled;

  @override
  Future<bool> initialize() => _adsService.initialize();

  // Banner Ads
  @override
  bool get isBannerAdLoaded => _adsService.isBannerAdLoaded;

  @override
  Future<bool> loadBannerAd() => _adsService.loadBannerAd();

  @override
  void disposeBannerAd() => _adsService.disposeBannerAd();

  @override
  Object? getBannerAdWidget() => _adsService.getBannerAdWidget();

  // Interstitial Ads
  @override
  bool get isInterstitialAdLoaded => _adsService.isInterstitialAdLoaded;

  @override
  Future<bool> loadInterstitialAd() => _adsService.loadInterstitialAd();

  @override
  Future<AdResult> showInterstitialAd(AdPlacement placement) =>
      _adsService.showInterstitialAd(placement);

  // Rewarded Ads
  @override
  bool get isRewardedAdLoaded => _adsService.isRewardedAdLoaded;

  @override
  Future<bool> loadRewardedAd() => _adsService.loadRewardedAd();

  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) =>
      _adsService.showRewardedAdWithPlacement(placement);

  // AdRewardProvider
  @override
  bool get isAdAvailable => _adsService.isAdAvailable;

  @override
  Future<bool> showRewardedAd() => _adsService.showRewardedAd();

  @override
  Stream<bool> get onAdAvailabilityChanged =>
      _adsService.onAdAvailabilityChanged;

  // Premium/Ad-Free
  @override
  void disableAds() => _adsService.disableAds();

  @override
  void enableAds() => _adsService.enableAds();

  // Events
  @override
  Stream<AdEvent> get onAdEvent => _adsService.onAdEvent;

  // Lifecycle
  @override
  void dispose() {
    _eventSubscription?.cancel();
    _adsService.dispose();
  }
}
