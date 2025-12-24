import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DatabaseConfig', () {
    test('has correct database name', () {
      expect(DatabaseConfig.databaseName, 'quiz_app.db');
    });

    test('has correct current version', () {
      expect(DatabaseConfig.currentVersion, 2);
    });

    test('minimum version is 1', () {
      expect(DatabaseConfig.minimumVersion, 1);
    });

    test('foreign keys are enabled by default', () {
      expect(DatabaseConfig.enableForeignKeys, true);
    });

    test('WAL mode is enabled by default', () {
      expect(DatabaseConfig.enableWalMode, true);
    });

    test('default page size is 50', () {
      expect(DatabaseConfig.defaultPageSize, 50);
    });

    test('max page size is 100', () {
      expect(DatabaseConfig.maxPageSize, 100);
    });
  });
}
