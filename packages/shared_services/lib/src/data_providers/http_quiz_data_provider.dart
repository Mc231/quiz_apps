import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// A provider that fetches quiz data from a remote URL via HTTP.
///
/// This provider uses HTTP GET to fetch JSON data from a remote server
/// and deserializes it into a list of objects of type [T].
///
/// Example usage:
/// ```dart
/// final provider = HttpQuizDataProvider<QuestionEntry>(
///   url: 'https://api.example.com/quiz/data',
///   fromJson: QuestionEntry.fromJson,
/// );
/// final data = await provider.provide();
/// ```
class HttpQuizDataProvider<T> extends ResourceProvider<List<T>> {
  /// The URL to fetch quiz data from.
  final String url;

  /// Function to deserialize JSON map to object of type [T].
  final T Function(Map<String, dynamic>) fromJson;

  /// HTTP client for making requests (injectable for testing).
  final http.Client? client;

  /// Timeout duration for HTTP requests.
  final Duration timeout;

  /// Creates a [HttpQuizDataProvider] with the given parameters.
  ///
  /// - [url]: The remote URL to fetch data from
  /// - [fromJson]: Function to convert JSON map to type [T]
  /// - [client]: Optional HTTP client (defaults to http.Client())
  /// - [timeout]: Request timeout (defaults to 10 seconds)
  HttpQuizDataProvider({
    required this.url,
    required this.fromJson,
    this.client,
    this.timeout = const Duration(seconds: 10),
  });

  /// Factory constructor for standard usage with default HTTP client.
  factory HttpQuizDataProvider.standard(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return HttpQuizDataProvider(url: url, fromJson: fromJson);
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
        throw HttpDataException(
          'Failed to load quiz data. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw HttpDataException('Network error: ${e.message}');
    } catch (e) {
      if (e is HttpDataException) rethrow;
      throw HttpDataException('Error fetching quiz data: $e');
    }
  }
}

/// Exception thrown when HTTP data fetching fails.
class HttpDataException implements Exception {
  final String message;
  final int? statusCode;

  HttpDataException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpDataException: $message';
}
