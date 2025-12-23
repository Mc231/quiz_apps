import 'package:flutter/material.dart';
import '../l10n/quiz_localizations.dart';

/// Data point for a trend chart.
class TrendDataPoint {
  /// Creates a [TrendDataPoint].
  const TrendDataPoint({
    required this.label,
    required this.value,
    this.date,
  });

  /// Display label (e.g., "Mon", "Jan 1").
  final String label;

  /// Value (usually percentage 0-100).
  final double value;

  /// Optional date for this point.
  final DateTime? date;
}

/// Direction of trend.
enum TrendType {
  /// Improving / increasing.
  improving,

  /// Declining / decreasing.
  declining,

  /// Stable / no change.
  stable,
}

/// A widget showing trend chart with bars.
class TrendsWidget extends StatelessWidget {
  /// Creates a [TrendsWidget].
  const TrendsWidget({
    super.key,
    required this.title,
    required this.dataPoints,
    this.trend,
    this.trendLabel,
    this.height = 160,
    this.barColor,
    this.emptyBarColor,
    this.showLabels = true,
  });

  /// Chart title.
  final String title;

  /// Data points to display.
  final List<TrendDataPoint> dataPoints;

  /// Overall trend direction.
  final TrendType? trend;

  /// Trend label text.
  final String? trendLabel;

  /// Chart height.
  final double height;

  /// Bar color.
  final Color? barColor;

  /// Empty bar background color.
  final Color? emptyBarColor;

  /// Whether to show x-axis labels.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: _buildChart(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trend != null && trendLabel != null) _buildTrendBadge(),
      ],
    );
  }

  Widget _buildTrendBadge() {
    final (color, icon) = _getTrendInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            trendLabel!,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getTrendInfo() {
    switch (trend) {
      case TrendType.improving:
        return (Colors.green, Icons.trending_up);
      case TrendType.declining:
        return (Colors.red, Icons.trending_down);
      case TrendType.stable:
      case null:
        return (Colors.grey, Icons.trending_flat);
    }
  }

  Widget _buildChart(BuildContext context, ThemeData theme) {
    if (dataPoints.isEmpty) {
      return Center(
        child: Text(
          QuizL10n.of(context).noData,
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    final maxValue = dataPoints.map((p) => p.value).reduce(
          (a, b) => a > b ? a : b,
        );
    final effectiveMax = maxValue > 0 ? maxValue : 100.0;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dataPoints.map((point) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildBar(theme, point, effectiveMax),
                ),
              );
            }).toList(),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            children: dataPoints.map((point) {
              return Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBar(ThemeData theme, TrendDataPoint point, double maxValue) {
    final percentage = (point.value / maxValue).clamp(0.0, 1.0);
    final color = barColor ?? theme.primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barHeight = constraints.maxHeight * percentage;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (point.value > 0)
              Text(
                '${point.value.round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: barHeight > 4 ? barHeight : 4,
              decoration: BoxDecoration(
                color: point.value > 0
                    ? color
                    : (emptyBarColor ?? Colors.grey[300]),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A mini trend indicator showing just the direction.
class MiniTrendIndicator extends StatelessWidget {
  /// Creates a [MiniTrendIndicator].
  const MiniTrendIndicator({
    super.key,
    required this.trend,
    this.label,
    this.size = 24,
  });

  /// Trend direction.
  final TrendType trend;

  /// Optional label.
  final String? label;

  /// Icon size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getTrendInfo();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: color),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(
            label!,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  (Color, IconData) _getTrendInfo() {
    switch (trend) {
      case TrendType.improving:
        return (Colors.green, Icons.trending_up);
      case TrendType.declining:
        return (Colors.red, Icons.trending_down);
      case TrendType.stable:
        return (Colors.grey, Icons.trending_flat);
    }
  }
}
