import 'package:quiz_engine/quiz_engine.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../data/flags_data_provider.dart';

/// Contains all dependencies needed to run the Flags Quiz app.
///
/// This class is internal to the app initialization process.
/// Use [FlagsQuizAppProvider.provideApp] instead of creating this directly.
class FlagsQuizDependencies {
  /// Creates [FlagsQuizDependencies]. Internal use only.
  const FlagsQuizDependencies({
    required this.services,
    required this.achievementsProvider,
    required this.dataProvider,
    required this.categories,
    required this.navigatorObserver,
  });

  /// All core services bundled together.
  final QuizServices services;

  /// Achievements data provider.
  final FlagsAchievementsDataProvider achievementsProvider;

  /// Data provider for loading quiz data.
  final FlagsDataProvider dataProvider;

  /// Quiz categories.
  final List<QuizCategory> categories;

  /// Navigator observer for automatic screen tracking.
  final AnalyticsNavigatorObserver navigatorObserver;
}
