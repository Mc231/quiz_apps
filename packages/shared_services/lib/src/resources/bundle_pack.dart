import 'resource_type.dart';

/// Represents a bundle of multiple resource types that can be purchased together.
///
/// Unlike [ResourcePack] which contains a single resource type, a [BundlePack]
/// contains multiple resource types with their respective amounts.
///
/// Example:
/// ```dart
/// final starterBundle = BundlePack(
///   id: 'bundle_starter',
///   productId: 'bundle_starter',
///   name: 'Starter Pack',
///   contents: {
///     ResourceType.lives(): 5,
///     ResourceType.fiftyFifty(): 5,
///     ResourceType.skip(): 5,
///   },
/// );
/// ```
class BundlePack {
  /// Unique identifier for this bundle.
  final String id;

  /// IAP product ID (platform-specific).
  ///
  /// This should match the product ID configured in App Store Connect
  /// or Google Play Console.
  final String productId;

  /// Display name of the bundle.
  final String name;

  /// Description of the bundle.
  final String? description;

  /// The contents of this bundle: resource types mapped to amounts.
  final Map<ResourceType, int> contents;

  /// Whether this bundle is marked as "best value".
  final bool isBestValue;

  /// Creates a [BundlePack].
  const BundlePack({
    required this.id,
    required this.productId,
    required this.name,
    this.description,
    required this.contents,
    this.isBestValue = false,
  });

  /// Gets the amount of a specific resource type in this bundle.
  ///
  /// Returns 0 if the resource type is not included.
  int getAmount(ResourceType type) => contents[type] ?? 0;

  /// Whether this bundle contains a specific resource type.
  bool contains(ResourceType type) => contents.containsKey(type);

  /// Total number of resources in this bundle (sum of all amounts).
  int get totalResources =>
      contents.values.fold(0, (sum, amount) => sum + amount);

  /// Creates a copy with the given fields replaced.
  BundlePack copyWith({
    String? id,
    String? productId,
    String? name,
    String? description,
    Map<ResourceType, int>? contents,
    bool? isBestValue,
  }) {
    return BundlePack(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      contents: contents ?? this.contents,
      isBestValue: isBestValue ?? this.isBestValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BundlePack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final resourcesStr = contents.entries
        .map((e) => '${e.value}x ${e.key.id}')
        .join(', ');
    return 'BundlePack($id: $resourcesStr)';
  }
}
