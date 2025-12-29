import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../l10n/quiz_localizations.dart';
import '../models/quiz_category.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_indicator.dart';
import 'category_card.dart';
import 'play_screen_config.dart';

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
    final l10n = QuizL10n.of(context);

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
          tooltip: QuizL10n.of(context).settings,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return config.loadingWidget ?? const LoadingIndicator();
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
    final l10n = QuizL10n.of(context);

    return EmptyStateWidget(
      icon: Icons.category_outlined,
      title: l10n.noSessionsYet, // Reusing existing string
    );
  }
}
