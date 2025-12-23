import 'package:flutter/material.dart';

import '../models/quiz_category.dart';

/// Configuration for category card appearance and behavior.
class CategoryCardStyle {
  /// Border radius for the card.
  final BorderRadius borderRadius;

  /// Elevation for the card.
  final double elevation;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Size for icons when no image is provided.
  final double iconSize;

  /// Size for images.
  final double imageSize;

  /// Spacing between image/icon and text.
  final double spacing;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Background color for the card.
  final Color? backgroundColor;

  /// Color for icons.
  final Color? iconColor;

  /// Whether to show a border around the card.
  final bool showBorder;

  /// Border color when [showBorder] is true.
  final Color? borderColor;

  /// Border width when [showBorder] is true.
  final double borderWidth;

  /// Creates a [CategoryCardStyle].
  const CategoryCardStyle({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
    this.padding = const EdgeInsets.all(16),
    this.iconSize = 48,
    this.imageSize = 64,
    this.spacing = 12,
    this.titleStyle,
    this.subtitleStyle,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1,
  });

  /// Default style for grid layout.
  const CategoryCardStyle.grid()
      : this(
          padding: const EdgeInsets.all(12),
          iconSize: 40,
          imageSize: 56,
          spacing: 8,
        );

  /// Default style for list layout.
  const CategoryCardStyle.list()
      : this(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          iconSize: 32,
          imageSize: 48,
          spacing: 16,
        );

  /// Creates a copy with specified fields replaced.
  CategoryCardStyle copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
    double? iconSize,
    double? imageSize,
    double? spacing,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color? backgroundColor,
    Color? iconColor,
    bool? showBorder,
    Color? borderColor,
    double? borderWidth,
  }) {
    return CategoryCardStyle(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      imageSize: imageSize ?? this.imageSize,
      spacing: spacing ?? this.spacing,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }
}

/// A card widget that displays a quiz category.
///
/// Shows the category's image or icon, title, and optional subtitle.
/// Supports both grid and list layouts through [CategoryCardStyle].
///
/// Example:
/// ```dart
/// CategoryCard(
///   category: europeCategory,
///   onTap: () => navigateToQuiz(europeCategory),
///   style: CategoryCardStyle.grid(),
/// )
/// ```
class CategoryCard extends StatelessWidget {
  /// The category to display.
  final QuizCategory category;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Style configuration for the card.
  final CategoryCardStyle style;

  /// Whether to use vertical layout (icon on top, text below).
  ///
  /// If false, uses horizontal layout (icon on left, text on right).
  final bool vertical;

  /// Creates a [CategoryCard].
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onLongPress,
    this.style = const CategoryCardStyle(),
    this.vertical = true,
  });

  /// Creates a [CategoryCard] for grid layout.
  const CategoryCard.grid({
    super.key,
    required this.category,
    this.onTap,
    this.onLongPress,
    this.style = const CategoryCardStyle.grid(),
  }) : vertical = true;

  /// Creates a [CategoryCard] for list layout.
  const CategoryCard.list({
    super.key,
    required this.category,
    this.onTap,
    this.onLongPress,
    this.style = const CategoryCardStyle.list(),
  }) : vertical = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveTitleStyle = style.titleStyle ??
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    final effectiveSubtitleStyle = style.subtitleStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    final effectiveBackgroundColor =
        style.backgroundColor ?? colorScheme.surface;

    final effectiveIconColor =
        style.iconColor ?? colorScheme.primary;

    final effectiveBorderColor =
        style.borderColor ?? colorScheme.outlineVariant;

    return Card(
      elevation: style.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: style.borderRadius,
        side: style.showBorder
            ? BorderSide(color: effectiveBorderColor, width: style.borderWidth)
            : BorderSide.none,
      ),
      color: effectiveBackgroundColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: style.padding,
          child: vertical
              ? _buildVerticalLayout(
                  context,
                  effectiveTitleStyle,
                  effectiveSubtitleStyle,
                  effectiveIconColor,
                )
              : _buildHorizontalLayout(
                  context,
                  effectiveTitleStyle,
                  effectiveSubtitleStyle,
                  effectiveIconColor,
                ),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(
    BuildContext context,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color iconColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVisual(context, iconColor),
        SizedBox(height: style.spacing),
        _buildTextContent(context, titleStyle, subtitleStyle, centered: true),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    BuildContext context,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color iconColor,
  ) {
    return Row(
      children: [
        _buildVisual(context, iconColor),
        SizedBox(width: style.spacing),
        Expanded(
          child: _buildTextContent(
            context,
            titleStyle,
            subtitleStyle,
            centered: false,
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildVisual(BuildContext context, Color iconColor) {
    if (category.imageProvider != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: category.imageProvider!,
          width: style.imageSize,
          height: style.imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildIconFallback(iconColor);
          },
        ),
      );
    }

    return _buildIconFallback(iconColor);
  }

  Widget _buildIconFallback(Color iconColor) {
    return Container(
      width: style.iconSize,
      height: style.iconSize,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        category.icon ?? Icons.quiz,
        size: style.iconSize * 0.6,
        color: iconColor,
      ),
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle, {
    required bool centered,
  }) {
    final title = category.title(context);
    final subtitle = category.subtitle?.call(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: subtitleStyle,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
