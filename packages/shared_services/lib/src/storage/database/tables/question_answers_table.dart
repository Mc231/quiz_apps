/// SQL schema definition for the question_answers table.
library;

import 'quiz_sessions_table.dart';

/// Table name constant.
const String questionAnswersTable = 'question_answers';

/// SQL statement to create the question_answers table.
const String createQuestionAnswersTable = '''
CREATE TABLE $questionAnswersTable (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  question_number INTEGER NOT NULL,
  question_id TEXT NOT NULL,
  question_type TEXT NOT NULL,
  question_content TEXT,
  question_resource_url TEXT,

  option_1_id TEXT NOT NULL,
  option_1_text TEXT NOT NULL,
  option_2_id TEXT NOT NULL,
  option_2_text TEXT NOT NULL,
  option_3_id TEXT NOT NULL,
  option_3_text TEXT NOT NULL,
  option_4_id TEXT NOT NULL,
  option_4_text TEXT NOT NULL,

  options_order TEXT NOT NULL,

  correct_answer_id TEXT NOT NULL,
  correct_answer_text TEXT NOT NULL,
  user_answer_id TEXT,
  user_answer_text TEXT,
  is_correct INTEGER NOT NULL,
  answer_status TEXT NOT NULL,
  time_spent_seconds INTEGER,
  answered_at INTEGER,
  hint_used TEXT,
  disabled_options TEXT,

  explanation TEXT,

  created_at INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES $quizSessionsTable(id) ON DELETE CASCADE
)
''';

/// SQL statements to create indexes for the question_answers table.
const List<String> createQuestionAnswersIndexes = [
  'CREATE INDEX idx_answers_session ON $questionAnswersTable(session_id)',
  'CREATE INDEX idx_answers_question ON $questionAnswersTable(question_id)',
  'CREATE INDEX idx_answers_correct ON $questionAnswersTable(is_correct)',
  'CREATE INDEX idx_answers_status ON $questionAnswersTable(answer_status)',
];

/// Column names for the question_answers table.
class QuestionAnswersColumns {
  QuestionAnswersColumns._();

  static const String id = 'id';
  static const String sessionId = 'session_id';
  static const String questionNumber = 'question_number';
  static const String questionId = 'question_id';
  static const String questionType = 'question_type';
  static const String questionContent = 'question_content';
  static const String questionResourceUrl = 'question_resource_url';
  static const String option1Id = 'option_1_id';
  static const String option1Text = 'option_1_text';
  static const String option2Id = 'option_2_id';
  static const String option2Text = 'option_2_text';
  static const String option3Id = 'option_3_id';
  static const String option3Text = 'option_3_text';
  static const String option4Id = 'option_4_id';
  static const String option4Text = 'option_4_text';
  static const String optionsOrder = 'options_order';
  static const String correctAnswerId = 'correct_answer_id';
  static const String correctAnswerText = 'correct_answer_text';
  static const String userAnswerId = 'user_answer_id';
  static const String userAnswerText = 'user_answer_text';
  static const String isCorrect = 'is_correct';
  static const String answerStatus = 'answer_status';
  static const String timeSpentSeconds = 'time_spent_seconds';
  static const String answeredAt = 'answered_at';
  static const String hintUsed = 'hint_used';
  static const String disabledOptions = 'disabled_options';
  static const String explanation = 'explanation';
  static const String createdAt = 'created_at';

  /// Layout used for this specific question.
  /// Stores the resolved layout type for this question
  /// (e.g., 'imageQuestionTextAnswers', 'textQuestionImageAnswers').
  /// Added in migration v7.
  static const String layoutUsed = 'layout_used';
}