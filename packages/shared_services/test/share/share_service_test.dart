import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ShareOperationResult', () {
    group('factory constructors', () {
      test('creates success result', () {
        final result = ShareOperationResult.success();

        expect(result, isA<ShareOperationSuccess>());
        expect((result as ShareOperationSuccess).sharedTo, isNull);
      });

      test('creates success result with sharedTo', () {
        final result = ShareOperationResult.success(sharedTo: 'Twitter');

        expect(result, isA<ShareOperationSuccess>());
        expect((result as ShareOperationSuccess).sharedTo, 'Twitter');
      });

      test('creates cancelled result', () {
        final result = ShareOperationResult.cancelled();

        expect(result, isA<ShareOperationCancelled>());
      });

      test('creates failed result', () {
        final result = ShareOperationResult.failed(
          message: 'Network error',
          error: Exception('test'),
        );

        expect(result, isA<ShareOperationFailed>());
        final failed = result as ShareOperationFailed;
        expect(failed.message, 'Network error');
        expect(failed.error, isA<Exception>());
      });

      test('creates unavailable result', () {
        final result = ShareOperationResult.unavailable(
          reason: 'Platform not supported',
        );

        expect(result, isA<ShareOperationUnavailable>());
        expect(
          (result as ShareOperationUnavailable).reason,
          'Platform not supported',
        );
      });
    });

    group('pattern matching', () {
      test('can pattern match on results', () {
        ShareOperationResult result = const ShareOperationSuccess();

        final message = switch (result) {
          ShareOperationSuccess() => 'success',
          ShareOperationCancelled() => 'cancelled',
          ShareOperationFailed(:final message) => 'failed: $message',
          ShareOperationUnavailable(:final reason) => 'unavailable: $reason',
        };

        expect(message, 'success');
      });
    });
  });

  group('NoOpShareService', () {
    late NoOpShareService service;

    setUp(() {
      service = const NoOpShareService();
    });

    test('canShare returns false', () {
      expect(service.canShare(), isFalse);
    });

    test('canShareImage returns false', () {
      expect(service.canShareImage(), isFalse);
    });

    test('shareText returns unavailable', () async {
      final result = await service.shareText(
        ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        ),
      );

      expect(result, isA<ShareOperationUnavailable>());
    });

    test('shareImage returns unavailable', () async {
      final result = await service.shareImage(
        ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        ),
        imageData: Uint8List(0),
      );

      expect(result, isA<ShareOperationUnavailable>());
    });

    test('generateShareText returns empty string', () {
      final text = service.generateShareText(
        ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        ),
      );

      expect(text, isEmpty);
    });

    test('generateShortShareText returns empty string', () {
      final text = service.generateShortShareText(
        ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        ),
      );

      expect(text, isEmpty);
    });

    test('config returns disabled config', () {
      expect(service.config.isEnabled, isFalse);
    });

    test('dispose does nothing', () {
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('MockShareService', () {
    late MockShareService service;

    setUp(() {
      service = MockShareService();
    });

    tearDown(() {
      service.dispose();
    });

    group('configuration', () {
      test('uses default test config', () {
        expect(service.config.appName, 'Test App');
      });

      test('accepts custom config', () {
        service = MockShareService(
          config: const ShareConfig(
            appName: 'Custom App',
            hashtags: ['Custom'],
          ),
        );

        expect(service.config.appName, 'Custom App');
        expect(service.config.hashtags, ['Custom']);
      });
    });

    group('canShare', () {
      test('returns true when text sharing enabled', () {
        service = MockShareService(
          config: const ShareConfig.test(enableTextSharing: true),
        );

        expect(service.canShare(), isTrue);
      });

      test('returns false when text sharing disabled', () {
        service = MockShareService(
          config: const ShareConfig.test(enableTextSharing: false),
        );

        expect(service.canShare(), isFalse);
      });
    });

    group('canShareImage', () {
      test('returns true when image sharing enabled', () {
        service = MockShareService(
          config: const ShareConfig.test(enableImageSharing: true),
        );

        expect(service.canShareImage(), isTrue);
      });

      test('returns false when image sharing disabled', () {
        service = MockShareService(
          config: const ShareConfig.test(enableImageSharing: false),
        );

        expect(service.canShareImage(), isFalse);
      });
    });

    group('shareText', () {
      test('returns success when simulateSuccess is true', () async {
        service = MockShareService(simulateSuccess: true);

        final result = await service.shareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(result, isA<ShareOperationSuccess>());
      });

      test('returns failed when simulateSuccess is false', () async {
        service = MockShareService(simulateSuccess: false);

        final result = await service.shareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(result, isA<ShareOperationFailed>());
      });

      test('adds result to shareHistory', () async {
        final shareResult = ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        await service.shareText(shareResult);

        expect(service.shareHistory, contains(shareResult));
        expect(service.lastSharedResult, equals(shareResult));
      });

      test('respects simulatedDelay', () async {
        service = MockShareService(
          simulatedDelay: const Duration(milliseconds: 100),
        );

        final stopwatch = Stopwatch()..start();
        await service.shareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('shareImage', () {
      test('returns success when simulateSuccess is true', () async {
        service = MockShareService(simulateSuccess: true);

        final result = await service.shareImage(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
          imageData: Uint8List(10),
        );

        expect(result, isA<ShareOperationSuccess>());
      });

      test('adds result to shareHistory', () async {
        final shareResult = ShareResult(
          score: 90.0,
          categoryName: 'Image Test',
          correctCount: 9,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        await service.shareImage(
          shareResult,
          imageData: Uint8List(10),
          text: 'Custom text',
        );

        expect(service.shareHistory, contains(shareResult));
      });
    });

    group('generateShareText', () {
      test('generates basic text with score and category', () {
        final text = service.generateShareText(
          ShareResult(
            score: 85.0,
            categoryName: 'European Flags',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(text, contains('85%'));
        expect(text, contains('European Flags'));
        expect(text, contains('17/20'));
      });

      test('includes achievement when present', () {
        final text = service.generateShareText(
          ShareResult(
            score: 100.0,
            categoryName: 'Test',
            correctCount: 10,
            totalCount: 10,
            mode: 'standard',
            timestamp: DateTime.now(),
            achievementUnlocked: 'Perfectionist',
          ),
        );

        expect(text, contains('Achievement unlocked: Perfectionist'));
      });

      test('includes app link when configured', () {
        service = MockShareService(
          config: const ShareConfig(
            appName: 'Flags Quiz',
            playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example',
            includeAppLink: true,
          ),
        );

        final text = service.generateShareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(text, contains('Play Flags Quiz'));
        expect(text, contains('https://play.google.com/store/apps/details?id=com.example'));
      });

      test('includes hashtags when configured', () {
        service = MockShareService(
          config: const ShareConfig(
            appName: 'Flags Quiz',
            hashtags: ['FlagsQuiz', 'Quiz'],
            includeHashtags: true,
          ),
        );

        final text = service.generateShareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(text, contains('#FlagsQuiz #Quiz'));
      });
    });

    group('generateShortShareText', () {
      test('generates short text with score and category', () {
        final text = service.generateShortShareText(
          ShareResult(
            score: 85.0,
            categoryName: 'European Flags',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(text, contains('85%'));
        expect(text, contains('European Flags'));
        expect(text, isNot(contains('17/20')));
      });

      test('includes hashtags when configured', () {
        service = MockShareService(
          config: const ShareConfig(
            appName: 'Test',
            hashtags: ['Quiz'],
            includeHashtags: true,
          ),
        );

        final text = service.generateShortShareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        expect(text, contains('#Quiz'));
      });
    });

    group('history management', () {
      test('lastSharedResult returns null when history empty', () {
        expect(service.lastSharedResult, isNull);
      });

      test('lastSharedResult returns most recent result', () async {
        final result1 = ShareResult(
          score: 80.0,
          categoryName: 'First',
          correctCount: 8,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );
        final result2 = ShareResult(
          score: 90.0,
          categoryName: 'Second',
          correctCount: 9,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        await service.shareText(result1);
        await service.shareText(result2);

        expect(service.lastSharedResult, equals(result2));
      });

      test('clearHistory clears all history', () async {
        await service.shareText(
          ShareResult(
            score: 85.0,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ),
        );

        service.clearHistory();

        expect(service.shareHistory, isEmpty);
        expect(service.lastSharedResult, isNull);
      });
    });
  });
}
