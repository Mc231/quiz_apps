import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../l10n/quiz_localizations.dart';
import '../models/quiz_category.dart';
import '../widgets/layout_mode_selector.dart';
import '../widgets/loading_indicator.dart';
import 'category_card.dart';
import 'play_screen_config.dart';
import 'play_screen_tab.dart';
import 'tabbed_play_screen_config.dart';

/// A play screen with swipable tabs for different content types.
///
/// Supports multiple tab types through the [PlayScreenTab] sealed class:
/// - [CategoriesTab] for displaying quiz categories
/// - [PracticeTab] for practicing wrong answers
/// - [CustomTab] for custom content
///
/// Example:
/// ```dart
/// TabbedPlayScreen(
///   tabs: [
///     PlayScreenTab.categories(
///       id: 'europe',
///       label: 'Europe',
///       categories: europeCategories,
///     ),
///     PlayScreenTab.categories(
///       id: 'asia',
///       label: 'Asia',
///       categories: asiaCategories,
///     ),
///     PlayScreenTab.practice(
///       id: 'practice',
///       label: 'Practice',
///       onLoadWrongAnswers: () => loadWrongAnswers(),
///     ),
///   ],
///   initialTabId: 'europe',
///   onCategorySelected: (category) => startQuiz(category),
/// )
/// ```
class TabbedPlayScreen extends StatefulWidget {
  /// Creates a [TabbedPlayScreen].
  const TabbedPlayScreen({
    super.key,
    required this.tabs,
    this.initialTabId,
    this.onCategorySelected,
    this.onCategoryLongPress,
    this.onSettingsPressed,
    this.onTabChanged,
    this.config = const TabbedPlayScreenConfig(),
  }) : assert(tabs.length > 0, 'At least one tab is required');

  /// List of tabs to display.
  final List<PlayScreenTab> tabs;

  /// ID of the tab to show initially.
  ///
  /// If null or not found, the first tab is shown.
  final String? initialTabId;

  /// Callback when a category is selected.
  final void Function(QuizCategory category)? onCategorySelected;

  /// Callback when a category is long-pressed.
  final void Function(QuizCategory category)? onCategoryLongPress;

  /// Callback when settings action is pressed.
  final VoidCallback? onSettingsPressed;

  /// Callback when the active tab changes.
  final void Function(PlayScreenTab tab)? onTabChanged;

  /// Configuration for the screen.
  final TabbedPlayScreenConfig config;

  @override
  State<TabbedPlayScreen> createState() => TabbedPlayScreenState();
}

/// State for [TabbedPlayScreen].
///
/// Exposes [switchToTabById] for programmatic tab switching (e.g., deep links).
class TabbedPlayScreenState extends State<TabbedPlayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<QuizCategory>> _practiceCache = {};
  final Map<String, bool> _practiceLoading = {};

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  void _initTabController() {
    final initialIndex = _findInitialTabIndex();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  int _findInitialTabIndex() {
    if (widget.initialTabId == null) return 0;

    final index = widget.tabs.indexWhere((tab) => tab.id == widget.initialTabId);
    return index >= 0 ? index : 0;
  }

  /// Switches to the tab with the given ID.
  ///
  /// Returns true if the tab was found and switched to, false otherwise.
  bool switchToTabById(String tabId) {
    final index = widget.tabs.indexWhere((tab) => tab.id == tabId);
    if (index < 0) return false;

    _tabController.animateTo(index);
    return true;
  }

  /// Gets the current tab ID.
  String get currentTabId => widget.tabs[_tabController.index].id;

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final currentTab = widget.tabs[_tabController.index];
    widget.onTabChanged?.call(currentTab);

    // Load practice tab data if needed
    if (currentTab is PracticeTab && !_practiceCache.containsKey(currentTab.id)) {
      _loadPracticeData(currentTab);
    }
  }

  Future<void> _loadPracticeData(PracticeTab tab) async {
    if (_practiceLoading[tab.id] == true) return;

    setState(() {
      _practiceLoading[tab.id] = true;
    });

    try {
      final categories = await tab.onLoadWrongAnswers();
      if (mounted) {
        setState(() {
          _practiceCache[tab.id] = categories;
          _practiceLoading[tab.id] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _practiceCache[tab.id] = [];
          _practiceLoading[tab.id] = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(TabbedPlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate controller if tabs changed
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _initTabController();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasSingleTab => widget.tabs.length == 1;

  @override
  Widget build(BuildContext context) {
    if (widget.config.showAppBar) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      );
    }

    // If only one tab, show content directly without tab bar
    if (_hasSingleTab) {
      return _buildTabContent(context, widget.tabs.first);
    }

    return Column(
      children: [
        _buildTabBar(context),
        Expanded(child: _buildTabBarView(context)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return AppBar(
      title: Text(widget.config.title ?? l10n.play),
      actions: _buildAppBarActions(context),
      // Hide tab bar when only one tab
      bottom: _hasSingleTab ? null : _buildTabBar(context),
    );
  }

  List<Widget>? _buildAppBarActions(BuildContext context) {
    final actions = <Widget>[];

    if (widget.config.appBarActions != null) {
      actions.addAll(widget.config.appBarActions!);
    }

    if (widget.config.showSettingsAction && widget.onSettingsPressed != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: widget.onSettingsPressed,
          tooltip: QuizL10n.of(context).settings,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  PreferredSizeWidget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: _tabController,
      isScrollable: widget.config.tabBarIsScrollable,
      indicatorColor:
          widget.config.tabBarIndicatorColor ?? theme.colorScheme.primary,
      indicatorWeight: widget.config.tabBarIndicatorWeight,
      labelColor: widget.config.tabBarLabelColor ?? theme.colorScheme.primary,
      unselectedLabelColor: widget.config.tabBarUnselectedLabelColor ??
          theme.colorScheme.onSurfaceVariant,
      tabs: widget.tabs.map((tab) => _buildTab(tab)).toList(),
    );
  }

  Widget _buildTab(PlayScreenTab tab) {
    if (tab.icon != null) {
      return Tab(
        icon: Icon(tab.icon),
        text: tab.label,
      );
    }
    return Tab(text: tab.label);
  }

  Widget _buildBody(BuildContext context) {
    return _buildTabBarView(context);
  }

  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: widget.tabs.map((tab) => _buildTabContent(context, tab)).toList(),
    );
  }

  Widget _buildTabContent(BuildContext context, PlayScreenTab tab) {
    return switch (tab) {
      CategoriesTab() => _buildCategoriesContent(context, tab),
      PracticeTab() => _buildPracticeContent(context, tab),
      CustomContentTab() => tab.builder(context),
    };
  }

  Widget _buildCategoriesContent(BuildContext context, CategoriesTab tab) {
    if (tab.categories.isEmpty) {
      return _buildEmptyState(context);
    }

    final hasLayoutOptions = widget.config.layoutModeOptions != null &&
        widget.config.layoutModeOptions!.isNotEmpty;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final layout = _resolveLayout(sizingInfo);

        if (layout == PlayScreenLayout.list) {
          return _buildListViewWithHeader(
            context,
            tab.categories,
            showLayoutSelector: hasLayoutOptions,
          );
        }

        return _buildGridViewWithHeader(
          context,
          tab.categories,
          sizingInfo,
          showLayoutSelector: hasLayoutOptions,
        );
      },
    );
  }

  Widget? _buildLayoutModeSelector(BuildContext context) {
    final options = widget.config.layoutModeOptions;
    if (options == null || options.isEmpty) return null;

    // Find selected option by ID, default to first
    final selectedId = widget.config.selectedLayoutModeId;
    final selectedOption = selectedId != null
        ? options.firstWhere(
            (o) => o.id == selectedId,
            orElse: () => options.first,
          )
        : options.first;

    return LayoutModeSelector(
      options: options,
      selectedOption: selectedOption,
      onOptionSelected: (option) {
        widget.config.onLayoutModeChanged?.call(option);
      },
      large: true,
    );
  }

  Widget? _buildHeaderWidget(BuildContext context) {
    final builder = widget.config.headerWidgetBuilder;
    if (builder == null) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: builder(context),
    );
  }

  Widget _buildListViewWithHeader(
    BuildContext context,
    List<QuizCategory> categories, {
    required bool showLayoutSelector,
  }) {
    final config = widget.config.playScreenConfig;
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.list();
    final headerWidget = _buildHeaderWidget(context);

    return CustomScrollView(
      slivers: [
        if (headerWidget != null)
          SliverToBoxAdapter(child: headerWidget),
        if (showLayoutSelector)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLayoutModeSelector(context),
            ),
          ),
        SliverPadding(
          padding: config.padding,
          sliver: SliverList.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: config.itemSpacing),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard.list(
                category: category,
                style: cardStyle,
                onTap: widget.onCategorySelected != null
                    ? () => widget.onCategorySelected!(category)
                    : null,
                onLongPress: widget.onCategoryLongPress != null
                    ? () => widget.onCategoryLongPress!(category)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridViewWithHeader(
    BuildContext context,
    List<QuizCategory> categories,
    SizingInformation sizingInfo, {
    required bool showLayoutSelector,
  }) {
    final config = widget.config.playScreenConfig;
    final columns = _getGridColumns(sizingInfo);
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.grid();
    final headerWidget = _buildHeaderWidget(context);

    return CustomScrollView(
      slivers: [
        if (headerWidget != null)
          SliverToBoxAdapter(child: headerWidget),
        if (showLayoutSelector)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLayoutModeSelector(context),
            ),
          ),
        SliverPadding(
          padding: config.padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: config.itemSpacing,
              crossAxisSpacing: config.itemSpacing,
              childAspectRatio: config.gridAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return CategoryCard.grid(
                  category: category,
                  style: cardStyle,
                  onTap: widget.onCategorySelected != null
                      ? () => widget.onCategorySelected!(category)
                      : null,
                  onLongPress: widget.onCategoryLongPress != null
                      ? () => widget.onCategoryLongPress!(category)
                      : null,
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeContent(BuildContext context, PracticeTab tab) {
    // Check if we need to load data
    if (!_practiceCache.containsKey(tab.id) && _practiceLoading[tab.id] != true) {
      // Trigger load on first view
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPracticeData(tab);
      });
    }

    // Show loading state
    if (_practiceLoading[tab.id] == true) {
      return widget.config.playScreenConfig.loadingWidget ??
          const LoadingIndicator();
    }

    // Get cached data
    final categories = _practiceCache[tab.id];

    // Show empty state if no data
    if (categories == null || categories.isEmpty) {
      return tab.emptyStateWidget ?? _buildPracticeEmptyState(context);
    }

    // Show categories
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final layout = _resolveLayout(sizingInfo);

        if (layout == PlayScreenLayout.list) {
          return _buildListView(context, categories);
        }

        return _buildGridView(context, categories, sizingInfo);
      },
    );
  }

  PlayScreenLayout _resolveLayout(SizingInformation sizingInfo) {
    final config = widget.config.playScreenConfig;

    if (config.layout != PlayScreenLayout.adaptive) {
      return config.layout;
    }

    if (sizingInfo.deviceScreenType == DeviceScreenType.mobile) {
      final isPortrait =
          sizingInfo.localWidgetSize.width < sizingInfo.localWidgetSize.height;
      return isPortrait ? PlayScreenLayout.list : PlayScreenLayout.grid;
    }

    return PlayScreenLayout.grid;
  }

  Widget _buildGridView(
    BuildContext context,
    List<QuizCategory> categories,
    SizingInformation sizingInfo,
  ) {
    final config = widget.config.playScreenConfig;
    final columns = _getGridColumns(sizingInfo);
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.grid();

    return GridView.builder(
      padding: config.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: config.itemSpacing,
        crossAxisSpacing: config.itemSpacing,
        childAspectRatio: config.gridAspectRatio,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard.grid(
          category: category,
          style: cardStyle,
          onTap: widget.onCategorySelected != null
              ? () => widget.onCategorySelected!(category)
              : null,
          onLongPress: widget.onCategoryLongPress != null
              ? () => widget.onCategoryLongPress!(category)
              : null,
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<QuizCategory> categories) {
    final config = widget.config.playScreenConfig;
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.list();

    return ListView.separated(
      padding: config.padding,
      itemCount: categories.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: config.itemSpacing),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard.list(
          category: category,
          style: cardStyle,
          onTap: widget.onCategorySelected != null
              ? () => widget.onCategorySelected!(category)
              : null,
          onLongPress: widget.onCategoryLongPress != null
              ? () => widget.onCategoryLongPress!(category)
              : null,
        );
      },
    );
  }

  int _getGridColumns(SizingInformation sizingInfo) {
    final config = widget.config.playScreenConfig;

    switch (sizingInfo.deviceScreenType) {
      case DeviceScreenType.desktop:
        return config.gridColumnsDesktop;
      case DeviceScreenType.tablet:
        return config.gridColumnsTablet;
      case DeviceScreenType.mobile:
      case DeviceScreenType.watch:
      default:
        return config.gridColumnsMobile;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final emptyWidget = widget.config.playScreenConfig.emptyStateWidget;
    if (emptyWidget != null) return emptyWidget;

    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSessionsYet,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeEmptyState(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPracticeItems,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noPracticeItemsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
