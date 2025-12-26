/// Migration v6: Add resource_inventory table for IAP/Ads support.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/resource_inventory_table.dart';
import 'migration.dart';

/// Migration v6 - Adds resource_inventory table.
///
/// Changes:
/// 1. Creates 'resource_inventory' table for tracking lives, hints, and skips
class MigrationV6 extends Migration {
  /// Creates the v6 migration.
  const MigrationV6()
      : super(
          version: 6,
          description: 'Add resource_inventory table for IAP/Ads support',
        );

  @override
  Future<void> migrate(Database db) async {
    // Create the resource_inventory table
    await db.execute(createResourceInventoryTable);
  }

  @override
  Future<void> rollback(Database db) async {
    // Drop the table on rollback
    await db.execute('DROP TABLE IF EXISTS $resourceInventoryTable');
  }
}
