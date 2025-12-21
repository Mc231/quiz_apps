import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_services/src/data_providers/http_quiz_data_provider.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
])
import 'http_quiz_data_provider_test.mocks.dart';

class MockModel {
  final String name;

  MockModel(this.name);

  factory MockModel.fromJson(Map<String, dynamic> json) {
    return MockModel(json['name'] ?? 'default');
  }

  @override
  bool operator ==(Object other) => other is MockModel && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('HttpQuizDataProvider Tests', () {
    test('should fetch and parse JSON correctly from remote URL', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}, {"name": "Test2"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final result = await provider.provide();

      // Then
      expect(result, isA<List<MockModel>>());
      expect(result, equals([MockModel('Test1'), MockModel('Test2')]));
      verify(mockClient.get(Uri.parse(url))).called(1);
    });

    test('should return empty list when JSON array is empty', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final result = await provider.provide();

      // Then
      expect(result, isEmpty);
    });

    test('should throw HttpDataException when status code is not 200', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsA(isA<HttpDataException>()));
    });

    test('should throw HttpDataException when network error occurs', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';

      when(mockClient.get(Uri.parse(url)))
          .thenThrow(http.ClientException('Network error'));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsA(isA<HttpDataException>()));
    });

    test('should throw HttpDataException when JSON parsing fails', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const invalidJson = '{invalid_json}';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(invalidJson, 200));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsA(isA<HttpDataException>()));
    });

    test('should create standard provider with correct URL', () {
      // Given
      const url = 'https://api.example.com/quiz/data';

      // When
      final provider = HttpQuizDataProvider.standard(
        url,
        MockModel.fromJson,
      );

      // Then
      expect(provider, isA<HttpQuizDataProvider<MockModel>>());
      expect(provider.url, equals(url));
    });

    test('should respect custom timeout duration', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        timeout: const Duration(seconds: 5),
      );

      // When
      final result = await provider.provide();

      // Then
      expect(result, isNotEmpty);
      expect(provider.timeout, equals(const Duration(seconds: 5)));
    });

    test('should throw HttpDataException when timeout occurs', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 2),
                () => http.Response('[{"name": "Test1"}]', 200),
              ));

      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        timeout: const Duration(milliseconds: 10),
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsA(isA<HttpDataException>()));
    });

    test('should work without client parameter (uses top-level http.get)', () {
      // Given
      const url = 'https://api.example.com/quiz/data';

      // When
      final provider = HttpQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        // No client parameter - uses top-level http.get
      );

      // Then
      expect(provider, isA<HttpQuizDataProvider<MockModel>>());
      expect(provider.client, isNull);
    });
  });

  group('HttpDataException Tests', () {
    test('should create exception with message only', () {
      // Given
      const message = 'Test error message';

      // When
      final exception = HttpDataException(message);

      // Then
      expect(exception.message, equals(message));
      expect(exception.statusCode, isNull);
      expect(exception.toString(), contains(message));
    });

    test('should create exception with message and status code', () {
      // Given
      const message = 'Not Found';
      const statusCode = 404;

      // When
      final exception = HttpDataException(message, statusCode: statusCode);

      // Then
      expect(exception.message, equals(message));
      expect(exception.statusCode, equals(statusCode));
    });
  });
}