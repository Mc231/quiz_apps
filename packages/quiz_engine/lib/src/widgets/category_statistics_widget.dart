import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';
import 'empty_state_widget.dart';

/// Data model for category statistics display.
class CategoryStatisticsData {
  /// Creates a [CategoryStatisticsData].
  const CategoryStatisticsData({
    required this.categoryId,
    required this.categoryName,
    required this.totalSessions,
    required this.averageScore,
    required this.bestScore,
    required this.accuracy,
    required this.totalQuestions,
    this.icon,
    this.color,
    this.lastPlayedAt,
  });

  /// Category identifier.
  final String categoryId;

  /// Display name of the category.
  final String categoryName;

  /// Total sessions played in this category.
  final int totalSessions;

  /// Average score percentage.
  final double averageScore;

  /// Best score percentage.
  final double bestScore;

  /// Accuracy percentage.
  final double accuracy;

  /// Total questions answered.
  final int totalQuestions;

  /// Optional icon for the category.
  final IconData? icon;

  /// Optional color for the category.
  final Color? color;

  /// When this category was last played.
  final DateTime? lastPlayedAt;

  /// Whether this category has been played.
  bool get hasData => totalSessions > 0;
}

/// Widget displaying statistics breakdown by category.
class CategoryStatisticsWidget extends StatelessWidget {
  /// Creates a [CategoryStatisticsWidget].
  const CategoryStatisticsWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.sortBy = CategorySortBy.sessions,
    this.maxCategories,
    this.showEmptyCategories = false,
  });

  /// List of category statistics.
  final List<CategoryStatisticsData> categories;

  /// Callback when a category is tapped.
  final void Function(CategoryStatisticsData category)? onCategoryTap;

  /// How to sort categories.
  final CategorySortBy sortBy;

  /// Maximum number of categories to show (null for all).
  final int? maxCategories;

  /// Whether to show categories with no data.
  final bool showEmptyCategories;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    var filteredCategories = showEmptyCategories
        ? categories
        : categories.where((c) => c.hasData).toList();

    // Sort categories
    filteredCategories = _sortCategories(filteredCategories);

    // Limit if needed
    if (maxCategories != null && filteredCategories.length > maxCategories!) {
      filteredCategories = filteredCategories.take(maxCategories!).toList();
    }

    if (filteredCategories.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.categoryBreakdown,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...filteredCategories.map((category) => _buildCategoryItem(
                context,
                category,
                l10n,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<CategoryStatisticsData> _sortCategories(
      List<CategoryStatisticsData> categories) {
    switch (sortBy) {
      case CategorySortBy.sessions:
        return categories
          ..sort((a, b) => b.totalSessions.compareTo(a.totalSessions));
      case CategorySortBy.averageScore:
        return categories
          ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
      case CategorySortBy.bestScore:
        return categories..sort((a, b) => b.bestScore.compareTo(a.bestScore));
      case CategorySortBy.accuracy:
        return categories..sort((a, b) => b.accuracy.compareTo(a.accuracy));
      case CategorySortBy.alphabetical:
        return categories
          ..sort((a, b) => a.categoryName.compareTo(b.categoryName));
      case CategorySortBy.lastPlayed:
        return categories
          ..sort((a, b) {
            if (a.lastPlayedAt == null && b.lastPlayedAt == null) return 0;
            if (a.lastPlayedAt == null) return 1;
            if (b.lastPlayedAt == null) return -1;
            return b.lastPlayedAt!.compareTo(a.lastPlayedAt!);
          });
    }
  }

  Widget _buildEmptyState(BuildContext context, QuizLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: EmptyStateWidget.compact(
        icon: Icons.category_outlined,
        title: l10n.noCategoryData,
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryStatisticsData category,
    QuizLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final color = category.color ?? theme.primaryColor;

    return InkWell(
      onTap: onCategoryTap != null ? () => onCategoryTap!(category) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon ?? Icons.folder_outlined,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.sessionsCount(category.totalSessions),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Stats column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildScoreBadge(context, category.averageScore, l10n),
                const SizedBox(height: 4),
                Text(
                  '${l10n.bestScore}: ${category.bestScore.round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Chevron
            if (onCategoryTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(
      BuildContext context, double score, QuizLocalizations l10n) {
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${score.round()}%',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// How to sort categories in the breakdown.
enum CategorySortBy {
  /// Sort by number of sessions (most played first).
  sessions,

  /// Sort by average score (highest first).
  averageScore,

  /// Sort by best score (highest first).
  bestScore,

  /// Sort by accuracy (highest first).
  accuracy,

  /// Sort alphabetically by name.
  alphabetical,

  /// Sort by last played date (most recent first).
  lastPlayed,
}

/// Compact category statistics card for grid display.
class CategoryStatisticsCard extends StatelessWidget {
  /// Creates a [CategoryStatisticsCard].
  const CategoryStatisticsCard({
    super.key,
    required this.category,
    this.onTap,
  });

  /// Category data to display.
  final CategoryStatisticsData category;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category.icon ?? Icons.folder_outlined,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  _buildScoreIndicator(category.averageScore),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.categoryName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.totalSessions} sessions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Progress bar for accuracy
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: category.accuracy / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(category.accuracy),
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(double score) {
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${score.round()}%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Grid layout for category statistics cards.
class CategoryStatisticsGrid extends StatelessWidget {
  /// Creates a [CategoryStatisticsGrid].
  const CategoryStatisticsGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  });

  /// List of category statistics.
  final List<CategoryStatisticsData> categories;

  /// Callback when a category is tapped.
  final void Function(CategoryStatisticsData category)? onCategoryTap;

  /// Number of columns.
  final int crossAxisCount;

  /// Aspect ratio of each card.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final filteredCategories =
        categories.where((c) => c.hasData).toList();

    if (filteredCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final category = filteredCategories[index];
          return CategoryStatisticsCard(
            category: category,
            onTap: onCategoryTap != null
                ? () => onCategoryTap!(category)
                : null,
          );
        },
      ),
    );
  }
}
