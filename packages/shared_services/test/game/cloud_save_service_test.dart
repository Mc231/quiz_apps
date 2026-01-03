import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/game/cloud_save_data.dart';
import 'package:shared_services/src/game/cloud_save_service.dart';

void main() {
  group('SaveResult', () {
    group('success factory', () {
      test('creates SaveSuccess with savedAt', () {
        final now = DateTime.now();
        final result = SaveResult.success(savedAt: now);

        expect(result, isA<SaveSuccess>());
        expect((result as SaveSuccess).savedAt, now);
      });

      test('creates SaveSuccess without savedAt', () {
        final result = SaveResult.success();

        expect(result, isA<SaveSuccess>());
        expect((result as SaveSuccess).savedAt, isNull);
      });
    });

    group('conflict factory', () {
      test('creates SaveConflict with local and remote data', () {
        final local = CloudSaveData.empty();
        final remote = CloudSaveData.empty().copyWith(longestStreak: 10);

        final result = SaveResult.conflict(
          localData: local,
          remoteData: remote,
        );

        expect(result, isA<SaveConflict>());
        expect((result as SaveConflict).localData, local);
        expect(result.remoteData, remote);
      });
    });

    group('failed factory', () {
      test('creates SaveFailed with error', () {
        final result = SaveResult.failed(
          error: 'Something went wrong',
          errorCode: 'ERR_001',
        );

        expect(result, isA<SaveFailed>());
        expect((result as SaveFailed).error, 'Something went wrong');
        expect(result.errorCode, 'ERR_001');
      });

      test('creates SaveFailed without errorCode', () {
        final result = SaveResult.failed(error: 'Error');

        expect(result, isA<SaveFailed>());
        expect((result as SaveFailed).errorCode, isNull);
      });
    });

    group('notAuthenticated factory', () {
      test('creates SaveNotAuthenticated', () {
        final result = SaveResult.notAuthenticated();

        expect(result, isA<SaveNotAuthenticated>());
      });
    });

    group('offline factory', () {
      test('creates SaveOffline', () {
        final result = SaveResult.offline();

        expect(result, isA<SaveOffline>());
      });
    });

    group('pattern matching', () {
      test('can switch on all result types', () {
        final results = <SaveResult>[
          SaveResult.success(),
          SaveResult.conflict(
            localData: CloudSaveData.empty(),
            remoteData: CloudSaveData.empty(),
          ),
          SaveResult.failed(error: 'Error'),
          SaveResult.notAuthenticated(),
          SaveResult.offline(),
        ];

        for (final result in results) {
          final message = switch (result) {
            SaveSuccess() => 'success',
            SaveConflict() => 'conflict',
            SaveFailed() => 'failed',
            SaveNotAuthenticated() => 'not authenticated',
            SaveOffline() => 'offline',
          };

          expect(message, isNotEmpty);
        }
      });
    });
  });

  group('LoadResult', () {
    group('success factory', () {
      test('creates LoadSuccess with data', () {
        final data = CloudSaveData.empty().copyWith(longestStreak: 10);
        final result = LoadResult.success(data: data);

        expect(result, isA<LoadSuccess>());
        expect((result as LoadSuccess).data, data);
      });
    });

    group('noData factory', () {
      test('creates LoadNoData', () {
        final result = LoadResult.noData();

        expect(result, isA<LoadNoData>());
      });
    });

    group('failed factory', () {
      test('creates LoadFailed with error', () {
        final result = LoadResult.failed(
          error: 'Load failed',
          errorCode: 'LOAD_ERR',
        );

        expect(result, isA<LoadFailed>());
        expect((result as LoadFailed).error, 'Load failed');
        expect(result.errorCode, 'LOAD_ERR');
      });

      test('creates LoadFailed without errorCode', () {
        final result = LoadResult.failed(error: 'Error');

        expect(result, isA<LoadFailed>());
        expect((result as LoadFailed).errorCode, isNull);
      });
    });

    group('notAuthenticated factory', () {
      test('creates LoadNotAuthenticated', () {
        final result = LoadResult.notAuthenticated();

        expect(result, isA<LoadNotAuthenticated>());
      });
    });

    group('offline factory', () {
      test('creates LoadOffline', () {
        final result = LoadResult.offline();

        expect(result, isA<LoadOffline>());
      });
    });

    group('pattern matching', () {
      test('can switch on all result types', () {
        final results = <LoadResult>[
          LoadResult.success(data: CloudSaveData.empty()),
          LoadResult.noData(),
          LoadResult.failed(error: 'Error'),
          LoadResult.notAuthenticated(),
          LoadResult.offline(),
        ];

        for (final result in results) {
          final message = switch (result) {
            LoadSuccess() => 'success',
            LoadNoData() => 'no data',
            LoadFailed() => 'failed',
            LoadNotAuthenticated() => 'not authenticated',
            LoadOffline() => 'offline',
          };

          expect(message, isNotEmpty);
        }
      });
    });
  });
}
