import 'package:flutter/widgets.dart';

import 'generated/quiz_engine_localizations.dart';
import 'generated/quiz_engine_localizations_en.dart';

// Re-export generated localizations for convenience
export 'generated/quiz_engine_localizations.dart';
export 'generated/quiz_engine_localizations_en.dart';

/// Type alias for backward compatibility.
///
/// [QuizLocalizations] is now an alias for [QuizEngineLocalizations],
/// which is generated from ARB files.
typedef QuizLocalizations = QuizEngineLocalizations;

/// Backward-compatible alias for English localizations.
typedef QuizLocalizationsEn = QuizEngineLocalizationsEn;

/// Helper class providing convenient access to quiz localizations.
///
/// This class provides a static [of] method that returns a non-nullable
/// localization instance, with fallback to English defaults.
///
/// Usage:
/// ```dart
/// final l10n = QuizL10n.of(context);
/// Text(l10n.play);
/// ```
class QuizL10n {
  QuizL10n._();

  /// Retrieves the [QuizLocalizations] for the given [context].
  ///
  /// Returns the localization provided by the delegate in the widget tree,
  /// or falls back to English defaults if not found.
  static QuizEngineLocalizations of(BuildContext context) {
    return QuizEngineLocalizations.of(context) ?? QuizEngineLocalizationsEn();
  }
}
