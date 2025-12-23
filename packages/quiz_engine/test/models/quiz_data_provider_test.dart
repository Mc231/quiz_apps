import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';
import 'package:quiz_engine/src/models/quiz_data_provider.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

class TestQuizDataProvider extends QuizDataProvider {
  final List<QuestionEntry> questions;
  final StorageConfig? storageConfig;
  final QuizConfig? quizConfig;

  const TestQuizDataProvider({
    this.questions = const [],
    this.storageConfig,
    this.quizConfig,
  });

  @override
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    QuizCategory category,
  ) async {
    return questions;
  }

  @override
  StorageConfig? createStorageConfig(
    BuildContext context,
    QuizCategory category,
  ) {
    return storageConfig;
  }

  @override
  QuizConfig? createQuizConfig(BuildContext context, QuizCategory category) {
    return quizConfig ?? super.createQuizConfig(context, category);
  }
}

void main() {
  final testCategory = QuizCategory(
    id: 'test',
    title: (context) => 'Test',
    config: const QuizConfig(quizId: 'category_config'),
  );

  group('QuizDataProvider', () {
    testWidgets('loadQuestions returns questions', (tester) async {
      final questions = [
        QuestionEntry(type: TextQuestion('Q1')),
        QuestionEntry(type: TextQuestion('Q2')),
      ];

      final provider = TestQuizDataProvider(questions: questions);

      List<QuestionEntry>? loadedQuestions;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              provider.loadQuestions(context, testCategory).then((result) {
                loadedQuestions = result;
              });
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadedQuestions, questions);
    });

    testWidgets('createStorageConfig returns config', (tester) async {
      const storageConfig = StorageConfig(
        quizType: 'test',
        quizCategory: 'category',
      );

      final provider = TestQuizDataProvider(storageConfig: storageConfig);

      StorageConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createStorageConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, storageConfig);
    });

    testWidgets('createQuizConfig defaults to category config', (tester) async {
      final provider = const TestQuizDataProvider();

      QuizConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createQuizConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result?.quizId, 'category_config');
    });

    testWidgets('createQuizConfig returns custom config when provided',
        (tester) async {
      const customConfig = QuizConfig(quizId: 'custom');
      final provider = const TestQuizDataProvider(quizConfig: customConfig);

      QuizConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createQuizConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result?.quizId, 'custom');
    });
  });

  group('CallbackQuizDataProvider', () {
    testWidgets('loadQuestionsCallback is called', (tester) async {
      final questions = [
        QuestionEntry(type: TextQuestion('Q1')),
      ];

      final provider = CallbackQuizDataProvider(
        loadQuestionsCallback: (context, category) async => questions,
      );

      List<QuestionEntry>? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              provider.loadQuestions(context, testCategory).then((q) {
                result = q;
              });
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(result, questions);
    });

    testWidgets('createStorageConfigCallback is called when provided',
        (tester) async {
      const storageConfig = StorageConfig(quizType: 'callback_test');

      final provider = CallbackQuizDataProvider(
        loadQuestionsCallback: (context, category) async => [],
        createStorageConfigCallback: (context, category) => storageConfig,
      );

      StorageConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createStorageConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, storageConfig);
    });

    testWidgets('createStorageConfig returns null when callback not provided',
        (tester) async {
      final provider = CallbackQuizDataProvider(
        loadQuestionsCallback: (context, category) async => [],
      );

      StorageConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createStorageConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isNull);
    });

    testWidgets('createQuizConfigCallback is called when provided',
        (tester) async {
      const quizConfig = QuizConfig(quizId: 'callback_config');

      final provider = CallbackQuizDataProvider(
        loadQuestionsCallback: (context, category) async => [],
        createQuizConfigCallback: (context, category) => quizConfig,
      );

      QuizConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createQuizConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result?.quizId, 'callback_config');
    });

    testWidgets('createQuizConfig falls back to category config',
        (tester) async {
      final provider = CallbackQuizDataProvider(
        loadQuestionsCallback: (context, category) async => [],
      );

      QuizConfig? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = provider.createQuizConfig(context, testCategory);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result?.quizId, 'category_config');
    });
  });
}
