import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../l10n/quiz_localizations.dart';
import '../models/quiz_category.dart';
import 'category_card.dart';

/// Layout style for the play screen.
enum PlayScreenLayout {
  /// Grid layout with cards in a responsive grid.
  grid,

  /// List layout with cards stacked vertically.
  list,

  /// Adaptive layout that switches based on screen size.
  adaptive,
}

/// Configuration for the play screen appearance and behavior.
class PlayScreenConfig {
  /// Title for the screen.
  ///
  /// If null, uses the localized "Play" string.
  final String? title;

  /// Layout style for displaying categories.
  final PlayScreenLayout layout;

  /// Number of columns for grid layout on mobile.
  final int gridColumnsMobile;

  /// Number of columns for grid layout on tablet.
  final int gridColumnsTablet;

  /// Number of columns for grid layout on desktop.
  final int gridColumnsDesktop;

  /// Aspect ratio for grid items.
  final double gridAspectRatio;

  /// Spacing between grid/list items.
  final double itemSpacing;

  /// Padding around the content.
  final EdgeInsets padding;

  /// Style for category cards.
  final CategoryCardStyle? cardStyle;

  /// Whether to show a settings action in the app bar.
  final bool showSettingsAction;

  /// Custom app bar actions.
  final List<Widget>? appBarActions;

  /// Whether to show the app bar.
  final bool showAppBar;

  /// Empty state widget when no categories are available.
  final Widget? emptyStateWidget;

  /// Loading state widget.
  final Widget? loadingWidget;

  /// Creates a [PlayScreenConfig].
  const PlayScreenConfig({
    this.title,
    this.layout = PlayScreenLayout.adaptive,
    this.gridColumnsMobile = 2,
    this.gridColumnsTablet = 3,
    this.gridColumnsDesktop = 4,
    this.gridAspectRatio = 1.0,
    this.itemSpacing = 12,
    this.padding = const EdgeInsets.all(16),
    this.cardStyle,
    this.showSettingsAction = true,
    this.appBarActions,
    this.showAppBar = true,
    this.emptyStateWidget,
    this.loadingWidget,
  });

  /// Creates a grid-focused configuration.
  const PlayScreenConfig.grid({
    this.title,
    this.gridColumnsMobile = 2,
    this.gridColumnsTablet = 3,
    this.gridColumnsDesktop = 4,
    this.gridAspectRatio = 1.0,
    this.itemSpacing = 12,
    this.padding = const EdgeInsets.all(16),
    this.cardStyle,
    this.showSettingsAction = true,
    this.appBarActions,
    this.showAppBar = true,
    this.emptyStateWidget,
    this.loadingWidget,
  }) : layout = PlayScreenLayout.grid;

  /// Creates a list-focused configuration.
  const PlayScreenConfig.list({
    this.title,
    this.itemSpacing = 8,
    this.padding = const EdgeInsets.all(16),
    this.cardStyle,
    this.showSettingsAction = true,
    this.appBarActions,
    this.showAppBar = true,
    this.emptyStateWidget,
    this.loadingWidget,
  })  : layout = PlayScreenLayout.list,
        gridColumnsMobile = 1,
        gridColumnsTablet = 1,
        gridColumnsDesktop = 1,
        gridAspectRatio = 1.0;
}

/// A screen that displays quiz categories for selection.
///
/// Supports grid, list, or adaptive layouts with responsive design.
/// Uses [QuizCategory] models from Sprint 11.1.
///
/// Example:
/// ```dart
/// PlayScreen(
///   categories: [europeCategory, asiaCategory],
///   onCategorySelected: (category) => startQuiz(category),
///   config: PlayScreenConfig.grid(),
/// )
/// ```
class PlayScreen extends StatelessWidget {
  /// List of categories to display.
  final List<QuizCategory> categories;

  /// Callback when a category is selected.
  final void Function(QuizCategory category)? onCategorySelected;

  /// Callback when a category is long-pressed.
  final void Function(QuizCategory category)? onCategoryLongPress;

  /// Callback when the settings action is pressed.
  final VoidCallback? onSettingsPressed;

  /// Configuration for the screen.
  final PlayScreenConfig config;

  /// Whether the screen is in a loading state.
  final bool isLoading;

  /// Creates a [PlayScreen].
  const PlayScreen({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.onCategoryLongPress,
    this.onSettingsPressed,
    this.config = const PlayScreenConfig(),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = QuizLocalizations.of(context);

    if (config.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(config.title ?? l10n.play),
          actions: _buildAppBarActions(context),
        ),
        body: _buildBody(context),
      );
    }

    return _buildBody(context);
  }

  List<Widget>? _buildAppBarActions(BuildContext context) {
    final actions = <Widget>[];

    if (config.appBarActions != null) {
      actions.addAll(config.appBarActions!);
    }

    if (config.showSettingsAction && onSettingsPressed != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsPressed,
          tooltip: QuizLocalizations.of(context).settings,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return config.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return config.emptyStateWidget ?? _buildDefaultEmptyState(context);
    }

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final layout = _resolveLayout(sizingInfo);

        if (layout == PlayScreenLayout.list) {
          return _buildListView(context);
        }

        return _buildGridView(context, sizingInfo);
      },
    );
  }

  PlayScreenLayout _resolveLayout(SizingInformation sizingInfo) {
    if (config.layout != PlayScreenLayout.adaptive) {
      return config.layout;
    }

    // Adaptive: use list on mobile portrait, grid otherwise
    if (sizingInfo.deviceScreenType == DeviceScreenType.mobile) {
      final isPortrait =
          sizingInfo.localWidgetSize.width < sizingInfo.localWidgetSize.height;
      return isPortrait ? PlayScreenLayout.list : PlayScreenLayout.grid;
    }

    return PlayScreenLayout.grid;
  }

  Widget _buildGridView(BuildContext context, SizingInformation sizingInfo) {
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
          onTap: onCategorySelected != null
              ? () => onCategorySelected!(category)
              : null,
          onLongPress: onCategoryLongPress != null
              ? () => onCategoryLongPress!(category)
              : null,
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
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
          onTap: onCategorySelected != null
              ? () => onCategorySelected!(category)
              : null,
          onLongPress: onCategoryLongPress != null
              ? () => onCategoryLongPress!(category)
              : null,
        );
      },
    );
  }

  int _getGridColumns(SizingInformation sizingInfo) {
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

  Widget _buildDefaultEmptyState(BuildContext context) {
    final l10n = QuizLocalizations.of(context);
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
              l10n.noSessionsYet, // Reusing existing string
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
}

/// A sliver version of [PlayScreen] for use in CustomScrollView.
class PlayScreenSliver extends StatelessWidget {
  /// List of categories to display.
  final List<QuizCategory> categories;

  /// Callback when a category is selected.
  final void Function(QuizCategory category)? onCategorySelected;

  /// Callback when a category is long-pressed.
  final void Function(QuizCategory category)? onCategoryLongPress;

  /// Configuration for the screen.
  final PlayScreenConfig config;

  /// Creates a [PlayScreenSliver].
  const PlayScreenSliver({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.onCategoryLongPress,
    this.config = const PlayScreenConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final layout = _resolveLayout(sizingInfo);

        if (layout == PlayScreenLayout.list) {
          return _buildSliverList(context);
        }

        return _buildSliverGrid(context, sizingInfo);
      },
    );
  }

  PlayScreenLayout _resolveLayout(SizingInformation sizingInfo) {
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

  Widget _buildSliverGrid(BuildContext context, SizingInformation sizingInfo) {
    final columns = _getGridColumns(sizingInfo);
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.grid();

    return SliverPadding(
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
              onTap: onCategorySelected != null
                  ? () => onCategorySelected!(category)
                  : null,
              onLongPress: onCategoryLongPress != null
                  ? () => onCategoryLongPress!(category)
                  : null,
            );
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildSliverList(BuildContext context) {
    final cardStyle = config.cardStyle ?? const CategoryCardStyle.list();

    return SliverPadding(
      padding: config.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < categories.length - 1 ? config.itemSpacing : 0,
              ),
              child: CategoryCard.list(
                category: category,
                style: cardStyle,
                onTap: onCategorySelected != null
                    ? () => onCategorySelected!(category)
                    : null,
                onLongPress: onCategoryLongPress != null
                    ? () => onCategoryLongPress!(category)
                    : null,
              ),
            );
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  int _getGridColumns(SizingInformation sizingInfo) {
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
}
