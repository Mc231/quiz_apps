import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('LeaderboardEntry', () {
    test('creates with required parameters', () {
      final entry = LeaderboardEntry(
        rank: 1,
        sessionId: 'session-1',
        quizName: 'Europe Quiz',
        score: 95.0,
        date: DateTime(2024, 1, 1),
      );

      expect(entry.rank, 1);
      expect(entry.sessionId, 'session-1');
      expect(entry.quizName, 'Europe Quiz');
      expect(entry.score, 95.0);
      expect(entry.isPerfect, isFalse);
    });

    test('creates with all parameters', () {
      final entry = LeaderboardEntry(
        rank: 1,
        sessionId: 'session-1',
        quizName: 'Europe Quiz',
        score: 100.0,
        date: DateTime(2024, 1, 1),
        categoryName: 'Europe',
        totalQuestions: 20,
        correctAnswers: 20,
        durationSeconds: 180,
        isPerfect: true,
      );

      expect(entry.isPerfect, isTrue);
      expect(entry.totalQuestions, 20);
      expect(entry.correctAnswers, 20);
      expect(entry.durationSeconds, 180);
    });

    test('formats duration correctly', () {
      final entry = LeaderboardEntry(
        rank: 1,
        sessionId: 'session-1',
        quizName: 'Quiz',
        score: 95.0,
        date: DateTime(2024, 1, 1),
        durationSeconds: 125,
      );

      expect(entry.formattedDuration, '2m 5s');
    });

    test('formats short duration correctly', () {
      final entry = LeaderboardEntry(
        rank: 1,
        sessionId: 'session-1',
        quizName: 'Quiz',
        score: 95.0,
        date: DateTime(2024, 1, 1),
        durationSeconds: 45,
      );

      expect(entry.formattedDuration, '45s');
    });
  });

  group('LeaderboardType', () {
    test('has all expected values', () {
      expect(LeaderboardType.values.length, 4);
      expect(LeaderboardType.values, contains(LeaderboardType.bestScores));
      expect(LeaderboardType.values, contains(LeaderboardType.fastestPerfect));
      expect(LeaderboardType.values, contains(LeaderboardType.mostPlayed));
      expect(LeaderboardType.values, contains(LeaderboardType.bestStreaks));
    });
  });

  group('LeaderboardWidget', () {
    testWidgets('shows empty state when no entries', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          const LeaderboardWidget(
            entries: [],
          ),
        ),
      );

      expect(find.byIcon(Icons.leaderboard_outlined), findsOneWidget);
    });

    testWidgets('shows leaderboard entries', (tester) async {
      final entries = [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'Europe Quiz',
          score: 95.0,
          date: DateTime.now(),
        ),
        LeaderboardEntry(
          rank: 2,
          sessionId: 'session-2',
          quizName: 'Asia Quiz',
          score: 90.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
          ),
        ),
      );

      expect(find.text('Europe Quiz'), findsOneWidget);
      expect(find.text('Asia Quiz'), findsOneWidget);
    });

    testWidgets('shows medal icons for top 3', (tester) async {
      final entries = [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'Quiz 1',
          score: 100.0,
          date: DateTime.now(),
        ),
        LeaderboardEntry(
          rank: 2,
          sessionId: 'session-2',
          quizName: 'Quiz 2',
          score: 95.0,
          date: DateTime.now(),
        ),
        LeaderboardEntry(
          rank: 3,
          sessionId: 'session-3',
          quizName: 'Quiz 3',
          score: 90.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
            showMedals: true,
          ),
        ),
      );

      // Should find medal icons for top 3
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(4)); // 3 medals + header
    });

    testWidgets('shows star for perfect scores', (tester) async {
      final entries = [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'Perfect Quiz',
          score: 100.0,
          date: DateTime.now(),
          isPerfect: true,
        ),
      ];

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('calls onEntryTap when entry is tapped', (tester) async {
      LeaderboardEntry? tappedEntry;

      final entries = [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'Quiz 1',
          score: 95.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
            onEntryTap: (entry) {
              tappedEntry = entry;
            },
          ),
        ),
      );

      await tester.tap(find.text('Quiz 1'));
      await tester.pump();

      expect(tappedEntry, isNotNull);
      expect(tappedEntry!.sessionId, 'session-1');
    });

    testWidgets('highlights session when highlightSessionId is set',
        (tester) async {
      final entries = [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'Quiz 1',
          score: 95.0,
          date: DateTime.now(),
        ),
        LeaderboardEntry(
          rank: 2,
          sessionId: 'session-2',
          quizName: 'Quiz 2',
          score: 90.0,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
            highlightSessionId: 'session-2',
          ),
        ),
      );

      // The widget should render without errors
      expect(find.text('Quiz 2'), findsOneWidget);
    });

    testWidgets('limits entries to maxEntries', (tester) async {
      final entries = List.generate(
        10,
        (i) => LeaderboardEntry(
          rank: i + 1,
          sessionId: 'session-$i',
          quizName: 'Quiz $i',
          score: 100.0 - i,
          date: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardWidget(
            entries: entries,
            maxEntries: 5,
          ),
        ),
      );

      // Should only show 5 entries
      expect(find.text('Quiz 0'), findsOneWidget);
      expect(find.text('Quiz 4'), findsOneWidget);
      expect(find.text('Quiz 5'), findsNothing);
    });
  });

  group('LeaderboardTypeSelector', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          LeaderboardTypeSelector(
            selectedType: LeaderboardType.bestScores,
            onTypeChanged: (_) {},
          ),
        ),
      );

      // Widget renders successfully
      expect(find.byType(LeaderboardTypeSelector), findsOneWidget);
    });
  });
}
