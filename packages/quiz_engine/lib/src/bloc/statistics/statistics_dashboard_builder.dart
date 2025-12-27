/// Builder widget for connecting StatisticsBloc to StatisticsDashboardScreen.
library;

import 'package:flutter/material.dart';

import '../../l10n/quiz_localizations.dart';
import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/category_statistics_widget.dart';
import '../../widgets/leaderboard_widget.dart';
import '../../widgets/session_card.dart';
import 'statistics_bloc.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// A builder widget that connects [StatisticsBloc] to [StatisticsDashboardScreen].
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class StatisticsDashboardBuilder extends StatefulWidget {
  /// Creates a [StatisticsDashboardBuilder].
  const StatisticsDashboardBuilder({
    super.key,
    required this.bloc,
    this.onSessionTap,
    this.onCategoryTap,
    this.onLeaderboardEntryTap,
    this.onViewAllSessions,
    this.showTabs = true,
  });

  /// The statistics BLoC to connect to.
  final StatisticsBloc bloc;

  /// Callback when a session is tapped.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when a category is tapped.
  final void Function(CategoryStatisticsData category)? onCategoryTap;

  /// Callback when a leaderboard entry is tapped.
  final void Function(LeaderboardEntry entry)? onLeaderboardEntryTap;

  /// Callback to view all sessions.
  final VoidCallback? onViewAllSessions;

  /// Whether to show tab navigation.
  final bool showTabs;

  @override
  State<StatisticsDashboardBuilder> createState() =>
      _StatisticsDashboardBuilderState();
}

class _StatisticsDashboardBuilderState
    extends State<StatisticsDashboardBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(StatisticsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StatisticsState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          StatisticsLoading() => _buildLoading(context),
          StatisticsLoaded() => _buildLoaded(context, state),
          StatisticsError() => _buildError(context, state),
        };
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = QuizL10n.of(context);
    return LoadingIndicator(message: l10n.loadingData);
  }

  Widget _buildError(BuildContext context, StatisticsError state) {
    final l10n = QuizL10n.of(context);
    return ErrorStateWidget(
      message: l10n.errorGeneric,
      onRetry: () => widget.bloc.add(StatisticsEvent.load()),
    );
  }

  Widget _buildLoaded(BuildContext context, StatisticsLoaded state) {
    final l10n = QuizL10n.of(context);

    if (!state.data.hasData) {
      return EmptyStateWidget(
        icon: Icons.analytics_outlined,
        title: l10n.noStatisticsYet,
        message: l10n.playQuizzesToSee,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.bloc.add(StatisticsEvent.refresh());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StatisticsDashboardContent(
        data: state.data,
        selectedTab: state.selectedTab,
        progressTimeRange: state.progressTimeRange,
        leaderboardType: state.leaderboardType,
        onTabChanged: (tab) => widget.bloc.add(StatisticsEvent.changeTab(tab)),
        onTimeRangeChanged: (range) =>
            widget.bloc.add(StatisticsEvent.changeTimeRange(range)),
        onLeaderboardTypeChanged: (type) =>
            widget.bloc.add(StatisticsEvent.changeLeaderboardType(type)),
        onSessionTap: widget.onSessionTap,
        onCategoryTap: widget.onCategoryTap,
        onLeaderboardEntryTap: widget.onLeaderboardEntryTap,
        onViewAllSessions: widget.onViewAllSessions,
        showTabs: widget.showTabs,
        isRefreshing: state.isRefreshing,
      ),
    );
  }
}
