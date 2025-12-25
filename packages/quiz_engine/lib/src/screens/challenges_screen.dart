import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;

import '../models/challenge_mode.dart';
import '../models/quiz_category.dart';
import '../models/quiz_data_provider.dart' as models;
import '../quiz_widget.dart';
import '../quiz_widget_entry.dart';
import '../widgets/challenge_list.dart';

/// A screen that displays challenge modes and handles the challenge flow.
///
/// When a challenge is selected:
/// 1. Shows a category picker dialog
/// 2. Starts the quiz with the challenge configuration
///
/// Example:
/// ```dart
/// ChallengesScreen(
///   challenges: FlagsChallenges.all,
///   categories: allCategories,
///   dataProvider: FlagsDataProvider(),
///   settingsService: settingsService,
///   storageService: storageService,
/// )
/// ```
class ChallengesScreen extends StatelessWidget {
  /// Creates a [ChallengesScreen].
  const ChallengesScreen({
    super.key,
    required this.challenges,
    required this.categories,
    required this.dataProvider,
    required this.settingsService,
    this.storageService,
    this.listConfig = const ChallengeListConfig(),
    this.categoryPickerTitle,
    this.onChallengeStarted,
    this.onQuizCompleted,
  });

  /// List of available challenge modes.
  final List<ChallengeMode> challenges;

  /// List of categories to choose from.
  final List<QuizCategory> categories;

  /// Data provider for loading questions.
  final models.QuizDataProvider dataProvider;

  /// Settings service for applying user settings.
  final SettingsService settingsService;

  /// Optional storage service for persisting results.
  final StorageService? storageService;

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

  @override
  Widget build(BuildContext context) {
    return ChallengeListWidget(
      challenges: challenges,
      config: listConfig,
      onChallengeSelected: (challenge) => _onChallengeSelected(context, challenge),
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
        categories: categories,
        title: categoryPickerTitle,
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
    onChallengeStarted?.call(challenge, category);

    // Load questions
    var questions = await dataProvider.loadQuestions(context, category);

    // Limit questions if challenge has a count limit
    if (challenge.questionCount != null && questions.length > challenge.questionCount!) {
      questions = questions.take(challenge.questionCount!).toList();
    }

    // Create quiz config from challenge
    final quizConfig = _createQuizConfig(context, challenge, category);

    // Create storage config
    final storageConfig = dataProvider.createStorageConfig(context, category);

    // Apply storage config
    final configWithStorage = quizConfig.copyWith(
      storageConfig: storageConfig,
    );

    // Create storage adapter
    QuizStorageAdapter? storageAdapter;
    if (storageService != null) {
      storageAdapter = QuizStorageAdapter(storageService!);
    }

    // Create config manager
    // Note: showAnswerFeedback comes from challenge mode, falling back to category
    final configManager = ConfigManager(
      defaultConfig: configWithStorage,
      getSettings: () => {
        'soundEnabled': settingsService.currentSettings.soundEnabled,
        'hapticEnabled': settingsService.currentSettings.hapticEnabled,
        'showAnswerFeedback':
            challenge.showAnswerFeedback ?? category.showAnswerFeedback ?? true,
      },
    );

    // Navigate to quiz
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => QuizWidget(
            quizEntry: QuizWidgetEntry(
              title: '${challenge.name}: ${category.title(context)}',
              dataProvider: () async => questions,
              configManager: configManager,
              storageService: storageAdapter,
              onQuizCompleted: onQuizCompleted,
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

    // Survival: lives + time
    if (hasLives && (hasPerQuestionTime || hasTotalTime)) {
      return QuizModeConfig.survival(
        lives: challenge.lives!,
        timePerQuestion: challenge.questionTimeSeconds ?? 30,
        totalTimeLimit: challenge.totalTimeSeconds,
      );
    }

    // Lives only
    if (hasLives) {
      return QuizModeConfig.lives(
        lives: challenge.lives!,
        allowSkip: challenge.allowSkip,
      );
    }

    // Timed only
    if (hasPerQuestionTime || hasTotalTime) {
      return QuizModeConfig.timed(
        timePerQuestion: challenge.questionTimeSeconds ?? 30,
        totalTimeLimit: challenge.totalTimeSeconds,
        allowSkip: challenge.allowSkip,
      );
    }

    // Endless mode
    if (challenge.isEndless) {
      return QuizModeConfig.endless();
    }

    // Standard mode
    return QuizModeConfig.standard(allowSkip: challenge.allowSkip);
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
