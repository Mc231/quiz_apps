import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_engine_core/src/business_logic/quiz_data_provider.dart';
import 'package:quiz_engine_core/src/asset_provider.dart';

@GenerateNiceMocks([
  MockSpec<AssetProvider>(),
])
import 'quiz_data_provider_test.mocks.dart';

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
  late MockAssetProvider mockProvider;
  late QuizDataProvider<MockModel> sut;

  setUp(() {
    mockProvider = MockAssetProvider();
    sut = QuizDataProvider(mockProvider, MockModel.fromJson);
  });

  group('QuizDataProvider Tests', () {
    test('should parse JSON correctly and return a list of models', () async {
      const jsonString = '[{"name": "Test1"}, {"name": "Test2"}]';
      when(mockProvider.provide()).thenAnswer((_) async => jsonString);

      // When
      final result = await sut.provide();

      // Then
      expect(result, isA<List<MockModel>>());
      expect(result, equals([MockModel('Test1'), MockModel('Test2')]));
    });

    test('should return an empty list when JSON array is empty', () async {
      // Given
      const jsonString = '[]';
      when(mockProvider.provide()).thenAnswer((_) async => jsonString);

      // When
      final result = await sut.provide();

      // Then
      expect(result, isEmpty);
    });

    test('should throw an exception when JSON is invalid', () async {
      const jsonString = '{invalid_json}';
      when(mockProvider.provide()).thenAnswer((_) async => jsonString);

      // When
      final call = sut.provide();

      // Then
      expect(call, throwsA(isA<FormatException>()));
    });

    test('should throw an exception when asset loading fails', () async {
      // Given ✅ Ensure the error is thrown properly
      when(mockProvider.provide()).thenThrow(Exception('Asset loading failed'));

      // When
      final call = sut.provide();

      // Then
      expect(call, throwsA(isA<Exception>()));
    });

    test('should create a standard provider with the correct asset path', () {
      // Given
      const path = 'assets/mock_data.json';

      // When
      final standardProvider = QuizDataProvider.standard(path, MockModel.fromJson);

      // Then
      expect(standardProvider, isA<QuizDataProvider<MockModel>>());
    });
  });
}