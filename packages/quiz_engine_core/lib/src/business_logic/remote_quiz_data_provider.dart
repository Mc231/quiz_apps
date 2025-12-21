import 'dart:convert';
import 'package:http/http.dart' as http;
import '../resource_provider.dart';

/// A provider that fetches quiz data from a remote URL.
///
/// This provider uses HTTP GET to fetch JSON data from a remote server
/// and deserializes it into a list of objects of type [T].
///
/// Example usage:
/// ```dart
/// final provider = RemoteQuizDataProvider<QuestionEntry>(
///   url: 'https://api.example.com/quiz/data',
///   fromJson: QuestionEntry.fromJson,
/// );
/// final data = await provider.provide();
/// ```
class RemoteQuizDataProvider<T> extends ResourceProvider<List<T>> {
  /// The URL to fetch quiz data from.
  final String url;

  /// Function to deserialize JSON map to object of type [T].
  final T Function(Map<String, dynamic>) fromJson;

  /// HTTP client for making requests (injectable for testing).
  final http.Client? client;

  /// Timeout duration for HTTP requests.
  final Duration timeout;

  /// Creates a [RemoteQuizDataProvider] with the given parameters.
  ///
  /// - [url]: The remote URL to fetch data from
  /// - [fromJson]: Function to convert JSON map to type [T]
  /// - [client]: Optional HTTP client (defaults to http.Client())
  /// - [timeout]: Request timeout (defaults to 10 seconds)
  RemoteQuizDataProvider({
    required this.url,
    required this.fromJson,
    this.client,
    this.timeout = const Duration(seconds: 10),
  });

  /// Factory constructor for standard usage with default HTTP client.
  factory RemoteQuizDataProvider.standard(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return RemoteQuizDataProvider(
      url: url,
      fromJson: fromJson,
    );
  }

  @override
  Future<List<T>> provide() async {
    try {
      final response = client != null
          ? await client!.get(Uri.parse(url)).timeout(timeout)
          : await http.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw RemoteDataException(
          'Failed to load quiz data. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw RemoteDataException('Network error: ${e.message}');
    } catch (e) {
      if (e is RemoteDataException) rethrow;
      throw RemoteDataException('Error fetching quiz data: $e');
    }
  }
}

/// Exception thrown when remote data fetching fails.
class RemoteDataException implements Exception {
  final String message;
  final int? statusCode;

  RemoteDataException(this.message, {this.statusCode});

  @override
  String toString() => 'RemoteDataException: $message';
}
