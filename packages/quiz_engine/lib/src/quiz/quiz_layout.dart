import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_engine/src/extensions/sizing_information_extension.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'quiz_answers_widget.dart';
import 'quiz_image_answers_widget.dart';
import 'quiz_image_widget.dart';
import 'quiz_text_widget.dart';
import 'quiz_audio_widget.dart';
import 'quiz_video_widget.dart';
import '../theme/quiz_theme_data.dart';
import '../widgets/adaptive_resource_panel.dart';
import '../widgets/game_resource_panel.dart';

/// A widget that displays the layout for a quiz screen, including the question and answer options.
///
/// The `QuizLayout` class is a stateless widget that presents the UI components for a quiz question,
/// adapting to different layout configurations. The layout adapts to the screen orientation
/// (portrait or landscape) using responsive design principles, and displays a progress indicator
/// at the bottom of the screen.
///
/// Layout configurations supported:
/// - [ImageQuestionTextAnswersLayout]: Shows image as question, text as answers (default)
/// - [TextQuestionImageAnswersLayout]: Shows text as question, images as answers
/// - [TextQuestionTextAnswersLayout]: Shows text as question, text as answers
/// - [AudioQuestionTextAnswersLayout]: Shows audio player as question, text as answers
///
/// Properties:
/// - `questionState`: The current state of the question, including the question details and progress.
/// - `information`: The sizing information for the current screen, used to adjust the layout.
/// - `processAnswer`: The callback function to process an answer when an option is selected.
/// - `resourceData`: Game resource panel data (lives, 50/50, skip) for adaptive display.
/// - `layoutConfig`: The resolved layout configuration for the current question.
class QuizLayout extends StatelessWidget {
  /// The current state of the question, including the question details and progress.
  final QuestionState questionState;

  /// The sizing information for the current screen, used to adjust the layout.
  final SizingInformation information;

  /// The callback function to process an answer when an option is selected.
  final Function(QuestionEntry) processAnswer;

  /// Game resource panel data (lives, 50/50, skip).
  /// If null, resources are not shown.
  final GameResourcePanelData? resourceData;

  /// Theme data for customizing quiz UI.
  final QuizThemeData themeData;

  /// The resolved layout configuration for the current question.
  ///
  /// This should be a concrete layout (not [MixedLayout]).
  /// Defaults to [ImageQuestionTextAnswersLayout] if null.
  final QuizLayoutConfig? layoutConfig;

  /// Creates a `QuizLayout` with the specified question state, sizing information, and answer processor.
  ///
  /// [key] is the unique key for this widget.
  /// [questionState] provides the current question and progress state.
  /// [information] supplies screen size and orientation information.
  /// [processAnswer] is called to process the selected answer.
  /// [resourceData] provides game resource data (lives, hints) for adaptive display.
  /// [themeData] provides theme customization options.
  /// [layoutConfig] specifies the layout configuration (defaults to image question with text answers).
  const QuizLayout({
    super.key,
    required this.questionState,
    required this.information,
    required this.processAnswer,
    this.resourceData,
    this.themeData = const QuizThemeData(),
    this.layoutConfig,
  });

  /// Gets the effective layout configuration.
  ///
  /// Returns [layoutConfig] if provided, otherwise defaults to [ImageQuestionTextAnswersLayout].
  QuizLayoutConfig get _effectiveLayout =>
      layoutConfig ?? const ImageQuestionTextAnswersLayout();

  @override
  Widget build(BuildContext context) {
    final orientation = information.orientation;
    return Column(
      children: [
        // Game Resource Panel (adaptive - shows only on portrait/watch)
        if (resourceData != null && resourceData!.hasResources)
          AdaptiveResourcePanel.forBody(
            data: resourceData!,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        if (orientation == Orientation.portrait)
          Expanded(
            child: Column(
              children: _imageAndButtons(questionState, information),
            ),
          ),
        if (orientation == Orientation.landscape)
          Expanded(
            child: Row(children: _imageAndButtons(questionState, information)),
          ),
        _progressColumn(context, information, questionState),
      ],
    );
  }

  /// Generates a list of widgets for the question content and answer buttons based on the screen orientation.
  ///
  /// This method creates the layout for the question content and answer buttons,
  /// adjusting their arrangement based on the orientation of the screen and the layout configuration.
  ///
  /// [state] is the current question state.
  /// [information] provides sizing details for the screen.
  ///
  /// Returns a list of `Widget` representing the question content and answer buttons.
  List<Widget> _imageAndButtons(
    QuestionState state,
    SizingInformation information,
  ) {
    final answer = state.question.answer;
    final code = answer.otherOptions["id"] as String;
    final questionSize = getImageSize(information);
    final isLandscape = information.orientation == Orientation.landscape;

    final questionWidget = _buildQuestionWidgetForLayout(
      state.question,
      code,
      questionSize,
    );
    final answersWidget = _buildAnswersWidget(state);

    return [
      if (isLandscape)
        Flexible(
          flex: 1,
          child: questionWidget,
        )
      else
        questionWidget,
      SizedBox(width: themeData.questionAnswerSpacing),
      Expanded(
        flex: isLandscape ? 2 : 1,
        child: answersWidget,
      ),
    ];
  }

  /// Builds the question widget based on the layout configuration.
  ///
  /// For [TextQuestionImageAnswersLayout], shows text with optional template substitution.
  /// For other layouts, shows the appropriate media type based on the question entry.
  Widget _buildQuestionWidgetForLayout(
    Question question,
    String code,
    double size,
  ) {
    final layout = _effectiveLayout;
    final answer = question.answer;

    return switch (layout) {
      TextQuestionImageAnswersLayout(:final questionTemplate) =>
        _buildTextQuestion(question, code, size, questionTemplate),
      TextQuestionTextAnswersLayout() =>
        _buildTextQuestion(question, code, size, null),
      AudioQuestionTextAnswersLayout() =>
        _buildQuestionWidget(answer, code, size),
      ImageQuestionTextAnswersLayout() =>
        _buildQuestionWidget(answer, code, size),
      MixedLayout() =>
        // MixedLayout should be resolved before reaching here
        _buildQuestionWidget(answer, code, size),
    };
  }

  /// Builds a text question widget with optional template substitution.
  ///
  /// If [questionTemplate] is provided, replaces `{name}` with the answer's name.
  Widget _buildTextQuestion(
    Question question,
    String code,
    double size,
    String? questionTemplate,
  ) {
    final answer = question.answer;
    String questionText;

    if (questionTemplate != null) {
      // Substitute {name} placeholder with the correct answer's name
      final name = answer.otherOptions['name'] as String? ?? '';
      questionText = questionTemplate.replaceAll('{name}', name);
    } else {
      // Use the answer's name as the question text
      questionText = answer.otherOptions['name'] as String? ?? '';
    }

    return QuizTextWidget(
      key: Key(code),
      entry: answer,
      width: size,
      height: size,
      displayText: questionText,
    );
  }

  /// Builds the answers widget based on the layout configuration.
  ///
  /// For [TextQuestionImageAnswersLayout], shows image answer options.
  /// For other layouts, shows text answer options.
  Widget _buildAnswersWidget(QuestionState state) {
    final layout = _effectiveLayout;

    return switch (layout) {
      TextQuestionImageAnswersLayout(:final imageSize) =>
        QuizImageAnswersWidget(
          key: Key('image_answers_${state.progress}'),
          options: state.question.options,
          sizingInformation: information,
          answerClickListener: processAnswer,
          disabledOptions: state.disabledOptions,
          imageSize: imageSize,
          themeData: themeData,
        ),
      _ => QuizAnswersWidget(
        options: state.question.options,
        sizingInformation: information,
        answerClickListener: processAnswer,
        disabledOptions: state.disabledOptions,
        themeData: themeData,
        key: Key(state.total.toString()),
      ),
    };
  }

  /// Builds the appropriate widget for the question type.
  ///
  /// This method uses pattern matching to render the correct widget based on
  /// the question type (text, image, audio, or video).
  ///
  /// [entry] is the question entry containing the question data.
  /// [code] is the unique identifier for the question.
  /// [size] is the size constraint for the widget.
  ///
  /// Returns a `Widget` representing the question content.
  Widget _buildQuestionWidget(QuestionEntry entry, String code, double size) {
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

  /// Builds the progress display including the progress text and linear progress indicator.
  ///
  /// This method creates the layout for displaying the current progress of the quiz, showing
  /// the number of questions completed and a progress bar.
  ///
  /// [context] is the `BuildContext` for accessing theme and localization.
  /// [information] provides sizing details for the screen.
  /// [state] is the current question state.
  ///
  /// Returns a `Widget` representing the progress display.
  Widget _progressColumn(
    BuildContext context,
    SizingInformation information,
    QuestionState state,
  ) {
    return Column(
      children: [
        Text(
          '${state.progress} / ${state.total}',
          style: TextStyle(fontSize: progressFontSize(context)),
        ),
        SizedBox(height: progressMargin),
        LinearProgressIndicator(value: state.percentageProgress),
      ],
    );
  }
}

/// Extension on `QuizLayout` to provide responsive layout utilities.
extension QuizLayoutSized on QuizLayout {
  /// Returns the size for the question image based on the screen size and theme.
  ///
  /// This method calculates the image size using a coefficient from the theme
  /// based on whether the device is a watch or not, adjusting the size to fit
  /// the screen dimensions.
  ///
  /// [information] provides sizing details for the screen.
  ///
  /// Returns the size for the image as a `double`.
  double getImageSize(SizingInformation information) {
    final width = information.localWidgetSize.width;
    final height = information.localWidgetSize.height;
    final minSize = min(width, height);
    final cof =
        information.isWatch
            ? themeData.imageSizeCoefficientWatch
            : themeData.imageSizeCoefficientNormal;
    return minSize * cof;
  }

  /// Returns the font size for the progress text based on the screen size and theme.
  ///
  /// This method uses `getValueForScreenType` to adjust the font size for different
  /// device types, pulling values from the theme configuration.
  ///
  /// [context] is the `BuildContext` used to determine the screen size.
  ///
  /// Returns the font size for the progress text.
  double progressFontSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: themeData.progressFontSizeMobile,
      tablet: themeData.progressFontSizeTablet,
      desktop: themeData.progressFontSizeDesktop,
      watch: themeData.progressFontSizeWatch,
    );
  }

  /// The margin used between the progress text and the progress indicator.
  double get progressMargin {
    return themeData.progressIndicatorSpacing;
  }
}
