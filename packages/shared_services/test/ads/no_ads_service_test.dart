import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('NoAdsService', () {
    late NoAdsService service;

    setUp(() {
      service = NoAdsService();
    });

    tearDown(() {
      service.dispose();
    });

    group('initialization', () {
      test('initializes successfully', () async {
        final result = await service.initialize();
        expect(result, isTrue);
        expect(service.isInitialized, isTrue);
      });

      test('isEnabled returns false', () {
        expect(service.isEnabled, isFalse);
      });

      test('config returns test config when none provided', () {
        expect(service.config, isA<AdsConfig>());
      });

      test('config returns provided config', () {
        final customConfig = AdsConfig(
          bannerAdUnitId: 'custom-banner',
          interstitialAdUnitId: 'custom-interstitial',
          rewardedAdUnitId: 'custom-rewarded',
        );
        final customService = NoAdsService(config: customConfig);
        expect(customService.config.bannerAdUnitId, 'custom-banner');
        customService.dispose();
      });
    });

    group('banner ads', () {
      test('isBannerAdLoaded returns false', () {
        expect(service.isBannerAdLoaded, isFalse);
      });

      test('loadBannerAd returns false', () async {
        final result = await service.loadBannerAd();
        expect(result, isFalse);
      });

      test('getBannerAdWidget returns null', () {
        expect(service.getBannerAdWidget(), isNull);
      });

      test('disposeBannerAd does nothing', () {
        expect(() => service.disposeBannerAd(), returnsNormally);
      });
    });

    group('interstitial ads', () {
      test('isInterstitialAdLoaded returns false', () {
        expect(service.isInterstitialAdLoaded, isFalse);
      });

      test('loadInterstitialAd returns false', () async {
        final result = await service.loadInterstitialAd();
        expect(result, isFalse);
      });

      test('showInterstitialAd returns notAvailable', () async {
        final result = await service.showInterstitialAd(
          AdPlacement.interstitialQuizComplete,
        );
        expect(result, isA<AdResultNotAvailable>());
      });
    });

    group('rewarded ads', () {
      test('isRewardedAdLoaded returns false', () {
        expect(service.isRewardedAdLoaded, isFalse);
      });

      test('loadRewardedAd returns false', () async {
        final result = await service.loadRewardedAd();
        expect(result, isFalse);
      });

      test('showRewardedAdWithPlacement returns notAvailable', () async {
        final result = await service.showRewardedAdWithPlacement(
          AdPlacement.rewardedLives,
        );
        expect(result, isA<AdResultNotAvailable>());
      });
    });

    group('AdRewardProvider implementation', () {
      test('isAdAvailable returns false', () {
        expect(service.isAdAvailable, isFalse);
      });

      test('showRewardedAd returns false', () async {
        final result = await service.showRewardedAd();
        expect(result, isFalse);
      });

      test('onAdAvailabilityChanged is a broadcast stream', () {
        expect(service.onAdAvailabilityChanged.isBroadcast, isTrue);
      });
    });

    group('premium controls', () {
      test('disableAds does nothing', () {
        expect(() => service.disableAds(), returnsNormally);
      });

      test('enableAds does nothing', () {
        expect(() => service.enableAds(), returnsNormally);
      });
    });

    group('events', () {
      test('onAdEvent is a broadcast stream', () {
        expect(service.onAdEvent.isBroadcast, isTrue);
      });
    });
  });

  group('AdsConfig', () {
    test('creates with required parameters', () {
      final config = AdsConfig(
        bannerAdUnitId: 'banner-id',
        interstitialAdUnitId: 'interstitial-id',
        rewardedAdUnitId: 'rewarded-id',
      );

      expect(config.bannerAdUnitId, 'banner-id');
      expect(config.interstitialAdUnitId, 'interstitial-id');
      expect(config.rewardedAdUnitId, 'rewarded-id');
      expect(config.testDeviceIds, isEmpty);
      expect(config.requestNonPersonalizedAdsOnly, isFalse);
    });

    test('creates with optional parameters', () {
      final config = AdsConfig(
        bannerAdUnitId: 'banner-id',
        interstitialAdUnitId: 'interstitial-id',
        rewardedAdUnitId: 'rewarded-id',
        testDeviceIds: ['device-1', 'device-2'],
        requestNonPersonalizedAdsOnly: true,
      );

      expect(config.testDeviceIds, ['device-1', 'device-2']);
      expect(config.requestNonPersonalizedAdsOnly, isTrue);
    });

    test('test factory creates valid test config', () {
      final config = AdsConfig.test();

      expect(config.bannerAdUnitId, isNotEmpty);
      expect(config.interstitialAdUnitId, isNotEmpty);
      expect(config.rewardedAdUnitId, isNotEmpty);
      // Test IDs should start with 'ca-app-pub-3940256099942544'
      expect(
        config.bannerAdUnitId.startsWith('ca-app-pub-3940256099942544'),
        isTrue,
      );
    });
  });

  group('AdResult', () {
    test('completed factory creates AdResultCompleted', () {
      final result = AdResult.completed(
        watchDuration: const Duration(seconds: 30),
        reward: const AdReward(type: 'lives', amount: 1),
      );

      expect(result, isA<AdResultCompleted>());
      final completed = result as AdResultCompleted;
      expect(completed.watchDuration, const Duration(seconds: 30));
      expect(completed.reward?.type, 'lives');
      expect(completed.reward?.amount, 1);
    });

    test('dismissed factory creates AdResultDismissed', () {
      final result = AdResult.dismissed(
        watchDuration: const Duration(seconds: 10),
      );

      expect(result, isA<AdResultDismissed>());
      final dismissed = result as AdResultDismissed;
      expect(dismissed.watchDuration, const Duration(seconds: 10));
    });

    test('failed factory creates AdResultFailed', () {
      final result = AdResult.failed(
        errorCode: 'ERROR_001',
        errorMessage: 'Ad failed to load',
        stage: AdFailureStage.load,
      );

      expect(result, isA<AdResultFailed>());
      final failed = result as AdResultFailed;
      expect(failed.errorCode, 'ERROR_001');
      expect(failed.errorMessage, 'Ad failed to load');
      expect(failed.stage, AdFailureStage.load);
    });

    test('notAvailable factory creates AdResultNotAvailable', () {
      final result = AdResult.notAvailable();
      expect(result, isA<AdResultNotAvailable>());
    });
  });

  group('AdPlacement', () {
    test('id returns correct string for each placement', () {
      expect(AdPlacement.bannerBottom.id, 'banner_bottom');
      expect(AdPlacement.bannerTop.id, 'banner_top');
      expect(AdPlacement.interstitialQuizComplete.id, 'interstitial_quiz_complete');
      expect(AdPlacement.interstitialBetweenLevels.id, 'interstitial_between_levels');
      expect(AdPlacement.rewardedLives.id, 'rewarded_lives');
      expect(AdPlacement.rewardedHints.id, 'rewarded_hints');
      expect(AdPlacement.rewardedSkip.id, 'rewarded_skip');
    });

    test('adType returns correct type for each placement', () {
      expect(AdPlacement.bannerBottom.adType, 'banner');
      expect(AdPlacement.bannerTop.adType, 'banner');
      expect(AdPlacement.interstitialQuizComplete.adType, 'interstitial');
      expect(AdPlacement.interstitialBetweenLevels.adType, 'interstitial');
      expect(AdPlacement.rewardedLives.adType, 'rewarded');
      expect(AdPlacement.rewardedHints.adType, 'rewarded');
      expect(AdPlacement.rewardedSkip.adType, 'rewarded');
    });
  });

  group('AdReward', () {
    test('creates with required parameters', () {
      const reward = AdReward(type: 'coins', amount: 100);

      expect(reward.type, 'coins');
      expect(reward.amount, 100);
    });
  });

  group('AdEvent', () {
    test('loaded factory creates AdEventLoaded', () {
      final event = AdEvent.loaded(
        adType: 'banner',
        placement: AdPlacement.bannerBottom,
      );

      expect(event, isA<AdEventLoaded>());
      final loaded = event as AdEventLoaded;
      expect(loaded.adType, 'banner');
      expect(loaded.placement, AdPlacement.bannerBottom);
    });

    test('failedToLoad factory creates AdEventFailedToLoad', () {
      final event = AdEvent.failedToLoad(
        adType: 'interstitial',
        placement: AdPlacement.interstitialQuizComplete,
        errorCode: '3',
        errorMessage: 'No fill',
      );

      expect(event, isA<AdEventFailedToLoad>());
      final failed = event as AdEventFailedToLoad;
      expect(failed.adType, 'interstitial');
      expect(failed.errorCode, '3');
    });

    test('shown factory creates AdEventShown', () {
      final event = AdEvent.shown(
        adType: 'rewarded',
        placement: AdPlacement.rewardedLives,
      );

      expect(event, isA<AdEventShown>());
    });

    test('clicked factory creates AdEventClicked', () {
      final event = AdEvent.clicked(
        adType: 'banner',
        placement: AdPlacement.bannerTop,
      );

      expect(event, isA<AdEventClicked>());
    });

    test('dismissed factory creates AdEventDismissed', () {
      final event = AdEvent.dismissed(
        adType: 'rewarded',
        placement: AdPlacement.rewardedHints,
        watchDuration: const Duration(seconds: 15),
      );

      expect(event, isA<AdEventDismissed>());
      final dismissed = event as AdEventDismissed;
      expect(dismissed.watchDuration, const Duration(seconds: 15));
    });

    test('completed factory creates AdEventCompleted', () {
      final event = AdEvent.completed(
        adType: 'rewarded',
        placement: AdPlacement.rewardedSkip,
        watchDuration: const Duration(seconds: 30),
        reward: const AdReward(type: 'skip', amount: 1),
      );

      expect(event, isA<AdEventCompleted>());
      final completed = event as AdEventCompleted;
      expect(completed.reward?.type, 'skip');
    });

    test('impression factory creates AdEventImpression', () {
      final event = AdEvent.impression(
        adType: 'banner',
        placement: AdPlacement.bannerBottom,
      );

      expect(event, isA<AdEventImpression>());
    });
  });
}
