import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_indicator.dart';

/// A tab widget displaying global leaderboard from Game Center/Play Games.
///
/// Fetches and displays the top scores from the platform's leaderboard,
/// highlights the current player's rank, and provides an option to
/// open the native leaderboard UI.
///
/// Example:
/// ```dart
/// GlobalLeaderboardTab(
///   leaderboardService: leaderboardService,
///   leaderboardId: 'global_scores',
/// )
/// ```
class GlobalLeaderboardTab extends StatefulWidget {
  /// Creates a [GlobalLeaderboardTab].
  const GlobalLeaderboardTab({
    super.key,
    required this.leaderboardService,
    required this.leaderboardId,
    this.maxEntries = 100,
    this.timeSpan = LeaderboardTimeSpan.allTime,
    this.onEntryTap,
  });

  /// The leaderboard service for fetching scores.
  final LeaderboardService leaderboardService;

  /// Platform-specific leaderboard ID.
  final String leaderboardId;

  /// Maximum number of entries to display.
  final int maxEntries;

  /// Time span filter for leaderboard.
  final LeaderboardTimeSpan timeSpan;

  /// Callback when a leaderboard entry is tapped.
  final void Function(LeaderboardEntry entry)? onEntryTap;

  @override
  State<GlobalLeaderboardTab> createState() => _GlobalLeaderboardTabState();
}

class _GlobalLeaderboardTabState extends State<GlobalLeaderboardTab> {
  bool _isLoading = true;
  String? _error;
  List<LeaderboardEntry> _entries = [];
  PlayerScore? _playerScore;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  @override
  void didUpdateWidget(GlobalLeaderboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leaderboardId != widget.leaderboardId ||
        oldWidget.timeSpan != widget.timeSpan) {
      _loadLeaderboard();
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await widget.leaderboardService.getTopScores(
        leaderboardId: widget.leaderboardId,
        count: widget.maxEntries,
        timeSpan: widget.timeSpan,
      );

      final playerScore = await widget.leaderboardService.getPlayerScore(
        leaderboardId: widget.leaderboardId,
        timeSpan: widget.timeSpan,
      );

      if (mounted) {
        setState(() {
          _entries = entries;
          _playerScore = playerScore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openNativeLeaderboard() async {
    // Log analytics event
    context.screenAnalyticsService.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: 'open_native_leaderboard',
        context: 'global_leaderboard_tab',
      ),
    );

    await widget.leaderboardService.showLeaderboard(
      leaderboardId: widget.leaderboardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return ErrorStateWidget(
        message: _error!,
        onRetry: _loadLeaderboard,
      );
    }

    if (_entries.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.leaderboard_outlined,
        title: l10n.noGlobalLeaderboardData,
        message: l10n.noGlobalLeaderboardMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: Column(
        children: [
          // Player's rank card (if available)
          if (_playerScore != null) _buildPlayerRankCard(l10n),

          // Open native leaderboard button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _openNativeLeaderboard,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(l10n.openInGameCenter),
            ),
          ),

          // Leaderboard entries
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final isCurrentPlayer =
                    _playerScore != null && entry.rank == _playerScore!.rank;
                return _buildLeaderboardEntry(entry, isCurrentPlayer, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRankCard(QuizLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${_playerScore!.rank}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourRank,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    _playerScore!.formattedScore ??
                        '${_playerScore!.score} pts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    LeaderboardEntry entry,
    bool isCurrentPlayer,
    QuizLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Container(
      color:
          isCurrentPlayer ? theme.colorScheme.primaryContainer.withAlpha(77) : null,
      child: ListTile(
        leading: _buildRankBadge(entry.rank, theme),
        title: Text(
          entry.displayName,
          style: TextStyle(
            fontWeight: isCurrentPlayer ? FontWeight.bold : null,
          ),
        ),
        subtitle: entry.timestamp != null
            ? Text(_formatTimestamp(entry.timestamp!, l10n))
            : null,
        trailing: Text(
          entry.formattedScore ?? '${entry.score}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(entry.rank, theme),
          ),
        ),
        onTap: widget.onEntryTap != null ? () => widget.onEntryTap!(entry) : null,
      ),
    );
  }

  Widget _buildRankBadge(int rank, ThemeData theme) {
    if (rank <= 3) {
      final color = switch (rank) {
        1 => const Color(0xFFFFD700), // Gold
        2 => const Color(0xFFC0C0C0), // Silver
        3 => const Color(0xFFCD7F32), // Bronze
        _ => Colors.grey,
      };

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.emoji_events,
            color: color,
            size: 22,
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int rank, ThemeData theme) {
    if (rank <= 3) {
      return switch (rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFF808080),
        3 => const Color(0xFFCD7F32),
        _ => theme.colorScheme.onSurface,
      };
    }
    return theme.colorScheme.onSurface;
  }

  String _formatTimestamp(DateTime timestamp, QuizLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// A tab switcher for switching between local and global leaderboards.
class LeaderboardSourceSelector extends StatelessWidget {
  /// Creates a [LeaderboardSourceSelector].
  const LeaderboardSourceSelector({
    super.key,
    required this.selectedSource,
    required this.onSourceChanged,
    this.isGlobalAvailable = true,
  });

  /// Currently selected source.
  final LeaderboardSource selectedSource;

  /// Callback when source changes.
  final void Function(LeaderboardSource source) onSourceChanged;

  /// Whether global leaderboard is available.
  final bool isGlobalAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<LeaderboardSource>(
        segments: [
          ButtonSegment(
            value: LeaderboardSource.local,
            icon: const Icon(Icons.phone_android),
            label: Text(l10n.localLeaderboard),
          ),
          ButtonSegment(
            value: LeaderboardSource.global,
            icon: const Icon(Icons.public),
            label: Text(l10n.globalLeaderboard),
            enabled: isGlobalAvailable,
          ),
        ],
        selected: {selectedSource},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            onSourceChanged(selection.first);
          }
        },
      ),
    );
  }
}

/// Source for leaderboard data.
enum LeaderboardSource {
  /// Local device leaderboard (from app database).
  local,

  /// Global leaderboard (from Game Center/Play Games).
  global,
}
