import '../resources/providers/ad_reward_provider.dart';
import 'ads_service.dart';

/// Adapter that connects [AdsService] to the [AdRewardProvider] interface.
///
/// This allows using any [AdsService] implementation (e.g., [AdMobService])
/// with the [ResourceManager] which expects an [AdRewardProvider].
///
/// Example usage:
/// ```dart
/// final adsService = AdMobService(config: config);
/// await adsService.initialize();
///
/// final resourceManager = ResourceManager(
///   config: ResourceConfig.standard(),
///   adProvider: AdMobRewardProvider(adsService),
///   repository: repository,
/// );
/// ```
class AdMobRewardProvider implements AdRewardProvider {
  /// Creates an [AdMobRewardProvider] with the given [AdsService].
  AdMobRewardProvider(this._adsService);

  final AdsService _adsService;

  @override
  bool get isAdAvailable => _adsService.isRewardedAdLoaded;

  @override
  Future<bool> showRewardedAd() async {
    final result = await _adsService.showRewardedAdWithPlacement(
      AdPlacement.rewardedLives,
    );
    return result is AdResultCompleted;
  }

  @override
  Stream<bool> get onAdAvailabilityChanged => _adsService.onAdAvailabilityChanged;
}
