import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

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

/// A sliver version of PlayScreen for use in CustomScrollView.
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

/// Extension to add copyWith functionality to [PlayScreenConfig].
extension PlayScreenConfigCopyWith on PlayScreenConfig {
  /// Creates a copy of this config with the given fields replaced.
  PlayScreenConfig copyWith({
    String? title,
    PlayScreenLayout? layout,
    int? gridColumnsMobile,
    int? gridColumnsTablet,
    int? gridColumnsDesktop,
    double? gridAspectRatio,
    double? itemSpacing,
    EdgeInsets? padding,
    CategoryCardStyle? cardStyle,
    bool? showSettingsAction,
    List<Widget>? appBarActions,
    bool? showAppBar,
    Widget? emptyStateWidget,
    Widget? loadingWidget,
  }) {
    return PlayScreenConfig(
      title: title ?? this.title,
      layout: layout ?? this.layout,
      gridColumnsMobile: gridColumnsMobile ?? this.gridColumnsMobile,
      gridColumnsTablet: gridColumnsTablet ?? this.gridColumnsTablet,
      gridColumnsDesktop: gridColumnsDesktop ?? this.gridColumnsDesktop,
      gridAspectRatio: gridAspectRatio ?? this.gridAspectRatio,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      padding: padding ?? this.padding,
      cardStyle: cardStyle ?? this.cardStyle,
      showSettingsAction: showSettingsAction ?? this.showSettingsAction,
      appBarActions: appBarActions ?? this.appBarActions,
      showAppBar: showAppBar ?? this.showAppBar,
      emptyStateWidget: emptyStateWidget ?? this.emptyStateWidget,
      loadingWidget: loadingWidget ?? this.loadingWidget,
    );
  }
}
