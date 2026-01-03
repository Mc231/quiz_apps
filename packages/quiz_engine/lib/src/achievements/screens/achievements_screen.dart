import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../services/quiz_services_context.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievements_list.dart';
import 'achievements_screen_config.dart';
import 'achievements_screen_data.dart';

/// Helper to track achievement detail viewed events.
void _trackAchievementDetailViewed(
  AnalyticsService analyticsService,
  AchievementDisplayData data,
) {
  analyticsService.logEvent(
    AchievementEvent.detailViewed(
      achievementId: data.achievement.id,
      achievementName: data.achievement.id, // Name requires context
      achievementCategory: data.achievement.tier.name,
      isUnlocked: data.isUnlocked,
      progress: data.progress.currentValue / data.progress.targetValue,
    ),
  );
}

/// A full-screen achievements display.
///
/// Shows a stats header with achievement counter and points,
/// filter chips for filtering achievements, and a scrollable
/// list of achievements grouped by category.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// AchievementsScreen(
///   data: AchievementsScreenData(
///     achievements: allAchievements,
///     totalPoints: 450,
///   ),
///   onRefresh: () async => loadAchievements(),
///   onAchievementTap: (data) => showDetails(data),
/// )
/// ```
class AchievementsScreen extends StatefulWidget {
  /// Creates an [AchievementsScreen].
  const AchievementsScreen({
    super.key,
    required this.data,
    this.config = const AchievementsScreenConfig(),
    this.onRefresh,
    this.onAchievementTap,
    this.appBar,
    this.showScaffold = false,
    this.highlightedAchievementId,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when an achievement is tapped.
  ///
  /// The callback receives both the [BuildContext] for showing dialogs/bottom sheets
  /// and the [AchievementDisplayData] containing achievement details.
  final void Function(BuildContext context, AchievementDisplayData achievement)?
      onAchievementTap;

  /// Optional custom app bar.
  final PreferredSizeWidget? appBar;

  /// Whether to wrap content in a Scaffold with AppBar.
  ///
  /// Set to `false` when using inside a tab or another scaffold.
  /// Defaults to `false` for use in QuizHomeScreen tabs.
  final bool showScaffold;

  /// The ID of an achievement to highlight and scroll to.
  ///
  /// When set, the screen will scroll to this achievement and apply
  /// a glowing highlight effect that fades over 2 seconds.
  final String? highlightedAchievementId;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late AchievementFilter _currentFilter;
  AchievementTier? _currentTierFilter;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.config.initialFilter;
    // Log screen view after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logScreenView();
    });
  }

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.achievements(
        unlockedCount: widget.data.unlockedCount,
        totalCount: widget.data.totalCount,
        totalPoints: widget.data.totalPoints,
      ),
    );
  }

  void _handleAchievementTap(AchievementDisplayData data) {
    // Track the view event
    _trackAchievementDetailViewed(_analyticsService, data);
    // Call the original callback with context
    widget.onAchievementTap?.call(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    final content = widget.config.enablePullToRefresh && widget.onRefresh != null
        ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: _buildContent(context),
          )
        : _buildContent(context);

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: widget.data,
              style: widget.config.headerStyle,
              showPoints: widget.config.showPointsInHeader,
            ),
          ),
        if (widget.config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: _currentFilter,
                onChanged: (filter) => setState(() => _currentFilter = filter),
                counts: widget.data.filterCounts,
              ),
            ),
          ),
        if (widget.config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: _currentTierFilter,
                onChanged: (tier) => setState(() => _currentTierFilter = tier),
              ),
            ),
          ),
        if (widget.config.showFilterChips || widget.config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          child: AchievementsList(
            achievements: widget.data.achievements,
            config: widget.config.listConfig.copyWith(
              filter: _currentFilter,
              tierFilter: _currentTierFilter,
              groupByCategory: widget.config.groupByCategory,
            ),
            onAchievementTap: widget.onAchievementTap != null
                ? _handleAchievementTap
                : null,
            highlightedAchievementId: widget.highlightedAchievementId,
          ),
        ),
      ],
    );
  }
}

/// Stats header showing achievement count and points.
class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader({
    required this.data,
    required this.style,
    required this.showPoints,
  });

  final AchievementsScreenData data;
  final AchievementsHeaderStyle style;
  final bool showPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final progress =
        data.totalCount > 0 ? data.unlockedCount / data.totalCount : 0.0;

    return Container(
      color: style.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      padding: style.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  label: l10n.achievementsUnlocked(
                    data.unlockedCount,
                    data.totalCount,
                  ),
                  sublabel: l10n.achievements,
                ),
              ),
              if (showPoints) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.stars,
                    iconColor: theme.colorScheme.secondary,
                    label: l10n.achievementPoints(data.totalPoints),
                    sublabel: _getRemainingPointsText(l10n),
                  ),
                ),
              ],
            ],
          ),
          if (style.showProgressBar) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(style.progressBarHeight / 2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: style.progressBarHeight,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completionPercentage((progress * 100).toInt()),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRemainingPointsText(QuizEngineLocalizations l10n) {
    if (data.remainingPoints > 0) {
      return l10n.pointsRemaining(data.remainingPoints);
    }
    return l10n.allPointsEarned;
  }
}

/// A stat card for the header.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sublabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A sliver version of the achievements screen for use in CustomScrollView.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class AchievementsScreenSliver extends StatefulWidget {
  /// Creates an [AchievementsScreenSliver].
  const AchievementsScreenSliver({
    super.key,
    required this.data,
    this.config = const AchievementsScreenConfig(),
    this.onAchievementTap,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when an achievement is tapped.
  ///
  /// The callback receives both the [BuildContext] for showing dialogs/bottom sheets
  /// and the [AchievementDisplayData] containing achievement details.
  final void Function(BuildContext context, AchievementDisplayData achievement)?
      onAchievementTap;

  @override
  State<AchievementsScreenSliver> createState() =>
      _AchievementsScreenSliverState();
}

class _AchievementsScreenSliverState extends State<AchievementsScreenSliver> {
  late AchievementFilter _currentFilter;
  AchievementTier? _currentTierFilter;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.config.initialFilter;
    // Log screen view after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logScreenView();
    });
  }

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.achievements(
        unlockedCount: widget.data.unlockedCount,
        totalCount: widget.data.totalCount,
        totalPoints: widget.data.totalPoints,
      ),
    );
  }

  void _handleAchievementTap(AchievementDisplayData data) {
    // Track the view event
    _trackAchievementDetailViewed(_analyticsService, data);
    // Call the original callback with context
    widget.onAchievementTap?.call(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (widget.config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: widget.data,
              style: widget.config.headerStyle,
              showPoints: widget.config.showPointsInHeader,
            ),
          ),
        if (widget.config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: _currentFilter,
                onChanged: (filter) => setState(() => _currentFilter = filter),
                counts: widget.data.filterCounts,
              ),
            ),
          ),
        if (widget.config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: _currentTierFilter,
                onChanged: (tier) => setState(() => _currentTierFilter = tier),
              ),
            ),
          ),
        if (widget.config.showFilterChips || widget.config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: AchievementsList(
            achievements: widget.data.achievements,
            config: widget.config.listConfig.copyWith(
              filter: _currentFilter,
              tierFilter: _currentTierFilter,
              groupByCategory: widget.config.groupByCategory,
            ),
            onAchievementTap: widget.onAchievementTap != null
                ? _handleAchievementTap
                : null,
          ),
        ),
      ],
    );
  }
}

/// A stateless content widget for use with AchievementsBloc.
///
/// This widget renders achievements content without managing its own state,
/// making it suitable for use with [AchievementsBuilder] and BLoC pattern.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// AchievementsBuilder(
///   bloc: achievementsBloc,
///   builder: (context, state) => AchievementsContent(
///     data: state.data,
///     filter: state.filter,
///     tierFilter: state.tierFilter,
///     isRefreshing: state.isRefreshing,
///     onFilterChanged: (filter) =>
///         achievementsBloc.add(AchievementsEvent.changeFilter(filter)),
///     onTierFilterChanged: (tier) =>
///         achievementsBloc.add(AchievementsEvent.changeTierFilter(tier)),
///     onRefresh: () async =>
///         achievementsBloc.add(AchievementsEvent.refresh()),
///   ),
/// )
/// ```
class AchievementsContent extends StatelessWidget {
  /// Creates an [AchievementsContent].
  const AchievementsContent({
    super.key,
    required this.data,
    this.filter = AchievementFilter.all,
    this.tierFilter,
    this.isRefreshing = false,
    this.config = const AchievementsScreenConfig(),
    this.onFilterChanged,
    this.onTierFilterChanged,
    this.onRefresh,
    this.onAchievementTap,
    this.highlightedAchievementId,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Current filter selection.
  final AchievementFilter filter;

  /// Current tier filter selection.
  final AchievementTier? tierFilter;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when filter changes.
  final void Function(AchievementFilter)? onFilterChanged;

  /// Callback when tier filter changes.
  final void Function(AchievementTier?)? onTierFilterChanged;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when an achievement is tapped.
  ///
  /// The callback receives both the [BuildContext] for showing dialogs/bottom sheets
  /// and the [AchievementDisplayData] containing achievement details.
  final void Function(BuildContext context, AchievementDisplayData achievement)?
      onAchievementTap;

  /// The ID of an achievement to highlight and scroll to.
  final String? highlightedAchievementId;

  void _handleAchievementTap(
    BuildContext context,
    AchievementDisplayData achievementData,
  ) {
    // Track the view event
    _trackAchievementDetailViewed(
      context.screenAnalyticsService,
      achievementData,
    );
    // Call the original callback with context
    onAchievementTap?.call(context, achievementData);
  }

  @override
  Widget build(BuildContext context) {
    final content = config.enablePullToRefresh && onRefresh != null
        ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: _buildContent(context),
          )
        : _buildContent(context);

    return content;
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: data,
              style: config.headerStyle,
              showPoints: config.showPointsInHeader,
            ),
          ),
        if (config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: filter,
                onChanged: onFilterChanged ?? (_) {},
                counts: data.filterCounts,
              ),
            ),
          ),
        if (config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: tierFilter,
                onChanged: onTierFilterChanged ?? (_) {},
              ),
            ),
          ),
        if (config.showFilterChips || config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          child: Builder(
            builder: (ctx) => AchievementsList(
              achievements: data.achievements,
              config: config.listConfig.copyWith(
                filter: filter,
                tierFilter: tierFilter,
                groupByCategory: config.groupByCategory,
              ),
              onAchievementTap: onAchievementTap != null
                  ? (data) => _handleAchievementTap(ctx, data)
                  : null,
              highlightedAchievementId: highlightedAchievementId,
            ),
          ),
        ),
      ],
    );
  }
}

/// An async builder for achievements screen data.
///
/// Handles loading and error states while fetching achievement data.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class AchievementsScreenBuilder extends StatelessWidget {
  /// Creates an [AchievementsScreenBuilder].
  const AchievementsScreenBuilder({
    super.key,
    required this.dataLoader,
    this.config = const AchievementsScreenConfig(),
    this.onAchievementTap,
    this.loadingBuilder,
    this.errorBuilder,
    this.appBar,
  });

  /// Function to load achievements data.
  final Future<AchievementsScreenData> Function() dataLoader;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when an achievement is tapped.
  ///
  /// The callback receives both the [BuildContext] for showing dialogs/bottom sheets
  /// and the [AchievementDisplayData] containing achievement details.
  final void Function(BuildContext context, AchievementDisplayData achievement)?
      onAchievementTap;

  /// Custom loading widget builder.
  final Widget Function(BuildContext)? loadingBuilder;

  /// Custom error widget builder.
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
      errorBuilder;

  /// Optional custom app bar.
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AchievementsScreenData>(
      future: dataLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? _buildLoading(context);
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(
                context,
                snapshot.error!,
                () => (context as Element).markNeedsBuild(),
              ) ??
              _buildError(context, snapshot.error!);
        }

        return AchievementsScreen(
          data: snapshot.data ?? const AchievementsScreenData.empty(),
          config: config,
          onRefresh: () async {
            await dataLoader();
            if (context.mounted) {
              (context as Element).markNeedsBuild();
            }
          },
          onAchievementTap: onAchievementTap,
          appBar: appBar,
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: const LoadingIndicator(),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final l10n = QuizL10n.of(context);

    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: ErrorStateWidget(
        message: l10n.initializationError(error.toString()),
      ),
    );
  }
}
