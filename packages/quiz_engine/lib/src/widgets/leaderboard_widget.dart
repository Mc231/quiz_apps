import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';
import 'empty_state_widget.dart';

/// Entry in a leaderboard.
class LeaderboardEntry {
  /// Creates a [LeaderboardEntry].
  const LeaderboardEntry({
    required this.rank,
    required this.sessionId,
    required this.quizName,
    required this.score,
    required this.date,
    this.categoryName,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.durationSeconds = 0,
    this.isPerfect = false,
  });

  /// Position in the leaderboard (1-based).
  final int rank;

  /// Session identifier.
  final String sessionId;

  /// Name of the quiz.
  final String quizName;

  /// Score percentage.
  final double score;

  /// Date of the session.
  final DateTime date;

  /// Optional category name.
  final String? categoryName;

  /// Total questions in the quiz.
  final int totalQuestions;

  /// Number of correct answers.
  final int correctAnswers;

  /// Duration in seconds.
  final int durationSeconds;

  /// Whether this was a perfect score.
  final bool isPerfect;

  /// Formatted duration string.
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

/// Type of leaderboard.
enum LeaderboardType {
  /// Best scores overall.
  bestScores,

  /// Fastest times for perfect scores.
  fastestPerfect,

  /// Most sessions played.
  mostPlayed,

  /// Best streaks.
  bestStreaks,
}

/// Widget displaying a local leaderboard.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class LeaderboardWidget extends StatefulWidget {
  /// Creates a [LeaderboardWidget].
  const LeaderboardWidget({
    super.key,
    required this.entries,
    this.title,
    this.type = LeaderboardType.bestScores,
    this.onEntryTap,
    this.maxEntries = 10,
    this.highlightSessionId,
    this.showMedals = true,
    this.categoryId,
  });

  /// Leaderboard entries (already sorted by rank).
  final List<LeaderboardEntry> entries;

  /// Leaderboard title.
  final String? title;

  /// Type of leaderboard.
  final LeaderboardType type;

  /// Callback when an entry is tapped.
  final void Function(LeaderboardEntry entry)? onEntryTap;

  /// Maximum entries to display.
  final int maxEntries;

  /// Session ID to highlight (e.g., current user's best).
  final String? highlightSessionId;

  /// Whether to show medal icons for top 3.
  final bool showMedals;

  /// Optional category ID for analytics.
  final String? categoryId;

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  bool _viewLogged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logLeaderboardViewed();
  }

  void _logLeaderboardViewed() {
    if (_viewLogged) return;
    _viewLogged = true;

    // Find user's rank if a highlight session is provided
    int userRank = 0;
    if (widget.highlightSessionId != null) {
      final index = widget.entries.indexWhere(
        (e) => e.sessionId == widget.highlightSessionId,
      );
      if (index >= 0) {
        userRank = widget.entries[index].rank;
      }
    }

    context.screenAnalyticsService.logEvent(
      InteractionEvent.leaderboardViewed(
        leaderboardType: widget.type.name,
        userRank: userRank,
        totalEntries: widget.entries.length,
        categoryId: widget.categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final displayEntries = widget.entries.take(widget.maxEntries).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  _getLeaderboardIcon(widget.type),
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title ?? _getDefaultTitle(widget.type, l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          if (displayEntries.isEmpty)
            _buildEmptyState(context, l10n)
          else
            ...displayEntries.map((entry) => _buildEntryItem(
                  context,
                  entry,
                  l10n,
                )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _getLeaderboardIcon(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.bestScores:
        return Icons.emoji_events;
      case LeaderboardType.fastestPerfect:
        return Icons.timer;
      case LeaderboardType.mostPlayed:
        return Icons.replay;
      case LeaderboardType.bestStreaks:
        return Icons.local_fire_department;
    }
  }

  String _getDefaultTitle(LeaderboardType type, QuizLocalizations l10n) {
    switch (type) {
      case LeaderboardType.bestScores:
        return l10n.bestScores;
      case LeaderboardType.fastestPerfect:
        return l10n.fastestPerfect;
      case LeaderboardType.mostPlayed:
        return l10n.mostPlayed;
      case LeaderboardType.bestStreaks:
        return l10n.bestStreaks;
    }
  }

  Widget _buildEmptyState(BuildContext context, QuizLocalizations l10n) {
    return EmptyStateWidget.compact(
      icon: Icons.leaderboard_outlined,
      title: l10n.noLeaderboardData,
    );
  }

  Widget _buildEntryItem(
    BuildContext context,
    LeaderboardEntry entry,
    QuizLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isHighlighted = entry.sessionId == widget.highlightSessionId;

    return Container(
      color: isHighlighted
          ? theme.primaryColor.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: widget.onEntryTap != null ? () => widget.onEntryTap!(entry) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Rank badge
              SizedBox(
                width: 36,
                child: _buildRankBadge(context, entry.rank),
              ),
              const SizedBox(width: 12),

              // Quiz info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.quizName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.isPerfect) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(entry.date, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Score/value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildScoreBadge(context, entry.score),
                  if (widget.type == LeaderboardType.fastestPerfect) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.formattedDuration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),

              // Chevron
              if (widget.onEntryTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    if (widget.showMedals && rank <= 3) {
      final medalColor = switch (rank) {
        1 => const Color(0xFFFFD700), // Gold
        2 => const Color(0xFFC0C0C0), // Silver
        3 => const Color(0xFFCD7F32), // Bronze
        _ => Colors.grey,
      };

      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: medalColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.emoji_events,
            color: medalColor,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context, double score) {
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

  String _formatDate(DateTime date, QuizLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Compact leaderboard row for inline display.
class LeaderboardRow extends StatelessWidget {
  /// Creates a [LeaderboardRow].
  const LeaderboardRow({
    super.key,
    required this.entry,
    this.onTap,
    this.showMedal = true,
  });

  /// Entry to display.
  final LeaderboardEntry entry;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether to show medal for top 3.
  final bool showMedal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 28,
              child: _buildRank(context),
            ),
            const SizedBox(width: 8),

            // Name
            Expanded(
              child: Text(
                entry.quizName,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Score
            Text(
              '${entry.score.round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(entry.score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRank(BuildContext context) {
    if (showMedal && entry.rank <= 3) {
      final medalColor = switch (entry.rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => Colors.grey,
      };

      return Icon(
        Icons.emoji_events,
        color: medalColor,
        size: 18,
      );
    }

    return Text(
      '${entry.rank}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Tab selector for different leaderboard types.
class LeaderboardTypeSelector extends StatelessWidget {
  /// Creates a [LeaderboardTypeSelector].
  const LeaderboardTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.availableTypes = const [
      LeaderboardType.bestScores,
      LeaderboardType.fastestPerfect,
    ],
  });

  /// Currently selected type.
  final LeaderboardType selectedType;

  /// Callback when type is changed.
  final void Function(LeaderboardType type) onTypeChanged;

  /// Available types to show.
  final List<LeaderboardType> availableTypes;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableTypes.map((type) {
          final isSelected = type == selectedType;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              avatar: Icon(
                _getTypeIcon(type),
                size: 18,
                color: isSelected ? Colors.white : null,
              ),
              label: Text(_getTypeLabel(type, l10n)),
              selected: isSelected,
              onSelected: (_) => onTypeChanged(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTypeIcon(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.bestScores:
        return Icons.emoji_events;
      case LeaderboardType.fastestPerfect:
        return Icons.timer;
      case LeaderboardType.mostPlayed:
        return Icons.replay;
      case LeaderboardType.bestStreaks:
        return Icons.local_fire_department;
    }
  }

  String _getTypeLabel(LeaderboardType type, QuizLocalizations l10n) {
    switch (type) {
      case LeaderboardType.bestScores:
        return l10n.bestScores;
      case LeaderboardType.fastestPerfect:
        return l10n.fastestPerfect;
      case LeaderboardType.mostPlayed:
        return l10n.mostPlayed;
      case LeaderboardType.bestStreaks:
        return l10n.bestStreaks;
    }
  }
}
