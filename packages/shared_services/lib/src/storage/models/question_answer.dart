/// Question answer data model for database persistence.
library;

import 'dart:convert';

import '../database/tables/question_answers_table.dart';

/// Represents the answer status for a question.
enum AnswerStatus {
  /// The user answered correctly.
  correct('correct'),

  /// The user answered incorrectly.
  incorrect('incorrect'),

  /// The user skipped the question.
  skipped('skipped'),

  /// The question timed out.
  timeout('timeout');

  const AnswerStatus(this.value);

  /// The string value stored in the database.
  final String value;

  /// Creates an [AnswerStatus] from its database string value.
  static AnswerStatus fromString(String value) {
    return AnswerStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AnswerStatus.skipped,
    );
  }
}

/// Represents the type of question.
enum QuestionType {
  /// Image-based question (e.g., flag image).
  image('image'),

  /// Text-based question.
  text('text'),

  /// Audio-based question.
  audio('audio'),

  /// Video-based question.
  video('video');

  const QuestionType(this.value);

  /// The string value stored in the database.
  final String value;

  /// Creates a [QuestionType] from its database string value.
  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.text,
    );
  }
}

/// Represents the hint used for a question.
enum HintUsed {
  /// No hint was used.
  none('none'),

  /// 50/50 hint was used.
  fiftyFifty('50_50'),

  /// Skip hint was used.
  skip('skip');

  const HintUsed(this.value);

  /// The string value stored in the database.
  final String value;

  /// Creates a [HintUsed] from its database string value.
  static HintUsed fromString(String? value) {
    if (value == null) return HintUsed.none;
    return HintUsed.values.firstWhere(
      (hint) => hint.value == value,
      orElse: () => HintUsed.none,
    );
  }
}

/// Represents an answer option.
class AnswerOption {
  /// Creates an [AnswerOption].
  const AnswerOption({
    required this.id,
    required this.text,
  });

  /// The unique identifier for this option.
  final String id;

  /// The display text for this option.
  final String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnswerOption && other.id == id && other.text == text;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() => 'AnswerOption(id: $id, text: $text)';
}

/// A question and answer record stored in the database.
class QuestionAnswer {
  /// Creates a new [QuestionAnswer].
  const QuestionAnswer({
    required this.id,
    required this.sessionId,
    required this.questionNumber,
    required this.questionId,
    required this.questionType,
    this.questionContent,
    this.questionResourceUrl,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.optionsOrder,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
    required this.answerStatus,
    this.timeSpentSeconds,
    this.answeredAt,
    this.hintUsed = HintUsed.none,
    this.disabledOptions = const [],
    this.explanation,
    required this.createdAt,
  });

  /// Unique identifier for this answer record.
  final String id;

  /// ID of the quiz session this answer belongs to.
  final String sessionId;

  /// Position of this question in the quiz (1-indexed).
  final int questionNumber;

  /// ID of the question.
  final String questionId;

  /// Type of the question.
  final QuestionType questionType;

  /// Content/text of the question (for text questions).
  final String? questionContent;

  /// URL or asset path for resource (image/audio/video) questions.
  final String? questionResourceUrl;

  /// First answer option.
  final AnswerOption option1;

  /// Second answer option.
  final AnswerOption option2;

  /// Third answer option.
  final AnswerOption option3;

  /// Fourth answer option.
  final AnswerOption option4;

  /// Order in which options were presented (list of option IDs).
  final List<String> optionsOrder;

  /// The correct answer.
  final AnswerOption correctAnswer;

  /// The user's selected answer (null if skipped/timeout).
  final AnswerOption? userAnswer;

  /// Whether the user answered correctly.
  final bool isCorrect;

  /// The status of this answer.
  final AnswerStatus answerStatus;

  /// Time spent on this question in seconds.
  final int? timeSpentSeconds;

  /// When the user answered.
  final DateTime? answeredAt;

  /// Which hint was used for this question.
  final HintUsed hintUsed;

  /// Option IDs that were disabled by 50/50 hint.
  final List<String> disabledOptions;

  /// Explanation shown after wrong answer.
  final String? explanation;

  /// When this record was created.
  final DateTime createdAt;

  /// All four options as a list.
  List<AnswerOption> get allOptions => [option1, option2, option3, option4];

  /// Options in the order they were presented.
  List<AnswerOption> get orderedOptions {
    final optionMap = {
      option1.id: option1,
      option2.id: option2,
      option3.id: option3,
      option4.id: option4,
    };
    return optionsOrder
        .map((id) => optionMap[id])
        .whereType<AnswerOption>()
        .toList();
  }

  /// Creates a [QuestionAnswer] from a database map.
  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      id: map[QuestionAnswersColumns.id] as String,
      sessionId: map[QuestionAnswersColumns.sessionId] as String,
      questionNumber: map[QuestionAnswersColumns.questionNumber] as int,
      questionId: map[QuestionAnswersColumns.questionId] as String,
      questionType: QuestionType.fromString(
        map[QuestionAnswersColumns.questionType] as String,
      ),
      questionContent: map[QuestionAnswersColumns.questionContent] as String?,
      questionResourceUrl:
          map[QuestionAnswersColumns.questionResourceUrl] as String?,
      option1: AnswerOption(
        id: map[QuestionAnswersColumns.option1Id] as String,
        text: map[QuestionAnswersColumns.option1Text] as String,
      ),
      option2: AnswerOption(
        id: map[QuestionAnswersColumns.option2Id] as String,
        text: map[QuestionAnswersColumns.option2Text] as String,
      ),
      option3: AnswerOption(
        id: map[QuestionAnswersColumns.option3Id] as String,
        text: map[QuestionAnswersColumns.option3Text] as String,
      ),
      option4: AnswerOption(
        id: map[QuestionAnswersColumns.option4Id] as String,
        text: map[QuestionAnswersColumns.option4Text] as String,
      ),
      optionsOrder: _parseJsonList(map[QuestionAnswersColumns.optionsOrder]),
      correctAnswer: AnswerOption(
        id: map[QuestionAnswersColumns.correctAnswerId] as String,
        text: map[QuestionAnswersColumns.correctAnswerText] as String,
      ),
      userAnswer: map[QuestionAnswersColumns.userAnswerId] != null
          ? AnswerOption(
              id: map[QuestionAnswersColumns.userAnswerId] as String,
              text: map[QuestionAnswersColumns.userAnswerText] as String? ?? '',
            )
          : null,
      isCorrect: (map[QuestionAnswersColumns.isCorrect] as int) == 1,
      answerStatus: AnswerStatus.fromString(
        map[QuestionAnswersColumns.answerStatus] as String,
      ),
      timeSpentSeconds: map[QuestionAnswersColumns.timeSpentSeconds] as int?,
      answeredAt: map[QuestionAnswersColumns.answeredAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[QuestionAnswersColumns.answeredAt] as int) * 1000,
            )
          : null,
      hintUsed: HintUsed.fromString(
        map[QuestionAnswersColumns.hintUsed] as String?,
      ),
      disabledOptions:
          _parseJsonList(map[QuestionAnswersColumns.disabledOptions]),
      explanation: map[QuestionAnswersColumns.explanation] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[QuestionAnswersColumns.createdAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [QuestionAnswer] to a database map.
  Map<String, dynamic> toMap() {
    return {
      QuestionAnswersColumns.id: id,
      QuestionAnswersColumns.sessionId: sessionId,
      QuestionAnswersColumns.questionNumber: questionNumber,
      QuestionAnswersColumns.questionId: questionId,
      QuestionAnswersColumns.questionType: questionType.value,
      QuestionAnswersColumns.questionContent: questionContent,
      QuestionAnswersColumns.questionResourceUrl: questionResourceUrl,
      QuestionAnswersColumns.option1Id: option1.id,
      QuestionAnswersColumns.option1Text: option1.text,
      QuestionAnswersColumns.option2Id: option2.id,
      QuestionAnswersColumns.option2Text: option2.text,
      QuestionAnswersColumns.option3Id: option3.id,
      QuestionAnswersColumns.option3Text: option3.text,
      QuestionAnswersColumns.option4Id: option4.id,
      QuestionAnswersColumns.option4Text: option4.text,
      QuestionAnswersColumns.optionsOrder: jsonEncode(optionsOrder),
      QuestionAnswersColumns.correctAnswerId: correctAnswer.id,
      QuestionAnswersColumns.correctAnswerText: correctAnswer.text,
      QuestionAnswersColumns.userAnswerId: userAnswer?.id,
      QuestionAnswersColumns.userAnswerText: userAnswer?.text,
      QuestionAnswersColumns.isCorrect: isCorrect ? 1 : 0,
      QuestionAnswersColumns.answerStatus: answerStatus.value,
      QuestionAnswersColumns.timeSpentSeconds: timeSpentSeconds,
      QuestionAnswersColumns.answeredAt: answeredAt != null
          ? answeredAt!.millisecondsSinceEpoch ~/ 1000
          : null,
      QuestionAnswersColumns.hintUsed: hintUsed.value,
      QuestionAnswersColumns.disabledOptions: jsonEncode(disabledOptions),
      QuestionAnswersColumns.explanation: explanation,
      QuestionAnswersColumns.createdAt: createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [QuestionAnswer] with the given fields replaced.
  QuestionAnswer copyWith({
    String? id,
    String? sessionId,
    int? questionNumber,
    String? questionId,
    QuestionType? questionType,
    String? questionContent,
    String? questionResourceUrl,
    AnswerOption? option1,
    AnswerOption? option2,
    AnswerOption? option3,
    AnswerOption? option4,
    List<String>? optionsOrder,
    AnswerOption? correctAnswer,
    AnswerOption? userAnswer,
    bool? isCorrect,
    AnswerStatus? answerStatus,
    int? timeSpentSeconds,
    DateTime? answeredAt,
    HintUsed? hintUsed,
    List<String>? disabledOptions,
    String? explanation,
    DateTime? createdAt,
  }) {
    return QuestionAnswer(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionNumber: questionNumber ?? this.questionNumber,
      questionId: questionId ?? this.questionId,
      questionType: questionType ?? this.questionType,
      questionContent: questionContent ?? this.questionContent,
      questionResourceUrl: questionResourceUrl ?? this.questionResourceUrl,
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
      option3: option3 ?? this.option3,
      option4: option4 ?? this.option4,
      optionsOrder: optionsOrder ?? this.optionsOrder,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      answerStatus: answerStatus ?? this.answerStatus,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      answeredAt: answeredAt ?? this.answeredAt,
      hintUsed: hintUsed ?? this.hintUsed,
      disabledOptions: disabledOptions ?? this.disabledOptions,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionAnswer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuestionAnswer(id: $id, questionId: $questionId, status: ${answerStatus.value})';
  }

  static List<String> _parseJsonList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.cast<String>();
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}
