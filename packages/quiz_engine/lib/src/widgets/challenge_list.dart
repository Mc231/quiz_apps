import 'package:flutter/material.dart';

import '../models/challenge_mode.dart';
import 'challenge_card.dart';

/// Configuration for [ChallengeListWidget].
class ChallengeListConfig {
  /// Creates a [ChallengeListConfig].
  const ChallengeListConfig({
    this.padding = const EdgeInsets.all(16.0),
    this.itemSpacing = 12.0,
    this.cardStyle = const ChallengeCardStyle(),
    this.showHeader = false,
    this.headerText,
    this.headerStyle,
    this.sortByDifficulty = false,
    this.groupByDifficulty = false,
  });

  /// Padding around the list.
  final EdgeInsets padding;

  /// Spacing between challenge cards.
  final double itemSpacing;

  /// Style for the challenge cards.
  final ChallengeCardStyle cardStyle;

  /// Whether to show a header above the list.
  final bool showHeader;

  /// Header text (if [showHeader] is true).
  final String? headerText;

  /// Style for the header text.
  final TextStyle? headerStyle;

  /// Whether to sort challenges by difficulty (easy first).
  final bool sortByDifficulty;

  /// Whether to group challenges by difficulty with section headers.
  final bool groupByDifficulty;
}

/// A widget that displays a list of challenge modes.
///
/// Shows challenge cards in a scrollable list with optional
/// difficulty sorting and grouping.
///
/// Example:
/// ```dart
/// ChallengeListWidget(
///   challenges: [survivalChallenge, timeAttackChallenge],
///   onChallengeSelected: (challenge) => showCategoryPicker(challenge),
/// )
/// ```
class ChallengeListWidget extends StatelessWidget {
  /// Creates a [ChallengeListWidget].
  const ChallengeListWidget({
    super.key,
    required this.challenges,
    required this.onChallengeSelected,
    this.config = const ChallengeListConfig(),
    this.trailingBuilder,
    this.emptyWidget,
  });

  /// List of challenge modes to display.
  final List<ChallengeMode> challenges;

  /// Callback when a challenge is selected.
  final void Function(ChallengeMode challenge) onChallengeSelected;

  /// Configuration for the list.
  final ChallengeListConfig config;

  /// Builder for trailing widget on each card (e.g., best score).
  final Widget Function(ChallengeMode challenge)? trailingBuilder;

  /// Widget to show when the list is empty.
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return emptyWidget ?? _buildDefaultEmptyState(context);
    }

    final sortedChallenges = _getSortedChallenges();

    if (config.groupByDifficulty) {
      return _buildGroupedList(context, sortedChallenges);
    }

    return _buildSimpleList(context, sortedChallenges);
  }

  List<ChallengeMode> _getSortedChallenges() {
    if (!config.sortByDifficulty && !config.groupByDifficulty) {
      return challenges;
    }

    final sorted = List<ChallengeMode>.from(challenges);
    sorted.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return sorted;
  }

  Widget _buildSimpleList(BuildContext context, List<ChallengeMode> items) {
    return ListView.builder(
      padding: config.padding,
      itemCount: items.length + (config.showHeader ? 1 : 0),
      itemBuilder: (context, index) {
        if (config.showHeader && index == 0) {
          return _buildHeader(context);
        }

        final challengeIndex = config.showHeader ? index - 1 : index;
        final challenge = items[challengeIndex];

        return Padding(
          padding: EdgeInsets.only(
            bottom: challengeIndex < items.length - 1 ? config.itemSpacing : 0,
          ),
          child: ChallengeCard(
            challenge: challenge,
            style: config.cardStyle,
            onTap: () => onChallengeSelected(challenge),
            trailing: trailingBuilder?.call(challenge),
          ),
        );
      },
    );
  }

  Widget _buildGroupedList(BuildContext context, List<ChallengeMode> items) {
    final theme = Theme.of(context);

    // Group by difficulty
    final grouped = <ChallengeDifficulty, List<ChallengeMode>>{};
    for (final challenge in items) {
      grouped.putIfAbsent(challenge.difficulty, () => []).add(challenge);
    }

    final sections = <Widget>[];

    if (config.showHeader) {
      sections.add(_buildHeader(context));
    }

    for (final difficulty in ChallengeDifficulty.values) {
      final challengesInGroup = grouped[difficulty];
      if (challengesInGroup == null || challengesInGroup.isEmpty) continue;

      // Section header
      sections.add(
        Padding(
          padding: EdgeInsets.only(
            top: sections.isEmpty ? 0 : 16,
            bottom: 8,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: difficulty.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                difficulty.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: difficulty.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );

      // Challenge cards in this group
      for (var i = 0; i < challengesInGroup.length; i++) {
        final challenge = challengesInGroup[i];
        sections.add(
          Padding(
            padding: EdgeInsets.only(
              bottom: i < challengesInGroup.length - 1 ? config.itemSpacing : 0,
            ),
            child: ChallengeCard(
              challenge: challenge,
              style: config.cardStyle,
              onTap: () => onChallengeSelected(challenge),
              trailing: trailingBuilder?.call(challenge),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: config.padding,
      children: sections,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: config.itemSpacing),
      child: Text(
        config.headerText ?? 'Challenges',
        style: config.headerStyle ??
            theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDefaultEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
