import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of [AchievementsDataProvider] for testing.
class MockAchievementsDataProvider implements AchievementsDataProvider {
  int loadAchievementsDataCallCount = 0;
  int onSessionCompletedCallCount = 0;
  QuizSession? lastCompletedSession;
  AchievementsTabData? dataToReturn;

  MockAchievementsDataProvider({this.dataToReturn});

  @override
  Future<AchievementsTabData> loadAchievementsData() async {
    loadAchievementsDataCallCount++;
    return dataToReturn ?? AchievementsTabData.empty();
  }

  @override
  Future<void> onSessionCompleted(QuizSession session) async {
    onSessionCompletedCallCount++;
    lastCompletedSession = session;
  }
}

void main() {
  group('AchievementsDataProvider', () {
    test('mock implementation tracks loadAchievementsData calls', () async {
      final provider = MockAchievementsDataProvider();

      expect(provider.loadAchievementsDataCallCount, 0);

      await provider.loadAchievementsData();
      expect(provider.loadAchievementsDataCallCount, 1);

      await provider.loadAchievementsData();
      expect(provider.loadAchievementsDataCallCount, 2);
    });

    test('mock implementation returns provided data', () async {
      final testData = AchievementsTabData(
        screenData: const AchievementsScreenData(
          achievements: [],
          totalPoints: 100,
        ),
      );

      final provider = MockAchievementsDataProvider(dataToReturn: testData);
      final result = await provider.loadAchievementsData();

      expect(result.screenData.totalPoints, 100);
    });

    test('mock implementation returns empty data when not configured', () async {
      final provider = MockAchievementsDataProvider();
      final result = await provider.loadAchievementsData();

      expect(result.screenData.achievements, isEmpty);
      expect(result.screenData.totalPoints, 0);
    });

    test('mock implementation tracks onSessionCompleted calls', () async {
      final provider = MockAchievementsDataProvider();
      final now = DateTime.now();
      final session = QuizSession(
        id: 'test-session-1',
        quizId: 'test-quiz',
        quizName: 'Test Quiz',
        quizType: 'standard',
        quizCategory: 'test',
        startTime: now,
        totalQuestions: 10,
        totalAnswered: 10,
        totalCorrect: 8,
        totalFailed: 2,
        totalSkipped: 0,
        scorePercentage: 80.0,
        completionStatus: CompletionStatus.completed,
        mode: QuizMode.normal,
        appVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
      );

      expect(provider.onSessionCompletedCallCount, 0);
      expect(provider.lastCompletedSession, isNull);

      await provider.onSessionCompleted(session);

      expect(provider.onSessionCompletedCallCount, 1);
      expect(provider.lastCompletedSession, session);
      expect(provider.lastCompletedSession?.id, 'test-session-1');
    });

    test('mock implementation tracks multiple session completions', () async {
      final provider = MockAchievementsDataProvider();
      final now = DateTime.now();
      final session1 = QuizSession(
        id: 'session-1',
        quizId: 'quiz-1',
        quizName: 'Quiz 1',
        quizType: 'standard',
        quizCategory: 'cat-1',
        startTime: now,
        totalQuestions: 5,
        totalAnswered: 5,
        totalCorrect: 4,
        totalFailed: 1,
        totalSkipped: 0,
        scorePercentage: 80.0,
        completionStatus: CompletionStatus.completed,
        mode: QuizMode.normal,
        appVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
      );
      final session2 = QuizSession(
        id: 'session-2',
        quizId: 'quiz-2',
        quizName: 'Quiz 2',
        quizType: 'timed',
        quizCategory: 'cat-2',
        startTime: now,
        totalQuestions: 10,
        totalAnswered: 10,
        totalCorrect: 9,
        totalFailed: 1,
        totalSkipped: 0,
        scorePercentage: 90.0,
        completionStatus: CompletionStatus.completed,
        mode: QuizMode.timed,
        appVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
      );

      await provider.onSessionCompleted(session1);
      expect(provider.onSessionCompletedCallCount, 1);
      expect(provider.lastCompletedSession?.id, 'session-1');

      await provider.onSessionCompleted(session2);
      expect(provider.onSessionCompletedCallCount, 2);
      expect(provider.lastCompletedSession?.id, 'session-2');
    });
  });
}
