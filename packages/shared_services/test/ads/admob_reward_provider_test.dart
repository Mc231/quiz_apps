import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock AdsService for testing AdMobRewardProvider.
class MockAdsService implements AdsService {
  bool _isRewardedAdLoaded = false;
  bool _rewardedAdResult = false;
  final _availabilityController = StreamController<bool>.broadcast();

  void setRewardedAdLoaded(bool value) {
    _isRewardedAdLoaded = value;
  }

  void setRewardedAdResult(bool value) {
    _rewardedAdResult = value;
  }

  void emitAvailabilityChange(bool available) {
    _availabilityController.add(available);
  }

  @override
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) async {
    if (_rewardedAdResult) {
      return AdResult.completed(
        watchDuration: const Duration(seconds: 30),
        reward: const AdReward(type: 'lives', amount: 1),
      );
    }
    return AdResult.dismissed();
  }

  @override
  Stream<bool> get onAdAvailabilityChanged => _availabilityController.stream;

  // Unused methods for this test
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
  Future<bool> loadRewardedAd() async => true;
  @override
  bool get isAdAvailable => isRewardedAdLoaded;
  @override
  Future<bool> showRewardedAd() async => _rewardedAdResult;
  @override
  void disableAds() {}
  @override
  void enableAds() {}
  @override
  Stream<AdEvent> get onAdEvent => const Stream.empty();
  @override
  void dispose() {
    _availabilityController.close();
  }
}

void main() {
  group('AdMobRewardProvider', () {
    late MockAdsService mockAdsService;
    late AdMobRewardProvider provider;

    setUp(() {
      mockAdsService = MockAdsService();
      provider = AdMobRewardProvider(mockAdsService);
    });

    tearDown(() {
      mockAdsService.dispose();
    });

    group('isAdAvailable', () {
      test('returns false when rewarded ad is not loaded', () {
        mockAdsService.setRewardedAdLoaded(false);
        expect(provider.isAdAvailable, isFalse);
      });

      test('returns true when rewarded ad is loaded', () {
        mockAdsService.setRewardedAdLoaded(true);
        expect(provider.isAdAvailable, isTrue);
      });
    });

    group('showRewardedAd', () {
      test('returns true when ad completes successfully', () async {
        mockAdsService.setRewardedAdResult(true);
        final result = await provider.showRewardedAd();
        expect(result, isTrue);
      });

      test('returns false when ad is dismissed', () async {
        mockAdsService.setRewardedAdResult(false);
        final result = await provider.showRewardedAd();
        expect(result, isFalse);
      });
    });

    group('onAdAvailabilityChanged', () {
      test('emits availability changes from ads service', () async {
        final emissions = <bool>[];
        final subscription = provider.onAdAvailabilityChanged.listen(
          emissions.add,
        );

        mockAdsService.emitAvailabilityChange(true);
        mockAdsService.emitAvailabilityChange(false);
        mockAdsService.emitAvailabilityChange(true);

        await Future<void>.delayed(Duration.zero);

        expect(emissions, [true, false, true]);
        await subscription.cancel();
      });
    });
  });
}
