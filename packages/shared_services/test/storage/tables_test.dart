import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('Quiz Sessions Table', () {
    test('table name is correct', () {
      expect(quizSessionsTable, 'quiz_sessions');
    });

    test('create table SQL contains required columns', () {
      expect(createQuizSessionsTable, contains('id TEXT PRIMARY KEY'));
      expect(createQuizSessionsTable, contains('quiz_name TEXT NOT NULL'));
      expect(createQuizSessionsTable, contains('quiz_id TEXT NOT NULL'));
      expect(createQuizSessionsTable, contains('quiz_type TEXT NOT NULL'));
      expect(createQuizSessionsTable, contains('total_questions INTEGER NOT NULL'));
      expect(createQuizSessionsTable, contains('score_percentage REAL NOT NULL'));
      expect(createQuizSessionsTable, contains('completion_status TEXT NOT NULL'));
      expect(createQuizSessionsTable, contains('mode TEXT NOT NULL'));
      expect(createQuizSessionsTable, contains('app_version TEXT NOT NULL'));
    });

    test('indexes are defined', () {
      expect(createQuizSessionsIndexes.length, greaterThan(0));
      expect(createQuizSessionsIndexes.any((sql) => sql.contains('idx_sessions_quiz_type')), true);
      expect(createQuizSessionsIndexes.any((sql) => sql.contains('idx_sessions_start_time')), true);
    });

    test('column names are correct', () {
      expect(QuizSessionsColumns.id, 'id');
      expect(QuizSessionsColumns.quizName, 'quiz_name');
      expect(QuizSessionsColumns.quizType, 'quiz_type');
      expect(QuizSessionsColumns.scorePercentage, 'score_percentage');
      expect(QuizSessionsColumns.completionStatus, 'completion_status');
      expect(QuizSessionsColumns.hintsUsed5050, 'hints_used_50_50');
    });
  });

  group('Question Answers Table', () {
    test('table name is correct', () {
      expect(questionAnswersTable, 'question_answers');
    });

    test('create table SQL contains required columns', () {
      expect(createQuestionAnswersTable, contains('id TEXT PRIMARY KEY'));
      expect(createQuestionAnswersTable, contains('session_id TEXT NOT NULL'));
      expect(createQuestionAnswersTable, contains('question_number INTEGER NOT NULL'));
      expect(createQuestionAnswersTable, contains('option_1_id TEXT NOT NULL'));
      expect(createQuestionAnswersTable, contains('option_1_text TEXT NOT NULL'));
      expect(createQuestionAnswersTable, contains('options_order TEXT NOT NULL'));
      expect(createQuestionAnswersTable, contains('correct_answer_id TEXT NOT NULL'));
      expect(createQuestionAnswersTable, contains('is_correct INTEGER NOT NULL'));
      expect(createQuestionAnswersTable, contains('answer_status TEXT NOT NULL'));
    });

    test('foreign key constraint is defined', () {
      expect(createQuestionAnswersTable, contains('FOREIGN KEY (session_id)'));
      expect(createQuestionAnswersTable, contains('ON DELETE CASCADE'));
    });

    test('indexes are defined', () {
      expect(createQuestionAnswersIndexes.length, greaterThan(0));
      expect(createQuestionAnswersIndexes.any((sql) => sql.contains('idx_answers_session')), true);
      expect(createQuestionAnswersIndexes.any((sql) => sql.contains('idx_answers_correct')), true);
    });
  });

  group('Global Statistics Table', () {
    test('table name is correct', () {
      expect(globalStatisticsTable, 'global_statistics');
    });

    test('create table SQL has singleton constraint', () {
      expect(createGlobalStatisticsTable, contains('id INTEGER PRIMARY KEY CHECK (id = 1)'));
    });

    test('insert statement has correct values', () {
      expect(insertGlobalStatisticsRow, contains('INSERT OR IGNORE'));
      expect(insertGlobalStatisticsRow, contains('VALUES (1,'));
    });
  });

  group('Quiz Type Statistics Table', () {
    test('table name is correct', () {
      expect(quizTypeStatisticsTable, 'quiz_type_statistics');
    });

    test('create table SQL has unique constraint', () {
      expect(createQuizTypeStatisticsTable, contains('UNIQUE(quiz_type, quiz_category)'));
    });

    test('foreign key for best_session_id is defined', () {
      expect(createQuizTypeStatisticsTable, contains('FOREIGN KEY (best_session_id)'));
      expect(createQuizTypeStatisticsTable, contains('ON DELETE SET NULL'));
    });
  });

  group('Daily Statistics Table', () {
    test('table name is correct', () {
      expect(dailyStatisticsTable, 'daily_statistics');
    });

    test('create table SQL has unique date constraint', () {
      expect(createDailyStatisticsTable, contains('date TEXT NOT NULL UNIQUE'));
    });

    test('indexes are defined', () {
      expect(createDailyStatisticsIndexes.length, greaterThan(0));
      expect(createDailyStatisticsIndexes.any((sql) => sql.contains('idx_daily_date')), true);
    });
  });

  group('User Settings Table', () {
    test('table name is correct', () {
      expect(userSettingsTable, 'user_settings');
    });

    test('create table SQL has singleton constraint', () {
      expect(createUserSettingsTable, contains('id INTEGER PRIMARY KEY CHECK (id = 1)'));
    });

    test('create table SQL has default values', () {
      expect(createUserSettingsTable, contains('sound_enabled INTEGER DEFAULT 1'));
      expect(createUserSettingsTable, contains('haptic_enabled INTEGER DEFAULT 1'));
      expect(createUserSettingsTable, contains("theme_mode TEXT DEFAULT 'light'"));
      expect(createUserSettingsTable, contains("language TEXT DEFAULT 'en'"));
      expect(createUserSettingsTable, contains('hints_50_50_available INTEGER DEFAULT 3'));
    });

    test('insert statement has correct values', () {
      expect(insertUserSettingsRow, contains('INSERT OR IGNORE'));
      expect(insertUserSettingsRow, contains('VALUES (1,'));
    });
  });
}
