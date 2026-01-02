import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('QuizNavigationResult', () {
    group('NavigationSuccess', () {
      test('creates via factory', () {
        final result = QuizNavigationResult.success();

        expect(result, isA<NavigationSuccess>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('equality', () {
        final result1 = QuizNavigationResult.success();
        final result2 = QuizNavigationResult.success();

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString', () {
        final result = QuizNavigationResult.success();

        expect(result.toString(), 'NavigationSuccess()');
      });
    });

    group('NavigationNotReady', () {
      test('creates via factory', () {
        final result = QuizNavigationResult.notReady();

        expect(result, isA<NavigationNotReady>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });

      test('equality', () {
        final result1 = QuizNavigationResult.notReady();
        final result2 = QuizNavigationResult.notReady();

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString', () {
        final result = QuizNavigationResult.notReady();

        expect(result.toString(), 'NavigationNotReady()');
      });
    });

    group('NavigationInvalidId', () {
      test('creates via factory', () {
        final result = QuizNavigationResult.invalidId(
          id: 'europe',
          type: 'category',
        );

        expect(result, isA<NavigationInvalidId>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);

        final invalidId = result as NavigationInvalidId;
        expect(invalidId.id, 'europe');
        expect(invalidId.type, 'category');
      });

      test('equality', () {
        final result1 = QuizNavigationResult.invalidId(
          id: 'europe',
          type: 'category',
        );
        final result2 = QuizNavigationResult.invalidId(
          id: 'europe',
          type: 'category',
        );
        final result3 = QuizNavigationResult.invalidId(
          id: 'asia',
          type: 'category',
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
        expect(result1, isNot(equals(result3)));
      });

      test('toString', () {
        final result = QuizNavigationResult.invalidId(
          id: 'europe',
          type: 'category',
        );

        expect(result.toString(), 'NavigationInvalidId(id: europe, type: category)');
      });
    });

    group('NavigationError', () {
      test('creates via factory', () {
        final result = QuizNavigationResult.error('timeout');

        expect(result, isA<NavigationError>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);

        final error = result as NavigationError;
        expect(error.message, 'timeout');
      });

      test('equality', () {
        final result1 = QuizNavigationResult.error('timeout');
        final result2 = QuizNavigationResult.error('timeout');
        final result3 = QuizNavigationResult.error('other');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
        expect(result1, isNot(equals(result3)));
      });

      test('toString', () {
        final result = QuizNavigationResult.error('timeout');

        expect(result.toString(), 'NavigationError(message: timeout)');
      });
    });

    group('pattern matching', () {
      test('matches all cases', () {
        void handleResult(QuizNavigationResult result) {
          final message = switch (result) {
            NavigationSuccess() => 'success',
            NavigationNotReady() => 'not_ready',
            NavigationInvalidId(:final id, :final type) => 'invalid_$type:$id',
            NavigationError(:final message) => 'error:$message',
          };

          expect(message, isNotNull);
        }

        handleResult(QuizNavigationResult.success());
        handleResult(QuizNavigationResult.notReady());
        handleResult(QuizNavigationResult.invalidId(id: 'x', type: 'y'));
        handleResult(QuizNavigationResult.error('z'));
      });
    });
  });
}
