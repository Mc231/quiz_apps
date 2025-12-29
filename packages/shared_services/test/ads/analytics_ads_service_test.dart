import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock AdsService for testing AnalyticsAdsService.
class MockAdsService implements AdsService {
  final _adEventController = StreamController<AdEvent>.broadcast();
  final _availabilityController = StreamController<bool>.broadcast();

  void emitAdEvent(AdEvent event) {
    _adEventController.add(event);
  }

  @override
  Stream<AdEvent> get onAdEvent => _adEventController.stream;

  @override
  Stream<bool> get onAdAvailabilityChanged => _availabilityController.stream;

  // Default implementations
  @override
  AdsConfig get config => AdsConfig.test();
  @override
  bool get isInitialized => true;
  @override
  bool get isEnabled => true;
  @override
  Future<bool> initialize() async => true;
  @override
  bool get isBannerAdLoaded => false;
  @override
  Future<bool> loadBannerAd() async => false;
  @override
  void disposeBannerAd() {}
  @override
  Object? getBannerAdWidget() => null;
  @override
  bool get isInterstitialAdLoaded => false;
  @override
  Future<bool> loadInterstitialAd() async => false;
  @override
  Future<AdResult> showInterstitialAd(AdPlacement placement) async =>
      AdResult.notAvailable();
  @override
  bool get isRewardedAdLoaded => false;
  @override
  Future<bool> loadRewardedAd() async => false;
  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) async =>
      AdResult.notAvailable();
  @override
  bool get isAdAvailable => false;
  @override
  Future<bool> showRewardedAd() async => false;
  @override
  void disableAds() {}
  @override
  void enableAds() {}
  @override
  void dispose() {
    _adEventController.close();
    _availabilityController.close();
  }
}

/// Mock AnalyticsService for testing.
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> loggedEvents = [];

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    loggedEvents.add(event);
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {}
  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}
  @override
  bool get isEnabled => true;
  @override
  Future<void> resetAnalyticsData() async {}
  @override
  void dispose() {}
}

void main() {
  group('AnalyticsAdsService', () {
    late MockAdsService mockAdsService;
    late MockAnalyticsService mockAnalyticsService;
    late AnalyticsAdsService service;

    setUp(() {
      mockAdsService = MockAdsService();
      mockAnalyticsService = MockAnalyticsService();
      service = AnalyticsAdsService(
        adsService: mockAdsService,
        analyticsService: mockAnalyticsService,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('event tracking', () {
      test('logs MonetizationEvent.adWatched on AdEventCompleted', () async {
        mockAdsService.emitAdEvent(AdEvent.completed(
          adType: 'rewarded',
          placement: AdPlacement.rewardedLives,
          watchDuration: const Duration(seconds: 30),
          reward: const AdReward(type: 'lives', amount: 1),
        ));

        // Allow stream to process
        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, hasLength(1));
        expect(mockAnalyticsService.loggedEvents.first, isA<AdWatchedEvent>());

        final event = mockAnalyticsService.loggedEvents.first as AdWatchedEvent;
        expect(event.adType, 'rewarded');
        expect(event.adPlacement, 'rewarded_lives');
        expect(event.wasCompleted, isTrue);
        expect(event.watchDuration, const Duration(seconds: 30));
        expect(event.rewardType, 'lives');
        expect(event.rewardAmount, 1);
      });

      test('logs MonetizationEvent.adWatched on AdEventDismissed', () async {
        mockAdsService.emitAdEvent(AdEvent.dismissed(
          adType: 'interstitial',
          placement: AdPlacement.interstitialQuizComplete,
          watchDuration: const Duration(seconds: 10),
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, hasLength(1));
        expect(mockAnalyticsService.loggedEvents.first, isA<AdWatchedEvent>());

        final event = mockAnalyticsService.loggedEvents.first as AdWatchedEvent;
        expect(event.adType, 'interstitial');
        expect(event.wasCompleted, isFalse);
        expect(event.watchDuration, const Duration(seconds: 10));
      });

      test('logs MonetizationEvent.adFailed on AdEventFailedToLoad', () async {
        mockAdsService.emitAdEvent(AdEvent.failedToLoad(
          adType: 'banner',
          placement: AdPlacement.bannerBottom,
          errorCode: '3',
          errorMessage: 'No fill',
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, hasLength(1));
        expect(mockAnalyticsService.loggedEvents.first, isA<AdFailedEvent>());

        final event = mockAnalyticsService.loggedEvents.first as AdFailedEvent;
        expect(event.adType, 'banner');
        expect(event.adPlacement, 'banner_bottom');
        expect(event.errorCode, '3');
        expect(event.errorMessage, 'No fill');
        expect(event.failureStage, 'load');
      });

      test('does not log for AdEventLoaded', () async {
        mockAdsService.emitAdEvent(AdEvent.loaded(
          adType: 'banner',
          placement: AdPlacement.bannerBottom,
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, isEmpty);
      });

      test('does not log for AdEventShown', () async {
        mockAdsService.emitAdEvent(AdEvent.shown(
          adType: 'rewarded',
          placement: AdPlacement.rewardedLives,
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, isEmpty);
      });

      test('does not log for AdEventClicked', () async {
        mockAdsService.emitAdEvent(AdEvent.clicked(
          adType: 'banner',
          placement: AdPlacement.bannerTop,
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, isEmpty);
      });

      test('does not log for AdEventImpression', () async {
        mockAdsService.emitAdEvent(AdEvent.impression(
          adType: 'banner',
          placement: AdPlacement.bannerBottom,
        ));

        await Future<void>.delayed(Duration.zero);

        expect(mockAnalyticsService.loggedEvents, isEmpty);
      });
    });

    group('delegation', () {
      test('delegates config to wrapped service', () {
        expect(service.config, mockAdsService.config);
      });

      test('delegates isInitialized to wrapped service', () {
        expect(service.isInitialized, mockAdsService.isInitialized);
      });

      test('delegates isEnabled to wrapped service', () {
        expect(service.isEnabled, mockAdsService.isEnabled);
      });

      test('delegates initialize to wrapped service', () async {
        final result = await service.initialize();
        expect(result, isTrue);
      });

      test('delegates isBannerAdLoaded to wrapped service', () {
        expect(service.isBannerAdLoaded, mockAdsService.isBannerAdLoaded);
      });

      test('delegates isInterstitialAdLoaded to wrapped service', () {
        expect(
          service.isInterstitialAdLoaded,
          mockAdsService.isInterstitialAdLoaded,
        );
      });

      test('delegates isRewardedAdLoaded to wrapped service', () {
        expect(service.isRewardedAdLoaded, mockAdsService.isRewardedAdLoaded);
      });

      test('delegates isAdAvailable to wrapped service', () {
        expect(service.isAdAvailable, mockAdsService.isAdAvailable);
      });
    });
  });
}
