/// Ads service exports.
///
/// Provides ad integration for quiz apps using Google AdMob.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:shared_services/shared_services.dart';
///
/// // Create service
/// final adsService = AdMobService(
///   config: AdsConfig(
///     bannerAdUnitId: 'ca-app-pub-xxx/banner',
///     interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
///     rewardedAdUnitId: 'ca-app-pub-xxx/rewarded',
///   ),
/// );
///
/// // Initialize
/// await adsService.initialize();
///
/// // Show rewarded ad
/// final result = await adsService.showRewardedAdWithPlacement(
///   AdPlacement.rewardedLives,
/// );
///
/// if (result is AdResultCompleted) {
///   // Grant reward
/// }
/// ```
///
/// ## Testing
///
/// Use [AdsConfig.test()] for development with Google's test ad IDs:
///
/// ```dart
/// final adsService = AdMobService(config: AdsConfig.test());
/// ```
///
/// ## Premium Users
///
/// Use [NoAdsService] for premium users who have removed ads:
///
/// ```dart
/// final adsService = isPremiumUser
///   ? NoAdsService()
///   : AdMobService(config: config);
/// ```
library;

export 'ads_service.dart';
export 'admob_service.dart';
export 'no_ads_service.dart';
export 'admob_reward_provider.dart';
export 'analytics_ads_service.dart';
