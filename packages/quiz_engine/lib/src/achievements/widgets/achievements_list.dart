import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../widgets/empty_state_widget.dart';
import '../achievement_category.dart';
import 'achievement_card.dart';

/// Filter options for achievements list.
enum AchievementFilter {
  /// Show all achievements.
  all,

  /// Show only unlocked achievements.
  unlocked,

  /// Show only locked achievements (with progress).
  inProgress,

  /// Show only locked achievements (no progress).
  locked,
}

/// Extension for filter display names.
extension AchievementFilterExtension on AchievementFilter {
  /// Display name for the filter (localized).
  String getLabel(QuizEngineLocalizations l10n) => switch (this) {
        AchievementFilter.all => l10n.filterAll,
        AchievementFilter.unlocked => l10n.filterUnlocked,
        AchievementFilter.inProgress => l10n.filterInProgress,
        AchievementFilter.locked => l10n.filterLocked,
      };
}

/// Sort options for achievements list.
enum AchievementSort {
  /// Sort by category.
  category,

  /// Sort by tier (rarity).
  tier,

  /// Sort by progress percentage.
  progress,

  /// Sort by unlock date (most recent first).
  recentlyUnlocked,
}

/// Configuration for [AchievementsList].
class AchievementsListConfig {
  /// Creates an [AchievementsListConfig].
  const AchievementsListConfig({
    this.filter = AchievementFilter.all,
    this.sort = AchievementSort.category,
    this.tierFilter,
    this.groupByCategory = true,
    this.showEmptyCategories = false,
    this.cardStyle = const AchievementCardStyle(),
    this.showFilterChips = true,
    this.showSortOptions = false,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 8.0,
    this.sectionSpacing = 24.0,
  });

  /// Current filter.
  final AchievementFilter filter;

  /// Current sort order.
  final AchievementSort sort;

  /// Optional tier filter (null = all tiers).
  final AchievementTier? tierFilter;

  /// Whether to group achievements by category.
  final bool groupByCategory;

  /// Whether to show empty categories.
  final bool showEmptyCategories;

  /// Style for achievement cards.
  final AchievementCardStyle cardStyle;

  /// Whether to show filter chips.
  final bool showFilterChips;

  /// Whether to show sort options.
  final bool showSortOptions;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Spacing between items.
  final double itemSpacing;

  /// Spacing between sections.
  final double sectionSpacing;

  /// Creates a copy with the given fields replaced.
  AchievementsListConfig copyWith({
    AchievementFilter? filter,
    AchievementSort? sort,
    AchievementTier? tierFilter,
    bool? groupByCategory,
    bool? showEmptyCategories,
    AchievementCardStyle? cardStyle,
    bool? showFilterChips,
    bool? showSortOptions,
    EdgeInsets? padding,
    double? itemSpacing,
    double? sectionSpacing,
  }) {
    return AchievementsListConfig(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      tierFilter: tierFilter ?? this.tierFilter,
      groupByCategory: groupByCategory ?? this.groupByCategory,
      showEmptyCategories: showEmptyCategories ?? this.showEmptyCategories,
      cardStyle: cardStyle ?? this.cardStyle,
      showFilterChips: showFilterChips ?? this.showFilterChips,
      showSortOptions: showSortOptions ?? this.showSortOptions,
      padding: padding ?? this.padding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
    );
  }
}

/// A scrollable list of achievements with filtering and grouping.
///
/// Supports:
/// - Filtering by status (all, unlocked, in progress, locked)
/// - Filtering by tier
/// - Grouping by category
/// - Sorting by category, tier, progress, or unlock date
/// - Highlighting and scrolling to a specific achievement
///
/// Example:
/// ```dart
/// AchievementsList(
///   achievements: allAchievements,
///   config: AchievementsListConfig(
///     filter: AchievementFilter.all,
///     groupByCategory: true,
///   ),
///   onAchievementTap: (data) => showDetails(data),
///   highlightedAchievementId: 'first_quiz', // Optional: scroll and highlight
/// )
/// ```
class AchievementsList extends StatefulWidget {
  /// Creates an [AchievementsList].
  const AchievementsList({
    super.key,
    required this.achievements,
    this.config = const AchievementsListConfig(),
    this.onAchievementTap,
    this.onFilterChanged,
    this.onSortChanged,
    this.emptyBuilder,
    this.headerBuilder,
    this.highlightedAchievementId,
  });

  /// All achievements to display.
  final List<AchievementDisplayData> achievements;

  /// Configuration for the list.
  final AchievementsListConfig config;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData)? onAchievementTap;

  /// Callback when filter changes.
  final void Function(AchievementFilter)? onFilterChanged;

  /// Callback when sort changes.
  final void Function(AchievementSort)? onSortChanged;

  /// Builder for empty state.
  final Widget Function(BuildContext)? emptyBuilder;

  /// Builder for optional header.
  final Widget Function(BuildContext)? headerBuilder;

  /// The ID of an achievement to highlight and scroll to.
  ///
  /// When set, the list will scroll to this achievement and apply
  /// a glowing highlight effect that fades over 2 seconds.
  final String? highlightedAchievementId;

  @override
  State<AchievementsList> createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  final Map<String, GlobalKey> _achievementKeys = {};
  bool _hasScrolledToHighlight = false;

  @override
  void initState() {
    super.initState();
    _setupAchievementKeys();
  }

  @override
  void didUpdateWidget(AchievementsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedAchievementId != oldWidget.highlightedAchievementId) {
      _hasScrolledToHighlight = false;
    }
    _setupAchievementKeys();
  }

  void _setupAchievementKeys() {
    // Create keys for all achievements
    for (final achievement in widget.achievements) {
      _achievementKeys.putIfAbsent(
        achievement.achievement.id,
        () => GlobalKey(),
      );
    }
  }

  void _scrollToHighlightedAchievement() {
    if (_hasScrolledToHighlight) return;
    if (widget.highlightedAchievementId == null) return;

    final key = _achievementKeys[widget.highlightedAchievementId];
    if (key?.currentContext != null) {
      _hasScrolledToHighlight = true;
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        alignment: 0.3, // Position 30% from top
      );
    }
  }

  List<AchievementDisplayData> get achievements => widget.achievements;
  AchievementsListConfig get config => widget.config;
  void Function(AchievementDisplayData)? get onAchievementTap => widget.onAchievementTap;
  Widget Function(BuildContext)? get emptyBuilder => widget.emptyBuilder;
  Widget Function(BuildContext)? get headerBuilder => widget.headerBuilder;

  @override
  Widget build(BuildContext context) {
    final filtered = _filterAchievements();
    final sorted = _sortAchievements(filtered);

    if (sorted.isEmpty) {
      return emptyBuilder?.call(context) ?? _buildEmptyState(context);
    }

    // Schedule scroll after build
    if (widget.highlightedAchievementId != null && !_hasScrolledToHighlight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlightedAchievement();
      });
    }

    if (config.groupByCategory) {
      return _buildGroupedList(context, sorted);
    }

    return _buildFlatList(context, sorted);
  }

  List<AchievementDisplayData> _filterAchievements() {
    var result = achievements.toList();

    // Apply status filter
    result = switch (config.filter) {
      AchievementFilter.all => result,
      AchievementFilter.unlocked =>
        result.where((a) => a.isUnlocked).toList(),
      AchievementFilter.inProgress =>
        result.where((a) => !a.isUnlocked && a.progress.hasProgress).toList(),
      AchievementFilter.locked =>
        result.where((a) => !a.isUnlocked && !a.progress.hasProgress).toList(),
    };

    // Apply tier filter
    if (config.tierFilter != null) {
      result =
          result.where((a) => a.achievement.tier == config.tierFilter).toList();
    }

    return result;
  }

  List<AchievementDisplayData> _sortAchievements(
    List<AchievementDisplayData> items,
  ) {
    final sorted = items.toList();

    switch (config.sort) {
      case AchievementSort.category:
        sorted.sort((a, b) {
          final catA = a.achievement.category ?? '';
          final catB = b.achievement.category ?? '';
          final catCompare = catA.compareTo(catB);
          if (catCompare != 0) return catCompare;
          return a.achievement.tier.index.compareTo(b.achievement.tier.index);
        });
      case AchievementSort.tier:
        sorted.sort((a, b) {
          final tierCompare =
              b.achievement.tier.index.compareTo(a.achievement.tier.index);
          if (tierCompare != 0) return tierCompare;
          return a.achievement.id.compareTo(b.achievement.id);
        });
      case AchievementSort.progress:
        sorted.sort((a, b) {
          // Unlocked first, then by progress percentage
          if (a.isUnlocked != b.isUnlocked) {
            return a.isUnlocked ? -1 : 1;
          }
          return b.progress.percentage.compareTo(a.progress.percentage);
        });
      case AchievementSort.recentlyUnlocked:
        sorted.sort((a, b) {
          final dateA = a.progress.unlockedAt;
          final dateB = b.progress.unlockedAt;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
    }

    return sorted;
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return EmptyStateWidget(
      icon: Icons.emoji_events_outlined,
      title: l10n.noAchievementsFound,
      message: l10n.tryChangingFilter,
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<AchievementDisplayData> items,
  ) {
    // Group by category
    final groups = <AchievementCategory, List<AchievementDisplayData>>{};

    for (final category in AchievementCategory.values) {
      final categoryItems = items
          .where((a) => a.achievement.category == category.name)
          .toList();
      if (categoryItems.isNotEmpty || config.showEmptyCategories) {
        groups[category] = categoryItems;
      }
    }

    // Add uncategorized items
    final uncategorized = items.where((a) {
      final cat = a.achievement.category;
      return cat == null ||
          !AchievementCategory.values.any((c) => c.name == cat);
    }).toList();

    return ListView.builder(
      padding: config.padding,
      itemCount: groups.length + (uncategorized.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < groups.length) {
          final entry = groups.entries.elementAt(index);
          return _buildCategorySection(context, entry.key, entry.value);
        } else {
          return _buildUncategorizedSection(context, uncategorized);
        }
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    AchievementCategory category,
    List<AchievementDisplayData> items,
  ) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: config.itemSpacing),
          child: Row(
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                category.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${items.where((a) => a.isUnlocked).length}/${items.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: config.sectionSpacing),
            child: Text(
              l10n.noAchievementsInCategory,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...items.map(
            (item) {
              final isHighlighted = item.achievement.id == widget.highlightedAchievementId;
              return Padding(
                key: _achievementKeys[item.achievement.id],
                padding: EdgeInsets.only(bottom: config.itemSpacing),
                child: AchievementCard(
                  data: item,
                  style: config.cardStyle,
                  isHighlighted: isHighlighted,
                  onTap: onAchievementTap != null
                      ? () => onAchievementTap!(item)
                      : null,
                ),
              );
            },
          ),
        SizedBox(height: config.sectionSpacing - config.itemSpacing),
      ],
    );
  }

  Widget _buildUncategorizedSection(
    BuildContext context,
    List<AchievementDisplayData> items,
  ) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: config.itemSpacing),
          child: Row(
            children: [
              const Text(
                '🎯',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.otherAchievements,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${items.where((a) => a.isUnlocked).length}/${items.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) {
            final isHighlighted = item.achievement.id == widget.highlightedAchievementId;
            return Padding(
              key: _achievementKeys[item.achievement.id],
              padding: EdgeInsets.only(bottom: config.itemSpacing),
              child: AchievementCard(
                data: item,
                style: config.cardStyle,
                isHighlighted: isHighlighted,
                onTap:
                    onAchievementTap != null ? () => onAchievementTap!(item) : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFlatList(
    BuildContext context,
    List<AchievementDisplayData> items,
  ) {
    return ListView.builder(
      padding: config.padding,
      itemCount: items.length + (headerBuilder != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (headerBuilder != null && index == 0) {
          return headerBuilder!(context);
        }

        final itemIndex = headerBuilder != null ? index - 1 : index;
        final item = items[itemIndex];
        final isHighlighted = item.achievement.id == widget.highlightedAchievementId;

        return Padding(
          key: _achievementKeys[item.achievement.id],
          padding: EdgeInsets.only(bottom: config.itemSpacing),
          child: AchievementCard(
            data: item,
            style: config.cardStyle,
            isHighlighted: isHighlighted,
            onTap:
                onAchievementTap != null ? () => onAchievementTap!(item) : null,
          ),
        );
      },
    );
  }
}

/// Filter chips for achievements list.
class AchievementFilterChips extends StatelessWidget {
  /// Creates [AchievementFilterChips].
  const AchievementFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.counts,
  });

  /// Currently selected filter.
  final AchievementFilter selected;

  /// Callback when filter changes.
  final void Function(AchievementFilter) onChanged;

  /// Optional counts for each filter (e.g., {all: 67, unlocked: 12}).
  final Map<AchievementFilter, int>? counts;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: AchievementFilter.values.map((filter) {
          final isSelected = filter == selected;
          final count = counts?[filter];
          final filterLabel = filter.getLabel(l10n);
          final label = count != null ? '$filterLabel ($count)' : filterLabel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Tier filter chips for achievements list.
class AchievementTierFilterChips extends StatelessWidget {
  /// Creates [AchievementTierFilterChips].
  const AchievementTierFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Currently selected tier (null = all).
  final AchievementTier? selected;

  /// Callback when tier changes.
  final void Function(AchievementTier?) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.allTiers),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...AchievementTier.values.map((tier) {
            final isSelected = tier == selected;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tier.icon),
                    const SizedBox(width: 4),
                    Text(tier.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onChanged(tier),
                backgroundColor: tier.color.withValues(alpha: 0.1),
                selectedColor: tier.color.withValues(alpha: 0.3),
              ),
            );
          }),
        ],
      ),
    );
  }
}
