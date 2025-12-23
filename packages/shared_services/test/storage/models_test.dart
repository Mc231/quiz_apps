import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuizSession', () {
    final now = DateTime.now();
    final session = QuizSession(
      id: 'session-1',
      quizName: 'Flags of Europe',
      quizId: 'flags-europe',
      quizType: 'flags',
      quizCategory: 'europe',
      totalQuestions: 10,
      totalAnswered: 10,
      totalCorrect: 8,
      totalFailed: 2,
      totalSkipped: 0,
      scorePercentage: 80.0,
      livesUsed: 1,
      startTime: now,
      endTime: now.add(const Duration(minutes: 5)),
      durationSeconds: 300,
      completionStatus: CompletionStatus.completed,
      mode: QuizMode.normal,
      hintsUsed5050: 1,
      hintsUsedSkip: 0,
      appVersion: '1.0.0',
      createdAt: now,
      updatedAt: now,
    );

    test('toMap creates correct database map', () {
      final map = session.toMap();

      expect(map['id'], 'session-1');
      expect(map['quiz_name'], 'Flags of Europe');
      expect(map['quiz_id'], 'flags-europe');
      expect(map['quiz_type'], 'flags');
      expect(map['quiz_category'], 'europe');
      expect(map['total_questions'], 10);
      expect(map['total_answered'], 10);
      expect(map['total_correct'], 8);
      expect(map['total_failed'], 2);
      expect(map['total_skipped'], 0);
      expect(map['score_percentage'], 80.0);
      expect(map['lives_used'], 1);
      expect(map['completion_status'], 'completed');
      expect(map['mode'], 'normal');
      expect(map['hints_used_50_50'], 1);
      expect(map['hints_used_skip'], 0);
      expect(map['app_version'], '1.0.0');
    });

    test('fromMap creates correct QuizSession', () {
      final map = session.toMap();
      final restored = QuizSession.fromMap(map);

      expect(restored.id, session.id);
      expect(restored.quizName, session.quizName);
      expect(restored.quizId, session.quizId);
      expect(restored.quizType, session.quizType);
      expect(restored.quizCategory, session.quizCategory);
      expect(restored.totalQuestions, session.totalQuestions);
      expect(restored.totalCorrect, session.totalCorrect);
      expect(restored.scorePercentage, session.scorePercentage);
      expect(restored.completionStatus, session.completionStatus);
      expect(restored.mode, session.mode);
    });

    test('isPerfectScore returns true for 100% score', () {
      final perfectSession = session.copyWith(
        scorePercentage: 100.0,
        totalCorrect: 10,
        totalFailed: 0,
      );
      expect(perfectSession.isPerfectScore, true);
      expect(session.isPerfectScore, false);
    });

    test('isCompleted returns true only for completed status', () {
      expect(session.isCompleted, true);

      final cancelledSession = session.copyWith(
        completionStatus: CompletionStatus.cancelled,
      );
      expect(cancelledSession.isCompleted, false);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = session.copyWith(
        scorePercentage: 90.0,
        totalCorrect: 9,
      );

      expect(updated.scorePercentage, 90.0);
      expect(updated.totalCorrect, 9);
      expect(updated.id, session.id); // unchanged
      expect(updated.quizName, session.quizName); // unchanged
    });
  });

  group('CompletionStatus', () {
    test('fromString parses valid values', () {
      expect(CompletionStatus.fromString('completed'), CompletionStatus.completed);
      expect(CompletionStatus.fromString('cancelled'), CompletionStatus.cancelled);
      expect(CompletionStatus.fromString('timeout'), CompletionStatus.timeout);
      expect(CompletionStatus.fromString('failed'), CompletionStatus.failed);
    });

    test('fromString returns cancelled for invalid values', () {
      expect(CompletionStatus.fromString('invalid'), CompletionStatus.cancelled);
    });
  });

  group('QuizMode', () {
    test('fromString parses valid values', () {
      expect(QuizMode.fromString('normal'), QuizMode.normal);
      expect(QuizMode.fromString('timed'), QuizMode.timed);
      expect(QuizMode.fromString('endless'), QuizMode.endless);
      expect(QuizMode.fromString('survival'), QuizMode.survival);
    });

    test('fromString returns normal for invalid values', () {
      expect(QuizMode.fromString('invalid'), QuizMode.normal);
    });
  });

  group('QuestionAnswer', () {
    final now = DateTime.now();
    final answer = QuestionAnswer(
      id: 'answer-1',
      sessionId: 'session-1',
      questionNumber: 1,
      questionId: 'q-1',
      questionType: QuestionType.image,
      questionResourceUrl: 'assets/flags/de.png',
      option1: const AnswerOption(id: 'o1', text: 'Germany'),
      option2: const AnswerOption(id: 'o2', text: 'France'),
      option3: const AnswerOption(id: 'o3', text: 'Italy'),
      option4: const AnswerOption(id: 'o4', text: 'Spain'),
      optionsOrder: ['o1', 'o3', 'o2', 'o4'],
      correctAnswer: const AnswerOption(id: 'o1', text: 'Germany'),
      userAnswer: const AnswerOption(id: 'o1', text: 'Germany'),
      isCorrect: true,
      answerStatus: AnswerStatus.correct,
      timeSpentSeconds: 5,
      answeredAt: now,
      hintUsed: HintUsed.none,
      disabledOptions: [],
      createdAt: now,
    );

    test('toMap creates correct database map', () {
      final map = answer.toMap();

      expect(map['id'], 'answer-1');
      expect(map['session_id'], 'session-1');
      expect(map['question_number'], 1);
      expect(map['question_id'], 'q-1');
      expect(map['question_type'], 'image');
      expect(map['option_1_id'], 'o1');
      expect(map['option_1_text'], 'Germany');
      expect(map['correct_answer_id'], 'o1');
      expect(map['user_answer_id'], 'o1');
      expect(map['is_correct'], 1);
      expect(map['answer_status'], 'correct');
      expect(map['hint_used'], 'none');
    });

    test('fromMap creates correct QuestionAnswer', () {
      final map = answer.toMap();
      final restored = QuestionAnswer.fromMap(map);

      expect(restored.id, answer.id);
      expect(restored.sessionId, answer.sessionId);
      expect(restored.questionNumber, answer.questionNumber);
      expect(restored.questionType, answer.questionType);
      expect(restored.isCorrect, answer.isCorrect);
      expect(restored.answerStatus, answer.answerStatus);
      expect(restored.optionsOrder, answer.optionsOrder);
    });

    test('orderedOptions returns options in presentation order', () {
      final ordered = answer.orderedOptions;

      expect(ordered.length, 4);
      expect(ordered[0].id, 'o1'); // Germany
      expect(ordered[1].id, 'o3'); // Italy
      expect(ordered[2].id, 'o2'); // France
      expect(ordered[3].id, 'o4'); // Spain
    });

    test('handles 50/50 hint with disabled options', () {
      final hintAnswer = answer.copyWith(
        hintUsed: HintUsed.fiftyFifty,
        disabledOptions: ['o2', 'o4'],
      );

      expect(hintAnswer.hintUsed, HintUsed.fiftyFifty);
      expect(hintAnswer.disabledOptions, ['o2', 'o4']);
    });

    test('handles skipped answer', () {
      final skippedAnswer = QuestionAnswer(
        id: 'answer-2',
        sessionId: 'session-1',
        questionNumber: 2,
        questionId: 'q-2',
        questionType: QuestionType.image,
        option1: const AnswerOption(id: 'o1', text: 'A'),
        option2: const AnswerOption(id: 'o2', text: 'B'),
        option3: const AnswerOption(id: 'o3', text: 'C'),
        option4: const AnswerOption(id: 'o4', text: 'D'),
        optionsOrder: ['o1', 'o2', 'o3', 'o4'],
        correctAnswer: const AnswerOption(id: 'o1', text: 'A'),
        userAnswer: null,
        isCorrect: false,
        answerStatus: AnswerStatus.skipped,
        hintUsed: HintUsed.skip,
        createdAt: now,
      );

      expect(skippedAnswer.userAnswer, isNull);
      expect(skippedAnswer.answerStatus, AnswerStatus.skipped);
      expect(skippedAnswer.hintUsed, HintUsed.skip);
    });
  });

  group('GlobalStatistics', () {
    test('empty creates default statistics', () {
      final stats = GlobalStatistics.empty();

      expect(stats.totalSessions, 0);
      expect(stats.totalCompletedSessions, 0);
      expect(stats.averageScorePercentage, 0);
      expect(stats.bestStreak, 0);
    });

    test('overallAccuracy calculates correctly', () {
      final now = DateTime.now();
      final stats = GlobalStatistics(
        totalQuestionsAnswered: 100,
        totalCorrectAnswers: 75,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.overallAccuracy, 75.0);
    });

    test('overallAccuracy returns 0 when no questions answered', () {
      final stats = GlobalStatistics.empty();
      expect(stats.overallAccuracy, 0);
    });

    test('completionRate calculates correctly', () {
      final now = DateTime.now();
      final stats = GlobalStatistics(
        totalSessions: 10,
        totalCompletedSessions: 8,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.completionRate, 80.0);
    });

    test('toMap and fromMap round-trip correctly', () {
      final now = DateTime.now();
      final stats = GlobalStatistics(
        totalSessions: 50,
        totalCompletedSessions: 45,
        totalQuestionsAnswered: 500,
        totalCorrectAnswers: 400,
        averageScorePercentage: 80.0,
        bestScorePercentage: 100.0,
        bestStreak: 25,
        totalPerfectScores: 5,
        createdAt: now,
        updatedAt: now,
      );

      final map = stats.toMap();
      final restored = GlobalStatistics.fromMap(map);

      expect(restored.totalSessions, stats.totalSessions);
      expect(restored.totalCompletedSessions, stats.totalCompletedSessions);
      expect(restored.averageScorePercentage, stats.averageScorePercentage);
      expect(restored.bestStreak, stats.bestStreak);
    });
  });

  group('QuizTypeStatistics', () {
    test('generateId creates correct ID', () {
      expect(QuizTypeStatistics.generateId('flags', null), 'flags');
      expect(QuizTypeStatistics.generateId('flags', 'europe'), 'flags_europe');
      expect(QuizTypeStatistics.generateId('capitals', 'asia'), 'capitals_asia');
    });

    test('empty creates default statistics for type', () {
      final stats = QuizTypeStatistics.empty(
        quizType: 'flags',
        quizCategory: 'europe',
      );

      expect(stats.id, 'flags_europe');
      expect(stats.quizType, 'flags');
      expect(stats.quizCategory, 'europe');
      expect(stats.totalSessions, 0);
    });

    test('displayName shows type and category', () {
      final now = DateTime.now();
      final stats = QuizTypeStatistics(
        id: 'flags_europe',
        quizType: 'flags',
        quizCategory: 'europe',
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.displayName, 'flags - europe');
    });

    test('displayName shows only type when no category', () {
      final now = DateTime.now();
      final stats = QuizTypeStatistics(
        id: 'flags',
        quizType: 'flags',
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.displayName, 'flags');
    });

    test('accuracy calculates correctly', () {
      final now = DateTime.now();
      final stats = QuizTypeStatistics(
        id: 'flags',
        quizType: 'flags',
        totalQuestions: 100,
        totalCorrect: 80,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.accuracy, 80.0);
    });
  });

  group('DailyStatistics', () {
    test('formatDate creates correct format', () {
      final date = DateTime(2025, 12, 23);
      expect(DailyStatistics.formatDate(date), '2025-12-23');
    });

    test('formatDate pads single digits', () {
      final date = DateTime(2025, 1, 5);
      expect(DailyStatistics.formatDate(date), '2025-01-05');
    });

    test('generateId creates correct ID', () {
      final date = DateTime(2025, 12, 23);
      expect(DailyStatistics.generateId(date), 'daily_2025-12-23');
    });

    test('empty creates default statistics for date', () {
      final date = DateTime(2025, 12, 23);
      final stats = DailyStatistics.empty(date: date);

      expect(stats.id, 'daily_2025-12-23');
      expect(stats.date, '2025-12-23');
      expect(stats.sessionsPlayed, 0);
    });

    test('dateTime parses date correctly', () {
      final now = DateTime.now();
      final stats = DailyStatistics(
        id: 'daily_2025-12-23',
        date: '2025-12-23',
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.dateTime, DateTime(2025, 12, 23));
    });

    test('accuracy calculates correctly', () {
      final now = DateTime.now();
      final stats = DailyStatistics(
        id: 'daily_2025-12-23',
        date: '2025-12-23',
        questionsAnswered: 50,
        correctAnswers: 40,
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.accuracy, 80.0);
    });

    test('timePlayed returns correct duration', () {
      final now = DateTime.now();
      final stats = DailyStatistics(
        id: 'daily_2025-12-23',
        date: '2025-12-23',
        timePlayedSeconds: 3600, // 1 hour
        createdAt: now,
        updatedAt: now,
      );

      expect(stats.timePlayed, const Duration(hours: 1));
    });
  });

  group('UserSettingsModel', () {
    test('defaults creates settings with default values', () {
      final settings = UserSettingsModel.defaults();

      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.exitConfirmationEnabled, true);
      expect(settings.showHints, true);
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.language, 'en');
      expect(settings.hints5050Available, 3);
      expect(settings.hintsSkipAvailable, 3);
    });

    test('totalHintsAvailable sums both hint types', () {
      final now = DateTime.now();
      final settings = UserSettingsModel(
        hints5050Available: 5,
        hintsSkipAvailable: 3,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.totalHintsAvailable, 8);
    });

    test('toMap and fromMap round-trip correctly', () {
      final now = DateTime.now();
      final settings = UserSettingsModel(
        soundEnabled: false,
        hapticEnabled: true,
        exitConfirmationEnabled: false,
        showHints: true,
        themeMode: AppThemeMode.dark,
        language: 'uk',
        hints5050Available: 5,
        hintsSkipAvailable: 2,
        lastPlayedQuizType: 'flags',
        lastPlayedCategory: 'europe',
        createdAt: now,
        updatedAt: now,
      );

      final map = settings.toMap();
      final restored = UserSettingsModel.fromMap(map);

      expect(restored.soundEnabled, settings.soundEnabled);
      expect(restored.hapticEnabled, settings.hapticEnabled);
      expect(restored.themeMode, settings.themeMode);
      expect(restored.language, settings.language);
      expect(restored.hints5050Available, settings.hints5050Available);
      expect(restored.lastPlayedQuizType, settings.lastPlayedQuizType);
    });

    test('copyWith creates new instance with updated fields', () {
      final settings = UserSettingsModel.defaults();
      final updated = settings.copyWith(
        soundEnabled: false,
        themeMode: AppThemeMode.dark,
      );

      expect(updated.soundEnabled, false);
      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.hapticEnabled, true); // unchanged
      expect(updated.language, 'en'); // unchanged
    });
  });

  group('AppThemeMode', () {
    test('values are defined correctly', () {
      expect(AppThemeMode.values.length, 3);
      expect(AppThemeMode.light.name, 'light');
      expect(AppThemeMode.dark.name, 'dark');
      expect(AppThemeMode.system.name, 'system');
    });

    test('parsing via UserSettingsModel.fromMap works correctly', () {
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch ~/ 1000;

      // Test light mode
      var map = _createSettingsMap('light', timestamp);
      var settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.light);

      // Test dark mode
      map = _createSettingsMap('dark', timestamp);
      settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.dark);

      // Test system mode
      map = _createSettingsMap('system', timestamp);
      settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.system);

      // Test invalid falls back to system
      map = _createSettingsMap('invalid', timestamp);
      settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.system);
    });
  });

  group('AnswerStatus', () {
    test('fromString parses valid values', () {
      expect(AnswerStatus.fromString('correct'), AnswerStatus.correct);
      expect(AnswerStatus.fromString('incorrect'), AnswerStatus.incorrect);
      expect(AnswerStatus.fromString('skipped'), AnswerStatus.skipped);
      expect(AnswerStatus.fromString('timeout'), AnswerStatus.timeout);
    });

    test('fromString returns skipped for invalid values', () {
      expect(AnswerStatus.fromString('invalid'), AnswerStatus.skipped);
    });
  });

  group('QuestionType', () {
    test('fromString parses valid values', () {
      expect(QuestionType.fromString('image'), QuestionType.image);
      expect(QuestionType.fromString('text'), QuestionType.text);
      expect(QuestionType.fromString('audio'), QuestionType.audio);
      expect(QuestionType.fromString('video'), QuestionType.video);
    });

    test('fromString returns text for invalid values', () {
      expect(QuestionType.fromString('invalid'), QuestionType.text);
    });
  });

  group('HintUsed', () {
    test('fromString parses valid values', () {
      expect(HintUsed.fromString('none'), HintUsed.none);
      expect(HintUsed.fromString('50_50'), HintUsed.fiftyFifty);
      expect(HintUsed.fromString('skip'), HintUsed.skip);
    });

    test('fromString returns none for null', () {
      expect(HintUsed.fromString(null), HintUsed.none);
    });

    test('fromString returns none for invalid values', () {
      expect(HintUsed.fromString('invalid'), HintUsed.none);
    });
  });
}

/// Helper to create a settings map for testing.
Map<String, dynamic> _createSettingsMap(String themeMode, int timestamp) {
  return {
    'id': 1,
    'sound_enabled': 1,
    'haptic_enabled': 1,
    'exit_confirmation_enabled': 1,
    'show_hints': 1,
    'theme_mode': themeMode,
    'language': 'en',
    'hints_50_50_available': 3,
    'hints_skip_available': 3,
    'last_played_quiz_type': null,
    'last_played_category': null,
    'created_at': timestamp,
    'updated_at': timestamp,
  };
}
