import 'dart:async';

import 'ads_service.dart';

/// No-op implementation of [AdsService] for premium users or testing.
///
/// This service:
/// - Returns `false` for all ad availability checks
/// - Returns [AdResultNotAvailable] for all show methods
/// - Does nothing for load/dispose methods
///
/// Use this when:
/// - User has purchased premium/ad-free
/// - Running in test environment
/// - Ads are disabled by configuration
///
/// Example usage:
/// ```dart
/// final adsService = isPremiumUser
///   ? NoAdsService()
///   : AdMobService(config: config);
/// ```
class NoAdsService implements AdsService {
  /// Creates a [NoAdsService].
  NoAdsService({
    AdsConfig? config,
  }) : _config = config ?? AdsConfig.test();

  final AdsConfig _config;
  bool _isInitialized = false;

  final _adEventController = StreamController<AdEvent>.broadcast();
  final _adAvailabilityController = StreamController<bool>.broadcast();

  @override
  AdsConfig get config => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isEnabled => false;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  // ============ Banner Ads ============

  @override
  bool get isBannerAdLoaded => false;

  @override
  Future<bool> loadBannerAd() async => false;

  @override
  void disposeBannerAd() {}

  @override
  Object? getBannerAdWidget() => null;

  // ============ Interstitial Ads ============

  @override
  bool get isInterstitialAdLoaded => false;

  @override
  Future<bool> loadInterstitialAd() async => false;

  @override
  Future<AdResult> showInterstitialAd(AdPlacement placement) async {
    return AdResult.notAvailable();
  }

  // ============ Rewarded Ads ============

  @override
  bool get isRewardedAdLoaded => false;

  @override
  Future<bool> loadRewardedAd() async => false;

  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) async {
    return AdResult.notAvailable();
  }

  // ============ AdRewardProvider Implementation ============

  @override
  bool get isAdAvailable => false;

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  Stream<bool> get onAdAvailabilityChanged => _adAvailabilityController.stream;

  // ============ Premium/Ad-Free ============

  @override
  void disableAds() {}

  @override
  void enableAds() {}

  // ============ Events ============

  @override
  Stream<AdEvent> get onAdEvent => _adEventController.stream;

  // ============ Lifecycle ============

  @override
  void dispose() {
    _adEventController.close();
    _adAvailabilityController.close();
  }
}
