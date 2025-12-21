import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';

void main() {
  group('QuestionType', () {
    test('TextQuestion should serialize and deserialize correctly', () {
      final textQuestion = TextQuestion("What is 2 + 2?");
      final jsonMap = textQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<TextQuestion>());
      expect((reconstructed as TextQuestion).text, "What is 2 + 2?");
    });

    test('ImageQuestion should serialize and deserialize correctly', () {
      final imageQuestion = ImageQuestion("assets/images/question.png");
      final jsonMap = imageQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<ImageQuestion>());
      expect((reconstructed as ImageQuestion).imagePath, "assets/images/question.png");
    });

    test('Invalid QuestionType should throw ArgumentError', () {
      final invalidJson = jsonDecode('{"type": "unknown", "value": "random"}');

      expect(() => QuestionType.fromJson(invalidJson), throwsArgumentError);
    });
  });

  group('QuestionEntry', () {
    test('QuestionEntry should serialize and deserialize correctly for TextQuestion', () {
      final entry = QuestionEntry(
        type: TextQuestion("What is the capital of France?"),
        otherOptions: {"difficulty": "easy"},
      );

      final jsonMap = entry.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionEntry.fromJson(parsedJson, (json) => json);

      expect(reconstructed.type, isA<TextQuestion>());
      expect((reconstructed.type as TextQuestion).text, "What is the capital of France?");
      expect(reconstructed.otherOptions["difficulty"], "easy");
    });

    test('QuestionEntry should serialize and deserialize correctly for ImageQuestion', () {
      final entry = QuestionEntry(
        type: ImageQuestion("assets/images/pic.png"),
        otherOptions: {"hint": "Find the flag!"},
      );

      final jsonMap = entry.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionEntry.fromJson(parsedJson, (json) => json);

      expect(reconstructed.type, isA<ImageQuestion>());
      expect((reconstructed.type as ImageQuestion).imagePath, "assets/images/pic.png");
      expect(reconstructed.otherOptions["hint"], "Find the flag!");
    });

    test('QuestionEntry should handle missing "otherOptions" gracefully', () {
      final jsonString = '{"type": {"type": "text", "text": "What is 2 + 2?"}}';
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionEntry.fromJson(parsedJson, (json) => json);

      expect(reconstructed.type, isA<TextQuestion>());
      expect((reconstructed.type as TextQuestion).text, "What is 2 + 2?");
      expect(reconstructed.otherOptions, isEmpty);
    });
  });
}