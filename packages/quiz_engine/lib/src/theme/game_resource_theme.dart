import 'package:flutter/material.dart';

/// Theme configuration for game resource buttons (Lives, 50/50, Skip).
///
/// Provides customization options for all visual elements of resource buttons,
/// including sizes, colors, animations, and responsive sizing.
///
/// Example:
/// ```dart
/// final theme = GameResourceTheme.standard();
/// // or
/// final theme = GameResourceTheme.compact(); // For AppBar usage
/// ```
class GameResourceTheme {
  // Button shape and size
  /// Size of the resource button (width and height)
  final double buttonSize;

  /// Size of the icon inside the button
  final double iconSize;

  /// Size of the count badge
  final double badgeSize;

  /// Font size for the badge count text
  final double badgeFontSize;

  /// Border radius for the button container
  final BorderRadius borderRadius;

  /// Elevation for active buttons
  final double elevation;

  /// Elevation for disabled buttons
  final double disabledElevation;

  // Colors
  /// Color for lives (heart) resource
  final Color livesColor;

  /// Color for 50/50 hint resource
  final Color fiftyFiftyColor;

  /// Color for skip hint resource
  final Color skipColor;

  /// Color for disabled/depleted resources
  final Color disabledColor;

  /// Text color for badge count
  final Color badgeTextColor;

  /// Background color for the button container
  final Color buttonBackgroundColor;

  /// Warning color (when count == 1)
  final Color warningColor;

  // Badge styling
  /// Border color for the badge
  final Color badgeBorderColor;

  /// Border width for the badge
  final double badgeBorderWidth;

  /// Badge offset from button edge (negative for overlap)
  final Offset badgeOffset;

  // Animation settings
  /// Duration for tap scale animation
  final Duration tapScaleDuration;

  /// Duration for pulse animation (last resource warning)
  final Duration pulseDuration;

  /// Duration for shake animation (on depletion)
  final Duration shakeDuration;

  /// Duration for badge count change animation
  final Duration countChangeDuration;

  /// Whether to show pulse animation on last resource
  final bool enablePulseOnLastResource;

  /// Whether to show shake animation on depletion
  final bool enableShakeOnDepletion;

  /// Whether to show glow effect on resource use
  final bool enableGlowOnUse;

  /// Scale factor when button is pressed
  final double pressedScale;

  /// Scale factor for pulse animation
  final double pulseScale;

  // Spacing
  /// Spacing between resource buttons
  final double spacingBetweenResources;

  // Responsive sizes (for different screen types)
  /// Button size for mobile devices
  final double buttonSizeMobile;

  /// Button size for tablet devices
  final double buttonSizeTablet;

  /// Button size for desktop devices
  final double buttonSizeDesktop;

  /// Button size for watch devices
  final double buttonSizeWatch;

  /// Icon size for mobile devices
  final double iconSizeMobile;

  /// Icon size for tablet devices
  final double iconSizeTablet;

  /// Icon size for desktop devices
  final double iconSizeDesktop;

  /// Icon size for watch devices
  final double iconSizeWatch;

  /// Badge size for mobile devices
  final double badgeSizeMobile;

  /// Badge size for tablet devices
  final double badgeSizeTablet;

  /// Badge size for desktop devices
  final double badgeSizeDesktop;

  /// Badge size for watch devices
  final double badgeSizeWatch;

  const GameResourceTheme({
    this.buttonSize = 48,
    this.iconSize = 24,
    this.badgeSize = 20,
    this.badgeFontSize = 11,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
    this.disabledElevation = 0,
    this.livesColor = const Color(0xFFE53935), // Red 600
    this.fiftyFiftyColor = const Color(0xFF1E88E5), // Blue 600
    this.skipColor = const Color(0xFFFB8C00), // Orange 600
    this.disabledColor = const Color(0xFF9E9E9E), // Grey 500
    this.badgeTextColor = Colors.white,
    this.buttonBackgroundColor = const Color(0x1A000000), // 10% black
    this.warningColor = const Color(0xFFFF9800), // Orange
    this.badgeBorderColor = Colors.white,
    this.badgeBorderWidth = 2,
    this.badgeOffset = const Offset(4, -4),
    this.tapScaleDuration = const Duration(milliseconds: 100),
    this.pulseDuration = const Duration(milliseconds: 800),
    this.shakeDuration = const Duration(milliseconds: 400),
    this.countChangeDuration = const Duration(milliseconds: 300),
    this.enablePulseOnLastResource = true,
    this.enableShakeOnDepletion = true,
    this.enableGlowOnUse = true,
    this.pressedScale = 0.95,
    this.pulseScale = 1.1,
    this.spacingBetweenResources = 12,
    // Responsive sizes - defaults
    this.buttonSizeMobile = 48,
    this.buttonSizeTablet = 56,
    this.buttonSizeDesktop = 56,
    this.buttonSizeWatch = 36,
    this.iconSizeMobile = 24,
    this.iconSizeTablet = 28,
    this.iconSizeDesktop = 28,
    this.iconSizeWatch = 18,
    this.badgeSizeMobile = 20,
    this.badgeSizeTablet = 24,
    this.badgeSizeDesktop = 24,
    this.badgeSizeWatch = 16,
  });

  /// Creates a standard theme for use in dedicated resource row (below AppBar).
  factory GameResourceTheme.standard() => const GameResourceTheme();

  /// Creates a compact theme for use inline in AppBar.
  factory GameResourceTheme.compact() => const GameResourceTheme(
        buttonSize: 40,
        iconSize: 20,
        badgeSize: 16,
        badgeFontSize: 9,
        elevation: 0,
        spacingBetweenResources: 8,
        buttonBackgroundColor: Colors.transparent,
        // Compact responsive sizes
        buttonSizeMobile: 40,
        buttonSizeTablet: 44,
        buttonSizeDesktop: 44,
        buttonSizeWatch: 32,
        iconSizeMobile: 20,
        iconSizeTablet: 22,
        iconSizeDesktop: 22,
        iconSizeWatch: 16,
        badgeSizeMobile: 16,
        badgeSizeTablet: 18,
        badgeSizeDesktop: 18,
        badgeSizeWatch: 14,
      );

  /// Creates a theme based on the given color scheme.
  factory GameResourceTheme.fromColorScheme(ColorScheme scheme) {
    return GameResourceTheme(
      livesColor: scheme.error,
      fiftyFiftyColor: scheme.primary,
      skipColor: scheme.tertiary,
      disabledColor: scheme.outline,
      badgeTextColor: scheme.onPrimary,
      buttonBackgroundColor: scheme.surfaceContainerHighest,
      warningColor: scheme.tertiary,
      badgeBorderColor: scheme.surface,
    );
  }

  /// Returns the button size for the given screen type.
  double getButtonSize(ScreenType screenType) {
    return switch (screenType) {
      ScreenType.mobile => buttonSizeMobile,
      ScreenType.tablet => buttonSizeTablet,
      ScreenType.desktop => buttonSizeDesktop,
      ScreenType.watch => buttonSizeWatch,
    };
  }

  /// Returns the icon size for the given screen type.
  double getIconSize(ScreenType screenType) {
    return switch (screenType) {
      ScreenType.mobile => iconSizeMobile,
      ScreenType.tablet => iconSizeTablet,
      ScreenType.desktop => iconSizeDesktop,
      ScreenType.watch => iconSizeWatch,
    };
  }

  /// Returns the badge size for the given screen type.
  double getBadgeSize(ScreenType screenType) {
    return switch (screenType) {
      ScreenType.mobile => badgeSizeMobile,
      ScreenType.tablet => badgeSizeTablet,
      ScreenType.desktop => badgeSizeDesktop,
      ScreenType.watch => badgeSizeWatch,
    };
  }

  /// Returns the badge font size scaled for the given screen type.
  double getBadgeFontSize(ScreenType screenType) {
    final badgeRatio = getBadgeSize(screenType) / badgeSizeMobile;
    return badgeFontSize * badgeRatio;
  }

  /// Returns the color for the given resource type.
  Color getResourceColor(GameResourceType type) {
    return switch (type) {
      GameResourceType.lives => livesColor,
      GameResourceType.fiftyFifty => fiftyFiftyColor,
      GameResourceType.skip => skipColor,
    };
  }

  /// Creates a copy of this theme with the specified fields replaced.
  GameResourceTheme copyWith({
    double? buttonSize,
    double? iconSize,
    double? badgeSize,
    double? badgeFontSize,
    BorderRadius? borderRadius,
    double? elevation,
    double? disabledElevation,
    Color? livesColor,
    Color? fiftyFiftyColor,
    Color? skipColor,
    Color? disabledColor,
    Color? badgeTextColor,
    Color? buttonBackgroundColor,
    Color? warningColor,
    Color? badgeBorderColor,
    double? badgeBorderWidth,
    Offset? badgeOffset,
    Duration? tapScaleDuration,
    Duration? pulseDuration,
    Duration? shakeDuration,
    Duration? countChangeDuration,
    bool? enablePulseOnLastResource,
    bool? enableShakeOnDepletion,
    bool? enableGlowOnUse,
    double? pressedScale,
    double? pulseScale,
    double? spacingBetweenResources,
    double? buttonSizeMobile,
    double? buttonSizeTablet,
    double? buttonSizeDesktop,
    double? buttonSizeWatch,
    double? iconSizeMobile,
    double? iconSizeTablet,
    double? iconSizeDesktop,
    double? iconSizeWatch,
    double? badgeSizeMobile,
    double? badgeSizeTablet,
    double? badgeSizeDesktop,
    double? badgeSizeWatch,
  }) {
    return GameResourceTheme(
      buttonSize: buttonSize ?? this.buttonSize,
      iconSize: iconSize ?? this.iconSize,
      badgeSize: badgeSize ?? this.badgeSize,
      badgeFontSize: badgeFontSize ?? this.badgeFontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      disabledElevation: disabledElevation ?? this.disabledElevation,
      livesColor: livesColor ?? this.livesColor,
      fiftyFiftyColor: fiftyFiftyColor ?? this.fiftyFiftyColor,
      skipColor: skipColor ?? this.skipColor,
      disabledColor: disabledColor ?? this.disabledColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      warningColor: warningColor ?? this.warningColor,
      badgeBorderColor: badgeBorderColor ?? this.badgeBorderColor,
      badgeBorderWidth: badgeBorderWidth ?? this.badgeBorderWidth,
      badgeOffset: badgeOffset ?? this.badgeOffset,
      tapScaleDuration: tapScaleDuration ?? this.tapScaleDuration,
      pulseDuration: pulseDuration ?? this.pulseDuration,
      shakeDuration: shakeDuration ?? this.shakeDuration,
      countChangeDuration: countChangeDuration ?? this.countChangeDuration,
      enablePulseOnLastResource:
          enablePulseOnLastResource ?? this.enablePulseOnLastResource,
      enableShakeOnDepletion:
          enableShakeOnDepletion ?? this.enableShakeOnDepletion,
      enableGlowOnUse: enableGlowOnUse ?? this.enableGlowOnUse,
      pressedScale: pressedScale ?? this.pressedScale,
      pulseScale: pulseScale ?? this.pulseScale,
      spacingBetweenResources:
          spacingBetweenResources ?? this.spacingBetweenResources,
      buttonSizeMobile: buttonSizeMobile ?? this.buttonSizeMobile,
      buttonSizeTablet: buttonSizeTablet ?? this.buttonSizeTablet,
      buttonSizeDesktop: buttonSizeDesktop ?? this.buttonSizeDesktop,
      buttonSizeWatch: buttonSizeWatch ?? this.buttonSizeWatch,
      iconSizeMobile: iconSizeMobile ?? this.iconSizeMobile,
      iconSizeTablet: iconSizeTablet ?? this.iconSizeTablet,
      iconSizeDesktop: iconSizeDesktop ?? this.iconSizeDesktop,
      iconSizeWatch: iconSizeWatch ?? this.iconSizeWatch,
      badgeSizeMobile: badgeSizeMobile ?? this.badgeSizeMobile,
      badgeSizeTablet: badgeSizeTablet ?? this.badgeSizeTablet,
      badgeSizeDesktop: badgeSizeDesktop ?? this.badgeSizeDesktop,
      badgeSizeWatch: badgeSizeWatch ?? this.badgeSizeWatch,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameResourceTheme &&
        other.buttonSize == buttonSize &&
        other.iconSize == iconSize &&
        other.badgeSize == badgeSize &&
        other.badgeFontSize == badgeFontSize &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation &&
        other.disabledElevation == disabledElevation &&
        other.livesColor == livesColor &&
        other.fiftyFiftyColor == fiftyFiftyColor &&
        other.skipColor == skipColor &&
        other.disabledColor == disabledColor &&
        other.badgeTextColor == badgeTextColor &&
        other.buttonBackgroundColor == buttonBackgroundColor &&
        other.warningColor == warningColor &&
        other.badgeBorderColor == badgeBorderColor &&
        other.badgeBorderWidth == badgeBorderWidth &&
        other.badgeOffset == badgeOffset &&
        other.tapScaleDuration == tapScaleDuration &&
        other.pulseDuration == pulseDuration &&
        other.shakeDuration == shakeDuration &&
        other.countChangeDuration == countChangeDuration &&
        other.enablePulseOnLastResource == enablePulseOnLastResource &&
        other.enableShakeOnDepletion == enableShakeOnDepletion &&
        other.enableGlowOnUse == enableGlowOnUse &&
        other.pressedScale == pressedScale &&
        other.pulseScale == pulseScale &&
        other.spacingBetweenResources == spacingBetweenResources &&
        other.buttonSizeMobile == buttonSizeMobile &&
        other.buttonSizeTablet == buttonSizeTablet &&
        other.buttonSizeDesktop == buttonSizeDesktop &&
        other.buttonSizeWatch == buttonSizeWatch &&
        other.iconSizeMobile == iconSizeMobile &&
        other.iconSizeTablet == iconSizeTablet &&
        other.iconSizeDesktop == iconSizeDesktop &&
        other.iconSizeWatch == iconSizeWatch &&
        other.badgeSizeMobile == badgeSizeMobile &&
        other.badgeSizeTablet == badgeSizeTablet &&
        other.badgeSizeDesktop == badgeSizeDesktop &&
        other.badgeSizeWatch == badgeSizeWatch;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      buttonSize,
      iconSize,
      badgeSize,
      badgeFontSize,
      borderRadius,
      elevation,
      disabledElevation,
      livesColor,
      fiftyFiftyColor,
      skipColor,
      disabledColor,
      badgeTextColor,
      buttonBackgroundColor,
      warningColor,
      badgeBorderColor,
      badgeBorderWidth,
      badgeOffset,
      tapScaleDuration,
      pulseDuration,
      shakeDuration,
      countChangeDuration,
      enablePulseOnLastResource,
      enableShakeOnDepletion,
      enableGlowOnUse,
      pressedScale,
      pulseScale,
      spacingBetweenResources,
      buttonSizeMobile,
      buttonSizeTablet,
      buttonSizeDesktop,
      buttonSizeWatch,
      iconSizeMobile,
      iconSizeTablet,
      iconSizeDesktop,
      iconSizeWatch,
      badgeSizeMobile,
      badgeSizeTablet,
      badgeSizeDesktop,
      badgeSizeWatch,
    ]);
  }
}

/// Types of game resources.
enum GameResourceType {
  /// Lives (hearts)
  lives,

  /// 50/50 hint (eliminate 2 wrong answers)
  fiftyFifty,

  /// Skip hint (skip question without penalty)
  skip,
}

/// Screen types for responsive sizing.
enum ScreenType {
  /// Mobile phone (< 600dp width)
  mobile,

  /// Tablet (600-1024dp width)
  tablet,

  /// Desktop (> 1024dp width)
  desktop,

  /// Watch (< 300dp width)
  watch,
}

/// Extension to determine screen type from Size.
extension ScreenTypeExtension on Size {
  /// Returns the screen type based on width.
  ScreenType get screenType {
    if (width < 300) return ScreenType.watch;
    if (width < 600) return ScreenType.mobile;
    if (width < 1024) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

/// Extension to get screen type from BuildContext.
extension ScreenTypeContextExtension on BuildContext {
  /// Returns the screen type based on the current media query.
  ScreenType get screenType => MediaQuery.sizeOf(this).screenType;
}
