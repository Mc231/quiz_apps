import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../l10n/quiz_localizations.dart';
import '../quiz/quiz_image_widget.dart';
import '../quiz/quiz_layout.dart';
import '../theme/quiz_animations.dart';
import '../theme/quiz_theme_data.dart';
import 'game_resource_panel.dart';

/// A widget that displays visual feedback after the user answers a question.
///
/// Shows the quiz layout with visual indication of whether the answer was
/// correct or incorrect, along with optional animations and effects.
///
/// This widget is displayed during the [AnswerFeedbackState] phase of the quiz.
/// Supports different layout configurations including image answer feedback.
class AnswerFeedbackWidget extends StatefulWidget {
  /// The current answer feedback state containing question and answer info
  final AnswerFeedbackState feedbackState;

  /// Callback to process the user's answer selection
  final Function(QuestionEntry answer) processAnswer;

  /// Game resource panel data (lives, 50/50, skip).
  final GameResourcePanelData? resourceData;

  /// Theme configuration for styling the feedback
  final QuizThemeData themeData;

  /// Responsive sizing information
  final SizingInformation information;

  /// The resolved layout configuration for this question.
  ///
  /// Used to display the correct answer in the appropriate format
  /// (text or image) based on the layout type.
  final QuizLayoutConfig? layoutConfig;

  const AnswerFeedbackWidget({
    super.key,
    required this.feedbackState,
    required this.processAnswer,
    this.resourceData,
    required this.themeData,
    required this.information,
    this.layoutConfig,
  });

  @override
  State<AnswerFeedbackWidget> createState() => _AnswerFeedbackWidgetState();
}

class _AnswerFeedbackWidgetState extends State<AnswerFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: QuizAnimations.answerFeedbackDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.answerFeedbackScaleCurve,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.answerFeedbackOpacityCurve,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original quiz layout (disabled state)
        Opacity(
          opacity: 0.6,
          child: IgnorePointer(
            child: QuizLayout(
              questionState: QuestionState(
                widget.feedbackState.question,
                widget.feedbackState.progress,
                widget.feedbackState.total,
                remainingLives: widget.feedbackState.remainingLives,
                resolvedLayout: widget.layoutConfig,
              ),
              information: widget.information,
              processAnswer: widget.processAnswer,
              resourceData: widget.resourceData,
              themeData: widget.themeData,
              layoutConfig: widget.layoutConfig,
            ),
          ),
        ),

        // Feedback overlay
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildFeedbackCard(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    final isCorrect = widget.feedbackState.isCorrect;
    final color =
        isCorrect
            ? widget.themeData.correctAnswerColor
            : widget.themeData.incorrectAnswerColor;

    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final l10n = QuizL10n.of(context);
    final message = isCorrect ? l10n.correctFeedback : l10n.incorrectFeedback;

    // Determine what type of correct answer preview to show for incorrect answers
    final showImageAnswer = !isCorrect && _isImageAnswerLayout();
    final showTextAnswer = !isCorrect && _isTextAnswerLayout();

    return Card(
      elevation: 8,
      color: color.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _getIconSize(), color: Colors.white),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: _getTextSize(),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Show correct answer for incorrect answers
            if (showImageAnswer) ...[
              const SizedBox(height: 16),
              _buildCorrectAnswerImagePreview(),
            ],
            if (showTextAnswer) ...[
              const SizedBox(height: 16),
              _buildCorrectAnswerTextPreview(),
            ],
          ],
        ),
      ),
    );
  }

  /// Checks if the current layout uses image answers.
  bool _isImageAnswerLayout() {
    final layout = widget.layoutConfig;
    return layout is TextQuestionImageAnswersLayout;
  }

  /// Checks if the current layout uses text answers.
  bool _isTextAnswerLayout() {
    final layout = widget.layoutConfig;
    return layout is ImageQuestionTextAnswersLayout ||
        layout is TextQuestionTextAnswersLayout ||
        layout is AudioQuestionTextAnswersLayout;
  }

  /// Builds a preview of the correct answer for image answer layouts.
  Widget _buildCorrectAnswerImagePreview() {
    final correctAnswer = widget.feedbackState.question.answer;
    final imageSize = _getCorrectAnswerImageSize();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: QuizImageWidget(
          key: Key('correct_answer_${correctAnswer.otherOptions["id"]}'),
          entry: correctAnswer,
          width: imageSize,
          height: imageSize,
        ),
      ),
    );
  }

  /// Returns the size for the correct answer image preview.
  double _getCorrectAnswerImageSize() {
    return getValueForScreenType<double>(
      context: context,
      mobile: 80,
      tablet: 100,
      desktop: 120,
      watch: 48,
    );
  }

  /// Builds a preview of the correct answer for text answer layouts.
  Widget _buildCorrectAnswerTextPreview() {
    final correctAnswer = widget.feedbackState.question.answer;
    final l10n = QuizL10n.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.correctAnswerLabel,
            style: TextStyle(
              fontSize: _getCorrectAnswerLabelSize(),
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            correctAnswer.otherOptions['name'] as String? ?? '',
            style: TextStyle(
              fontSize: _getCorrectAnswerTextSize(),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Returns the font size for the correct answer label.
  double _getCorrectAnswerLabelSize() {
    return getValueForScreenType<double>(
      context: context,
      mobile: 12,
      tablet: 14,
      desktop: 14,
      watch: 10,
    );
  }

  /// Returns the font size for the correct answer text.
  double _getCorrectAnswerTextSize() {
    return getValueForScreenType<double>(
      context: context,
      mobile: 18,
      tablet: 22,
      desktop: 22,
      watch: 14,
    );
  }

  double _getIconSize() {
    return getValueForScreenType<double>(
      context: context,
      mobile: 64,
      tablet: 96,
      desktop: 96,
      watch: 32,
    );
  }

  double _getTextSize() {
    return getValueForScreenType<double>(
      context: context,
      mobile: 24,
      tablet: 32,
      desktop: 32,
      watch: 16,
    );
  }
}
