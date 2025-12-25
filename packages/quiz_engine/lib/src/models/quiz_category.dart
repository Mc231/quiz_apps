import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// A function that returns a localized string given a BuildContext.
///
/// Used to provide localized titles and subtitles for quiz categories
/// that are resolved at build time when the context is available.
///
/// Example:
/// ```dart
/// LocalizedString title = (context) => AppLocalizations.of(context)!.europe;
/// ```
typedef LocalizedString = String Function(BuildContext context);

/// Represents a quiz category that can be displayed in the play screen.
///
/// A category contains display information (title, subtitle, icon/image)
/// and optional configuration overrides for quizzes in this category.
///
/// Example:
/// ```dart
/// final europeCategory = QuizCategory(
///   id: 'europe',
///   title: (context) => AppLocalizations.of(context)!.europe,
///   subtitle: (context) => '${countries.length} countries',
///   icon: Icons.flag,
///   config: QuizConfig(quizId: 'flags_europe'),
/// );
/// ```
class QuizCategory {
  /// Unique identifier for this category.
  ///
  /// Used for storage, analytics, and identification.
  /// Should be stable across app versions.
  final String id;

  /// Localized title for the category.
  ///
  /// Resolved at build time when BuildContext is available.
  final LocalizedString title;

  /// Optional localized subtitle for the category.
  ///
  /// Can show additional info like item count or description.
  final LocalizedString? subtitle;

  /// Optional image provider for the category.
  ///
  /// Used to display a category image (e.g., flag, map, icon).
  /// Either [imageProvider] or [icon] should be provided.
  final ImageProvider? imageProvider;

  /// Optional icon for the category.
  ///
  /// Used when no image is available.
  /// Either [imageProvider] or [icon] should be provided.
  final IconData? icon;

  /// Optional configuration overrides for quizzes in this category.
  ///
  /// If not provided, default quiz configuration will be used.
  final QuizConfig? config;

  /// Optional metadata for the category.
  ///
  /// Can store additional app-specific data.
  final Map<String, dynamic>? metadata;

  /// Whether to show answer feedback for quizzes in this category.
  ///
  /// If null, uses the global default from UIBehaviorConfig.
  /// Can be overridden by mode-specific settings.
  final bool? showAnswerFeedback;

  /// Creates a [QuizCategory].
  ///
  /// [id] and [title] are required.
  /// Either [imageProvider] or [icon] should typically be provided.
  const QuizCategory({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageProvider,
    this.icon,
    this.config,
    this.metadata,
    this.showAnswerFeedback,
  });

  /// Creates a copy of this category with the given fields replaced.
  QuizCategory copyWith({
    String? id,
    LocalizedString? title,
    LocalizedString? subtitle,
    ImageProvider? imageProvider,
    IconData? icon,
    QuizConfig? config,
    Map<String, dynamic>? metadata,
    bool? showAnswerFeedback,
  }) {
    return QuizCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageProvider: imageProvider ?? this.imageProvider,
      icon: icon ?? this.icon,
      config: config ?? this.config,
      metadata: metadata ?? this.metadata,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QuizCategory(id: $id)';
}
