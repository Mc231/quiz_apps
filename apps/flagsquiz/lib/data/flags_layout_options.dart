import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../l10n/app_localizations.dart';

/// Creates layout mode options for the Flags Quiz challenges.
///
/// Returns a list of [LayoutModeOption] that users can choose from
/// when starting a challenge. Each option defines how questions and
/// answers are displayed.
///
/// Available modes:
/// - **Standard**: Show flag image as question, country names as answers
/// - **Reverse**: Show country name as question, flag images as answers
/// - **Mixed**: Randomly alternate between standard and reverse
///
/// Example:
/// ```dart
/// final options = createFlagsLayoutOptions(context);
/// ```
List<LayoutModeOption> createFlagsLayoutOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
    LayoutModeOption(
      id: 'standard',
      icon: Icons.image_outlined,
      label: l10n.layoutModeStandard,
      shortLabel: l10n.layoutModeStandardShort,
      description: l10n.layoutModeStandardDesc,
      layoutConfig: const ImageQuestionTextAnswersLayout(),
    ),
    LayoutModeOption(
      id: 'reverse',
      icon: Icons.text_fields,
      label: l10n.layoutModeReverse,
      shortLabel: l10n.layoutModeReverseShort,
      description: l10n.layoutModeReverseDesc,
      layoutConfig: TextQuestionImageAnswersLayout(
        questionTemplate: l10n.whichFlagIs('{name}'),
      ),
    ),
    LayoutModeOption(
      id: 'mixed',
      icon: Icons.shuffle,
      label: l10n.layoutModeMixed,
      shortLabel: l10n.layoutModeMixedShort,
      description: l10n.layoutModeMixedDesc,
      layoutConfig: MixedLayout(
        layouts: [
          const ImageQuestionTextAnswersLayout(),
          TextQuestionImageAnswersLayout(
            questionTemplate: l10n.whichFlagIs('{name}'),
          ),
        ],
      ),
    ),
  ];
}
