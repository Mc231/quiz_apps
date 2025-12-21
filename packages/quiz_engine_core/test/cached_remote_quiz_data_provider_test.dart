import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_engine_core/src/business_logic/cached_remote_quiz_data_provider.dart';
import 'package:quiz_engine_core/src/business_logic/remote_quiz_data_provider.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
])
import 'cached_remote_quiz_data_provider_test.mocks.dart';

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

  group('CachedRemoteQuizDataProvider Tests', () {
    test('should fetch and cache data on first request', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}, {"name": "Test2"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Test1'), MockModel('Test2')]));
      verify(mockClient.get(Uri.parse(url))).called(1);
    });

    test('should return cached data on second request without fetching', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}, {"name": "Test2"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        cacheDuration: const Duration(hours: 1),
      );

      // When
      final result1 = await provider.provide();
      final result2 = await provider.provide();

      // Then
      expect(result1, equals(result2));
      verify(mockClient.get(Uri.parse(url))).called(1); // Only called once
    });

    test('should refetch data after cache expires', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        cacheDuration: const Duration(milliseconds: 100),
      );

      // When
      await provider.provide();
      await Future.delayed(const Duration(milliseconds: 150)); // Wait for cache to expire
      await provider.provide();

      // Then
      verify(mockClient.get(Uri.parse(url))).called(2); // Called twice
    });

    test('should return cached data when network fails', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Cached"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // First request - cache data
      await provider.provide();

      // Second request - network fails
      when(mockClient.get(Uri.parse(url)))
          .thenThrow(http.ClientException('Network error'));

      // When
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Cached')])); // Returns cached data
    });

    test('should return expired cached data when HTTP error occurs', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Cached"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        cacheDuration: const Duration(milliseconds: 100),
      );

      // First request - cache data
      await provider.provide();

      // Wait for cache to expire
      await Future.delayed(const Duration(milliseconds: 150));

      // Second request - server error
      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      // When
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Cached')])); // Returns expired cached data
    });

    test('should clear cache when clearCache is called', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse1 = '[{"name": "First"}]';
      const jsonResponse2 = '[{"name": "Second"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse1, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // First request
      final result1 = await provider.provide();
      expect(result1, equals([MockModel('First')]));

      // Clear cache
      provider.clearCache();

      // Change mock response
      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse2, 200));

      // Second request after clearing cache
      final result2 = await provider.provide();

      // Then
      expect(result2, equals([MockModel('Second')]));
      verify(mockClient.get(Uri.parse(url))).called(2); // Called twice
    });

    test('should create standard provider with correct parameters', () {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const cacheDuration = Duration(hours: 2);

      // When
      final provider = CachedRemoteQuizDataProvider.standard(
        url,
        MockModel.fromJson,
        cacheDuration: cacheDuration,
      );

      // Then
      expect(provider, isA<CachedRemoteQuizDataProvider<MockModel>>());
      expect(provider.url, equals(url));
      expect(provider.cacheDuration, equals(cacheDuration));
    });

    test('should throw exception when no cache and network fails', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';

      when(mockClient.get(Uri.parse(url)))
          .thenThrow(http.ClientException('Network error'));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsException); // No cached data to fall back on
    });

    test('should return cached data when generic exception occurs', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Cached"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // First request - cache data
      await provider.provide();

      // Second request - generic exception
      when(mockClient.get(Uri.parse(url)))
          .thenThrow(Exception('Generic error'));

      // When
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Cached')])); // Returns cached data
    });

    test('should rethrow RemoteDataException when no cache available', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When
      final call = provider.provide();

      // Then
      expect(call, throwsA(isA<RemoteDataException>()));
    });

    test('should handle timeout and return cached data if available', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Cached"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
        timeout: const Duration(milliseconds: 10),
      );

      // First request - cache data
      await provider.provide();

      // Second request - timeout
      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 2),
                () => http.Response('[{"name": "New"}]', 200),
              ));

      // When
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Cached')])); // Returns cached data
    });

    test('should work without client parameter (uses top-level http.get)', () {
      // Given
      const url = 'https://api.example.com/quiz/data';

      // When
      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        // No client parameter
      );

      // Then
      expect(provider, isA<CachedRemoteQuizDataProvider<MockModel>>());
      expect(provider.client, isNull);
    });

    test('_isCacheValid should return false when cache is null', () async {
      // Given
      const url = 'https://api.example.com/quiz/data';
      const jsonResponse = '[{"name": "Test1"}]';

      when(mockClient.get(Uri.parse(url)))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final provider = CachedRemoteQuizDataProvider<MockModel>(
        url: url,
        fromJson: MockModel.fromJson,
        client: mockClient,
      );

      // When - cache is not valid initially, should fetch from network
      final result = await provider.provide();

      // Then
      expect(result, equals([MockModel('Test1')]));
      verify(mockClient.get(Uri.parse(url))).called(1);
    });
  });
}
