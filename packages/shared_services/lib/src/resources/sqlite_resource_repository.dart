import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../storage/database/app_database.dart';
import '../storage/database/tables/resource_inventory_table.dart';
import 'resource_inventory.dart';
import 'resource_repository.dart';
import 'resource_type.dart';

/// SQLite implementation of [ResourceRepository].
///
/// Persists resource inventory to the app's SQLite database.
/// Data survives app restarts.
///
/// Example usage:
/// ```dart
/// final repository = SqliteResourceRepository(AppDatabase.instance);
/// final manager = ResourceManager(
///   config: ResourceConfig.standard(),
///   repository: repository,
/// );
/// ```
class SqliteResourceRepository implements ResourceRepository {
  /// The database instance.
  final AppDatabase _database;

  /// Key for storing last reset date in a separate entry.
  static const String _lastResetKey = '_system_last_reset';

  /// Creates a [SqliteResourceRepository].
  SqliteResourceRepository(this._database);

  @override
  Future<ResourceInventoryEntity?> getInventory(ResourceType type) async {
    final results = await _database.query(
      resourceInventoryTable,
      where: '${ResourceInventoryColumns.resourceType} = ?',
      whereArgs: [type.id],
    );

    if (results.isEmpty) return null;

    return _entityFromMap(results.first);
  }

  @override
  Future<void> saveInventory(
    ResourceType type,
    ResourceInventoryEntity entity,
  ) async {
    final now = DateTime.now();
    final map = {
      ResourceInventoryColumns.resourceType: type.id,
      ResourceInventoryColumns.freeRemaining: entity.freeRemaining,
      ResourceInventoryColumns.purchasedRemaining: entity.purchasedRemaining,
      ResourceInventoryColumns.lastResetDate:
          entity.lastResetDate.millisecondsSinceEpoch,
      ResourceInventoryColumns.createdAt:
          entity.createdAt.millisecondsSinceEpoch,
      ResourceInventoryColumns.updatedAt: now.millisecondsSinceEpoch,
    };

    // Use INSERT OR REPLACE to handle both insert and update
    await _database.insert(
      resourceInventoryTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<ResourceType, ResourceInventoryEntity>> getAllInventories() async {
    final results = await _database.query(
      resourceInventoryTable,
      where: '${ResourceInventoryColumns.resourceType} != ?',
      whereArgs: [_lastResetKey],
    );

    final inventories = <ResourceType, ResourceInventoryEntity>{};

    for (final row in results) {
      final typeId = row[ResourceInventoryColumns.resourceType] as String;
      final type = ResourceType.fromId(typeId);
      if (type != null) {
        inventories[type] = _entityFromMap(row);
      }
    }

    return inventories;
  }

  @override
  Future<void> resetFreePools(Map<ResourceType, int> dailyLimits) async {
    final now = DateTime.now();

    await _database.transaction((txn) async {
      for (final entry in dailyLimits.entries) {
        final type = entry.key;
        final limit = entry.value;

        // Check if entry exists
        final existing = await txn.query(
          resourceInventoryTable,
          where: '${ResourceInventoryColumns.resourceType} = ?',
          whereArgs: [type.id],
        );

        if (existing.isNotEmpty) {
          // Update existing entry
          await txn.update(
            resourceInventoryTable,
            {
              ResourceInventoryColumns.freeRemaining: limit,
              ResourceInventoryColumns.lastResetDate:
                  now.millisecondsSinceEpoch,
              ResourceInventoryColumns.updatedAt: now.millisecondsSinceEpoch,
            },
            where: '${ResourceInventoryColumns.resourceType} = ?',
            whereArgs: [type.id],
          );
        } else {
          // Insert new entry
          await txn.insert(
            resourceInventoryTable,
            {
              ResourceInventoryColumns.resourceType: type.id,
              ResourceInventoryColumns.freeRemaining: limit,
              ResourceInventoryColumns.purchasedRemaining: 0,
              ResourceInventoryColumns.lastResetDate:
                  now.millisecondsSinceEpoch,
              ResourceInventoryColumns.createdAt: now.millisecondsSinceEpoch,
              ResourceInventoryColumns.updatedAt: now.millisecondsSinceEpoch,
            },
          );
        }
      }
    });
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    // Get the most recent lastResetDate from any inventory entry
    final results = await _database.query(
      resourceInventoryTable,
      columns: [ResourceInventoryColumns.lastResetDate],
      orderBy: '${ResourceInventoryColumns.lastResetDate} DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    final timestamp =
        results.first[ResourceInventoryColumns.lastResetDate] as int?;
    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> setLastResetDate(DateTime date) async {
    // The last reset date is tracked per-inventory entry
    // This method updates all existing entries
    final now = DateTime.now();
    await _database.update(
      resourceInventoryTable,
      {
        ResourceInventoryColumns.lastResetDate: date.millisecondsSinceEpoch,
        ResourceInventoryColumns.updatedAt: now.millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<void> clearAll() async {
    await _database.delete(resourceInventoryTable);
  }

  /// Converts a database row to a [ResourceInventoryEntity].
  ResourceInventoryEntity _entityFromMap(Map<String, dynamic> map) {
    return ResourceInventoryEntity(
      resourceTypeId: map[ResourceInventoryColumns.resourceType] as String,
      freeRemaining: map[ResourceInventoryColumns.freeRemaining] as int,
      purchasedRemaining:
          map[ResourceInventoryColumns.purchasedRemaining] as int,
      lastResetDate: DateTime.fromMillisecondsSinceEpoch(
        map[ResourceInventoryColumns.lastResetDate] as int,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[ResourceInventoryColumns.createdAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[ResourceInventoryColumns.updatedAt] as int,
      ),
    );
  }
}
