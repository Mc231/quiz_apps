import 'package:flutter/material.dart';

import '../theme/game_resource_theme.dart';
import 'game_resource_panel.dart';

/// Where the resource panel should be placed.
enum ResourcePanelPlacement {
  /// Inline with AppBar actions (landscape, tablet, desktop).
  appBar,

  /// Dedicated row below AppBar (portrait, watch).
  belowAppBar,
}

/// Determines the appropriate panel placement based on screen characteristics.
///
/// Decision logic:
/// - Mobile Portrait → belowAppBar (larger touch targets)
/// - Mobile Landscape → appBar (save vertical space)
/// - Tablet/Desktop → appBar (plenty of horizontal space)
/// - Watch → belowAppBar (very limited AppBar space)
ResourcePanelPlacement getResourcePanelPlacement(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final screenType = size.screenType;
  final orientation = MediaQuery.orientationOf(context);

  return switch ((screenType, orientation)) {
    (ScreenType.mobile, Orientation.portrait) => ResourcePanelPlacement.belowAppBar,
    (ScreenType.mobile, Orientation.landscape) => ResourcePanelPlacement.appBar,
    (ScreenType.tablet, _) => ResourcePanelPlacement.appBar,
    (ScreenType.desktop, _) => ResourcePanelPlacement.appBar,
    (ScreenType.watch, _) => ResourcePanelPlacement.belowAppBar,
  };
}

/// A wrapper that shows the resource panel only at the correct placement.
///
/// Use two instances of this widget - one in the AppBar and one below it.
/// Each instance will only render when it's the active placement location.
///
/// Example:
/// ```dart
/// // In AppBar actions:
/// AdaptiveResourcePanel(
///   data: resourceData,
///   targetPlacement: ResourcePanelPlacement.appBar,
/// )
///
/// // Below AppBar in body:
/// AdaptiveResourcePanel(
///   data: resourceData,
///   targetPlacement: ResourcePanelPlacement.belowAppBar,
/// )
/// ```
class AdaptiveResourcePanel extends StatelessWidget {
  /// The resource panel data to display.
  final GameResourcePanelData data;

  /// The target placement for this instance.
  ///
  /// The panel will only render if the current screen's placement
  /// matches this target placement.
  final ResourcePanelPlacement targetPlacement;

  /// Override theme for this panel.
  final GameResourceTheme? theme;

  /// Padding around the panel (only applies when rendered).
  final EdgeInsets padding;

  /// Background decoration for the panel container (belowAppBar only).
  final BoxDecoration? decoration;

  const AdaptiveResourcePanel({
    super.key,
    required this.data,
    required this.targetPlacement,
    this.theme,
    this.padding = EdgeInsets.zero,
    this.decoration,
  });

  /// Creates a panel for AppBar placement with compact theme.
  factory AdaptiveResourcePanel.forAppBar({
    Key? key,
    required GameResourcePanelData data,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8),
  }) {
    return AdaptiveResourcePanel(
      key: key,
      data: data,
      targetPlacement: ResourcePanelPlacement.appBar,
      theme: GameResourceTheme.compact(),
      padding: padding,
    );
  }

  /// Creates a panel for below AppBar placement with standard theme.
  factory AdaptiveResourcePanel.forBody({
    Key? key,
    required GameResourcePanelData data,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 8),
    BoxDecoration? decoration,
  }) {
    return AdaptiveResourcePanel(
      key: key,
      data: data,
      targetPlacement: ResourcePanelPlacement.belowAppBar,
      theme: GameResourceTheme.standard(),
      padding: padding,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is the correct placement for current screen
    final currentPlacement = getResourcePanelPlacement(context);
    if (currentPlacement != targetPlacement) {
      return const SizedBox.shrink();
    }

    // Don't render if no resources
    if (!data.hasResources) {
      return const SizedBox.shrink();
    }

    // Determine theme based on placement
    final effectiveTheme = theme ??
        (targetPlacement == ResourcePanelPlacement.appBar
            ? GameResourceTheme.compact()
            : GameResourceTheme.standard());

    Widget panel = data.toPanel(
      theme: effectiveTheme,
      alignment: MainAxisAlignment.center,
    );

    // Wrap with padding
    if (padding != EdgeInsets.zero) {
      panel = Padding(padding: padding, child: panel);
    }

    // Wrap with decoration container (for belowAppBar styling)
    if (decoration != null && targetPlacement == ResourcePanelPlacement.belowAppBar) {
      panel = DecoratedBox(
        decoration: decoration!,
        child: panel,
      );
    }

    return panel;
  }
}

/// A convenience widget that manages both AppBar and body placements.
///
/// Provides the panel data to both locations and handles the adaptive
/// rendering automatically.
///
/// Example:
/// ```dart
/// class QuizScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AdaptiveResourcePanelScope(
///       data: GameResourcePanelData(...),
///       builder: (context, appBarPanel, bodyPanel) {
///         return Scaffold(
///           appBar: AppBar(
///             actions: [appBarPanel, ...otherActions],
///           ),
///           body: Column(
///             children: [
///               bodyPanel,
///               Expanded(child: quizContent),
///             ],
///           ),
///         );
///       },
///     );
///   }
/// }
/// ```
class AdaptiveResourcePanelScope extends StatelessWidget {
  /// The resource panel data.
  final GameResourcePanelData data;

  /// Builder that receives both panel widgets.
  final Widget Function(
    BuildContext context,
    Widget appBarPanel,
    Widget bodyPanel,
  ) builder;

  /// Padding for AppBar panel.
  final EdgeInsets appBarPadding;

  /// Padding for body panel.
  final EdgeInsets bodyPadding;

  /// Decoration for body panel container.
  final BoxDecoration? bodyDecoration;

  const AdaptiveResourcePanelScope({
    super.key,
    required this.data,
    required this.builder,
    this.appBarPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.bodyPadding = const EdgeInsets.symmetric(vertical: 8),
    this.bodyDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final appBarPanel = AdaptiveResourcePanel.forAppBar(
      data: data,
      padding: appBarPadding,
    );

    final bodyPanel = AdaptiveResourcePanel.forBody(
      data: data,
      padding: bodyPadding,
      decoration: bodyDecoration,
    );

    return builder(context, appBarPanel, bodyPanel);
  }
}

/// Extension for checking placement.
extension ResourcePanelPlacementExtension on BuildContext {
  /// Returns the current resource panel placement for this context.
  ResourcePanelPlacement get resourcePanelPlacement =>
      getResourcePanelPlacement(this);

  /// Returns true if resources should be shown in AppBar.
  bool get shouldShowResourcesInAppBar =>
      resourcePanelPlacement == ResourcePanelPlacement.appBar;

  /// Returns true if resources should be shown below AppBar.
  bool get shouldShowResourcesBelowAppBar =>
      resourcePanelPlacement == ResourcePanelPlacement.belowAppBar;
}
