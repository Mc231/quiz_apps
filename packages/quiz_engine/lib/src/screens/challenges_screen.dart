import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;

import '../analytics/quiz_analytics_adapter.dart';
import '../models/challenge_mode.dart';
import '../models/quiz_category.dart';
import '../models/quiz_data_provider.dart' as models;
import '../quiz_widget.dart';
import '../quiz_widget_entry.dart';
import '../services/quiz_services_context.dart';
import '../widgets/challenge_list.dart';

/// A screen that displays challenge modes and handles the challenge flow.
///
/// When a challenge is selected:
/// 1. Shows a category picker dialog
/// 2. Starts the quiz with the challenge configuration
///
/// Services are obtained from [QuizServicesProvider] via context:
/// - `context.settingsService` for user settings
/// - `context.screenAnalyticsService` for analytics tracking
/// - `context.storageService` for persisting results
///
/// Example:
/// ```dart
/// ChallengesScreen(
///   challenges: FlagsChallenges.all,
///   categories: allCategories,
///   dataProvider: FlagsDataProvider(),
/// )
/// ```
class ChallengesScreen extends StatefulWidget {
  /// Creates a [ChallengesScreen].
  const ChallengesScreen({
    super.key,
    required this.challenges,
    required this.categories,
    required this.dataProvider,
    this.listConfig = const ChallengeListConfig(),
    this.categoryPickerTitle,
    this.onChallengeStarted,
    this.onQuizCompleted,
    this.completedChallengeCount = 0,
  });

  /// List of available challenge modes.
  final List<ChallengeMode> challenges;

  /// List of categories to choose from.
  final List<QuizCategory> categories;

  /// Data provider for loading questions.
  final models.QuizDataProvider dataProvider;

  /// Configuration for the challenge list.
  final ChallengeListConfig listConfig;

  /// Title for the category picker dialog.
  final String? categoryPickerTitle;

  /// Callback when a challenge is started (for analytics, etc.).
  final void Function(ChallengeMode challenge, QuizCategory category)?
      onChallengeStarted;

  /// Callback invoked when a challenge quiz is completed.
  ///
  /// Use this to integrate with achievement systems, analytics,
  /// or any post-quiz processing.
  final void Function(QuizResults results)? onQuizCompleted;

  /// Number of completed challenges for analytics tracking.
  final int completedChallengeCount;

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  // Service accessors via context
  AnalyticsService get _analyticsService => context.screenAnalyticsService;
  SettingsService get _settingsService => context.settingsService;
  StorageService get _storageService => context.storageService;

  bool _screenViewLogged = false;

  @override
  Widget build(BuildContext context) {
    // Log screen view on first build when context is available
    if (!_screenViewLogged) {
      _screenViewLogged = true;
      _logScreenView();
    }

    return ChallengeListWidget(
      challenges: widget.challenges,
      config: widget.listConfig,
      onChallengeSelected: (challenge) => _onChallengeSelected(context, challenge),
    );
  }

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.challenges(
        challengeCount: widget.challenges.length,
        completedCount: widget.completedChallengeCount,
      ),
    );
  }

  void _onChallengeSelected(BuildContext context, ChallengeMode challenge) {
    _showCategoryPicker(context, challenge);
  }

  void _showCategoryPicker(BuildContext context, ChallengeMode challenge) {
    showModalBottomSheet<QuizCategory>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CategoryPickerSheet(
        challenge: challenge,
        categories: widget.categories,
        title: widget.categoryPickerTitle,
        onCategorySelected: (category) {
          Navigator.pop(context);
          _startChallenge(context, challenge, category);
        },
      ),
    );
  }

  void _startChallenge(
    BuildContext context,
    ChallengeMode challenge,
    QuizCategory category,
  ) async {
    // Notify callback
    widget.onChallengeStarted?.call(challenge, category);

    // Log challenge selected event
    _analyticsService.logEvent(
      InteractionEvent.categorySelected(
        categoryId: category.id,
        categoryName: category.title(context),
        categoryIndex: widget.categories.indexOf(category),
      ),
    );

    // Load questions
    var questions = await widget.dataProvider.loadQuestions(context, category);

    // Limit questions if challenge has a count limit
    if (challenge.questionCount != null && questions.length > challenge.questionCount!) {
      questions = questions.take(challenge.questionCount!).toList();
    }

    // Create quiz config from challenge
    final quizConfig = _createQuizConfig(context, challenge, category);

    // Create storage config
    final storageConfig = widget.dataProvider.createStorageConfig(context, category);

    // Get layout config from provider
    final layoutConfig = widget.dataProvider.createLayoutConfig(context, category);

    // Apply storage config and layout config
    final configWithStorage = quizConfig.copyWith(
      storageConfig: storageConfig,
      layoutConfig: layoutConfig,
    );

    // Create storage adapter
    final storageAdapter = QuizStorageAdapter(_storageService);

    // Create analytics adapter
    final quizAnalyticsAdapter = QuizAnalyticsAdapter(_analyticsService);

    // Create config manager
    // Note: showAnswerFeedback comes from challenge mode, falling back to category
    final configManager = ConfigManager(
      defaultConfig: configWithStorage,
      getSettings: () => {
        'soundEnabled': _settingsService.currentSettings.soundEnabled,
        'hapticEnabled': _settingsService.currentSettings.hapticEnabled,
        'showAnswerFeedback': challenge.showAnswerFeedback,
      },
    );

    // Navigate to quiz
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'challenge_quiz'),
          builder: (ctx) => QuizWidget(
            quizEntry: QuizWidgetEntry(
              title: '${challenge.name}: ${category.title(context)}',
              dataProvider: () async => questions,
              configManager: configManager,
              storageService: storageAdapter,
              quizAnalyticsService: quizAnalyticsAdapter,
              onQuizCompleted: widget.onQuizCompleted,
            ),
          ),
        ),
      );
    }
  }

  QuizConfig _createQuizConfig(
    BuildContext context,
    ChallengeMode challenge,
    QuizCategory category,
  ) {
    // Create appropriate mode config based on challenge
    final modeConfig = _createModeConfig(challenge);

    // Create hint config
    final hintConfig = challenge.showHints
        ? const HintConfig()
        : HintConfig.noHints();

    return QuizConfig(
      quizId: '${category.id}_${challenge.id}',
      modeConfig: modeConfig,
      hintConfig: hintConfig,
    );
  }

  QuizModeConfig _createModeConfig(ChallengeMode challenge) {
    // Determine mode based on challenge settings
    final hasLives = challenge.lives != null;
    final hasPerQuestionTime = challenge.questionTimeSeconds != null;
    final hasTotalTime = challenge.totalTimeSeconds != null;
    final showFeedback = challenge.showAnswerFeedback;

    // Survival: lives + time
    if (hasLives && (hasPerQuestionTime || hasTotalTime)) {
      return QuizModeConfig.survival(
        showAnswerFeedback: showFeedback,
        lives: challenge.lives!,
        timePerQuestion: challenge.questionTimeSeconds ?? 30,
        totalTimeLimit: challenge.totalTimeSeconds,
      );
    }

    // Lives only
    if (hasLives) {
      return QuizModeConfig.lives(
        showAnswerFeedback: showFeedback,
        lives: challenge.lives!,
        allowSkip: challenge.allowSkip,
      );
    }

    // Timed only
    if (hasPerQuestionTime || hasTotalTime) {
      return QuizModeConfig.timed(
        showAnswerFeedback: showFeedback,
        timePerQuestion: challenge.questionTimeSeconds ?? 30,
        totalTimeLimit: challenge.totalTimeSeconds,
        allowSkip: challenge.allowSkip,
      );
    }

    // Endless mode
    if (challenge.isEndless) {
      return QuizModeConfig.endless(showAnswerFeedback: showFeedback);
    }

    // Standard mode
    return QuizModeConfig.standard(
      showAnswerFeedback: showFeedback,
      allowSkip: challenge.allowSkip,
    );
  }
}

/// BLoC-compatible content widget for challenges.
///
/// This widget receives all state and callbacks externally, making it
/// suitable for use with [ChallengesBloc] via [ChallengesBuilder].
///
/// Services are obtained from [QuizServicesProvider] via context.
class ChallengesContent extends StatelessWidget {
  /// Creates a [ChallengesContent].
  const ChallengesContent({
    super.key,
    required this.challenges,
    required this.categories,
    required this.onChallengeSelected,
    this.listConfig = const ChallengeListConfig(),
    this.isRefreshing = false,
    this.onRefresh,
    this.categoryPickerTitle,
    this.trailingBuilder,
  });

  /// List of available challenges.
  final List<ChallengeMode> challenges;

  /// List of available categories.
  final List<QuizCategory> categories;

  /// Callback when a challenge and category are selected.
  final void Function(ChallengeMode challenge, QuizCategory category)
      onChallengeSelected;

  /// Configuration for the challenge list.
  final ChallengeListConfig listConfig;

  /// Whether the content is refreshing.
  final bool isRefreshing;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Title for the category picker dialog.
  final String? categoryPickerTitle;

  /// Builder for trailing widget on each card.
  final Widget Function(ChallengeMode challenge)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final content = ChallengeListWidget(
      challenges: challenges,
      config: listConfig,
      trailingBuilder: trailingBuilder,
      onChallengeSelected: (challenge) =>
          _showCategoryPicker(context, challenge),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }

  void _showCategoryPicker(BuildContext context, ChallengeMode challenge) {
    showModalBottomSheet<QuizCategory>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CategoryPickerSheet(
        challenge: challenge,
        categories: categories,
        title: categoryPickerTitle,
        onCategorySelected: (category) {
          Navigator.pop(context);
          onChallengeSelected(challenge, category);
        },
      ),
    );
  }
}

/// Bottom sheet for picking a category.
class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.challenge,
    required this.categories,
    required this.onCategorySelected,
    this.title,
  });

  final ChallengeMode challenge;
  final List<QuizCategory> categories;
  final void Function(QuizCategory) onCategorySelected;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: challenge.difficulty.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          challenge.icon,
                          color: challenge.difficulty.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              title ?? 'Select a category',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Category list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: Icon(category.icon),
                    title: Text(category.title(context)),
                    subtitle: category.subtitle != null
                        ? Text(category.subtitle!(context))
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onCategorySelected(category),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
