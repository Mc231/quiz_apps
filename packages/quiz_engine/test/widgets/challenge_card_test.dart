import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  final testChallenge = ChallengeMode(
    id: 'survival',
    name: 'Survival',
    description: '3 lives, no hints. Can you survive?',
    icon: Icons.favorite,
    difficulty: ChallengeDifficulty.hard,
    lives: 3,
    showHints: false,
    allowSkip: false,
  );

  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ChallengeMode', () {
    test('creates with required fields', () {
      expect(testChallenge.id, 'survival');
      expect(testChallenge.name, 'Survival');
      expect(testChallenge.difficulty, ChallengeDifficulty.hard);
      expect(testChallenge.lives, 3);
      expect(testChallenge.showHints, false);
    });

    test('copyWith creates modified copy', () {
      final modified = testChallenge.copyWith(
        name: 'Modified Survival',
        lives: 5,
      );

      expect(modified.id, 'survival');
      expect(modified.name, 'Modified Survival');
      expect(modified.lives, 5);
      expect(modified.difficulty, ChallengeDifficulty.hard);
    });

    test('equality based on id', () {
      final same = ChallengeMode(
        id: 'survival',
        name: 'Different Name',
        description: 'Different description',
        icon: Icons.star,
        difficulty: ChallengeDifficulty.easy,
      );

      expect(testChallenge, equals(same));
    });
  });

  group('ChallengeDifficulty', () {
    test('easy has correct color', () {
      expect(ChallengeDifficulty.easy.color, const Color(0xFF4CAF50));
    });

    test('medium has correct color', () {
      expect(ChallengeDifficulty.medium.color, const Color(0xFFFF9800));
    });

    test('hard has correct color', () {
      expect(ChallengeDifficulty.hard.color, const Color(0xFFF44336));
    });

    test('has correct labels', () {
      expect(ChallengeDifficulty.easy.label, 'Easy');
      expect(ChallengeDifficulty.medium.label, 'Medium');
      expect(ChallengeDifficulty.hard.label, 'Hard');
    });
  });

  group('ChallengeCard', () {
    testWidgets('displays challenge name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(challenge: testChallenge),
        ),
      );

      expect(find.text('Survival'), findsOneWidget);
    });

    testWidgets('displays challenge description', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(challenge: testChallenge),
        ),
      );

      expect(find.text('3 lives, no hints. Can you survive?'), findsOneWidget);
    });

    testWidgets('displays difficulty badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(challenge: testChallenge),
        ),
      );

      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(
            challenge: testChallenge,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ChallengeCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('displays trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(
            challenge: testChallenge,
            trailing: const Text('Best: 100'),
          ),
        ),
      );

      expect(find.text('Best: 100'), findsOneWidget);
    });

    testWidgets('hides difficulty badge when configured', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeCard(
            challenge: testChallenge,
            style: const ChallengeCardStyle(showDifficultyBadge: false),
          ),
        ),
      );

      expect(find.text('Hard'), findsNothing);
    });
  });

  group('DifficultyIndicator', () {
    testWidgets('displays label by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const DifficultyIndicator(difficulty: ChallengeDifficulty.medium),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('hides label when configured', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const DifficultyIndicator(
            difficulty: ChallengeDifficulty.medium,
            showLabel: false,
            showIcon: true,
          ),
        ),
      );

      expect(find.text('Medium'), findsNothing);
      expect(find.byIcon(ChallengeDifficulty.medium.icon), findsOneWidget);
    });
  });

  group('ChallengeListWidget', () {
    final challenges = [
      ChallengeMode(
        id: 'survival',
        name: 'Survival',
        description: 'Test your limits',
        icon: Icons.favorite,
        difficulty: ChallengeDifficulty.hard,
      ),
      ChallengeMode(
        id: 'marathon',
        name: 'Marathon',
        description: 'Endless mode',
        icon: Icons.directions_run,
        difficulty: ChallengeDifficulty.easy,
      ),
      ChallengeMode(
        id: 'time_attack',
        name: 'Time Attack',
        description: '60 seconds',
        icon: Icons.timer,
        difficulty: ChallengeDifficulty.medium,
      ),
    ];

    testWidgets('displays all challenges', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: challenges,
            onChallengeSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Survival'), findsOneWidget);
      expect(find.text('Marathon'), findsOneWidget);
      expect(find.text('Time Attack'), findsOneWidget);
    });

    testWidgets('calls onChallengeSelected when challenge tapped',
        (tester) async {
      ChallengeMode? selected;

      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: challenges,
            onChallengeSelected: (c) => selected = c,
          ),
        ),
      );

      await tester.tap(find.text('Marathon'));
      await tester.pump();

      expect(selected?.id, 'marathon');
    });

    testWidgets('shows empty state when no challenges', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: const [],
            onChallengeSelected: (_) {},
          ),
        ),
      );

      expect(find.text('No challenges available'), findsOneWidget);
    });

    testWidgets('shows custom empty widget when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: const [],
            onChallengeSelected: (_) {},
            emptyWidget: const Text('Custom empty'),
          ),
        ),
      );

      expect(find.text('Custom empty'), findsOneWidget);
    });

    testWidgets('sorts by difficulty when configured', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: challenges,
            onChallengeSelected: (_) {},
            config: const ChallengeListConfig(sortByDifficulty: true),
          ),
        ),
      );

      // Find all challenge cards
      final cards = find.byType(ChallengeCard);
      expect(cards, findsNWidgets(3));
    });

    testWidgets('shows header when configured', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ChallengeListWidget(
            challenges: challenges,
            onChallengeSelected: (_) {},
            config: const ChallengeListConfig(
              showHeader: true,
              headerText: 'Game Modes',
            ),
          ),
        ),
      );

      expect(find.text('Game Modes'), findsOneWidget);
    });
  });
}
