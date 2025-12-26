/// SQL schema definition for the resource_inventory table.
library;

/// Table name constant.
const String resourceInventoryTable = 'resource_inventory';

/// SQL statement to create the resource_inventory table.
const String createResourceInventoryTable = '''
CREATE TABLE $resourceInventoryTable (
  resource_type TEXT PRIMARY KEY,
  free_remaining INTEGER NOT NULL DEFAULT 0,
  purchased_remaining INTEGER NOT NULL DEFAULT 0,
  last_reset_date INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

/// Column names for the resource_inventory table.
class ResourceInventoryColumns {
  ResourceInventoryColumns._();

  static const String resourceType = 'resource_type';
  static const String freeRemaining = 'free_remaining';
  static const String purchasedRemaining = 'purchased_remaining';
  static const String lastResetDate = 'last_reset_date';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
