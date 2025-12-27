/// Event classes for the Achievements BLoC.
library;

import 'package:shared_services/shared_services.dart' show AchievementTier;

import '../../achievements/widgets/achievements_list.dart';

/// Sealed class representing all possible events for achievements screen.
sealed class AchievementsEvent {
  /// Creates an [AchievementsEvent].
  const AchievementsEvent();

  /// Creates a load event to initialize achievements.
  factory AchievementsEvent.load() = LoadAchievements;

  /// Creates an event to refresh achievements data.
  factory AchievementsEvent.refresh() = RefreshAchievements;

  /// Creates an event to change the filter.
  factory AchievementsEvent.changeFilter(AchievementFilter filter) =
      AchievementsChangeFilter;

  /// Creates an event to change the tier filter.
  factory AchievementsEvent.changeTierFilter(AchievementTier? tier) =
      AchievementsChangeTierFilter;
}

/// Event to load achievements.
class LoadAchievements extends AchievementsEvent {
  /// Creates a [LoadAchievements].
  const LoadAchievements();
}

/// Event to refresh achievements data.
class RefreshAchievements extends AchievementsEvent {
  /// Creates a [RefreshAchievements].
  const RefreshAchievements();
}

/// Event to change the filter.
class AchievementsChangeFilter extends AchievementsEvent {
  /// Creates an [AchievementsChangeFilter].
  const AchievementsChangeFilter(this.filter);

  /// The new filter to apply.
  final AchievementFilter filter;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementsChangeFilter && other.filter == filter;
  }

  @override
  int get hashCode => filter.hashCode;
}

/// Event to change the tier filter.
class AchievementsChangeTierFilter extends AchievementsEvent {
  /// Creates an [AchievementsChangeTierFilter].
  const AchievementsChangeTierFilter(this.tier);

  /// The new tier filter to apply, or null to clear.
  final AchievementTier? tier;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementsChangeTierFilter && other.tier == tier;
  }

  @override
  int get hashCode => tier.hashCode;
}
