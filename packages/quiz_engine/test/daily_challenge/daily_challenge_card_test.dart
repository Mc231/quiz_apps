import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  late DailyChallenge testChallenge;
  late DailyChallengeResult testResult;
  late DailyChallengeStatus availableStatus;
  late DailyChallengeStatus completedStatus;

  setUp(() {
    testChallenge = DailyChallenge.forToday(
      categoryId: 'test_category',
      questionCount: 10,
      timeLimitSeconds: 300, // 5 minutes
    );

    testResult = DailyChallengeResult.create(
      challengeId: testChallenge.id,
      score: 80,
      correctCount: 8,
      totalQuestions: 10,
      completionTimeSeconds: 180,
      streakBonus: 10,
      timeBonus: 5,
    );

    availableStatus = DailyChallengeStatus(
      challenge: testChallenge,
      isCompleted: false,
      timeUntilNextChallenge: const Duration(hours: 12),
    );

    completedStatus = DailyChallengeStatus(
      challenge: testChallenge,
      result: testResult,
      isCompleted: true,
      timeUntilNextChallenge: const Duration(hours: 12),
    );
  });

  Widget buildTestWidget(
    DailyChallengeStatus status, {
    VoidCallback? onTap,
    VoidCallback? onViewResults,
    DailyChallengeCardStyle style = const DailyChallengeCardStyle(),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        QuizEngineLocalizations.delegate,
      ],
      home: Scaffold(
        body: DailyChallengeCard(
          status: status,
          onTap: onTap,
          onViewResults: onViewResults,
          style: style,
        ),
      ),
    );
  }

  group('DailyChallengeCard', () {
    testWidgets('displays daily challenge title', (tester) async {
      await tester.pumpWidget(buildTestWidget(availableStatus));
      await tester.pumpAndSettle();

      expect(find.text('Daily Challenge'), findsOneWidget);
    });

    testWidgets('displays Available Now badge when not completed',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(availableStatus));
      await tester.pumpAndSettle();

      expect(find.text('Available Now'), findsOneWidget);
    });

    testWidgets('displays Completed! badge when completed', (tester) async {
      await tester.pumpWidget(buildTestWidget(completedStatus));
      await tester.pumpAndSettle();

      expect(find.text('Completed!'), findsOneWidget);
    });

    testWidgets('displays question count', (tester) async {
      await tester.pumpWidget(buildTestWidget(availableStatus));
      await tester.pumpAndSettle();

      expect(find.text('10 Questions'), findsOneWidget);
    });

    testWidgets('displays time limit in minutes', (tester) async {
      await tester.pumpWidget(buildTestWidget(availableStatus));
      await tester.pumpAndSettle();

      expect(find.text('5 min limit'), findsOneWidget);
    });

    testWidgets('shows Start Challenge button when not completed',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(availableStatus));
      await tester.pumpAndSettle();

      expect(find.text('Start Challenge'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows View Results button when completed', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        completedStatus,
        onViewResults: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('View Results'), findsOneWidget);
    });

    testWidgets('calls onTap when start button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        availableStatus,
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Challenge'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onViewResults when view results button is tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        completedStatus,
        onViewResults: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Results'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays countdown timer when completed', (tester) async {
      await tester.pumpWidget(buildTestWidget(completedStatus));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.textContaining('Next in'), findsOneWidget);
    });

    testWidgets('uses compact layout when specified', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        availableStatus,
        style: const DailyChallengeCardStyle(compact: true),
      ));
      await tester.pumpAndSettle();

      // Compact mode should not show the start button
      expect(find.text('Start Challenge'), findsNothing);
      // But should still show the title
      expect(find.text('Daily Challenge'), findsOneWidget);
    });
  });

  group('DailyChallengeCardCompact', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizEngineLocalizations.delegate,
          ],
          home: Scaffold(
            body: DailyChallengeCardCompact(
              status: availableStatus,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Challenge'), findsOneWidget);
    });
  });
}
