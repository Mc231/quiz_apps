import 'package:quiz_engine_core/src/model/question_type.dart';

/// Represents structured question data in a quiz.
class QuestionEntry {
  /// The type of question (`text`, `image`, etc.).
  final QuestionType type;

  /// (Optional) Additional metadata (e.g., hints, difficulty, etc.).
  final Map<String, dynamic> otherOptions;

  /// Creates a new `QuestionData` instance.
  QuestionEntry({required this.type, this.otherOptions = const {}});

  /// Factory method to create `QuestionData<T>` from JSON.
  factory QuestionEntry.fromJson(
    Map<String, dynamic> json,
    Function(dynamic) fromJson,
  ) {
    return QuestionEntry(
      type: QuestionType.fromJson(json['type']),
      // ✅ Convert JSON to QuestionType
      otherOptions:
          json['otherOptions'] != null
              ? Map<String, dynamic>.from(json['otherOptions'])
              : {},
    );
  }

  /// Converts `QuestionData` to JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(), // ✅ Convert QuestionType to JSON
      'otherOptions': otherOptions,
    };
  }
}
