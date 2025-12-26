/// Interface for rewarded ad integration.
///
/// Implement this in your app when ready to show rewarded ads.
/// Pass to [ResourceManager] to enable "Watch Ad" option.
///
/// Example implementation with AdMob:
/// ```dart
/// class AdMobRewardProvider implements AdRewardProvider {
///   RewardedAd? _rewardedAd;
///
///   @override
///   bool get isAdAvailable => _rewardedAd != null;
///
///   @override
///   Future<bool> showRewardedAd() async {
///     if (_rewardedAd == null) return false;
///
///     final completer = Completer<bool>();
///     _rewardedAd!.show(
///       onUserEarnedReward: (ad, reward) {
///         completer.complete(true);
///       },
///     );
///     return completer.future;
///   }
///
///   @override
///   Stream<bool> get onAdAvailabilityChanged => _availabilityController.stream;
/// }
/// ```
abstract class AdRewardProvider {
  /// Whether a rewarded ad is currently available to show.
  bool get isAdAvailable;

  /// Show a rewarded ad.
  ///
  /// Returns `true` if the user watched the full ad and should receive reward.
  /// Returns `false` if ad was skipped, failed, or not available.
  Future<bool> showRewardedAd();

  /// Stream of ad availability changes.
  ///
  /// Useful for updating UI when ads become available/unavailable.
  Stream<bool> get onAdAvailabilityChanged;
}

/// Stub implementation when ads are not yet integrated.
///
/// Use this as a placeholder until your app integrates rewarded ads.
/// The "Watch Ad" option will be hidden when using this provider.
class NoAdsProvider implements AdRewardProvider {
  /// Creates a [NoAdsProvider].
  const NoAdsProvider();

  @override
  bool get isAdAvailable => false;

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  Stream<bool> get onAdAvailabilityChanged => Stream.value(false);
}
