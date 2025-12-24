import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  late SessionDetailData sessionWithWrongAnswers;
  late SessionDetailTexts texts;

  setUp(() {
    sessionWithWrongAnswers = SessionDetailData(
      id: 'test-session-1',
      quizName: 'Test Quiz',
      totalQuestions: 5,
      totalCorrect: 3,
      totalIncorrect: 2,
      totalSkipped: 0,
      scorePercentage: 60.0,
      completionStatus: 'completed',
      startTime: DateTime(2024, 1, 1, 10, 0),
      durationSeconds: 120,
      questions: [
        const ReviewedQuestion(
          questionNumber: 1,
          questionText: 'Question 1',
          userAnswer: 'Correct Answer',
          correctAnswer: 'Correct Answer',
          isCorrect: true,
          isSkipped: false,
        ),
        const ReviewedQuestion(
          questionNumber: 2,
          questionText: 'Question 2',
          userAnswer: 'Wrong Answer',
          correctAnswer: 'Correct Answer',
          isCorrect: false,
          isSkipped: false,
        ),
        const ReviewedQuestion(
          questionNumber: 3,
          questionText: 'Question 3',
          userAnswer: 'Correct Answer',
          correctAnswer: 'Correct Answer',
          isCorrect: true,
          isSkipped: false,
        ),
        const ReviewedQuestion(
          questionNumber: 4,
          questionText: 'Question 4',
          userAnswer: 'Wrong Answer',
          correctAnswer: 'Correct Answer',
          isCorrect: false,
          isSkipped: false,
        ),
        const ReviewedQuestion(
          questionNumber: 5,
          questionText: 'Question 5',
          userAnswer: 'Correct Answer',
          correctAnswer: 'Correct Answer',
          isCorrect: true,
          isSkipped: false,
        ),
      ],
    );

    texts = SessionDetailTexts(
      title: 'Session Details',
      reviewAnswersLabel: 'Review Answers',
      practiceWrongAnswersLabel: 'Practice Wrong',
      exportLabel: 'Export',
      deleteLabel: 'Delete',
      scoreLabel: 'Score',
      correctLabel: 'Correct',
      incorrectLabel: 'Incorrect',
      skippedLabel: 'Skipped',
      durationLabel: 'Duration',
      questionLabel: (n) => 'Question $n',
      yourAnswerLabel: 'Your Answer',
      correctAnswerLabel: 'Correct Answer',
      formatDate: (date) => '${date.year}-${date.month}-${date.day}',
      formatStatus: (status, isPerfect) => (status, Colors.green),
      deleteDialogTitle: 'Delete Session',
      deleteDialogMessage: 'Are you sure?',
      cancelLabel: 'Cancel',
      showAllLabel: 'All',
      showWrongOnlyLabel: 'Wrong Only',
    );
  });

  group('SessionDetailScreen', () {
    testWidgets('displays session summary', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
          ),
        ),
      );

      expect(find.text('Test Quiz'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('shows filter toggle when there are wrong answers',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Wrong Only'), findsOneWidget);
    });

    testWidgets('shows first question by default', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
          ),
        ),
      );

      // First question should be visible (sliver list lazy loads)
      expect(find.text('Question 1'), findsAtLeastNWidgets(1));
    });

    testWidgets('filter toggle interaction works', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
          ),
        ),
      );

      // Initially "All" should be selected
      final allButton = find.text('All');
      expect(allButton, findsOneWidget);

      // Tap the "Wrong Only" button
      await tester.tap(find.text('Wrong Only'));
      await tester.pumpAndSettle();

      // Wrong Only should now be selected - verify by checking we still have both buttons
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Wrong Only'), findsOneWidget);

      // First wrong answer (Question 2) should be visible
      expect(find.text('Question 2'), findsAtLeastNWidgets(1));
      // Correct answer (Question 1) should NOT be visible
      expect(find.text('Question 1'), findsNothing);
    });

    testWidgets('can toggle back to show all questions', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
          ),
        ),
      );

      // Verify Question 1 (correct) is visible
      expect(find.text('Question 1'), findsAtLeastNWidgets(1));

      // Tap "Wrong Only" first
      await tester.tap(find.text('Wrong Only'));
      await tester.pumpAndSettle();

      // Correct answer should be hidden
      expect(find.text('Question 1'), findsNothing);

      // Tap "All" to go back
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // First question should be visible again
      expect(find.text('Question 1'), findsAtLeastNWidgets(1));
    });

    testWidgets('does not show filter toggle when all answers are correct',
        (tester) async {
      final perfectSession = SessionDetailData(
        id: 'perfect-session',
        quizName: 'Perfect Quiz',
        totalQuestions: 2,
        totalCorrect: 2,
        totalIncorrect: 0,
        totalSkipped: 0,
        scorePercentage: 100.0,
        completionStatus: 'completed',
        startTime: DateTime(2024, 1, 1, 10, 0),
        questions: const [
          ReviewedQuestion(
            questionNumber: 1,
            questionText: 'Question 1',
            userAnswer: 'Correct',
            correctAnswer: 'Correct',
            isCorrect: true,
            isSkipped: false,
          ),
          ReviewedQuestion(
            questionNumber: 2,
            questionText: 'Question 2',
            userAnswer: 'Correct',
            correctAnswer: 'Correct',
            isCorrect: true,
            isSkipped: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: perfectSession,
            texts: texts,
          ),
        ),
      );

      // Filter toggle should not be shown
      expect(find.text('All'), findsNothing);
      expect(find.text('Wrong Only'), findsNothing);
    });

    testWidgets('shows practice button when there are wrong answers',
        (tester) async {
      var practicePressed = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          SessionDetailScreen(
            session: sessionWithWrongAnswers,
            texts: texts,
            onPracticeWrongAnswers: () {
              practicePressed = true;
            },
          ),
        ),
      );

      // Find and tap the practice button
      final practiceButton = find.textContaining('Practice Wrong');
      expect(practiceButton, findsOneWidget);

      await tester.tap(practiceButton);
      await tester.pump();

      expect(practicePressed, isTrue);
    });
  });

  group('SessionDetailData', () {
    test('isPerfectScore returns true for 100%', () {
      final perfectSession = SessionDetailData(
        id: 'test',
        quizName: 'Test',
        totalQuestions: 10,
        totalCorrect: 10,
        totalIncorrect: 0,
        totalSkipped: 0,
        scorePercentage: 100.0,
        completionStatus: 'completed',
        startTime: DateTime.now(),
        questions: const [],
      );

      expect(perfectSession.isPerfectScore, isTrue);
    });

    test('wrongAnswersCount counts only wrong (not skipped) answers', () {
      expect(sessionWithWrongAnswers.wrongAnswersCount, 2);
    });
  });

  group('QuestionFilterMode', () {
    test('has expected values', () {
      expect(QuestionFilterMode.values.length, 2);
      expect(QuestionFilterMode.values, contains(QuestionFilterMode.all));
      expect(QuestionFilterMode.values, contains(QuestionFilterMode.wrongOnly));
    });
  });
}
