import 'package:flutter/foundation.dart';

/// Type of in-app purchase product.
enum IAPProductType {
  /// Can be purchased multiple times (lives, hints, bundles).
  consumable,

  /// Can only be purchased once (remove_ads).
  nonConsumable,

  /// Recurring subscription (premium_monthly, premium_yearly).
  subscription,
}

/// Represents an in-app purchase product.
///
/// Contains both the product definition and store-fetched details
/// like localized pricing.
///
/// Example:
/// ```dart
/// final product = IAPProduct(
///   id: 'lives_small',
///   type: IAPProductType.consumable,
///   title: '5 Lives',
///   description: 'Get 5 extra lives',
///   price: '$0.99',
///   rawPrice: 0.99,
///   currencyCode: 'USD',
/// );
/// ```
@immutable
class IAPProduct {
  /// Creates an [IAPProduct].
  const IAPProduct({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.price,
    this.rawPrice,
    this.currencyCode,
    this.currencySymbol,
  });

  /// Creates a product definition without store details.
  ///
  /// Use this when defining products before querying the store.
  const IAPProduct.definition({
    required this.id,
    required this.type,
    this.title = '',
    this.description = '',
  })  : price = null,
        rawPrice = null,
        currencyCode = null,
        currencySymbol = null;

  /// Unique product identifier (e.g., 'lives_small', 'remove_ads').
  ///
  /// This must match the product ID configured in App Store Connect
  /// or Google Play Console.
  final String id;

  /// Type of product (consumable, non-consumable, or subscription).
  final IAPProductType type;

  /// Localized title from the store.
  final String title;

  /// Localized description from the store.
  final String description;

  /// Formatted price string from the store (e.g., '$0.99', '0,99 EUR').
  ///
  /// This is already localized and formatted for display.
  final String? price;

  /// Raw price as double for calculations.
  ///
  /// Use this for analytics or price comparisons.
  final double? rawPrice;

  /// ISO 4217 currency code (e.g., 'USD', 'EUR', 'GBP').
  final String? currencyCode;

  /// Currency symbol (e.g., '$', 'EUR', 'GBP').
  final String? currencySymbol;

  /// Whether product details have been loaded from the store.
  bool get isLoaded => price != null;

  /// Creates a copy with store details populated.
  IAPProduct withStoreDetails({
    required String title,
    required String description,
    required String price,
    required double rawPrice,
    required String currencyCode,
    String? currencySymbol,
  }) {
    return IAPProduct(
      id: id,
      type: type,
      title: title,
      description: description,
      price: price,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    );
  }

  /// Creates a copy with the given fields replaced.
  IAPProduct copyWith({
    String? id,
    IAPProductType? type,
    String? title,
    String? description,
    String? price,
    double? rawPrice,
    String? currencyCode,
    String? currencySymbol,
  }) {
    return IAPProduct(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      rawPrice: rawPrice ?? this.rawPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IAPProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'IAPProduct($id, type: $type, price: $price)';
  }
}
