/// Model representing a paginated result set.
///
/// Contains items for the current page along with pagination metadata
/// to enable efficient loading of large data sets.
library;

/// A paginated result containing items and metadata.
///
/// This class wraps a list of items with pagination information,
/// enabling efficient incremental loading of large datasets.
///
/// Example:
/// ```dart
/// final result = await repository.getPaginatedSessions(
///   filter: filter,
///   limit: 20,
///   offset: 0,
/// );
///
/// if (result.hasMore) {
///   // Load next page
///   final nextPage = await repository.getPaginatedSessions(
///     filter: filter,
///     limit: 20,
///     offset: result.nextOffset,
///   );
/// }
/// ```
class PaginatedResult<T> {
  /// Creates a [PaginatedResult].
  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.offset,
    required this.limit,
  });

  /// Creates an empty [PaginatedResult].
  factory PaginatedResult.empty() => PaginatedResult<T>(
        items: const [],
        totalCount: 0,
        offset: 0,
        limit: 0,
      );

  /// The items for the current page.
  final List<T> items;

  /// Total number of items matching the query (across all pages).
  final int totalCount;

  /// The offset used to fetch this page.
  final int offset;

  /// The limit used to fetch this page.
  final int limit;

  /// Whether there are more items after this page.
  bool get hasMore => offset + items.length < totalCount;

  /// The offset to use for fetching the next page.
  int get nextOffset => offset + items.length;

  /// The current page number (1-indexed).
  int get currentPage => limit > 0 ? (offset ~/ limit) + 1 : 1;

  /// The total number of pages.
  int get totalPages => limit > 0 ? (totalCount / limit).ceil() : 1;

  /// Whether this is the first page.
  bool get isFirstPage => offset == 0;

  /// Whether this is the last page.
  bool get isLastPage => !hasMore;

  /// Number of items on this page.
  int get pageSize => items.length;

  /// Whether the result is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the result is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// Creates a copy of this result with different items.
  ///
  /// Useful for transforming the items while preserving pagination metadata.
  PaginatedResult<R> map<R>(R Function(T) transform) {
    return PaginatedResult<R>(
      items: items.map(transform).toList(),
      totalCount: totalCount,
      offset: offset,
      limit: limit,
    );
  }

  /// Creates a copy with updated values.
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? offset,
    int? limit,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult('
        'items: ${items.length}, '
        'totalCount: $totalCount, '
        'offset: $offset, '
        'limit: $limit, '
        'hasMore: $hasMore'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginatedResult<T>) return false;
    return totalCount == other.totalCount &&
        offset == other.offset &&
        limit == other.limit &&
        _listEquals(items, other.items);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        totalCount,
        offset,
        limit,
      );

  bool _listEquals(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
