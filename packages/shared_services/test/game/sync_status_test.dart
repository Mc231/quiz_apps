import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/game/sync_status.dart';

void main() {
  group('SyncStatus', () {
    group('enum values', () {
      test('has all expected values', () {
        expect(SyncStatus.values, hasLength(5));
        expect(SyncStatus.values, contains(SyncStatus.synced));
        expect(SyncStatus.values, contains(SyncStatus.syncing));
        expect(SyncStatus.values, contains(SyncStatus.pendingSync));
        expect(SyncStatus.values, contains(SyncStatus.offline));
        expect(SyncStatus.values, contains(SyncStatus.error));
      });
    });

    group('isSynced', () {
      test('returns true only for synced', () {
        expect(SyncStatus.synced.isSynced, isTrue);
        expect(SyncStatus.syncing.isSynced, isFalse);
        expect(SyncStatus.pendingSync.isSynced, isFalse);
        expect(SyncStatus.offline.isSynced, isFalse);
        expect(SyncStatus.error.isSynced, isFalse);
      });
    });

    group('isSyncing', () {
      test('returns true only for syncing', () {
        expect(SyncStatus.synced.isSyncing, isFalse);
        expect(SyncStatus.syncing.isSyncing, isTrue);
        expect(SyncStatus.pendingSync.isSyncing, isFalse);
        expect(SyncStatus.offline.isSyncing, isFalse);
        expect(SyncStatus.error.isSyncing, isFalse);
      });
    });

    group('hasPendingChanges', () {
      test('returns true only for pendingSync', () {
        expect(SyncStatus.synced.hasPendingChanges, isFalse);
        expect(SyncStatus.syncing.hasPendingChanges, isFalse);
        expect(SyncStatus.pendingSync.hasPendingChanges, isTrue);
        expect(SyncStatus.offline.hasPendingChanges, isFalse);
        expect(SyncStatus.error.hasPendingChanges, isFalse);
      });
    });

    group('isOffline', () {
      test('returns true only for offline', () {
        expect(SyncStatus.synced.isOffline, isFalse);
        expect(SyncStatus.syncing.isOffline, isFalse);
        expect(SyncStatus.pendingSync.isOffline, isFalse);
        expect(SyncStatus.offline.isOffline, isTrue);
        expect(SyncStatus.error.isOffline, isFalse);
      });
    });

    group('hasError', () {
      test('returns true only for error', () {
        expect(SyncStatus.synced.hasError, isFalse);
        expect(SyncStatus.syncing.hasError, isFalse);
        expect(SyncStatus.pendingSync.hasError, isFalse);
        expect(SyncStatus.offline.hasError, isFalse);
        expect(SyncStatus.error.hasError, isTrue);
      });
    });

    group('canSync', () {
      test('returns true for synced, pendingSync, and syncing', () {
        expect(SyncStatus.synced.canSync, isTrue);
        expect(SyncStatus.syncing.canSync, isTrue);
        expect(SyncStatus.pendingSync.canSync, isTrue);
        expect(SyncStatus.offline.canSync, isFalse);
        expect(SyncStatus.error.canSync, isFalse);
      });
    });

    group('needsAttention', () {
      test('returns true for pendingSync and error', () {
        expect(SyncStatus.synced.needsAttention, isFalse);
        expect(SyncStatus.syncing.needsAttention, isFalse);
        expect(SyncStatus.pendingSync.needsAttention, isTrue);
        expect(SyncStatus.offline.needsAttention, isFalse);
        expect(SyncStatus.error.needsAttention, isTrue);
      });
    });
  });
}
