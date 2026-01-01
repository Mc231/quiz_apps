import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('ShareImageResult', () {
    group('factory constructors', () {
      test('creates success result', () {
        final result = ShareImageResult.success(
          imageData: Uint8List(100),
          filePath: '/tmp/test.png',
          width: 1080,
          height: 1920,
        );

        expect(result, isA<ShareImageSuccess>());
        final success = result as ShareImageSuccess;
        expect(success.imageData.length, 100);
        expect(success.filePath, '/tmp/test.png');
        expect(success.width, 1080);
        expect(success.height, 1920);
      });

      test('creates failed result', () {
        final error = Exception('test error');
        final result = ShareImageResult.failed(
          message: 'Generation failed',
          error: error,
        );

        expect(result, isA<ShareImageFailed>());
        final failed = result as ShareImageFailed;
        expect(failed.message, 'Generation failed');
        expect(failed.error, error);
      });

      test('creates failed result without error', () {
        final result = ShareImageResult.failed(
          message: 'Generation failed',
        );

        expect(result, isA<ShareImageFailed>());
        expect((result as ShareImageFailed).error, isNull);
      });
    });

    test('can pattern match on results', () {
      ShareImageResult result = ShareImageSuccess(
        imageData: Uint8List(0),
        filePath: '/tmp/test.png',
        width: 1080,
        height: 1920,
      );

      final message = switch (result) {
        ShareImageSuccess(:final filePath) => 'success: $filePath',
        ShareImageFailed(:final message) => 'failed: $message',
      };

      expect(message, 'success: /tmp/test.png');
    });
  });

  group('ShareImageGenerator', () {
    late ShareImageGenerator generator;

    setUp(() {
      generator = const ShareImageGenerator();
    });

    test('provides boundary key', () {
      expect(generator.boundaryKey, isA<GlobalKey>());
    });

    test('boundary key is consistent', () {
      final key1 = generator.boundaryKey;
      final key2 = generator.boundaryKey;
      expect(key1, same(key2));
    });

    // Note: Full image generation tests require a widget testing environment
    // with Overlay support, which is complex to set up in unit tests.
    // The actual image capture functionality is tested via integration tests.
  });

  group('ShareImageSuccess', () {
    test('stores all properties', () {
      final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final success = ShareImageSuccess(
        imageData: imageData,
        filePath: '/path/to/image.png',
        width: 1080,
        height: 1920,
      );

      expect(success.imageData, imageData);
      expect(success.filePath, '/path/to/image.png');
      expect(success.width, 1080);
      expect(success.height, 1920);
    });
  });

  group('ShareImageFailed', () {
    test('stores message and optional error', () {
      final error = Exception('Test error');
      const failed = ShareImageFailed(
        message: 'Failed to generate',
        error: null,
      );
      final failedWithError = ShareImageFailed(
        message: 'Failed with error',
        error: error,
      );

      expect(failed.message, 'Failed to generate');
      expect(failed.error, isNull);
      expect(failedWithError.error, error);
    });
  });
}
