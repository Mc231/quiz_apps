import 'base_config.dart';
import 'image_answer_size.dart';
import 'mixed_layout_strategy.dart';

/// Base sealed class for quiz layout configurations.
///
/// Defines how questions and answers are displayed in the quiz UI.
/// Each layout variant specifies the type of question display and answer format.
sealed class QuizLayoutConfig extends BaseConfig {
  const QuizLayoutConfig();

  /// Factory for image question with text answers (default layout).
  ///
  /// Question displays an image, answers are text buttons.
  /// Example: Show a flag image, user selects country name.
  factory QuizLayoutConfig.imageQuestionTextAnswers() =
      ImageQuestionTextAnswersLayout;

  /// Factory for text question with image answers.
  ///
  /// Question displays text, answers are images.
  /// Example: Show "Select the flag of France", user selects flag image.
  factory QuizLayoutConfig.textQuestionImageAnswers({
    ImageAnswerSize imageSize,
    String? questionTemplate,
  }) = TextQuestionImageAnswersLayout;

  /// Factory for text question with text answers.
  ///
  /// Both question and answers are text-based.
  /// Example: Trivia questions with multiple choice text answers.
  factory QuizLayoutConfig.textQuestionTextAnswers() =
      TextQuestionTextAnswersLayout;

  /// Factory for audio question with text answers.
  ///
  /// Question plays audio, answers are text buttons.
  /// Example: Play national anthem, user selects country name.
  factory QuizLayoutConfig.audioQuestionTextAnswers({
    bool autoPlay,
    bool showReplayButton,
  }) = AudioQuestionTextAnswersLayout;

  /// Factory for mixed layout that varies per question.
  ///
  /// Dynamically selects layout for each question based on strategy.
  /// Example: Alternate between image-text and text-image layouts.
  factory QuizLayoutConfig.mixed({
    required List<QuizLayoutConfig> layouts,
    MixedLayoutStrategy strategy,
  }) = MixedLayout;

  /// Deserialize from map.
  factory QuizLayoutConfig.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;

    return switch (type) {
      'imageQuestionTextAnswers' => ImageQuestionTextAnswersLayout.fromMap(map),
      'textQuestionImageAnswers' => TextQuestionImageAnswersLayout.fromMap(map),
      'textQuestionTextAnswers' => TextQuestionTextAnswersLayout.fromMap(map),
      'audioQuestionTextAnswers' => AudioQuestionTextAnswersLayout.fromMap(map),
      'mixed' => MixedLayout.fromMap(map),
      _ => throw ArgumentError('Unknown layout type: $type'),
    };
  }

  @override
  int get version => 1;
}

/// Image question with text answers layout.
///
/// The default quiz layout where:
/// - Question: Displays an image (e.g., flag, logo, photo)
/// - Answers: Text buttons for selection
class ImageQuestionTextAnswersLayout extends QuizLayoutConfig {
  const ImageQuestionTextAnswersLayout();

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'imageQuestionTextAnswers',
      'version': version,
    };
  }

  factory ImageQuestionTextAnswersLayout.fromMap(Map<String, dynamic> map) {
    return const ImageQuestionTextAnswersLayout();
  }
}

/// Text question with image answers layout.
///
/// Reverse of the default layout where:
/// - Question: Displays text (optionally using a template)
/// - Answers: Image buttons for selection
class TextQuestionImageAnswersLayout extends QuizLayoutConfig {
  /// Size configuration for answer images.
  final ImageAnswerSize imageSize;

  /// Template for generating question text.
  ///
  /// Use `{name}` as placeholder for the correct answer's name.
  /// Example: "Select the flag of {name}" -> "Select the flag of France"
  ///
  /// If null, uses the question's default text.
  final String? questionTemplate;

  const TextQuestionImageAnswersLayout({
    this.imageSize = const MediumImageSize(),
    this.questionTemplate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'textQuestionImageAnswers',
      'version': version,
      'imageSize': imageSize.toMap(),
      if (questionTemplate != null) 'questionTemplate': questionTemplate,
    };
  }

  factory TextQuestionImageAnswersLayout.fromMap(Map<String, dynamic> map) {
    return TextQuestionImageAnswersLayout(
      imageSize: map['imageSize'] != null
          ? ImageAnswerSize.fromMap(map['imageSize'] as Map<String, dynamic>)
          : const MediumImageSize(),
      questionTemplate: map['questionTemplate'] as String?,
    );
  }

  TextQuestionImageAnswersLayout copyWith({
    ImageAnswerSize? imageSize,
    String? questionTemplate,
  }) {
    return TextQuestionImageAnswersLayout(
      imageSize: imageSize ?? this.imageSize,
      questionTemplate: questionTemplate ?? this.questionTemplate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextQuestionImageAnswersLayout &&
        other.imageSize == imageSize &&
        other.questionTemplate == questionTemplate;
  }

  @override
  int get hashCode => Object.hash(imageSize, questionTemplate);
}

/// Text question with text answers layout.
///
/// Pure text-based layout where:
/// - Question: Displays text
/// - Answers: Text buttons for selection
class TextQuestionTextAnswersLayout extends QuizLayoutConfig {
  const TextQuestionTextAnswersLayout();

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'textQuestionTextAnswers',
      'version': version,
    };
  }

  factory TextQuestionTextAnswersLayout.fromMap(Map<String, dynamic> map) {
    return const TextQuestionTextAnswersLayout();
  }
}

/// Audio question with text answers layout.
///
/// Audio-based layout where:
/// - Question: Plays audio content
/// - Answers: Text buttons for selection
class AudioQuestionTextAnswersLayout extends QuizLayoutConfig {
  /// Whether to auto-play audio when question is displayed.
  final bool autoPlay;

  /// Whether to show a replay button for the audio.
  final bool showReplayButton;

  const AudioQuestionTextAnswersLayout({
    this.autoPlay = true,
    this.showReplayButton = true,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'audioQuestionTextAnswers',
      'version': version,
      'autoPlay': autoPlay,
      'showReplayButton': showReplayButton,
    };
  }

  factory AudioQuestionTextAnswersLayout.fromMap(Map<String, dynamic> map) {
    return AudioQuestionTextAnswersLayout(
      autoPlay: map['autoPlay'] as bool? ?? true,
      showReplayButton: map['showReplayButton'] as bool? ?? true,
    );
  }

  AudioQuestionTextAnswersLayout copyWith({
    bool? autoPlay,
    bool? showReplayButton,
  }) {
    return AudioQuestionTextAnswersLayout(
      autoPlay: autoPlay ?? this.autoPlay,
      showReplayButton: showReplayButton ?? this.showReplayButton,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioQuestionTextAnswersLayout &&
        other.autoPlay == autoPlay &&
        other.showReplayButton == showReplayButton;
  }

  @override
  int get hashCode => Object.hash(autoPlay, showReplayButton);
}

/// Mixed layout that varies per question.
///
/// Selects a layout for each question based on the configured strategy.
/// Useful for creating variety in quiz presentation.
class MixedLayout extends QuizLayoutConfig {
  /// Available layouts to choose from.
  ///
  /// Must contain at least one non-mixed layout.
  final List<QuizLayoutConfig> layouts;

  /// Strategy for selecting layouts.
  final MixedLayoutStrategy strategy;

  const MixedLayout({
    required this.layouts,
    this.strategy = const AlternatingStrategy(),
  });

  /// Selects the layout for a given question index.
  ///
  /// Returns the resolved (non-mixed) layout for the question.
  /// Throws [ArgumentError] if layouts is empty.
  QuizLayoutConfig selectLayout(int questionIndex) {
    if (layouts.isEmpty) {
      throw ArgumentError('MixedLayout requires at least one layout');
    }
    final index = strategy.selectIndex(questionIndex, layouts.length);
    final selected = layouts[index];

    // If selected is also a MixedLayout, recursively resolve
    if (selected is MixedLayout) {
      return selected.selectLayout(questionIndex);
    }

    return selected;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'mixed',
      'version': version,
      'layouts': layouts.map((l) => l.toMap()).toList(),
      'strategy': strategy.toMap(),
    };
  }

  factory MixedLayout.fromMap(Map<String, dynamic> map) {
    final layoutsList = (map['layouts'] as List)
        .map((l) => QuizLayoutConfig.fromMap(l as Map<String, dynamic>))
        .toList();

    return MixedLayout(
      layouts: layoutsList,
      strategy: map['strategy'] != null
          ? MixedLayoutStrategy.fromMap(map['strategy'] as Map<String, dynamic>)
          : const AlternatingStrategy(),
    );
  }

  MixedLayout copyWith({
    List<QuizLayoutConfig>? layouts,
    MixedLayoutStrategy? strategy,
  }) {
    return MixedLayout(
      layouts: layouts ?? this.layouts,
      strategy: strategy ?? this.strategy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MixedLayout) return false;
    if (layouts.length != other.layouts.length) return false;
    for (var i = 0; i < layouts.length; i++) {
      if (layouts[i] != other.layouts[i]) return false;
    }
    return strategy == other.strategy;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(layouts), strategy);
}