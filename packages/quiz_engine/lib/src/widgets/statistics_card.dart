import 'package:flutter/material.dart';

/// A card widget for displaying a single statistic.
class StatisticsCard extends StatelessWidget {
  /// Creates a [StatisticsCard].
  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendLabel,
    this.onTap,
  });

  /// Title of the statistic.
  final String title;

  /// Main value to display.
  final String value;

  /// Optional subtitle for additional context.
  final String? subtitle;

  /// Optional icon.
  final IconData? icon;

  /// Optional icon color.
  final Color? iconColor;

  /// Trend direction: positive, negative, or neutral.
  final TrendDirection? trend;

  /// Optional trend label.
  final String? trendLabel;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (iconColor ?? theme.primaryColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: iconColor ?? theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trend != null) _buildTrendIndicator(),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (subtitle != null || trendLabel != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (trendLabel != null)
                      Text(
                        trendLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTrendColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final color = _getTrendColor();
    final icon = _getTrendIcon();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Color _getTrendColor() {
    switch (trend) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.neutral:
      case null:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon() {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.neutral:
      case null:
        return Icons.trending_flat;
    }
  }
}

/// Direction of a trend.
enum TrendDirection {
  /// Improving / increasing.
  up,

  /// Declining / decreasing.
  down,

  /// Stable / no change.
  neutral,
}

/// A grid of statistics cards.
class StatisticsGrid extends StatelessWidget {
  /// Creates a [StatisticsGrid].
  const StatisticsGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1.1,
    this.padding = const EdgeInsets.all(16),
  });

  /// Statistics cards to display.
  final List<Widget> children;

  /// Number of columns.
  final int crossAxisCount;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Aspect ratio of each card.
  final double childAspectRatio;

  /// Padding around the grid.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      children: children,
    );
  }
}
