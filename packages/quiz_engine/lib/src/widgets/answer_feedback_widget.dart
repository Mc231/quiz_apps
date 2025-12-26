import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/quiz_theme_data.dart';
import '../quiz/quiz_layout.dart';
import '../l10n/quiz_localizations.dart';
import 'game_resource_panel.dart';

/// A widget that displays visual feedback after the user answers a question.
///
/// Shows the quiz layout with visual indication of whether the answer was
/// correct or incorrect, along with optional animations and effects.
///
/// This widget is displayed during the [AnswerFeedbackState] phase of the quiz.
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

  const AnswerFeedbackWidget({
    super.key,
    required this.feedbackState,
    required this.processAnswer,
    this.resourceData,
    required this.themeData,
    required this.information,
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
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
              ),
              information: widget.information,
              processAnswer: widget.processAnswer,
              resourceData: widget.resourceData,
              themeData: widget.themeData,
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
          ],
        ),
      ),
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
