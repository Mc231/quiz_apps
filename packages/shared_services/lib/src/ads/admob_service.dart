import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';

/// AdMob implementation of [AdsService].
///
/// Provides real ad integration using Google Mobile Ads SDK.
///
/// Example usage:
/// ```dart
/// final adsService = AdMobService(
///   config: AdsConfig(
///     bannerAdUnitId: 'ca-app-pub-xxx/banner',
///     interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
///     rewardedAdUnitId: 'ca-app-pub-xxx/rewarded',
///   ),
/// );
///
/// await adsService.initialize();
///
/// // Load ads proactively
/// await adsService.loadRewardedAd();
///
/// // Show when ready
/// if (adsService.isRewardedAdLoaded) {
///   final result = await adsService.showRewardedAdWithPlacement(
///     AdPlacement.rewardedLives,
///   );
/// }
/// ```
class AdMobService implements AdsService {
  /// Creates an [AdMobService] with the given configuration.
  AdMobService({
    required AdsConfig config,
  }) : _config = config;

  final AdsConfig _config;
  bool _isInitialized = false;
  bool _isEnabled = true;

  // Banner ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Interstitial ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  // Rewarded ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  // Event streams
  final _adEventController = StreamController<AdEvent>.broadcast();
  final _adAvailabilityController = StreamController<bool>.broadcast();

  @override
  AdsConfig get config => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await MobileAds.instance.initialize();

      // Configure test devices
      if (_config.testDeviceIds.isNotEmpty) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: _config.testDeviceIds),
        );
      }

      _isInitialized = true;

      // Pre-load ads
      if (_isEnabled) {
        unawaited(loadInterstitialAd());
        unawaited(loadRewardedAd());
      }

      return true;
    } catch (e) {
      debugPrint('AdMobService: Failed to initialize: $e');
      return false;
    }
  }

  AdRequest _createAdRequest() {
    return AdRequest(
      nonPersonalizedAds: _config.requestNonPersonalizedAdsOnly,
    );
  }

  // ============ Banner Ads ============

  @override
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  @override
  Future<bool> loadBannerAd() async {
    if (!_isInitialized || !_isEnabled) return false;
    if (_isBannerAdLoaded) return true;

    final completer = Completer<bool>();

    _bannerAd = BannerAd(
      adUnitId: _config.bannerAdUnitId,
      size: AdSize.banner,
      request: _createAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          _adEventController.add(AdEvent.loaded(
            adType: 'banner',
            placement: AdPlacement.bannerBottom,
          ));
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          _adEventController.add(AdEvent.failedToLoad(
            adType: 'banner',
            placement: AdPlacement.bannerBottom,
            errorCode: error.code.toString(),
            errorMessage: error.message,
          ));
          if (!completer.isCompleted) completer.complete(false);
        },
        onAdOpened: (ad) {
          _adEventController.add(AdEvent.clicked(
            adType: 'banner',
            placement: AdPlacement.bannerBottom,
          ));
        },
        onAdImpression: (ad) {
          _adEventController.add(AdEvent.impression(
            adType: 'banner',
            placement: AdPlacement.bannerBottom,
          ));
        },
      ),
    );

    await _bannerAd!.load();
    return completer.future;
  }

  @override
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  @override
  Object? getBannerAdWidget() {
    if (!_isBannerAdLoaded || _bannerAd == null) return null;
    return _bannerAd;
  }

  // ============ Interstitial Ads ============

  @override
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  @override
  Future<bool> loadInterstitialAd() async {
    if (!_isInitialized || !_isEnabled) return false;
    if (_isInterstitialAdLoaded) return true;

    final completer = Completer<bool>();

    await InterstitialAd.load(
      adUnitId: _config.interstitialAdUnitId,
      request: _createAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _adEventController.add(AdEvent.loaded(
            adType: 'interstitial',
            placement: AdPlacement.interstitialQuizComplete,
          ));
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          _adEventController.add(AdEvent.failedToLoad(
            adType: 'interstitial',
            placement: AdPlacement.interstitialQuizComplete,
            errorCode: error.code.toString(),
            errorMessage: error.message,
          ));
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  @override
  Future<AdResult> showInterstitialAd(AdPlacement placement) async {
    if (!_isInitialized || !_isEnabled) {
      return AdResult.notAvailable();
    }

    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      return AdResult.notAvailable();
    }

    final completer = Completer<AdResult>();
    final startTime = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _adEventController.add(AdEvent.shown(
          adType: 'interstitial',
          placement: placement,
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        final duration = DateTime.now().difference(startTime);
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;

        _adEventController.add(AdEvent.completed(
          adType: 'interstitial',
          placement: placement,
          watchDuration: duration,
        ));

        if (!completer.isCompleted) {
          completer.complete(AdResult.completed(watchDuration: duration));
        }

        // Preload next ad
        unawaited(loadInterstitialAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;

        if (!completer.isCompleted) {
          completer.complete(AdResult.failed(
            errorCode: error.code.toString(),
            errorMessage: error.message,
            stage: AdFailureStage.show,
          ));
        }

        // Preload next ad
        unawaited(loadInterstitialAd());
      },
      onAdImpression: (ad) {
        _adEventController.add(AdEvent.impression(
          adType: 'interstitial',
          placement: placement,
        ));
      },
      onAdClicked: (ad) {
        _adEventController.add(AdEvent.clicked(
          adType: 'interstitial',
          placement: placement,
        ));
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  // ============ Rewarded Ads ============

  @override
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  @override
  Future<bool> loadRewardedAd() async {
    if (!_isInitialized || !_isEnabled) return false;
    if (_isRewardedAdLoaded) return true;

    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: _config.rewardedAdUnitId,
      request: _createAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          _adAvailabilityController.add(true);
          _adEventController.add(AdEvent.loaded(
            adType: 'rewarded',
            placement: AdPlacement.rewardedLives,
          ));
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _adAvailabilityController.add(false);
          _adEventController.add(AdEvent.failedToLoad(
            adType: 'rewarded',
            placement: AdPlacement.rewardedLives,
            errorCode: error.code.toString(),
            errorMessage: error.message,
          ));
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) async {
    if (!_isInitialized || !_isEnabled) {
      return AdResult.notAvailable();
    }

    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      return AdResult.notAvailable();
    }

    final completer = Completer<AdResult>();
    final startTime = DateTime.now();
    AdReward? earnedReward;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _adEventController.add(AdEvent.shown(
          adType: 'rewarded',
          placement: placement,
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        final duration = DateTime.now().difference(startTime);
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _adAvailabilityController.add(false);

        if (earnedReward != null) {
          _adEventController.add(AdEvent.completed(
            adType: 'rewarded',
            placement: placement,
            watchDuration: duration,
            reward: earnedReward,
          ));

          if (!completer.isCompleted) {
            completer.complete(AdResult.completed(
              watchDuration: duration,
              reward: earnedReward,
            ));
          }
        } else {
          _adEventController.add(AdEvent.dismissed(
            adType: 'rewarded',
            placement: placement,
            watchDuration: duration,
          ));

          if (!completer.isCompleted) {
            completer.complete(AdResult.dismissed(watchDuration: duration));
          }
        }

        // Preload next ad
        unawaited(loadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _adAvailabilityController.add(false);

        if (!completer.isCompleted) {
          completer.complete(AdResult.failed(
            errorCode: error.code.toString(),
            errorMessage: error.message,
            stage: AdFailureStage.show,
          ));
        }

        // Preload next ad
        unawaited(loadRewardedAd());
      },
      onAdImpression: (ad) {
        _adEventController.add(AdEvent.impression(
          adType: 'rewarded',
          placement: placement,
        ));
      },
      onAdClicked: (ad) {
        _adEventController.add(AdEvent.clicked(
          adType: 'rewarded',
          placement: placement,
        ));
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = AdReward(
          type: reward.type,
          amount: reward.amount.toInt(),
        );
      },
    );

    return completer.future;
  }

  // ============ AdRewardProvider Implementation ============

  @override
  bool get isAdAvailable => _isRewardedAdLoaded;

  @override
  Future<bool> showRewardedAd() async {
    final result = await showRewardedAdWithPlacement(AdPlacement.rewardedLives);
    return result is AdResultCompleted;
  }

  @override
  Stream<bool> get onAdAvailabilityChanged => _adAvailabilityController.stream;

  // ============ Premium/Ad-Free ============

  @override
  void disableAds() {
    _isEnabled = false;
    disposeBannerAd();

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;

    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoaded = false;
    _adAvailabilityController.add(false);
  }

  @override
  void enableAds() {
    _isEnabled = true;
    if (_isInitialized) {
      unawaited(loadInterstitialAd());
      unawaited(loadRewardedAd());
    }
  }

  // ============ Events ============

  @override
  Stream<AdEvent> get onAdEvent => _adEventController.stream;

  // ============ Lifecycle ============

  @override
  void dispose() {
    disposeBannerAd();

    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;

    _adEventController.close();
    _adAvailabilityController.close();
  }
}
