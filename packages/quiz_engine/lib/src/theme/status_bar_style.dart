import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that styles the system status bar to match the app's theme.
///
/// Wraps its child with [AnnotatedRegion] to set the status bar color
/// and icon brightness based on the current theme or provided color.
///
/// Example usage:
/// ```dart
/// StatusBarStyle(
///   child: Scaffold(
///     appBar: AppBar(title: Text('My Screen')),
///     body: MyContent(),
///   ),
/// )
/// ```
class StatusBarStyle extends StatelessWidget {
  /// Creates a [StatusBarStyle] widget.
  const StatusBarStyle({
    super.key,
    required this.child,
    this.statusBarColor,
    this.iconBrightness,
  });

  /// Creates a [StatusBarStyle] that matches the AppBar color.
  ///
  /// This is the most common use case - status bar blends with AppBar.
  const StatusBarStyle.matchAppBar({
    super.key,
    required this.child,
  })  : statusBarColor = null,
        iconBrightness = null;

  /// Creates a [StatusBarStyle] with a transparent status bar.
  ///
  /// Useful for screens with edge-to-edge content or custom headers.
  const StatusBarStyle.transparent({
    super.key,
    required this.child,
    this.iconBrightness,
  }) : statusBarColor = Colors.transparent;

  /// Creates a [StatusBarStyle] with light icons (for dark backgrounds).
  const StatusBarStyle.light({
    super.key,
    required this.child,
    this.statusBarColor,
  }) : iconBrightness = Brightness.light;

  /// Creates a [StatusBarStyle] with dark icons (for light backgrounds).
  const StatusBarStyle.dark({
    super.key,
    required this.child,
    this.statusBarColor,
  }) : iconBrightness = Brightness.dark;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The background color of the status bar.
  ///
  /// If null, uses the AppBar background color from the theme.
  /// On iOS, this only affects the status bar when using
  /// [SystemUiOverlayStyle.statusBarColor] on Android.
  final Color? statusBarColor;

  /// The brightness of the status bar icons.
  ///
  /// If null, automatically determined based on theme brightness:
  /// - [Brightness.light] icons for dark themes
  /// - [Brightness.dark] icons for light themes
  final Brightness? iconBrightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = statusBarColor ??
        theme.appBarTheme.backgroundColor ??
        theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconBrightness =
        iconBrightness ?? (isDark ? Brightness.light : Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Android status bar color
        statusBarColor: effectiveColor,
        // Android status bar icon brightness
        statusBarIconBrightness: effectiveIconBrightness,
        // iOS status bar brightness (inverted logic: dark brightness = light icons)
        statusBarBrightness:
            effectiveIconBrightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        // Navigation bar styling (Android)
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: effectiveIconBrightness,
      ),
      child: child,
    );
  }
}