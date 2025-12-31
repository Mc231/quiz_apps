import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../components/image_option_button.dart';
import '../extensions/sizing_information_extension.dart';
import '../theme/quiz_theme_data.dart';

/// A widget that displays image-based answer options in a grid layout.
///
/// The `QuizImageAnswersWidget` presents answer options as images
/// arranged in a responsive grid (typically 2x2 for 4 options).
/// Supports disabled options for 50/50 hints and theme customization.
///
/// Example:
/// ```dart
/// QuizImageAnswersWidget(
///   key: Key('image_answers'),
///   options: [option1, option2, option3, option4],
///   sizingInformation: sizingInfo,
///   answerClickListener: (answer) => handleAnswer(answer),
///   imageSize: const MediumImageSize(),
/// )
/// ```
class QuizImageAnswersWidget extends StatelessWidget {
  /// The list of answer options to display.
  final List<QuestionEntry> options;

  /// The sizing information for responsive layout.
  final SizingInformation sizingInformation;

  /// Callback when an answer option is selected.
  final Function(QuestionEntry answer) answerClickListener;

  /// Set of disabled options (e.g., from 50/50 hint).
  final Set<QuestionEntry> disabledOptions;

  /// Size configuration for answer images.
  final ImageAnswerSize imageSize;

  /// Theme data for customizing appearance.
  final QuizThemeData themeData;

  /// Function to get the semantic label for an option.
  /// If null, defaults to using otherOptions["name"] or "id".
  final String Function(QuestionEntry option)? semanticLabelBuilder;

  /// Creates a `QuizImageAnswersWidget`.
  ///
  /// [options] is the list of answer options to display.
  /// [sizingInformation] provides screen size and orientation info.
  /// [answerClickListener] is called when an option is selected.
  /// [disabledOptions] specifies which options should be disabled.
  /// [imageSize] controls the image dimensions.
  /// [themeData] provides theme customization.
  /// [semanticLabelBuilder] optionally provides custom semantic labels.
  const QuizImageAnswersWidget({
    required Key super.key,
    required this.options,
    required this.sizingInformation,
    required this.answerClickListener,
    this.disabledOptions = const {},
    this.imageSize = const MediumImageSize(),
    this.themeData = const QuizThemeData(),
    this.semanticLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    final spacing = imageSize.spacing;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount: options.length,
      itemBuilder: (context, index) => _buildImageOption(
        context,
        options[index],
      ),
    );
  }

  /// Builds an image option button for the given option.
  Widget _buildImageOption(BuildContext context, QuestionEntry option) {
    final isDisabled = disabledOptions.contains(option);
    final imageSource = _getImageSource(option);
    final semanticLabel = _getSemanticLabel(option);

    return ImageOptionButton(
      key: Key('image_option_${_getOptionId(option)}'),
      imageSource: imageSource,
      semanticLabel: semanticLabel,
      onTap: isDisabled ? null : () => answerClickListener(option),
      isDisabled: isDisabled,
      imageSize: imageSize,
      themeData: themeData,
    );
  }

  /// Gets the image source from the question entry.
  ImageSource _getImageSource(QuestionEntry option) {
    final type = option.type;

    if (type is ImageQuestion) {
      final path = type.imagePath;
      // Determine if it's a network URL or asset path
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return ImageSource.network(path);
      }
      return ImageSource.asset(path);
    }

    // For non-image types, check otherOptions for an image path
    final imagePath = option.otherOptions['imagePath'] as String?;
    if (imagePath != null) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return ImageSource.network(imagePath);
      }
      return ImageSource.asset(imagePath);
    }

    // Fallback: return a placeholder
    return const ImageSource.asset('assets/placeholder.png');
  }

  /// Gets the semantic label for accessibility.
  String _getSemanticLabel(QuestionEntry option) {
    if (semanticLabelBuilder != null) {
      return semanticLabelBuilder!(option);
    }

    // Try to get name from otherOptions
    final name = option.otherOptions['name'] as String?;
    if (name != null) return name;

    // Fallback to ID
    final id = option.otherOptions['id'] as String?;
    return id ?? 'Answer option';
  }

  /// Gets a unique identifier for the option.
  String _getOptionId(QuestionEntry option) {
    final id = option.otherOptions['id'] as String?;
    return id?.toLowerCase() ?? option.hashCode.toString();
  }

  /// Determines the number of columns based on screen size and option count.
  int _getCrossAxisCount(BuildContext context) {
    final optionCount = options.length;

    // For 2 or fewer options, use single column on small screens
    if (optionCount <= 2) {
      return getValueForScreenType(
        context: context,
        mobile: sizingInformation.orientation == Orientation.portrait ? 2 : 2,
        tablet: 2,
        desktop: 2,
        watch: 1,
      );
    }

    // For 3-4 options, use 2x2 grid
    if (optionCount <= 4) {
      return getValueForScreenType(
        context: context,
        mobile: 2,
        tablet: 2,
        desktop: 2,
        watch: 2,
      );
    }

    // For more options, use 3 columns on larger screens
    return getValueForScreenType(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 3,
      watch: 2,
    );
  }

  /// Gets the aspect ratio for grid children.
  double _getChildAspectRatio(BuildContext context) {
    // Default to square aspect ratio, or use custom if specified
    final aspectRatio = imageSize.aspectRatio;
    if (aspectRatio != null) {
      return aspectRatio;
    }

    // Default to slightly taller than square for better image display
    return getValueForScreenType(
      context: context,
      mobile: 1.0,
      tablet: 1.0,
      desktop: 1.0,
      watch: 0.9,
    );
  }
}

