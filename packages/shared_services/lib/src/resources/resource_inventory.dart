import 'resource_type.dart';

/// Inventory state for a single resource type.
///
/// Tracks both free (daily reset) and purchased (permanent) pools.
///
/// Example:
/// ```dart
/// final inventory = ResourceInventory(
///   type: ResourceType.lives(),
///   freeRemaining: 3,
///   freeLimit: 5,
///   purchasedRemaining: 10,
/// );
///
/// print(inventory.total);       // 13
/// print(inventory.isAvailable); // true
/// ```
class ResourceInventory {
  /// The resource type this inventory tracks.
  final ResourceType type;

  /// Remaining free resources (resets daily).
  final int freeRemaining;

  /// Daily limit for free resources.
  final int freeLimit;

  /// Remaining purchased resources (never expires).
  final int purchasedRemaining;

  /// Creates a [ResourceInventory].
  const ResourceInventory({
    required this.type,
    required this.freeRemaining,
    required this.freeLimit,
    required this.purchasedRemaining,
  });

  /// Creates an empty inventory for a resource type.
  factory ResourceInventory.empty(ResourceType type, {int freeLimit = 0}) {
    return ResourceInventory(
      type: type,
      freeRemaining: freeLimit,
      freeLimit: freeLimit,
      purchasedRemaining: 0,
    );
  }

  /// Total available (free + purchased).
  int get total => freeRemaining + purchasedRemaining;

  /// Whether any resources are available.
  bool get isAvailable => total > 0;

  /// Whether free pool is depleted.
  bool get isFreeDepleted => freeRemaining <= 0;

  /// Whether purchased pool is depleted.
  bool get isPurchasedDepleted => purchasedRemaining <= 0;

  /// Percentage of free pool remaining (0.0 to 1.0).
  double get freePercentage => freeLimit > 0 ? freeRemaining / freeLimit : 0.0;

  /// Creates a copy with one resource consumed.
  ///
  /// Consumes from free pool first, then purchased pool.
  /// Returns null if no resources available.
  ResourceInventory? consume() {
    if (!isAvailable) return null;

    // Consume from free pool first (use it or lose it)
    if (freeRemaining > 0) {
      return copyWith(freeRemaining: freeRemaining - 1);
    }

    // Then consume from purchased pool
    return copyWith(purchasedRemaining: purchasedRemaining - 1);
  }

  /// Creates a copy with resources added to purchased pool.
  ResourceInventory addPurchased(int amount) {
    return copyWith(purchasedRemaining: purchasedRemaining + amount);
  }

  /// Creates a copy with free pool reset to daily limit.
  ResourceInventory resetFreePool() {
    return copyWith(freeRemaining: freeLimit);
  }

  /// Creates a copy with the given fields replaced.
  ResourceInventory copyWith({
    ResourceType? type,
    int? freeRemaining,
    int? freeLimit,
    int? purchasedRemaining,
  }) {
    return ResourceInventory(
      type: type ?? this.type,
      freeRemaining: freeRemaining ?? this.freeRemaining,
      freeLimit: freeLimit ?? this.freeLimit,
      purchasedRemaining: purchasedRemaining ?? this.purchasedRemaining,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResourceInventory &&
        other.type == type &&
        other.freeRemaining == freeRemaining &&
        other.freeLimit == freeLimit &&
        other.purchasedRemaining == purchasedRemaining;
  }

  @override
  int get hashCode => Object.hash(type, freeRemaining, freeLimit, purchasedRemaining);

  @override
  String toString() =>
      'ResourceInventory(${type.id}: $freeRemaining/$freeLimit free, $purchasedRemaining purchased)';
}

/// Database entity for resource inventory.
///
/// Used for persisting inventory state to the database.
class ResourceInventoryEntity {
  /// Resource type ID (e.g., 'lives', 'fiftyFifty', 'skip').
  final String resourceTypeId;

  /// Remaining free resources.
  final int freeRemaining;

  /// Remaining purchased resources.
  final int purchasedRemaining;

  /// Date of last daily reset.
  final DateTime lastResetDate;

  /// When this entity was created.
  final DateTime createdAt;

  /// When this entity was last updated.
  final DateTime updatedAt;

  /// Creates a [ResourceInventoryEntity].
  const ResourceInventoryEntity({
    required this.resourceTypeId,
    required this.freeRemaining,
    required this.purchasedRemaining,
    required this.lastResetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an entity from a database map.
  factory ResourceInventoryEntity.fromMap(Map<String, dynamic> map) {
    return ResourceInventoryEntity(
      resourceTypeId: map['resource_type'] as String,
      freeRemaining: map['free_remaining'] as int,
      purchasedRemaining: map['purchased_remaining'] as int,
      lastResetDate: DateTime.parse(map['last_reset_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts this entity to a database map.
  Map<String, dynamic> toMap() {
    return {
      'resource_type': resourceTypeId,
      'free_remaining': freeRemaining,
      'purchased_remaining': purchasedRemaining,
      'last_reset_date': lastResetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts this entity to a [ResourceInventory].
  ///
  /// Returns null if the resource type ID is not recognized.
  ResourceInventory? toInventory(int freeLimit) {
    final type = ResourceType.fromId(resourceTypeId);
    if (type == null) return null;

    return ResourceInventory(
      type: type,
      freeRemaining: freeRemaining,
      freeLimit: freeLimit,
      purchasedRemaining: purchasedRemaining,
    );
  }

  /// Creates an entity from a [ResourceInventory].
  factory ResourceInventoryEntity.fromInventory(
    ResourceInventory inventory, {
    DateTime? lastResetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return ResourceInventoryEntity(
      resourceTypeId: inventory.type.id,
      freeRemaining: inventory.freeRemaining,
      purchasedRemaining: inventory.purchasedRemaining,
      lastResetDate: lastResetDate ?? now,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a copy with the given fields replaced.
  ResourceInventoryEntity copyWith({
    String? resourceTypeId,
    int? freeRemaining,
    int? purchasedRemaining,
    DateTime? lastResetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResourceInventoryEntity(
      resourceTypeId: resourceTypeId ?? this.resourceTypeId,
      freeRemaining: freeRemaining ?? this.freeRemaining,
      purchasedRemaining: purchasedRemaining ?? this.purchasedRemaining,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ResourceInventoryEntity($resourceTypeId: $freeRemaining free, $purchasedRemaining purchased)';
}
