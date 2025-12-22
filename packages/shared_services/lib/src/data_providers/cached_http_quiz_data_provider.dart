import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'http_quiz_data_provider.dart';

/// A provider that fetches quiz data from a remote URL with caching support.
///
/// This provider caches the fetched data in memory and reuses it for
/// subsequent requests until the cache expires. This reduces network
/// requests and improves performance.
///
/// Example usage:
/// ```dart
/// final provider = CachedHttpQuizDataProvider<QuestionEntry>(
///   url: 'https://api.example.com/quiz/data',
///   fromJson: QuestionEntry.fromJson,
///   cacheDuration: Duration(hours: 1),
/// );
/// final data = await provider.provide(); // Fetches from network
/// final data2 = await provider.provide(); // Returns cached data
/// ```
class CachedHttpQuizDataProvider<T> extends ResourceProvider<List<T>> {
  /// The URL to fetch quiz data from.
  final String url;

  /// Function to deserialize JSON map to object of type [T].
  final T Function(Map<String, dynamic>) fromJson;

  /// HTTP client for making requests (injectable for testing).
  final http.Client? client;

  /// Timeout duration for HTTP requests.
  final Duration timeout;

  /// How long to keep cached data before refetching.
  final Duration cacheDuration;

  /// Cached data.
  List<T>? _cachedData;

  /// Time when data was cached.
  DateTime? _cacheTime;

  /// Creates a [CachedHttpQuizDataProvider] with the given parameters.
  ///
  /// - [url]: The remote URL to fetch data from
  /// - [fromJson]: Function to convert JSON map to type [T]
  /// - [client]: Optional HTTP client (defaults to http.Client())
  /// - [timeout]: Request timeout (defaults to 10 seconds)
  /// - [cacheDuration]: How long to cache data (defaults to 1 hour)
  CachedHttpQuizDataProvider({
    required this.url,
    required this.fromJson,
    this.client,
    this.timeout = const Duration(seconds: 10),
    this.cacheDuration = const Duration(hours: 1),
  });

  /// Factory constructor for standard usage with default settings.
  factory CachedHttpQuizDataProvider.standard(
    String url,
    T Function(Map<String, dynamic>) fromJson, {
    Duration cacheDuration = const Duration(hours: 1),
  }) {
    return CachedHttpQuizDataProvider(
      url: url,
      fromJson: fromJson,
      cacheDuration: cacheDuration,
    );
  }

  /// Checks if the cached data is still valid.
  bool get _isCacheValid {
    if (_cachedData == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < cacheDuration;
  }

  /// Clears the cached data, forcing a fresh fetch on next request.
  void clearCache() {
    _cachedData = null;
    _cacheTime = null;
  }

  @override
  Future<List<T>> provide() async {
    // Return cached data if valid
    if (_isCacheValid) {
      return _cachedData!;
    }

    try {
      final response = client != null
          ? await client!.get(Uri.parse(url)).timeout(timeout)
          : await http.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final data = jsonList
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();

        // Update cache
        _cachedData = data;
        _cacheTime = DateTime.now();

        return data;
      } else {
        // If request failed but we have expired cached data, return it
        if (_cachedData != null) {
          return _cachedData!;
        }

        throw HttpDataException(
          'Failed to load quiz data. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      // If network error but we have cached data, return it even if expired
      if (_cachedData != null) {
        return _cachedData!;
      }
      throw HttpDataException('Network error: ${e.message}');
    } catch (e) {
      // Return cached data if available, even if expired
      if (_cachedData != null && e is! HttpDataException) {
        return _cachedData!;
      }
      if (e is HttpDataException) rethrow;
      throw HttpDataException('Error fetching quiz data: $e');
    }
  }
}
