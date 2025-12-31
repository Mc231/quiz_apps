import 'package:flutter/material.dart';

import '../utils/layout_mode_labels.dart';

/// Data model for a reviewed question.
class ReviewedQuestion {
  /// Creates a [ReviewedQuestion].
  const ReviewedQuestion({
    required this.questionNumber,
    required this.questionText,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect = false,
    this.isSkipped = false,
    this.explanation,
    this.questionImagePath,
    this.layoutUsed,
  });

  /// Question number (1-indexed).
  final int questionNumber;

  /// The question text.
  final String questionText;

  /// The correct answer.
  final String correctAnswer;

  /// User's answer (null if skipped).
  final String? userAnswer;

  /// Whether the user answered correctly.
  final bool isCorrect;

  /// Whether the question was skipped.
  final bool isSkipped;

  /// Optional explanation for the answer.
  final String? explanation;

  /// Optional image path for the question.
  final String? questionImagePath;

  /// Layout used for this question.
  final String? layoutUsed;
}

/// Widget for displaying a single reviewed question.
class QuestionReviewWidget extends StatelessWidget {
  /// Creates a [QuestionReviewWidget].
  const QuestionReviewWidget({
    super.key,
    required this.question,
    required this.questionLabel,
    required this.yourAnswerLabel,
    required this.correctAnswerLabel,
    required this.skippedLabel,
    this.imageBuilder,
    this.showNumber = true,
    this.expandable = true,
  });

  /// The question data to display.
  final ReviewedQuestion question;

  /// Label for "Question" (e.g., "Question 1").
  final String Function(int number) questionLabel;

  /// Label for "Your answer".
  final String yourAnswerLabel;

  /// Label for "Correct answer".
  final String correctAnswerLabel;

  /// Label for "Skipped".
  final String skippedLabel;

  /// Optional image builder for question images.
  final Widget Function(String path)? imageBuilder;

  /// Whether to show the question number.
  final bool showNumber;

  /// Whether the card is expandable.
  final bool expandable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 12),
            if (question.questionImagePath != null &&
                imageBuilder != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageBuilder!(question.questionImagePath!),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              question.questionText,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildAnswerSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (showNumber) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getHeaderColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              questionLabel(question.questionNumber),
              style: theme.textTheme.labelMedium?.copyWith(
                color: _getHeaderColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (question.layoutUsed != null) ...[
            const SizedBox(width: 8),
            Builder(
              builder: (context) => LayoutModeBadge(
                layoutMode: question.layoutUsed,
                compact: true,
                showIcon: true,
              ),
            ),
          ],
          const Spacer(),
        ],
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (question.isSkipped) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.skip_next,
          color: Colors.orange,
          size: 20,
        ),
      );
    }

    final color = question.isCorrect ? Colors.green : Colors.red;
    final icon = question.isCorrect ? Icons.check : Icons.close;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildAnswerSection(ThemeData theme) {
    if (question.isSkipped) {
      return _buildAnswerRow(
        theme,
        label: yourAnswerLabel,
        value: skippedLabel,
        isCorrect: false,
        isSkipped: true,
      );
    }

    return Column(
      children: [
        if (question.userAnswer != null)
          _buildAnswerRow(
            theme,
            label: yourAnswerLabel,
            value: question.userAnswer!,
            isCorrect: question.isCorrect,
          ),
        if (!question.isCorrect) ...[
          const SizedBox(height: 8),
          _buildAnswerRow(
            theme,
            label: correctAnswerLabel,
            value: question.correctAnswer,
            isCorrectAnswer: true,
          ),
        ],
        if (question.explanation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerRow(
    ThemeData theme, {
    required String label,
    required String value,
    bool isCorrect = false,
    bool isCorrectAnswer = false,
    bool isSkipped = false,
  }) {
    Color bgColor;
    Color textColor;

    if (isSkipped) {
      bgColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange[800]!;
    } else if (isCorrectAnswer) {
      bgColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green[800]!;
    } else if (isCorrect) {
      bgColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green[800]!;
    } else {
      bgColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red[800]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (question.isSkipped) return Colors.orange.withValues(alpha: 0.3);
    return question.isCorrect
        ? Colors.green.withValues(alpha: 0.3)
        : Colors.red.withValues(alpha: 0.3);
  }

  Color _getHeaderColor() {
    if (question.isSkipped) return Colors.orange;
    return question.isCorrect ? Colors.green : Colors.red;
  }
}

/// A list of reviewed questions.
class QuestionReviewList extends StatelessWidget {
  /// Creates a [QuestionReviewList].
  const QuestionReviewList({
    super.key,
    required this.questions,
    required this.questionLabel,
    required this.yourAnswerLabel,
    required this.correctAnswerLabel,
    required this.skippedLabel,
    this.imageBuilder,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
  });

  /// List of questions to display.
  final List<ReviewedQuestion> questions;

  /// Label for "Question" (e.g., "Question 1").
  final String Function(int number) questionLabel;

  /// Label for "Your answer".
  final String yourAnswerLabel;

  /// Label for "Correct answer".
  final String correctAnswerLabel;

  /// Label for "Skipped".
  final String skippedLabel;

  /// Optional image builder for question images.
  final Widget Function(String path)? imageBuilder;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Whether the list should shrink wrap.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return QuestionReviewWidget(
          question: questions[index],
          questionLabel: questionLabel,
          yourAnswerLabel: yourAnswerLabel,
          correctAnswerLabel: correctAnswerLabel,
          skippedLabel: skippedLabel,
          imageBuilder: imageBuilder,
        );
      },
    );
  }
}
