import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import 'achievement_icon_animated.dart';
import 'achievement_tier_badge.dart';

/// Data needed to display achievement details.
class AchievementDetailsData {
  /// Creates an [AchievementDetailsData].
  const AchievementDetailsData({
    required this.achievement,
    required this.progress,
  });

  /// The achievement definition.
  final Achievement achievement;

  /// The progress toward this achievement.
  final AchievementProgress progress;

  /// Whether the achievement is unlocked.
  bool get isUnlocked => progress.isUnlocked;

  /// Whether the achievement is hidden and not yet unlocked.
  bool get isHiddenAndLocked => achievement.isHidden && !isUnlocked;

  /// Whether to show progress (has target > 1 and not unlocked).
  bool get showProgress =>
      !isUnlocked && achievement.progressTarget > 1 && progress.hasProgress;
}

/// Configuration for sharing achievements.
class AchievementShareConfig {
  /// Creates an [AchievementShareConfig].
  const AchievementShareConfig({
    required this.appName,
    required this.deepLinkScheme,
    this.hashtags = const [],
  });

  /// App name for share message.
  final String appName;

  /// Deep link scheme (e.g., 'flagsquiz').
  final String deepLinkScheme;

  /// Hashtags to include in share message.
  final List<String> hashtags;

  /// Generates the deep link URL for an achievement.
  String generateDeepLink(String achievementId) {
    return '$deepLinkScheme://achievement/$achievementId';
  }

  /// Generates the share text for an achievement.
  String generateShareText({
    required String achievementName,
    required String achievementDescription,
    required String tierName,
    required int points,
    required String achievementId,
  }) {
    final buffer = StringBuffer();

    // Main message
    buffer.writeln('I unlocked "$achievementName" in $appName!');
    buffer.writeln();
    buffer.writeln('$achievementDescription - $tierName (+$points pts)');
    buffer.writeln();
    buffer.writeln('Think you can beat me?');
    buffer.writeln(generateDeepLink(achievementId));

    // Hashtags
    if (hashtags.isNotEmpty) {
      buffer.writeln();
      buffer.write(hashtags.map((tag) => '#$tag').join(' '));
    }

    return buffer.toString().trim();
  }
}

/// A bottom sheet that displays achievement details.
///
/// Shows different content based on achievement state:
/// - **Unlocked**: Icon with animation, full details, share button
/// - **Locked with progress**: Greyed icon, progress bar, encouragement
/// - **Hidden**: Mystery icon, minimal info
///
/// Example:
/// ```dart
/// await AchievementDetailsBottomSheet.show(
///   context: context,
///   data: AchievementDetailsData(
///     achievement: myAchievement,
///     progress: myProgress,
///   ),
///   shareConfig: AchievementShareConfig(
///     appName: 'Flags Quiz',
///     deepLinkScheme: 'flagsquiz',
///   ),
///   onShare: (shareText) async {
///     await Share.share(shareText);
///   },
/// );
/// ```
class AchievementDetailsBottomSheet extends StatelessWidget {
  /// Creates an [AchievementDetailsBottomSheet].
  const AchievementDetailsBottomSheet({
    super.key,
    required this.data,
    this.shareConfig,
    this.onShare,
  });

  /// The achievement data to display.
  final AchievementDetailsData data;

  /// Configuration for sharing (required for share button to appear).
  final AchievementShareConfig? shareConfig;

  /// Callback when share button is pressed.
  final Future<void> Function(String shareText)? onShare;

  /// Shows the achievement details bottom sheet.
  ///
  /// Returns `true` if the share button was pressed, `false` otherwise.
  static Future<bool?> show({
    required BuildContext context,
    required AchievementDetailsData data,
    AchievementShareConfig? shareConfig,
    Future<void> Function(String shareText)? onShare,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailsBottomSheet(
        data: data,
        shareConfig: shareConfig,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Content based on state
              if (data.isHiddenAndLocked)
                _buildHiddenContent(context, theme)
              else if (data.isUnlocked)
                _buildUnlockedContent(context, theme)
              else
                _buildLockedContent(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenContent(BuildContext context, ThemeData theme) {
    final l10n = QuizL10n.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mystery icon
        AchievementIconAnimated(
          icon: '?',
          tier: data.achievement.tier,
          isUnlocked: false,
          isHidden: true,
          size: 80,
        ),
        const SizedBox(height: 20),

        // Hidden title
        Text(
          l10n.hiddenAchievement,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Tier badge
        AchievementTierBadge(
          tier: data.achievement.tier,
          size: AchievementTierBadgeSize.medium,
        ),
        const SizedBox(height: 16),

        // Hidden description
        Text(
          l10n.achievementDetailsHiddenMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUnlockedContent(BuildContext context, ThemeData theme) {
    final l10n = QuizL10n.of(context);
    final tierColor = data.achievement.tier.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon
        AchievementIconAnimated(
          icon: data.achievement.icon,
          tier: data.achievement.tier,
          isUnlocked: true,
          size: 80,
        ),
        const SizedBox(height: 20),

        // Achievement name
        Text(
          data.achievement.name(context),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Tier and points
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AchievementTierBadge(
              tier: data.achievement.tier,
              size: AchievementTierBadgeSize.medium,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.achievementPoints(data.achievement.points),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: tierColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          data.achievement.description(context),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Divider
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 12),

        // Unlock date
        if (data.progress.unlockedAt != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.achievementDetailsUnlockedOn(
                  _formatDate(data.progress.unlockedAt!, context),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),

        // Share button
        if (shareConfig != null && onShare != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _handleShare(context),
              icon: const Icon(Icons.share),
              label: Text(l10n.shareAchievement),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLockedContent(BuildContext context, ThemeData theme) {
    final l10n = QuizL10n.of(context);
    final tierColor = data.achievement.tier.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greyed icon
        AchievementIconAnimated(
          icon: data.achievement.icon,
          tier: data.achievement.tier,
          isUnlocked: false,
          size: 80,
          animate: false,
        ),
        const SizedBox(height: 20),

        // Achievement name
        Text(
          data.achievement.name(context),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Tier and points
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.7,
              child: AchievementTierBadge(
                tier: data.achievement.tier,
                size: AchievementTierBadgeSize.medium,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.achievementPoints(data.achievement.points),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          data.achievement.description(context),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Divider
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 12),

        // Progress bar (if applicable)
        if (data.showProgress) ...[
          _buildProgressSection(context, theme, tierColor),
          const SizedBox(height: 16),
        ],

        // Locked status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.achievementDetailsKeepPlaying,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    ThemeData theme,
    Color tierColor,
  ) {
    final l10n = QuizL10n.of(context);

    return Column(
      children: [
        // Progress label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievementProgress(
                data.progress.currentValue,
                data.progress.targetValue,
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                color: tierColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.completionPercentage(data.progress.percentageInt),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: data.progress.percentage,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(tierColor),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final l10n = QuizL10n.of(context);

    if (dateDay == today) {
      return '${l10n.today}, ${DateFormat.jm().format(date)}';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday}, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat.yMMMd().add_jm().format(date);
    }
  }

  Future<void> _handleShare(BuildContext context) async {
    if (shareConfig == null || onShare == null) return;

    final shareText = shareConfig!.generateShareText(
      achievementName: data.achievement.name(context),
      achievementDescription: data.achievement.description(context),
      tierName: data.achievement.tier.name,
      points: data.achievement.points,
      achievementId: data.achievement.id,
    );

    await onShare!(shareText);

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}