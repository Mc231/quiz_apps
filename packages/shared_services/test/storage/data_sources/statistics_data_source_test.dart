import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StatisticsDataSource Interface', () {
    test('StatisticsDataSourceImpl can be instantiated', () {
      expect(
        () => StatisticsDataSourceImpl(),
        returnsNormally,
      );
    });
  });

  group('GlobalStatistics model integration', () {
    test('GlobalStatistics.empty creates valid default values', () {
      final stats = GlobalStatistics.empty();

      expect(stats.totalSessions, 0);
      expect(stats.totalCompletedSessions, 0);
      expect(stats.totalCancelledSessions, 0);
      expect(stats.totalQuestionsAnswered, 0);
      expect(stats.totalCorrectAnswers, 0);
      expect(stats.averageScorePercentage, 0.0);
      expect(stats.bestScorePercentage, 0.0);
    });

    test('GlobalStatistics calculates overallAccuracy correctly', () {
      final now = DateTime.now();
      final stats = GlobalStatistics(
        totalSessions: 10,
        totalCompletedSessions: 8,
        totalCancelledSessions: 2,
        totalQuestionsAnswered: 100,
        totalCorrectAnswers: 75,
        totalIncorrectAnswers: 20,
        totalSkippedQuestions: 5,
        totalTimePlayedSeconds: 3600,
        totalHints5050Used: 10,
        totalHintsSkipUsed: 5,
        averageScorePercentage: 75.0,
        bestScorePercentage: 100.0,
        worstScorePercentage: 50.0,
        currentStreak: 3,
        bestStreak: 5,
        totalPerfectScores: 2,
        firstSessionDate: DateTime(2024, 1, 1),
        lastSessionDate: DateTime(2024, 12, 1),
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.overallAccuracy, 75.0);
      expect(stats.completionRate, 80.0);
    });

    test('GlobalStatistics handles zero questions for accuracy', () {
      final now = DateTime.now();
      final stats = GlobalStatistics(
        totalQuestionsAnswered: 0,
        totalCorrectAnswers: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.overallAccuracy, 0.0);
    });
  });

  group('QuizTypeStatistics model integration', () {
    test('QuizTypeStatistics.generateId creates correct ID', () {
      expect(
        QuizTypeStatistics.generateId('flags', null),
        'flags',
      );
      expect(
        QuizTypeStatistics.generateId('flags', 'europe'),
        'flags_europe',
      );
    });

    test('QuizTypeStatistics calculates accuracy correctly', () {
      final now = DateTime.now();
      final stats = QuizTypeStatistics(
        id: 'flags_europe',
        quizType: 'flags',
        quizCategory: 'europe',
        totalSessions: 5,
        totalCompletedSessions: 4,
        totalQuestions: 50,
        totalCorrect: 40,
        totalIncorrect: 8,
        totalSkipped: 2,
        averageScorePercentage: 80.0,
        bestScorePercentage: 100.0,
        bestSessionId: 'session-1',
        totalTimePlayedSeconds: 1200,
        averageTimePerQuestion: 24.0,
        totalPerfectScores: 1,
        lastPlayedAt: DateTime(2024, 12, 1),
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.accuracy, 80.0);
      expect(stats.completionRate, 80.0);
    });

    test('QuizTypeStatistics.empty creates valid defaults', () {
      final stats = QuizTypeStatistics.empty(
        quizType: 'flags',
        quizCategory: 'europe',
      );

      expect(stats.id, 'flags_europe');
      expect(stats.quizType, 'flags');
      expect(stats.quizCategory, 'europe');
      expect(stats.totalSessions, 0);
    });
  });

  group('DailyStatistics model integration', () {
    test('DailyStatistics.formatDate returns correct format', () {
      final date = DateTime(2024, 6, 15);
      expect(DailyStatistics.formatDate(date), '2024-06-15');
    });

    test('DailyStatistics.formatDate handles single digit months and days', () {
      final date = DateTime(2024, 1, 5);
      expect(DailyStatistics.formatDate(date), '2024-01-05');
    });

    test('DailyStatistics calculates accuracy correctly', () {
      final now = DateTime.now();
      final stats = DailyStatistics(
        id: 'daily_2024-06-15',
        date: '2024-06-15',
        sessionsPlayed: 3,
        sessionsCompleted: 2,
        sessionsCancelled: 1,
        questionsAnswered: 30,
        correctAnswers: 24,
        incorrectAnswers: 4,
        skippedAnswers: 2,
        timePlayedSeconds: 600,
        averageScorePercentage: 80.0,
        bestScorePercentage: 90.0,
        perfectScores: 0,
        hints5050Used: 2,
        hintsSkipUsed: 1,
        livesUsed: 3,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.accuracy, 80.0);
      expect(stats.completionRate, closeTo(66.67, 0.1));
    });

    test('DailyStatistics handles zero questions for accuracy', () {
      final now = DateTime.now();
      final stats = DailyStatistics(
        id: 'daily_2024-06-15',
        date: '2024-06-15',
        sessionsPlayed: 0,
        sessionsCompleted: 0,
        sessionsCancelled: 0,
        questionsAnswered: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        skippedAnswers: 0,
        timePlayedSeconds: 0,
        averageScorePercentage: 0.0,
        bestScorePercentage: 0.0,
        perfectScores: 0,
        hints5050Used: 0,
        hintsSkipUsed: 0,
        livesUsed: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.accuracy, 0.0);
    });

    test('DailyStatistics.empty creates valid defaults', () {
      final date = DateTime(2024, 6, 15);
      final stats = DailyStatistics.empty(date: date);

      expect(stats.id, 'daily_2024-06-15');
      expect(stats.date, '2024-06-15');
      expect(stats.sessionsPlayed, 0);
    });

    test('DailyStatistics.generateId creates correct ID', () {
      final date = DateTime(2024, 6, 15);
      expect(DailyStatistics.generateId(date), 'daily_2024-06-15');
    });
  });
}
