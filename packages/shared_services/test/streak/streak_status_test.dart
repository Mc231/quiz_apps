import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakStatus', () {
    group('values', () {
      test('has all expected values', () {
        expect(StreakStatus.values, hasLength(4));
        expect(StreakStatus.values, contains(StreakStatus.active));
        expect(StreakStatus.values, contains(StreakStatus.atRisk));
        expect(StreakStatus.values, contains(StreakStatus.broken));
        expect(StreakStatus.values, contains(StreakStatus.none));
      });
    });

    group('isActive', () {
      test('returns true for active status', () {
        expect(StreakStatus.active.isActive, true);
      });

      test('returns true for atRisk status', () {
        expect(StreakStatus.atRisk.isActive, true);
      });

      test('returns false for broken status', () {
        expect(StreakStatus.broken.isActive, false);
      });

      test('returns false for none status', () {
        expect(StreakStatus.none.isActive, false);
      });
    });

    group('needsActivityToday', () {
      test('returns false for active status', () {
        expect(StreakStatus.active.needsActivityToday, false);
      });

      test('returns true for atRisk status', () {
        expect(StreakStatus.atRisk.needsActivityToday, true);
      });

      test('returns false for broken status', () {
        expect(StreakStatus.broken.needsActivityToday, false);
      });

      test('returns false for none status', () {
        expect(StreakStatus.none.needsActivityToday, false);
      });
    });

    group('isEmpty', () {
      test('returns false for active status', () {
        expect(StreakStatus.active.isEmpty, false);
      });

      test('returns false for atRisk status', () {
        expect(StreakStatus.atRisk.isEmpty, false);
      });

      test('returns true for broken status', () {
        expect(StreakStatus.broken.isEmpty, true);
      });

      test('returns true for none status', () {
        expect(StreakStatus.none.isEmpty, true);
      });
    });

    group('fromString', () {
      test('parses active correctly', () {
        expect(StreakStatus.fromString('active'), StreakStatus.active);
      });

      test('parses atRisk correctly', () {
        expect(StreakStatus.fromString('atRisk'), StreakStatus.atRisk);
      });

      test('parses broken correctly', () {
        expect(StreakStatus.fromString('broken'), StreakStatus.broken);
      });

      test('parses none correctly', () {
        expect(StreakStatus.fromString('none'), StreakStatus.none);
      });

      test('returns none for invalid value', () {
        expect(StreakStatus.fromString('invalid'), StreakStatus.none);
      });

      test('returns none for null', () {
        expect(StreakStatus.fromString(null), StreakStatus.none);
      });
    });
  });
}
