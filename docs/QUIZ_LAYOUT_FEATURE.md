# Quiz Layout Feature Requirements Document

## Executive Summary

### Project Purpose
Implement support for **Image Answer Options** in the quiz engine, enabling a new quiz layout where:
- **Question**: Text-based (e.g., "Which flag is Germany?")
- **Answer Options**: 4 images (e.g., 4 flag images to choose from)

This is the opposite of the current layout where the question is an image and answers are text.

### Business Value
- **Enhanced Learning Modes**: Users can practice both "flag recognition" (image question, text answers) and "flag recall" (text question, image answers)
- **Increased Engagement**: Variety in quiz formats keeps users engaged
- **Reusability**: The same country/flag dataset can support multiple quiz modes
- **Foundation for Future Apps**: Other quiz apps (e.g., animal quizzes, logo quizzes) will benefit from flexible layout options

### Key Stakeholders
- **End Users**: Quiz players who want varied learning experiences
- **App Developers**: Teams building quiz apps using the quiz_engine packages
- **Content Creators**: Those defining quiz categories and configurations

### Success Criteria
1. Categories can specify their preferred layout (image-question or text-question)
2. Both layouts render correctly in portrait and landscape orientations
3. Existing image-question quizzes continue to work without changes (backward compatibility)
4. Image answer options support proper accessibility (screen readers)
5. Performance remains smooth with multiple image options loading simultaneously

---

## Current Architecture Analysis

### Data Layer (`quiz_engine_core`)

#### QuestionType Sealed Class
**File**: `/packages/quiz_engine_core/lib/src/model/question_type.dart`

```dart
sealed class QuestionType {
  factory QuestionType.image(String imagePath) = ImageQuestion;
  factory QuestionType.text(String text) = TextQuestion;
  factory QuestionType.audio(String audioPath) = AudioQuestion;
  factory QuestionType.video(String videoUrl, {String? thumbnailPath}) = VideoQuestion;
}
```

**Analysis**: This sealed class already supports multiple question types. However, it's currently used to define the **question content** only, not the **answer format**.

#### QuestionEntry Class
**File**: `/packages/quiz_engine_core/lib/src/model/question_entry.dart`

```dart
class QuestionEntry {
  final QuestionType type;  // Defines how this entry is displayed
  final Map<String, dynamic> otherOptions;  // Metadata (id, name, etc.)
}
```

**Key Insight**: Each `QuestionEntry` has a `type` that determines its rendering. Currently:
- The **answer** entry's type is used to render the question display
- The **options** entries' types are used to extract text for answer buttons

#### Question Class
**File**: `/packages/quiz_engine_core/lib/src/model/question.dart`

```dart
class Question {
  final QuestionEntry answer;        // The correct answer
  final List<QuestionEntry> options; // All options including correct answer
}
```

**Key Insight**: The `Question` class doesn't distinguish between question display type and answer display type. The `answer.type` is used for question rendering.

### UI Layer (`quiz_engine`)

#### QuizLayout Widget
**File**: `/packages/quiz_engine/lib/src/quiz/quiz_layout.dart`

The layout currently:
1. Reads `question.answer.type` to determine question widget type
2. Uses pattern matching to select appropriate widget:
   - `ImageQuestion` -> `QuizImageWidget`
   - `TextQuestion` -> `QuizTextWidget`
   - `AudioQuestion` -> `QuizAudioWidget`
   - `VideoQuestion` -> `QuizVideoWidget`
3. Always renders answers using `QuizAnswersWidget` which displays **text buttons**

```dart
Widget _buildQuestionWidget(QuestionEntry entry, String code, double size) {
  return switch (entry.type) {
    TextQuestion() => QuizTextWidget(...),
    ImageQuestion() => QuizImageWidget(...),
    AudioQuestion() => QuizAudioWidget(...),
    VideoQuestion() => QuizVideoWidget(...),
  };
}
```

#### QuizAnswersWidget
**File**: `/packages/quiz_engine/lib/src/quiz/quiz_answers_widget.dart`

**Current Behavior**: Always renders text buttons using `OptionButton`:
```dart
final String title;
if (option.type is TextQuestion) {
  title = (option.type as TextQuestion).text;
} else {
  title = option.otherOptions["name"] as String? ?? code;
}
return OptionButton(title: title, ...);
```

**Gap Identified**: No support for rendering image-based answer options.

### App Layer (`flagsquiz`)

#### Country Model
**File**: `/apps/flagsquiz/lib/models/country.dart`

```dart
QuestionEntry get toQuestionEntry {
  return QuestionEntry(
    type: ImageQuestion(flagLocalImage),  // Always image type
    otherOptions: {
      "correctAnswer": name,
      "continent": continent.name,
      "id": code,
      "name": localizedCountryName,
    },
  );
}
```

**Key Insight**: Country entries are created with `ImageQuestion` type. To support text-question layout, we need a way to generate `TextQuestion` entries or configure the display mode.

---

## Gap Analysis

### What Exists
| Component | Status | Notes |
|-----------|--------|-------|
| `QuestionType` sealed class | Exists | Supports image, text, audio, video |
| `QuestionEntry` model | Exists | Has type and metadata |
| `QuizImageWidget` | Exists | Renders single image question |
| `QuizTextWidget` | Exists | Renders single text question |
| `OptionButton` | Exists | Renders text-based answer option |
| `QuizAnswersWidget` | Exists | Grid of text answer buttons |
| `QuizLayout` | Exists | Orchestrates question + answers layout |
| `QuizCategory` | Exists | Category configuration |

### What Is Missing

| Component | Required | Purpose |
|-----------|----------|---------|
| **ImageOptionButton** | New Widget | Renders image-based answer option |
| **QuizImageAnswersWidget** | New Widget | Grid of image answer buttons |
| **QuizLayoutConfig** | New Sealed Class | Defines layout variants (static + mixed) |
| **MixedLayout** | New Config | Dynamic layout that alternates between variants |
| **MixedLayoutStrategy** | New Enum | Strategy for layout selection (random, alternating) |
| **Layout-aware QuizLayout** | Modified | Choose answer widget based on config |
| **Layout-aware QuizBloc** | Modified | Resolve layout per question for mixed mode |
| **Category layout config** | Modified | Allow categories to specify layout |

---

## Proposed Solution Architecture

### Design Principles
1. **Backward Compatibility**: Existing quizzes must work without changes
2. **Configuration-Driven**: Layout determined by category/quiz configuration
3. **Separation of Concerns**: Question display and answer display are independent
4. **Reusability**: New widgets can be used across different quiz types
5. **Accessibility**: Image options must have proper semantic labels

### High-Level Architecture

```
QuizCategory
    |
    +-- layoutConfig: QuizLayoutConfig
           |
           +-- Static Layouts (fixed for entire quiz):
           |     - ImageQuestionTextAnswersLayout
           |     - TextQuestionImageAnswersLayout
           |     - TextQuestionTextAnswersLayout
           |     - AudioQuestionTextAnswersLayout
           |
           +-- Dynamic Layout (varies per question):
                 - MixedLayout
                       +-- allowedLayouts: List<QuizLayoutConfig>
                       +-- strategy: MixedLayoutStrategy (random | alternating | weighted)

QuizBloc (for MixedLayout)
    |
    +-- Resolves layout per question using MixedLayout.selectLayout(questionIndex)
    +-- Passes resolved layout to QuizLayout widget

QuizLayout
    |
    +-- Receives resolved (non-mixed) layout
    +-- Uses layout to select question widget
    +-- Uses layout to select answer widget

QuizAnswersWidget (existing) -> Text answers
QuizImageAnswersWidget (new) -> Image answers
```

### Mixed Layout Flow

```
Quiz Start
    │
    ▼
┌─────────────────────────────────────┐
│  QuestionConfig.layoutConfig        │
│  = MixedLayout(                     │
│      allowedLayouts: [              │
│        ImageQuestionTextAnswers,    │
│        TextQuestionImageAnswers,    │
│      ],                             │
│      strategy: random,              │
│    )                                │
└─────────────────────────────────────┘
    │
    ▼ For each question
┌─────────────────────────────────────┐
│  QuizBloc.selectLayoutForQuestion() │
│  → MixedLayout.selectLayout(index)  │
│  → Returns concrete layout          │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│  Question 1: ImageQuestionTextAnswers│
│  Question 2: TextQuestionImageAnswers│
│  Question 3: ImageQuestionTextAnswers│
│  Question 4: TextQuestionImageAnswers│
│  ... (randomly selected)            │
└─────────────────────────────────────┘
```

---

## Data Model Changes

### 1. New: QuizLayoutConfig

**File**: `/packages/quiz_engine_core/lib/src/model/config/quiz_layout_config.dart`

```dart
/// Configuration for quiz question and answer display.
///
/// Determines how questions and answers are rendered in the quiz.
sealed class QuizLayoutConfig {
  const QuizLayoutConfig();

  /// Standard layout: Image question with text answer options.
  /// Example: Show flag image, user picks country name.
  factory QuizLayoutConfig.imageQuestionTextAnswers() = ImageQuestionTextAnswersLayout;

  /// Reverse layout: Text question with image answer options.
  /// Example: Show "Which flag is Germany?", user picks from 4 flags.
  factory QuizLayoutConfig.textQuestionImageAnswers() = TextQuestionImageAnswersLayout;

  /// Text-only layout: Text question with text answer options.
  /// Example: "What is the capital of France?", user picks city name.
  factory QuizLayoutConfig.textQuestionTextAnswers() = TextQuestionTextAnswersLayout;

  /// Audio layout: Audio question with text answer options.
  /// Example: Play national anthem, user picks country name.
  factory QuizLayoutConfig.audioQuestionTextAnswers() = AudioQuestionTextAnswersLayout;

  /// Mixed/Dynamic layout: Randomly alternates between specified layouts.
  /// Each question randomly picks from the allowed layouts list.
  /// Example: Some questions show flag→pick name, others show name→pick flag.
  factory QuizLayoutConfig.mixed({
    required List<QuizLayoutConfig> allowedLayouts,
    MixedLayoutStrategy strategy,
  }) = MixedLayout;

  /// Convert to JSON-compatible map.
  Map<String, dynamic> toMap();

  /// Create from JSON map.
  factory QuizLayoutConfig.fromMap(Map<String, dynamic> map);
}

/// Standard layout: Image question with text answers.
class ImageQuestionTextAnswersLayout extends QuizLayoutConfig {
  const ImageQuestionTextAnswersLayout();

  @override
  Map<String, dynamic> toMap() => {'type': 'imageQuestionTextAnswers'};
}

/// Reverse layout: Text question with image answers.
class TextQuestionImageAnswersLayout extends QuizLayoutConfig {
  /// The text template for generating questions.
  /// Use {name} placeholder for the item name.
  /// Example: "Which flag is {name}?"
  final String questionTemplate;

  /// Image size configuration for answer options.
  final ImageAnswerSize imageSize;

  const TextQuestionImageAnswersLayout({
    this.questionTemplate = 'Which one is {name}?',
    this.imageSize = ImageAnswerSize.medium,
  });

  @override
  Map<String, dynamic> toMap() => {
    'type': 'textQuestionImageAnswers',
    'questionTemplate': questionTemplate,
    'imageSize': imageSize.name,
  };
}

/// Text-only layout: Text question with text answers.
class TextQuestionTextAnswersLayout extends QuizLayoutConfig {
  const TextQuestionTextAnswersLayout();

  @override
  Map<String, dynamic> toMap() => {'type': 'textQuestionTextAnswers'};
}

/// Audio layout: Audio question with text answers.
class AudioQuestionTextAnswersLayout extends QuizLayoutConfig {
  const AudioQuestionTextAnswersLayout();

  @override
  Map<String, dynamic> toMap() => {'type': 'audioQuestionTextAnswers'};
}

/// Mixed/Dynamic layout: Randomly alternates between specified layouts.
///
/// This layout enables variety within a single quiz session by randomly
/// selecting from a list of allowed layouts for each question.
class MixedLayout extends QuizLayoutConfig {
  /// The list of layouts to randomly choose from.
  /// Must contain at least 2 layouts for meaningful mixing.
  final List<QuizLayoutConfig> allowedLayouts;

  /// Strategy for selecting layouts during the quiz.
  final MixedLayoutStrategy strategy;

  const MixedLayout({
    required this.allowedLayouts,
    this.strategy = MixedLayoutStrategy.random,
  });

  /// Selects a layout for a given question index.
  QuizLayoutConfig selectLayout(int questionIndex, [int? seed]) {
    return switch (strategy) {
      MixedLayoutStrategy.random => _randomLayout(seed),
      MixedLayoutStrategy.alternating => _alternatingLayout(questionIndex),
      MixedLayoutStrategy.weighted => _weightedLayout(seed),
    };
  }

  QuizLayoutConfig _randomLayout(int? seed) {
    final random = seed != null ? Random(seed) : Random();
    return allowedLayouts[random.nextInt(allowedLayouts.length)];
  }

  QuizLayoutConfig _alternatingLayout(int questionIndex) {
    return allowedLayouts[questionIndex % allowedLayouts.length];
  }

  QuizLayoutConfig _weightedLayout(int? seed) {
    // For now, same as random. Could be extended with weights.
    return _randomLayout(seed);
  }

  @override
  Map<String, dynamic> toMap() => {
    'type': 'mixed',
    'allowedLayouts': allowedLayouts.map((l) => l.toMap()).toList(),
    'strategy': strategy.name,
  };
}

/// Strategy for selecting layouts in MixedLayout.
enum MixedLayoutStrategy {
  /// Randomly select a layout for each question.
  random,

  /// Alternate through layouts in order (1, 2, 1, 2, ...).
  alternating,

  /// Weighted random selection (future: allow specifying weights).
  weighted,
}

/// Image answer size options for responsive layouts.
enum ImageAnswerSize {
  /// Small images (good for 4+ options)
  small,
  /// Medium images (default, good for 4 options)
  medium,
  /// Large images (good for 2-3 options)
  large,
}
```

### 2. Modify: QuestionConfig

**File**: `/packages/quiz_engine_core/lib/src/model/config/question_config.dart`

Add layout configuration:

```dart
class QuestionConfig extends BaseConfig {
  final int optionCount;
  final bool shuffleQuestions;
  final bool shuffleOptions;

  /// Layout configuration for question and answer display.
  /// Defaults to standard image question with text answers.
  final QuizLayoutConfig layoutConfig;

  const QuestionConfig({
    this.optionCount = 4,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
    this.layoutConfig = const ImageQuestionTextAnswersLayout(),
    this.version = 1,
  });

  // ... existing code ...
}
```

### 3. Modify: QuizCategory

**File**: `/packages/quiz_engine/lib/src/models/quiz_category.dart`

Add optional layout override:

```dart
class QuizCategory {
  final String id;
  final LocalizedString title;
  final LocalizedString? subtitle;
  final ImageProvider? imageProvider;
  final IconData? icon;
  final QuizConfig? config;
  final Map<String, dynamic>? metadata;
  final bool showAnswerFeedback;

  /// Optional layout configuration override.
  /// If null, uses the default from QuestionConfig.
  final QuizLayoutConfig? layoutConfig;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.showAnswerFeedback,
    this.subtitle,
    this.imageProvider,
    this.icon,
    this.config,
    this.metadata,
    this.layoutConfig,
  });
}
```

---

## UI Component Changes

### 1. New: ImageOptionButton Widget

**File**: `/packages/quiz_engine/lib/src/components/image_option_button.dart`

```dart
/// A button widget displaying an image as an answer option.
///
/// Used in image-answer layouts where users select from image options.
/// Supports disabled state, selection highlighting, and accessibility.
class ImageOptionButton extends StatelessWidget {
  /// The image path (asset or network URL).
  final String imagePath;

  /// Semantic label for accessibility.
  final String semanticLabel;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is disabled (e.g., from 50/50 hint).
  final bool isDisabled;

  /// Theme data for styling.
  final QuizThemeData themeData;

  const ImageOptionButton({
    super.key,
    required this.imagePath,
    required this.semanticLabel,
    required this.onPressed,
    this.isDisabled = false,
    this.themeData = const QuizThemeData(),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isDisabled
          ? QuizL10n.of(context).accessibilityAnswerDisabled(semanticLabel)
          : QuizL10n.of(context).accessibilityAnswerOption(semanticLabel),
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: themeData.buttonBorderRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: themeData.buttonBorderRadius,
              border: Border.all(
                color: isDisabled ? Colors.grey : themeData.buttonBorderColor,
                width: themeData.buttonBorderWidth,
              ),
              color: isDisabled ? Colors.grey[300] : null,
            ),
            child: ClipRRect(
              borderRadius: themeData.buttonBorderRadius,
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: _buildImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const Center(
      child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
    );
  }
}
```

### 2. New: QuizImageAnswersWidget

**File**: `/packages/quiz_engine/lib/src/quiz/quiz_image_answers_widget.dart`

```dart
/// A widget that displays image-based answer options in a grid.
///
/// Used when the quiz layout specifies image answers (e.g., pick the correct flag).
/// Adapts to different screen sizes and orientations.
class QuizImageAnswersWidget extends StatelessWidget {
  /// The list of question entries to display as image options.
  final List<QuestionEntry> options;

  /// Sizing information for responsive layout.
  final SizingInformation sizingInformation;

  /// Callback when an option is selected.
  final Function(QuestionEntry answer) answerClickListener;

  /// Set of disabled options (e.g., from 50/50 hint).
  final Set<QuestionEntry> disabledOptions;

  /// Theme data for styling.
  final QuizThemeData themeData;

  /// Image size configuration.
  final ImageAnswerSize imageSize;

  const QuizImageAnswersWidget({
    required Key key,
    required this.options,
    required this.sizingInformation,
    required this.answerClickListener,
    this.disabledOptions = const {},
    this.themeData = const QuizThemeData(),
    this.imageSize = ImageAnswerSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      mainAxisSpacing: _getAxisSpacing(context),
      crossAxisSpacing: _getAxisSpacing(context),
      childAspectRatio: _getChildAspectRatio(),
      crossAxisCount: _getCrossAxisCount(),
      children: options
          .map((option) => _createImageOptionButton(option, context))
          .toList(),
    );
  }

  Widget _createImageOptionButton(QuestionEntry option, BuildContext context) {
    final code = (option.otherOptions["id"] as String).toLowerCase();
    final name = option.otherOptions["name"] as String? ?? code;
    final imagePath = _getImagePath(option);
    final isDisabled = disabledOptions.contains(option);

    return ImageOptionButton(
      key: Key("image_button_$code"),
      imagePath: imagePath,
      semanticLabel: name,
      onPressed: () => answerClickListener(option),
      isDisabled: isDisabled,
      themeData: themeData,
    );
  }

  String _getImagePath(QuestionEntry option) {
    // If the option type is ImageQuestion, use its path
    if (option.type is ImageQuestion) {
      return (option.type as ImageQuestion).imagePath;
    }
    // Fallback: try to get image path from otherOptions
    return option.otherOptions["imagePath"] as String? ?? '';
  }

  int _getCrossAxisCount() {
    // 2x2 grid for 4 options
    if (options.length <= 4) return 2;
    // 3 columns for more options
    return 3;
  }

  double _getChildAspectRatio() {
    // Square images work well for flags
    return 1.0;
  }

  double _getAxisSpacing(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      watch: 4.0,
    );
  }
}
```

### 3. Modify: QuizLayout

**File**: `/packages/quiz_engine/lib/src/quiz/quiz_layout.dart`

Update to support configurable answer display:

```dart
class QuizLayout extends StatelessWidget {
  final QuestionState questionState;
  final SizingInformation information;
  final Function(QuestionEntry) processAnswer;
  final GameResourcePanelData? resourceData;
  final QuizThemeData themeData;

  /// Layout configuration for question and answer display.
  /// Defaults to standard image question with text answers.
  final QuizLayoutConfig layoutConfig;

  const QuizLayout({
    super.key,
    required this.questionState,
    required this.information,
    required this.processAnswer,
    this.resourceData,
    this.themeData = const QuizThemeData(),
    this.layoutConfig = const ImageQuestionTextAnswersLayout(),
  });

  @override
  Widget build(BuildContext context) {
    // ... existing layout code ...
  }

  List<Widget> _imageAndButtons(
    QuestionState state,
    SizingInformation information,
  ) {
    final answer = state.question.answer;
    final code = answer.otherOptions["id"] as String;
    final questionSize = getImageSize(information);
    final isLandscape = information.orientation == Orientation.landscape;

    return [
      if (isLandscape)
        Flexible(
          flex: 1,
          child: _buildQuestionWidget(answer, code, questionSize),
        )
      else
        _buildQuestionWidget(answer, code, questionSize),
      SizedBox(width: themeData.questionAnswerSpacing),
      Expanded(
        flex: isLandscape ? 2 : 1,
        child: _buildAnswersWidget(state, information),
      ),
    ];
  }

  /// Builds the question widget based on layout configuration.
  Widget _buildQuestionWidget(QuestionEntry entry, String code, double size) {
    return switch (layoutConfig) {
      TextQuestionImageAnswersLayout(:final questionTemplate) =>
        _buildTextQuestionFromTemplate(entry, code, size, questionTemplate),
      _ => _buildQuestionWidgetFromType(entry, code, size),
    };
  }

  /// Builds a text question using a template.
  Widget _buildTextQuestionFromTemplate(
    QuestionEntry entry,
    String code,
    double size,
    String template,
  ) {
    final name = entry.otherOptions["name"] as String? ?? code;
    final questionText = template.replaceAll('{name}', name);

    return QuizTextWidget(
      key: Key(code),
      entry: QuestionEntry(
        type: TextQuestion(questionText),
        otherOptions: entry.otherOptions,
      ),
      width: size,
      height: size,
    );
  }

  /// Builds the question widget from entry type (existing behavior).
  Widget _buildQuestionWidgetFromType(QuestionEntry entry, String code, double size) {
    return switch (entry.type) {
      TextQuestion() => QuizTextWidget(
        key: Key(code),
        entry: entry,
        width: size,
        height: size,
      ),
      ImageQuestion() => QuizImageWidget(
        key: Key(code),
        entry: entry,
        width: size,
        height: size,
      ),
      AudioQuestion() => QuizAudioWidget(
        key: Key(code),
        entry: entry,
        width: size,
        height: size,
      ),
      VideoQuestion() => QuizVideoWidget(
        key: Key(code),
        entry: entry,
        width: size,
        height: size,
      ),
    };
  }

  /// Builds the answers widget based on layout configuration.
  Widget _buildAnswersWidget(QuestionState state, SizingInformation information) {
    return switch (layoutConfig) {
      TextQuestionImageAnswersLayout(:final imageSize) =>
        QuizImageAnswersWidget(
          key: Key(state.total.toString()),
          options: state.question.options,
          sizingInformation: information,
          answerClickListener: processAnswer,
          disabledOptions: state.disabledOptions,
          themeData: themeData,
          imageSize: imageSize,
        ),
      _ => QuizAnswersWidget(
        key: Key(state.total.toString()),
        options: state.question.options,
        sizingInformation: information,
        answerClickListener: processAnswer,
        disabledOptions: state.disabledOptions,
        themeData: themeData,
      ),
    };
  }
}
```

### 4. Modify: QuizScreen

**File**: `/packages/quiz_engine/lib/src/quiz/quiz_screen.dart`

Pass layout config to QuizLayout:

```dart
Widget _buildBody(QuizState? state, GameResourcePanelData? resourceData) {
  // ... existing code ...

  final questionState = state as QuestionState;
  final layoutConfig = _bloc.config.questionConfig.layoutConfig;

  return ResponsiveBuilder(
    builder: (context, information) {
      return QuizLayout(
        questionState: questionState,
        information: information,
        processAnswer: _bloc.processAnswer,
        resourceData: resourceData,
        themeData: widget.themeData,
        layoutConfig: layoutConfig,
      );
    },
  );
}
```

---

## Configuration Approach

### How Categories Specify Layout

Categories can specify their layout in two ways:

#### 1. Via QuizConfig.questionConfig

```dart
// In FlagsDataProvider
@override
QuizConfig? createQuizConfig(BuildContext context, QuizCategory category) {
  // Check if this category uses reverse layout
  final useImageAnswers = category.metadata?['useImageAnswers'] == true;

  return QuizConfig(
    quizId: category.id,
    questionConfig: QuestionConfig(
      layoutConfig: useImageAnswers
          ? TextQuestionImageAnswersLayout(
              questionTemplate: l10n.whichFlagIs, // "Which flag is {name}?"
            )
          : const ImageQuestionTextAnswersLayout(),
    ),
    // ... other config ...
  );
}
```

#### 2. Via Category Definition

```dart
// In flags_categories.dart
List<QuizCategory> createFlagsCategories(CountryCounts counts) {
  return [
    // Standard layout: Image question, text answers
    QuizCategory(
      id: 'europe',
      title: (context) => l10n.europe,
      showAnswerFeedback: true,
      layoutConfig: const ImageQuestionTextAnswersLayout(),
    ),

    // Reverse layout: Text question, image answers
    QuizCategory(
      id: 'europe_reverse',
      title: (context) => l10n.europeReverse,
      subtitle: (context) => l10n.identifyFlags,
      showAnswerFeedback: true,
      layoutConfig: TextQuestionImageAnswersLayout(
        questionTemplate: l10n.whichFlagIs, // "Which flag is {name}?"
      ),
    ),

    // Mixed/Dynamic layout: Randomly alternates between layouts
    QuizCategory(
      id: 'europe_mixed',
      title: (context) => l10n.europeMixed,
      subtitle: (context) => l10n.mixedModeDescription,
      showAnswerFeedback: true,
      layoutConfig: MixedLayout(
        allowedLayouts: [
          const ImageQuestionTextAnswersLayout(),
          TextQuestionImageAnswersLayout(questionTemplate: l10n.whichFlagIs),
        ],
        strategy: MixedLayoutStrategy.random,
      ),
    ),

    // Alternating layout: Predictable pattern (Q1, Q2, Q1, Q2, ...)
    QuizCategory(
      id: 'europe_alternating',
      title: (context) => l10n.europeAlternating,
      showAnswerFeedback: true,
      layoutConfig: MixedLayout(
        allowedLayouts: [
          const ImageQuestionTextAnswersLayout(),
          TextQuestionImageAnswersLayout(questionTemplate: l10n.whichFlagIs),
        ],
        strategy: MixedLayoutStrategy.alternating,
      ),
    ),
  ];
}
```

#### 3. Mixed Layout Usage Patterns

```dart
// Pattern 1: Random mix - each question randomly picks a layout
QuizLayoutConfig.mixed(
  allowedLayouts: [
    const ImageQuestionTextAnswersLayout(),
    TextQuestionImageAnswersLayout(questionTemplate: 'Which flag is {name}?'),
  ],
  strategy: MixedLayoutStrategy.random,
)

// Pattern 2: Alternating - predictable pattern for structured learning
// Q1: flag→name, Q2: name→flag, Q3: flag→name, Q4: name→flag...
QuizLayoutConfig.mixed(
  allowedLayouts: [
    const ImageQuestionTextAnswersLayout(),
    TextQuestionImageAnswersLayout(questionTemplate: 'Which flag is {name}?'),
  ],
  strategy: MixedLayoutStrategy.alternating,
)

// Pattern 3: Three-way mix (for apps with multiple content types)
QuizLayoutConfig.mixed(
  allowedLayouts: [
    const ImageQuestionTextAnswersLayout(),     // Show flag, pick name
    TextQuestionImageAnswersLayout(...),         // Show name, pick flag
    const TextQuestionTextAnswersLayout(),       // Show capital, pick country
  ],
  strategy: MixedLayoutStrategy.random,
)
```

---

## Implementation Phases/Sprints

### Phase 1: Core Data Model (Sprint 1)

**Files to Create/Modify:**

1. **Create** `/packages/quiz_engine_core/lib/src/model/config/quiz_layout_config.dart`
   - Sealed class `QuizLayoutConfig` with all layout variants:
     - `ImageQuestionTextAnswersLayout` (current default)
     - `TextQuestionImageAnswersLayout` (reverse layout)
     - `TextQuestionTextAnswersLayout` (text-only)
     - `AudioQuestionTextAnswersLayout` (audio questions)
     - `MixedLayout` (dynamic/random layout per question)
   - `ImageAnswerSize` enum (small, medium, large)
   - `MixedLayoutStrategy` enum (random, alternating, weighted)
   - JSON serialization support for all types

2. **Modify** `/packages/quiz_engine_core/lib/src/model/config/question_config.dart`
   - Add `layoutConfig` field
   - Update `toMap()` and `fromMap()`
   - Update `copyWith()`

3. **Modify** `/packages/quiz_engine_core/lib/src/model/config/config_exports.dart`
   - Export new `quiz_layout_config.dart`

4. **Create** `/packages/quiz_engine_core/test/model/config/quiz_layout_config_test.dart`
   - Unit tests for all layout types (static and mixed)
   - JSON serialization tests
   - MixedLayout.selectLayout() tests for each strategy

**Estimated Effort**: 1.5 days

### Phase 2: UI Components (Sprint 2)

**Files to Create:**

1. **Create** `/packages/quiz_engine/lib/src/components/image_option_button.dart`
   - Image-based answer button widget
   - Disabled state support
   - Accessibility support

2. **Create** `/packages/quiz_engine/lib/src/quiz/quiz_image_answers_widget.dart`
   - Grid layout for image answer options
   - Responsive sizing
   - Integration with theme

3. **Create** `/packages/quiz_engine/test/widgets/image_option_button_test.dart`
   - Widget tests for ImageOptionButton

4. **Create** `/packages/quiz_engine/test/widgets/quiz_image_answers_widget_test.dart`
   - Widget tests for QuizImageAnswersWidget

**Estimated Effort**: 2 days

### Phase 3: Layout Integration (Sprint 3)

**Files to Modify:**

1. **Modify** `/packages/quiz_engine/lib/src/quiz/quiz_layout.dart`
   - Add `layoutConfig` parameter (receives resolved non-mixed layout)
   - Implement layout-aware question widget builder
   - Implement layout-aware answers widget builder

2. **Modify** `/packages/quiz_engine/lib/src/bloc/quiz/quiz_bloc.dart`
   - Add `resolveLayoutForQuestion(int questionIndex)` method
   - Handle MixedLayout by selecting concrete layout per question
   - Store resolved layout in QuestionState for UI rendering
   - Use consistent seed for reproducible layout selection (optional)

3. **Modify** `/packages/quiz_engine/lib/src/bloc/quiz/quiz_state.dart`
   - Add `resolvedLayout` field to `QuestionState`
   - Ensure layout is available for each question display

4. **Modify** `/packages/quiz_engine/lib/src/quiz/quiz_screen.dart`
   - Pass resolved `layoutConfig` from state to QuizLayout

5. **Modify** `/packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart`
   - Support image answer feedback display

6. **Update** `/packages/quiz_engine/lib/quiz_engine.dart`
   - Export new widgets and configs

7. **Create/Modify** tests:
   - `/packages/quiz_engine/test/quiz/quiz_layout_test.dart`
   - `/packages/quiz_engine/test/quiz/quiz_screen_test.dart`
   - `/packages/quiz_engine/test/bloc/quiz_bloc_layout_test.dart` (new)

**Estimated Effort**: 2.5 days

### Phase 4: Category Configuration (Sprint 4)

**Files to Modify:**

1. **Modify** `/packages/quiz_engine/lib/src/models/quiz_category.dart`
   - Add optional `layoutConfig` field
   - Update `copyWith()`

2. **Modify** `/packages/quiz_engine/lib/src/models/quiz_data_provider.dart`
   - Document layout configuration pattern

3. **Update** `/packages/quiz_engine/test/models/quiz_category_test.dart`
   - Test layout config support

**Estimated Effort**: 0.5 days

### Phase 5: Flags Quiz Integration (Sprint 5)

**Files to Create/Modify:**

1. **Modify** `/apps/flagsquiz/lib/data/flags_categories.dart`
   - Add reverse layout categories (optional feature flag)

2. **Modify** `/apps/flagsquiz/lib/data/flags_data_provider.dart`
   - Handle layout config in `createQuizConfig`

3. **Add** localization strings:
   - `/apps/flagsquiz/lib/l10n/intl_en.arb` - "Which flag is {name}?"
   - `/packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` - Generic strings

4. **Create** integration tests

**Estimated Effort**: 1 day

### Phase 6: Data Persistence & App-Wide Integration (Sprint 6)

**Goal:** Ensure layout information is persisted and displayed throughout the app.

**Database Changes:**

1. **Modify** `quiz_sessions` table schema:
   - Add `layout_mode` column (TEXT) - stores layout type identifier
   - Values: `imageQuestionTextAnswers`, `textQuestionImageAnswers`, `mixed`, etc.

2. **Modify** `quiz_answers` table schema:
   - Add `layout_used` column (TEXT) - stores the resolved layout for each question
   - Important for MixedLayout where each question may have different layout

**Files to Modify:**

1. **Database Layer:**
   - `/packages/shared_services/lib/src/storage/database/database_helper.dart` - Add migration
   - `/packages/shared_services/lib/src/storage/models/quiz_session.dart` - Add `layoutMode` field
   - `/packages/shared_services/lib/src/storage/models/quiz_answer.dart` - Add `layoutUsed` field
   - `/packages/shared_services/lib/src/storage/data_sources/quiz_session_data_source.dart` - Update queries

2. **Session Recording:**
   - `/packages/quiz_engine/lib/src/bloc/quiz/quiz_bloc.dart` - Record layout per answer
   - Ensure `QuizSession` is created with `layoutMode` field

3. **Session History Screen:**
   - `/packages/quiz_engine/lib/src/screens/session_history_screen.dart` - Show layout mode badge/indicator
   - Add filter option by layout mode (optional)

4. **Session Detail Screen:**
   - `/packages/quiz_engine/lib/src/screens/session_detail_screen.dart` - Show layout per question
   - Display appropriate visualization (image or text) based on stored layout

5. **Statistics Screen:**
   - `/packages/quiz_engine/lib/src/screens/statistics_screen.dart` - Show breakdown by layout mode
   - `/packages/quiz_engine/lib/src/screens/statistics_dashboard_screen.dart` - Layout mode stats

6. **Results Screen:**
   - `/packages/quiz_engine/lib/src/screens/quiz_results_screen.dart` - Show layout mode used

7. **Analytics Events:**
   - Update `QuizEvent.started` - Add `layoutMode` parameter
   - Update `QuizEvent.completed` - Add `layoutMode` parameter
   - Update `QuestionEvent.answered` - Add `layoutUsed` parameter

**UI Considerations:**

- Use icons/badges to indicate layout mode:
  - 🖼️→📝 Image question, text answers (default)
  - 📝→🖼️ Text question, image answers
  - 🔀 Mixed mode
- Show layout breakdown in session review
- For mixed mode sessions, show per-question layout in detail view

**Estimated Effort**: 2 days

---

### Phase 7: Polish and Documentation (Sprint 7)

1. Update `PHASE_IMPLEMENTATION.md` with completed tasks
2. Add documentation to `CORE_ARCHITECTURE_GUIDE.md`
3. Performance testing with multiple images
4. Accessibility testing with VoiceOver/TalkBack
5. Manual testing on different device sizes
6. Test layout display in all screens (history, detail, statistics, results)

**Estimated Effort**: 1 day

---

## Testing Requirements

### Unit Tests

1. **QuizLayoutConfig Tests**
   - Factory methods create correct types
   - JSON serialization/deserialization
   - Default values

2. **QuestionConfig Tests**
   - Layout config is preserved in copyWith
   - Default layout is ImageQuestionTextAnswers

### Widget Tests

1. **ImageOptionButton Tests**
   - Renders image correctly (asset)
   - Renders image correctly (network)
   - Disabled state appearance
   - Tap callback fires
   - Accessibility labels present

2. **QuizImageAnswersWidget Tests**
   - Renders correct number of options
   - Grid layout adapts to screen size
   - Disabled options display correctly
   - Tap selects correct option

3. **QuizLayout Tests**
   - ImageQuestionTextAnswers shows text buttons
   - TextQuestionImageAnswers shows image buttons
   - Question template substitution works
   - Landscape/portrait layouts work

### Integration Tests

1. **Full Quiz Flow**
   - Start quiz with image answers
   - Answer questions correctly
   - Use 50/50 hint (disables 2 images)
   - Complete quiz
   - Review results

2. **Backward Compatibility**
   - Existing flags quiz works unchanged
   - No visual differences in standard layout

---

## Backwards Compatibility Considerations

### No Breaking Changes

1. **Default Behavior Preserved**
   - `QuestionConfig()` defaults to `ImageQuestionTextAnswersLayout()`
   - Existing quizzes continue working without code changes

2. **Optional Parameters**
   - `layoutConfig` is optional everywhere
   - Null means "use default"

3. **QuestionEntry Unchanged**
   - No changes to how entries are created
   - `type` still determines content type
   - `otherOptions` still stores metadata

### Migration Path

For apps wanting to adopt the new feature:

```dart
// Before (unchanged, still works)
QuestionConfig()

// After (opt-in to new layout)
QuestionConfig(
  layoutConfig: TextQuestionImageAnswersLayout(
    questionTemplate: 'Which flag is {name}?',
  ),
)
```

---

## Edge Cases and Error Scenarios

### 1. Missing Image Path
**Scenario**: QuestionEntry used in image answers doesn't have an image path.
**Handling**: Show broken image placeholder; log warning.

### 2. Network Image Fails
**Scenario**: Network image URL returns 404 or times out.
**Handling**: Show broken image placeholder; allow selection anyway.

### 3. Mixed Entry Types
**Scenario**: Options list contains both ImageQuestion and TextQuestion entries.
**Handling**: Extract image path from ImageQuestion; fallback to placeholder for others.

### 4. Empty Question Template
**Scenario**: Template is empty or null.
**Handling**: Use default template "Which one is {name}?".

### 5. Missing {name} Placeholder
**Scenario**: Template doesn't contain {name}.
**Handling**: Use template as-is; log warning.

---

## Agent Orchestration Guidance

### Recommended Agent Specializations

1. **Data Model Agent** (Sprint 1)
   - Creates QuizLayoutConfig sealed class
   - Modifies QuestionConfig
   - Writes unit tests

2. **Widget Builder Agent** (Sprint 2)
   - Creates ImageOptionButton
   - Creates QuizImageAnswersWidget
   - Writes widget tests

3. **Integration Agent** (Sprints 3-4)
   - Modifies QuizLayout
   - Modifies QuizScreen
   - Updates QuizCategory
   - Writes integration tests

4. **App Integration Agent** (Sprint 5)
   - Modifies flagsquiz app
   - Adds localization strings
   - Creates sample categories

### Task Sequencing

```
[Sprint 1] Data Models
    |
    v
[Sprint 2] UI Components (can start after Sprint 1 models)
    |
    v
[Sprint 3] Layout Integration (needs Sprints 1 + 2)
    |
    v
[Sprint 4] Category Config (needs Sprint 3)
    |
    v
[Sprint 5] App Integration (needs Sprint 4)
    |
    v
[Sprint 6] Polish & Docs
```

### Quality Checkpoints

- [ ] Sprint 1: All unit tests pass for new config classes
- [ ] Sprint 2: Widget tests pass; visual review of image buttons
- [ ] Sprint 3: Existing quiz layouts unchanged; new layout renders correctly
- [ ] Sprint 4: Category can specify layout; data provider respects config
- [ ] Sprint 5: Flags quiz has working reverse layout option
- [ ] Sprint 6: Full test suite passes; accessibility verified

---

## Open Questions and Assumptions

### Assumptions Made

1. **Image Size**: Assumes square images work well for flag options
2. **Grid Layout**: 2x2 grid for 4 options is optimal for image answers
3. **Template Syntax**: `{name}` is sufficient for question generation
4. **No New Assets**: Uses existing flag images for both layouts

### Questions Requiring Stakeholder Input

1. **Feature Flag**: Should reverse layout be behind a feature flag or immediately visible?
2. **Category Names**: What should reverse layout categories be called? (e.g., "Europe - Identify Flags")
3. **Question Templates**: Are there app-specific templates needed beyond "Which flag is {name}?"
4. **Analytics**: Should we track which layout mode users prefer?
5. **A/B Testing**: Should we measure engagement differences between layouts?

---

## Appendix: File Reference

### Files to Create

| File Path | Purpose |
|-----------|---------|
| `packages/quiz_engine_core/lib/src/model/config/quiz_layout_config.dart` | Layout config sealed class |
| `packages/quiz_engine_core/test/model/config/quiz_layout_config_test.dart` | Unit tests |
| `packages/quiz_engine/lib/src/components/image_option_button.dart` | Image answer button widget |
| `packages/quiz_engine/lib/src/quiz/quiz_image_answers_widget.dart` | Image answers grid widget |
| `packages/quiz_engine/test/widgets/image_option_button_test.dart` | Widget tests |
| `packages/quiz_engine/test/widgets/quiz_image_answers_widget_test.dart` | Widget tests |

### Files to Modify

| File Path | Changes |
|-----------|---------|
| `packages/quiz_engine_core/lib/src/model/config/question_config.dart` | Add layoutConfig field |
| `packages/quiz_engine_core/lib/src/model/config/config_exports.dart` | Export new config |
| `packages/quiz_engine/lib/src/quiz/quiz_layout.dart` | Layout-aware widget selection |
| `packages/quiz_engine/lib/src/quiz/quiz_screen.dart` | Pass layout config |
| `packages/quiz_engine/lib/src/widgets/answer_feedback_widget.dart` | Image answer feedback |
| `packages/quiz_engine/lib/src/models/quiz_category.dart` | Add layoutConfig field |
| `packages/quiz_engine/lib/quiz_engine.dart` | Export new widgets |
| `apps/flagsquiz/lib/data/flags_categories.dart` | Add reverse categories |
| `apps/flagsquiz/lib/data/flags_data_provider.dart` | Handle layout config |
| `apps/flagsquiz/lib/l10n/intl_en.arb` | Add localization strings |
| `packages/quiz_engine/lib/src/l10n/arb/quiz_engine_en.arb` | Add localization strings |

---

## Summary

This requirements document provides a complete roadmap for implementing image answer options in the quiz engine. The solution:

1. **Introduces a flexible layout system** via `QuizLayoutConfig` sealed class
2. **Creates new UI components** for rendering image-based answer options
3. **Maintains full backward compatibility** with existing quizzes
4. **Allows per-category configuration** of question/answer display types
5. **Follows established patterns** in the codebase (sealed classes, factory methods, theming)
6. **Provides comprehensive testing requirements** for each component

The implementation is divided into 6 sprints, with clear dependencies and checkpoints, making it actionable for AI agents to build incrementally.
