/// State classes for the Achievements BLoC.
library;

import 'package:shared_services/shared_services.dart' show AchievementTier;

import '../../achievements/screens/achievements_screen.dart';
import '../../achievements/widgets/achievements_list.dart';

/// Sealed class representing all possible states for achievements screen.
sealed class AchievementsState {
  /// Creates an [AchievementsState].
  const AchievementsState();

  /// Creates a loading state.
  factory AchievementsState.loading() = AchievementsLoading;

  /// Creates a loaded state with achievements data.
  factory AchievementsState.loaded({
    required AchievementsScreenData data,
    AchievementFilter filter,
    AchievementTier? tierFilter,
    bool isRefreshing,
  }) = AchievementsLoaded;

  /// Creates an error state.
  factory AchievementsState.error({
    required String message,
    Object? error,
  }) = AchievementsError;
}

/// State when achievements are loading.
class AchievementsLoading extends AchievementsState {
  /// Creates an [AchievementsLoading].
  const AchievementsLoading();
}

/// State when achievements are loaded.
class AchievementsLoaded extends AchievementsState {
  /// Creates an [AchievementsLoaded].
  const AchievementsLoaded({
    required this.data,
    this.filter = AchievementFilter.all,
    this.tierFilter,
    this.isRefreshing = false,
  });

  /// The achievements data.
  final AchievementsScreenData data;

  /// Current filter selection.
  final AchievementFilter filter;

  /// Current tier filter selection.
  final AchievementTier? tierFilter;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// Creates a copy with updated values.
  AchievementsLoaded copyWith({
    AchievementsScreenData? data,
    AchievementFilter? filter,
    AchievementTier? tierFilter,
    bool? isRefreshing,
    bool clearTierFilter = false,
  }) {
    return AchievementsLoaded(
      data: data ?? this.data,
      filter: filter ?? this.filter,
      tierFilter: clearTierFilter ? null : (tierFilter ?? this.tierFilter),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementsLoaded &&
        other.data == data &&
        other.filter == filter &&
        other.tierFilter == tierFilter &&
        other.isRefreshing == isRefreshing;
  }

  @override
  int get hashCode => Object.hash(data, filter, tierFilter, isRefreshing);
}

/// State when there's an error loading achievements.
class AchievementsError extends AchievementsState {
  /// Creates an [AchievementsError].
  const AchievementsError({
    required this.message,
    this.error,
  });

  /// The error message to display.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementsError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
