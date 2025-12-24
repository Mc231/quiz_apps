import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Data point for progress tracking.
class ProgressDataPoint {
  /// Creates a [ProgressDataPoint].
  const ProgressDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.sessions = 0,
    this.questionsAnswered = 0,
  });

  /// The date for this data point.
  final DateTime date;

  /// The value (typically 0-100 for percentage).
  final double value;

  /// Optional label for display.
  final String? label;

  /// Number of sessions on this date.
  final int sessions;

  /// Number of questions answered on this date.
  final int questionsAnswered;
}

/// Time range for progress chart.
enum ProgressTimeRange {
  /// Last 7 days.
  week,

  /// Last 30 days.
  month,

  /// Last 90 days.
  quarter,

  /// Last 365 days.
  year,

  /// All time.
  allTime,
}

/// Widget showing progress/improvement over time with a line/area chart.
class ProgressChartWidget extends StatelessWidget {
  /// Creates a [ProgressChartWidget].
  const ProgressChartWidget({
    super.key,
    required this.dataPoints,
    this.title,
    this.subtitle,
    this.height = 200,
    this.showArea = true,
    this.showPoints = true,
    this.showGrid = true,
    this.lineColor,
    this.areaColor,
    this.gridColor,
    this.improvement,
  });

  /// Data points to display.
  final List<ProgressDataPoint> dataPoints;

  /// Chart title.
  final String? title;

  /// Chart subtitle.
  final String? subtitle;

  /// Chart height.
  final double height;

  /// Whether to show filled area under the line.
  final bool showArea;

  /// Whether to show data points.
  final bool showPoints;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Line color (defaults to primary).
  final Color? lineColor;

  /// Area fill color (defaults to line color with opacity).
  final Color? areaColor;

  /// Grid line color.
  final Color? gridColor;

  /// Overall improvement percentage (positive = improving).
  final double? improvement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

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
            if (title != null) _buildHeader(context, theme, l10n),
            if (title != null) const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: dataPoints.isEmpty
                  ? _buildEmptyState(context, l10n)
                  : _buildChart(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, QuizLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (improvement != null) _buildImprovementBadge(l10n),
      ],
    );
  }

  Widget _buildImprovementBadge(QuizLocalizations l10n) {
    final isPositive = improvement! >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$sign${improvement!.round()}%',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, QuizLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noProgressData,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, ThemeData theme) {
    final color = lineColor ?? theme.primaryColor;

    return CustomPaint(
      size: Size.infinite,
      painter: _ProgressChartPainter(
        dataPoints: dataPoints,
        lineColor: color,
        areaColor: areaColor ?? color.withValues(alpha: 0.2),
        gridColor: gridColor ?? Colors.grey[300]!,
        showArea: showArea,
        showPoints: showPoints,
        showGrid: showGrid,
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  _ProgressChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.areaColor,
    required this.gridColor,
    required this.showArea,
    required this.showPoints,
    required this.showGrid,
  });

  final List<ProgressDataPoint> dataPoints;
  final Color lineColor;
  final Color areaColor;
  final Color gridColor;
  final bool showArea;
  final bool showPoints;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    const leftPadding = 40.0;
    const bottomPadding = 30.0;
    const topPadding = 10.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    // Find min/max values
    final maxValue = dataPoints.map((p) => p.value).reduce(
          (a, b) => a > b ? a : b,
        );
    final minValue = dataPoints.map((p) => p.value).reduce(
          (a, b) => a < b ? a : b,
        );

    // Add padding to range
    final valueRange = maxValue - minValue;
    final effectiveMin = (minValue - valueRange * 0.1).clamp(0.0, 100.0);
    final effectiveMax = (maxValue + valueRange * 0.1).clamp(0.0, 100.0);
    final effectiveRange =
        effectiveMax - effectiveMin > 0 ? effectiveMax - effectiveMin : 10.0;

    // Draw grid
    if (showGrid) {
      _drawGrid(
        canvas,
        size,
        leftPadding,
        topPadding,
        chartWidth,
        chartHeight,
        effectiveMin,
        effectiveMax,
      );
    }

    // Calculate points
    final points = <Offset>[];
    for (var i = 0; i < dataPoints.length; i++) {
      final x = leftPadding + (i / (dataPoints.length - 1)) * chartWidth;
      final normalizedValue =
          (dataPoints[i].value - effectiveMin) / effectiveRange;
      final y = topPadding + chartHeight - (normalizedValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw area
    if (showArea && points.length > 1) {
      final areaPath = Path();
      areaPath.moveTo(points.first.dx, topPadding + chartHeight);
      areaPath.lineTo(points.first.dx, points.first.dy);

      for (var i = 1; i < points.length; i++) {
        areaPath.lineTo(points[i].dx, points[i].dy);
      }

      areaPath.lineTo(points.last.dx, topPadding + chartHeight);
      areaPath.close();

      final areaPaint = Paint()
        ..color = areaColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw line
    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (var i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw points
    if (showPoints) {
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final point in points) {
        canvas.drawCircle(point, 5, pointBorderPaint);
        canvas.drawCircle(point, 4, pointPaint);
      }
    }

    // Draw x-axis labels
    _drawXAxisLabels(canvas, size, leftPadding, chartWidth, bottomPadding);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double leftPadding,
    double topPadding,
    double chartWidth,
    double chartHeight,
    double minValue,
    double maxValue,
  ) {
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );

    // Horizontal grid lines (5 lines)
    const gridLines = 4;
    for (var i = 0; i <= gridLines; i++) {
      final y = topPadding + (i / gridLines) * chartHeight;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - 10, y),
        gridPaint,
      );

      // Value label
      final value = maxValue - (i / gridLines) * (maxValue - minValue);
      final textSpan = TextSpan(
        text: '${value.round()}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }
  }

  void _drawXAxisLabels(
    Canvas canvas,
    Size size,
    double leftPadding,
    double chartWidth,
    double bottomPadding,
  ) {
    if (dataPoints.isEmpty) return;

    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );

    // Show first, middle, and last labels
    final labelsToShow = [
      0,
      if (dataPoints.length > 2) dataPoints.length ~/ 2,
      if (dataPoints.length > 1) dataPoints.length - 1,
    ];

    for (final index in labelsToShow) {
      final point = dataPoints[index];
      final label =
          point.label ?? '${point.date.day}/${point.date.month}';

      final x = leftPadding + (index / (dataPoints.length - 1)) * chartWidth;

      final textSpan = TextSpan(
        text: label,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          size.height - bottomPadding + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return dataPoints != oldDelegate.dataPoints ||
        lineColor != oldDelegate.lineColor ||
        showArea != oldDelegate.showArea;
  }
}

/// Time range selector for progress charts.
class ProgressTimeRangeSelector extends StatelessWidget {
  /// Creates a [ProgressTimeRangeSelector].
  const ProgressTimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.availableRanges = const [
      ProgressTimeRange.week,
      ProgressTimeRange.month,
      ProgressTimeRange.quarter,
    ],
  });

  /// Currently selected time range.
  final ProgressTimeRange selectedRange;

  /// Callback when range is changed.
  final void Function(ProgressTimeRange range) onRangeChanged;

  /// Available ranges to show.
  final List<ProgressTimeRange> availableRanges;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableRanges.map((range) {
          final isSelected = range == selectedRange;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_getRangeLabel(range, l10n)),
              selected: isSelected,
              onSelected: (_) => onRangeChanged(range),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getRangeLabel(ProgressTimeRange range, QuizLocalizations l10n) {
    switch (range) {
      case ProgressTimeRange.week:
        return l10n.lastWeek;
      case ProgressTimeRange.month:
        return l10n.lastMonth;
      case ProgressTimeRange.quarter:
        return l10n.last3Months;
      case ProgressTimeRange.year:
        return l10n.lastYear;
      case ProgressTimeRange.allTime:
        return l10n.allTime;
    }
  }
}

/// Summary statistics for a progress period.
class ProgressSummary {
  /// Creates a [ProgressSummary].
  const ProgressSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.startValue,
    required this.endValue,
    required this.averageValue,
    required this.highestValue,
    required this.lowestValue,
    required this.totalSessions,
    required this.totalQuestions,
  });

  /// Start of the period.
  final DateTime periodStart;

  /// End of the period.
  final DateTime periodEnd;

  /// Value at the start of the period.
  final double startValue;

  /// Value at the end of the period.
  final double endValue;

  /// Average value over the period.
  final double averageValue;

  /// Highest value in the period.
  final double highestValue;

  /// Lowest value in the period.
  final double lowestValue;

  /// Total sessions in the period.
  final int totalSessions;

  /// Total questions answered in the period.
  final int totalQuestions;

  /// Change from start to end.
  double get change => endValue - startValue;

  /// Percentage change from start.
  double get percentageChange =>
      startValue > 0 ? ((endValue - startValue) / startValue) * 100 : 0;

  /// Whether there was improvement.
  bool get isImproving => change > 0;

  /// Whether performance was stable.
  bool get isStable => change.abs() < 2;

  /// Whether there was decline.
  bool get isDeclining => change < 0;
}

/// Compact progress summary widget.
class ProgressSummaryWidget extends StatelessWidget {
  /// Creates a [ProgressSummaryWidget].
  const ProgressSummaryWidget({
    super.key,
    required this.summary,
  });

  /// Summary data to display.
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

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
            Text(
              l10n.progressSummary,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.averageScore,
                    '${summary.averageValue.round()}%',
                    Icons.score,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.change,
                    '${summary.change >= 0 ? '+' : ''}${summary.change.round()}%',
                    summary.isImproving ? Icons.trending_up : Icons.trending_down,
                    summary.isImproving ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.totalSessions,
                    summary.totalSessions.toString(),
                    Icons.quiz,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.totalQuestions,
                    summary.totalQuestions.toString(),
                    Icons.help_outline,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
