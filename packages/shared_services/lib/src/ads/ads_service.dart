import 'dart:async';

import '../resources/providers/ad_reward_provider.dart';

/// Configuration for the ads service.
class AdsConfig {
  /// Creates an [AdsConfig].
  const AdsConfig({
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    this.testDeviceIds = const [],
    this.requestNonPersonalizedAdsOnly = false,
  });

  /// Creates a test configuration with AdMob test ad unit IDs.
  ///
  /// Use this for development and testing. These are official Google test IDs
  /// that always return test ads.
  factory AdsConfig.test() => const AdsConfig(
        bannerAdUnitId: 'ca-app-pub-3940256099942544/6300978111',
        interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
        rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',
      );

  /// Banner ad unit ID.
  final String bannerAdUnitId;

  /// Interstitial ad unit ID.
  final String interstitialAdUnitId;

  /// Rewarded ad unit ID.
  final String rewardedAdUnitId;

  /// List of test device IDs for receiving test ads in development.
  final List<String> testDeviceIds;

  /// Whether to request only non-personalized ads (for GDPR compliance).
  final bool requestNonPersonalizedAdsOnly;
}

/// Result of showing an ad.
sealed class AdResult {
  const AdResult._();

  /// Ad was shown and completed successfully.
  factory AdResult.completed({
    Duration? watchDuration,
    AdReward? reward,
  }) = AdResultCompleted;

  /// Ad was dismissed before completion.
  factory AdResult.dismissed({
    Duration? watchDuration,
  }) = AdResultDismissed;

  /// Ad failed to load or show.
  factory AdResult.failed({
    required String errorCode,
    required String errorMessage,
    required AdFailureStage stage,
  }) = AdResultFailed;

  /// Ad was not available (not loaded).
  factory AdResult.notAvailable() = AdResultNotAvailable;
}

/// Ad completed successfully.
final class AdResultCompleted extends AdResult {
  const AdResultCompleted({this.watchDuration, this.reward}) : super._();

  /// How long the user watched the ad.
  final Duration? watchDuration;

  /// Reward earned from rewarded ad.
  final AdReward? reward;
}

/// Ad was dismissed before completion.
final class AdResultDismissed extends AdResult {
  const AdResultDismissed({this.watchDuration}) : super._();

  /// How long the user watched before dismissing.
  final Duration? watchDuration;
}

/// Ad failed to load or show.
final class AdResultFailed extends AdResult {
  const AdResultFailed({
    required this.errorCode,
    required this.errorMessage,
    required this.stage,
  }) : super._();

  /// Error code from the ad SDK.
  final String errorCode;

  /// Human-readable error message.
  final String errorMessage;

  /// Stage at which the failure occurred.
  final AdFailureStage stage;
}

/// Ad was not available.
final class AdResultNotAvailable extends AdResult {
  const AdResultNotAvailable() : super._();
}

/// Stage at which an ad failure occurred.
enum AdFailureStage {
  /// Failed during ad load.
  load,

  /// Failed when trying to show ad.
  show,
}

/// Reward earned from a rewarded ad.
class AdReward {
  const AdReward({
    required this.type,
    required this.amount,
  });

  /// Type of reward (e.g., "lives", "hints", "coins").
  final String type;

  /// Amount of reward.
  final int amount;
}

/// Type of ad placement in the app.
enum AdPlacement {
  /// Banner at the bottom of the screen.
  bannerBottom,

  /// Banner at the top of the screen.
  bannerTop,

  /// Interstitial shown after quiz completion.
  interstitialQuizComplete,

  /// Interstitial shown between levels.
  interstitialBetweenLevels,

  /// Rewarded ad for extra lives.
  rewardedLives,

  /// Rewarded ad for hints.
  rewardedHints,

  /// Rewarded ad for skip.
  rewardedSkip,
}

/// Extension to get string representation of [AdPlacement].
extension AdPlacementExtension on AdPlacement {
  /// Get the string ID for analytics.
  String get id {
    switch (this) {
      case AdPlacement.bannerBottom:
        return 'banner_bottom';
      case AdPlacement.bannerTop:
        return 'banner_top';
      case AdPlacement.interstitialQuizComplete:
        return 'interstitial_quiz_complete';
      case AdPlacement.interstitialBetweenLevels:
        return 'interstitial_between_levels';
      case AdPlacement.rewardedLives:
        return 'rewarded_lives';
      case AdPlacement.rewardedHints:
        return 'rewarded_hints';
      case AdPlacement.rewardedSkip:
        return 'rewarded_skip';
    }
  }

  /// Get the ad type for analytics.
  String get adType {
    switch (this) {
      case AdPlacement.bannerBottom:
      case AdPlacement.bannerTop:
        return 'banner';
      case AdPlacement.interstitialQuizComplete:
      case AdPlacement.interstitialBetweenLevels:
        return 'interstitial';
      case AdPlacement.rewardedLives:
      case AdPlacement.rewardedHints:
      case AdPlacement.rewardedSkip:
        return 'rewarded';
    }
  }
}

/// Abstract service for managing advertisements.
///
/// Provides a unified interface for:
/// - Banner ads (displayed inline in UI)
/// - Interstitial ads (full-screen, shown at transition points)
/// - Rewarded ads (user watches to earn rewards)
///
/// Implementations:
/// - [AdMobService] - Real AdMob integration for production
/// - [NoAdsService] - Stub for premium users or testing
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
/// // Show rewarded ad for lives
/// final result = await adsService.showRewardedAd(AdPlacement.rewardedLives);
/// if (result is AdResultCompleted) {
///   // Grant reward
/// }
/// ```
abstract class AdsService implements AdRewardProvider {
  /// Configuration for the ads service.
  AdsConfig get config;

  /// Whether the service has been initialized.
  bool get isInitialized;

  /// Whether ads are enabled.
  bool get isEnabled;

  /// Initialize the ads service.
  ///
  /// Must be called before using any other methods.
  /// Returns `true` if initialization was successful.
  Future<bool> initialize();

  // ============ Banner Ads ============

  /// Whether a banner ad is currently loaded and ready.
  bool get isBannerAdLoaded;

  /// Load a banner ad.
  ///
  /// Call this before trying to display a banner.
  Future<bool> loadBannerAd();

  /// Dispose the current banner ad.
  ///
  /// Call this when the banner is no longer needed.
  void disposeBannerAd();

  /// Get a widget to display the banner ad.
  ///
  /// Returns `null` if no banner is loaded.
  /// The returned widget should be placed in your widget tree.
  Object? getBannerAdWidget();

  // ============ Interstitial Ads ============

  /// Whether an interstitial ad is currently loaded and ready.
  bool get isInterstitialAdLoaded;

  /// Load an interstitial ad.
  ///
  /// Call this proactively so ads are ready when needed.
  Future<bool> loadInterstitialAd();

  /// Show the loaded interstitial ad.
  ///
  /// Returns the result of showing the ad.
  /// Automatically loads the next interstitial after showing.
  Future<AdResult> showInterstitialAd(AdPlacement placement);

  // ============ Rewarded Ads ============

  /// Whether a rewarded ad is currently loaded and ready.
  bool get isRewardedAdLoaded;

  /// Load a rewarded ad.
  ///
  /// Call this proactively so ads are ready when needed.
  Future<bool> loadRewardedAd();

  /// Show the loaded rewarded ad.
  ///
  /// Returns the result including any reward earned.
  /// Automatically loads the next rewarded ad after showing.
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement);

  // ============ Premium/Ad-Free ============

  /// Disable all ads (e.g., after premium purchase).
  ///
  /// This will dispose all loaded ads and prevent new ones from loading.
  void disableAds();

  /// Re-enable ads (e.g., if premium subscription expires).
  void enableAds();

  // ============ Events ============

  /// Stream of ad events for analytics tracking.
  Stream<AdEvent> get onAdEvent;

  // ============ Lifecycle ============

  /// Dispose the service and all loaded ads.
  void dispose();
}

/// Events emitted by the ads service.
sealed class AdEvent {
  const AdEvent._();

  factory AdEvent.loaded({
    required String adType,
    required AdPlacement placement,
  }) = AdEventLoaded;

  factory AdEvent.failedToLoad({
    required String adType,
    required AdPlacement placement,
    required String errorCode,
    required String errorMessage,
  }) = AdEventFailedToLoad;

  factory AdEvent.shown({
    required String adType,
    required AdPlacement placement,
  }) = AdEventShown;

  factory AdEvent.clicked({
    required String adType,
    required AdPlacement placement,
  }) = AdEventClicked;

  factory AdEvent.dismissed({
    required String adType,
    required AdPlacement placement,
    Duration? watchDuration,
  }) = AdEventDismissed;

  factory AdEvent.completed({
    required String adType,
    required AdPlacement placement,
    Duration? watchDuration,
    AdReward? reward,
  }) = AdEventCompleted;

  factory AdEvent.impression({
    required String adType,
    required AdPlacement placement,
  }) = AdEventImpression;
}

final class AdEventLoaded extends AdEvent {
  const AdEventLoaded({
    required this.adType,
    required this.placement,
  }) : super._();

  final String adType;
  final AdPlacement placement;
}

final class AdEventFailedToLoad extends AdEvent {
  const AdEventFailedToLoad({
    required this.adType,
    required this.placement,
    required this.errorCode,
    required this.errorMessage,
  }) : super._();

  final String adType;
  final AdPlacement placement;
  final String errorCode;
  final String errorMessage;
}

final class AdEventShown extends AdEvent {
  const AdEventShown({
    required this.adType,
    required this.placement,
  }) : super._();

  final String adType;
  final AdPlacement placement;
}

final class AdEventClicked extends AdEvent {
  const AdEventClicked({
    required this.adType,
    required this.placement,
  }) : super._();

  final String adType;
  final AdPlacement placement;
}

final class AdEventDismissed extends AdEvent {
  const AdEventDismissed({
    required this.adType,
    required this.placement,
    this.watchDuration,
  }) : super._();

  final String adType;
  final AdPlacement placement;
  final Duration? watchDuration;
}

final class AdEventCompleted extends AdEvent {
  const AdEventCompleted({
    required this.adType,
    required this.placement,
    this.watchDuration,
    this.reward,
  }) : super._();

  final String adType;
  final AdPlacement placement;
  final Duration? watchDuration;
  final AdReward? reward;
}

final class AdEventImpression extends AdEvent {
  const AdEventImpression({
    required this.adType,
    required this.placement,
  }) : super._();

  final String adType;
  final AdPlacement placement;
}
