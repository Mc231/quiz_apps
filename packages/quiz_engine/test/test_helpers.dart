import 'package:quiz_engine/src/quiz_widget_entry.dart';

/// Test helper to create QuizTexts with all required fields for testing.
const testQuizTexts = QuizTexts(
  title: 'Test Quiz',
  gameOverText: 'Game Over',
  exitDialogTitle: 'Exit Quiz?',
  exitDialogMessage: 'Are you sure you want to exit? Your progress will be lost.',
  exitDialogConfirm: 'Yes',
  exitDialogCancel: 'No',
  correctFeedback: 'Correct!',
  incorrectFeedback: 'Incorrect!',
  hint5050Label: '50/50',
  hintSkipLabel: 'Skip',
  timerSecondsSuffix: 's',
  videoLoadError: 'Failed to load video',
);