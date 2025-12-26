import 'resource_inventory.dart';
import 'resource_type.dart';

/// Repository interface for persisting resource inventory.
///
/// Implement this interface to store resource inventory in your preferred
/// storage backend (SQLite, SharedPreferences, etc.).
///
/// Example SQLite implementation:
/// ```dart
/// class SqliteResourceRepository implements ResourceRepository {
///   final Database _database;
///
///   SqliteResourceRepository(this._database);
///
///   @override
///   Future<ResourceInventoryEntity?> getInventory(ResourceType type) async {
///     final result = await _database.query(
///       'resource_inventory',
///       where: 'resource_type = ?',
///       whereArgs: [type.id],
///     );
///     if (result.isEmpty) return null;
///     return ResourceInventoryEntity.fromMap(result.first);
///   }
///
///   // ... other methods
/// }
/// ```
abstract class ResourceRepository {
  /// Get inventory for a resource type.
  ///
  /// Returns null if no inventory exists for the type.
  Future<ResourceInventoryEntity?> getInventory(ResourceType type);

  /// Save inventory for a resource type.
  ///
  /// Creates a new record if none exists, otherwise updates.
  Future<void> saveInventory(ResourceType type, ResourceInventoryEntity entity);

  /// Get all inventories.
  Future<Map<ResourceType, ResourceInventoryEntity>> getAllInventories();

  /// Reset free pools to daily limits.
  ///
  /// This should update the free_remaining field for all resource types
  /// to their configured daily limits.
  Future<void> resetFreePools(Map<ResourceType, int> dailyLimits);

  /// Get the date of the last daily reset.
  ///
  /// Returns null if no reset has ever occurred.
  Future<DateTime?> getLastResetDate();

  /// Set the date of the last daily reset.
  Future<void> setLastResetDate(DateTime date);

  /// Delete all inventory data.
  ///
  /// Use with caution - this removes all resource data.
  Future<void> clearAll();
}

/// In-memory implementation of [ResourceRepository].
///
/// Useful for testing or when persistence is not required.
/// Data is lost when the app is closed.
class InMemoryResourceRepository implements ResourceRepository {
  final Map<String, ResourceInventoryEntity> _inventories = {};
  DateTime? _lastResetDate;

  @override
  Future<ResourceInventoryEntity?> getInventory(ResourceType type) async {
    return _inventories[type.id];
  }

  @override
  Future<void> saveInventory(
    ResourceType type,
    ResourceInventoryEntity entity,
  ) async {
    _inventories[type.id] = entity;
  }

  @override
  Future<Map<ResourceType, ResourceInventoryEntity>> getAllInventories() async {
    final result = <ResourceType, ResourceInventoryEntity>{};
    for (final entry in _inventories.entries) {
      final type = ResourceType.fromId(entry.key);
      if (type != null) {
        result[type] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<void> resetFreePools(Map<ResourceType, int> dailyLimits) async {
    final now = DateTime.now();
    for (final entry in dailyLimits.entries) {
      final existing = _inventories[entry.key.id];
      if (existing != null) {
        _inventories[entry.key.id] = existing.copyWith(
          freeRemaining: entry.value,
          lastResetDate: now,
          updatedAt: now,
        );
      } else {
        _inventories[entry.key.id] = ResourceInventoryEntity(
          resourceTypeId: entry.key.id,
          freeRemaining: entry.value,
          purchasedRemaining: 0,
          lastResetDate: now,
          createdAt: now,
          updatedAt: now,
        );
      }
    }
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    return _lastResetDate;
  }

  @override
  Future<void> setLastResetDate(DateTime date) async {
    _lastResetDate = date;
  }

  @override
  Future<void> clearAll() async {
    _inventories.clear();
    _lastResetDate = null;
  }
}
