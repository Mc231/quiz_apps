# New Quiz App Creation Guide

**Quick reference for creating a new quiz app in the monorepo**

This guide shows you exactly what code goes where when creating a new quiz app.

---

## Step 1: Generate App Structure

Use the generator script:

```bash
cd tools
./create_quiz_app.sh "Capitals Quiz" "capitals_quiz" "com.yourcompany.capitalsquiz"
cd ..
melos bootstrap
```

---

## Step 2: Define Domain Models

**File:** `apps/capitals_quiz/lib/models/capital.dart`

```dart
class Capital {
  final String countryName;
  final String capitalName;
  final String countryCode;
  final String flagPath;
  final String continent;

  const Capital({
    required this.countryName,
    required this.capitalName,
    required this.countryCode,
    required this.flagPath,
    required this.continent,
  });

  // JSON deserialization
  factory Capital.fromJson(Map<String, dynamic> json) {
    return Capital(
      countryName: json['country'] as String,
      capitalName: json['capital'] as String,
      countryCode: json['code'] as String,
      flagPath: json['flag'] as String,
      continent: json['continent'] as String,
    );
  }

  // Convert to QuestionEntry (from quiz_engine_core)
  QuestionEntry toQuestionEntry() {
    return QuestionEntry(
      questionType: ImageQuestion(imagePath: flagPath),
      otherOptions: {
        'id': countryCode,
        'name': capitalName, // This is what will be shown as answer text
        'country': countryName,
        'continent': continent,
        'correctAnswer': capitalName,
      },
    );
  }
}
```

---

## Step 3: Create Data File

**File:** `apps/capitals_quiz/assets/capitals.json`

```json
[
  {
    "country": "France",
    "capital": "Paris",
    "code": "FR",
    "flag": "assets/images/france.png",
    "continent": "Europe"
  },
  {
    "country": "Japan",
    "capital": "Tokyo",
    "code": "JP",
    "flag": "assets/images/japan.png",
    "continent": "Asia"
  }
]
```

**Update:** `apps/capitals_quiz/pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/capitals.json
    - assets/images/
```

---

## Step 4: Create Home Screen

**File:** `apps/capitals_quiz/lib/ui/home/home_screen.dart`

```dart
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import '../category_selection/category_selection_screen.dart';

class CapitalsQuizHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capitals Quiz'),
      ),
      body: Column(
        children: [
          // Optional: Stats overview (reusable component)
          FutureBuilder<OverallStatistics>(
            future: _loadStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();

              return StatsOverviewCard(
                quizzesCompleted: snapshot.data!.totalQuizzesCompleted,
                averageAccuracy: snapshot.data!.overallAccuracy,
                currentStreak: snapshot.data!.currentStreak,
              );
            },
          ),

          // Play button
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () => _navigateToCategorySelection(context),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Play',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),

          // Bottom navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _showAchievements(context),
                icon: Icon(Icons.emoji_events),
                label: Text('Achievements'),
              ),
              TextButton.icon(
                onPressed: () => _showStatistics(context),
                icon: Icon(Icons.bar_chart),
                label: Text('Stats'),
              ),
              TextButton.icon(
                onPressed: () => _showSettings(context),
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToCategorySelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategorySelectionScreen(),
      ),
    );
  }

  Future<OverallStatistics> _loadStatistics() async {
    // Load from your statistics repository
    return AppDependencies.statisticsRepository.getOverallStatistics();
  }

  void _showAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(
          achievements: AppDependencies.achievements,
          repository: AppDependencies.achievementRepository,
        ),
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(
          repository: AppDependencies.statisticsRepository,
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(),
      ),
    );
  }
}
```

---

## Step 5: Create Category Selection Screen

**File:** `apps/capitals_quiz/lib/ui/category_selection/category_selection_screen.dart`

```dart
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import '../../models/capital.dart';
import '../../services/app_dependencies.dart';

enum Continent { all, europe, asia, africa, northAmerica, southAmerica, oceania }

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Region')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          _buildCategoryCard(context, Continent.all, 'All Capitals'),
          _buildCategoryCard(context, Continent.europe, 'Europe'),
          _buildCategoryCard(context, Continent.asia, 'Asia'),
          _buildCategoryCard(context, Continent.africa, 'Africa'),
          _buildCategoryCard(context, Continent.northAmerica, 'North America'),
          _buildCategoryCard(context, Continent.southAmerica, 'South America'),
          _buildCategoryCard(context, Continent.oceania, 'Oceania'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Continent continent,
    String title,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _startQuiz(context, continent),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, Continent continent) {
    // Create quiz configuration
    final config = QuizConfig(
      quizId: 'capitals_${continent.name}',

      // Choose mode (or let user select)
      modeConfig: QuizModeConfig.standard(),
      // OR: QuizModeConfig.timed(timePerQuestion: 30),
      // OR: QuizModeConfig.lives(lives: 3),

      // Scoring
      scoringStrategy: SimpleScoring(),

      // UI preferences
      showAnswerFeedback: true,
      answerFeedbackDuration: 1500,
      playSounds: true,
      hapticFeedback: true,

      // Hints
      hintConfig: HintConfig(
        initialHints: {
          HintType.fiftyFifty: 3,
          HintType.skip: 2,
          HintType.revealLetter: 3,
        },
      ),

      // Services (injected from app dependencies)
      statisticsRepository: AppDependencies.statisticsRepository,
      achievementRepository: AppDependencies.achievementRepository,
      analyticsService: AppDependencies.analyticsService,
      adsService: AppDependencies.adsService,
    );

    // Create theme (or use default)
    final themeData = QuizThemeData(
      buttonColor: Theme.of(context).primaryColor,
      buttonTextColor: Colors.white,
      correctAnswerColor: Colors.green,
      incorrectAnswerColor: Colors.red,
      // ... customize as needed
    );

    // Navigate to quiz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizWidget(
          config: config,
          themeData: themeData,
          dataProvider: () => _loadCapitals(continent),
        ),
      ),
    );
  }

  Future<List<QuestionEntry>> _loadCapitals(Continent continent) async {
    // Load data from JSON
    final provider = QuizDataProvider<Capital>.standard(
      'assets/capitals.json',
      Capital.fromJson,
    );

    var capitals = await provider.provide();

    // Filter by continent
    if (continent != Continent.all) {
      capitals = capitals
          .where((c) => c.continent.toLowerCase() == continent.name)
          .toList();
    }

    // Convert to QuestionEntry
    return capitals.map((c) => c.toQuestionEntry()).toList();
  }
}
```

---

## Step 6: Setup App Dependencies

**File:** `apps/capitals_quiz/lib/services/app_dependencies.dart`

```dart
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';
import 'statistics_repository_impl.dart';
import 'achievement_repository_impl.dart';
import '../models/achievements.dart';

class AppDependencies {
  static late StatisticsRepository statisticsRepository;
  static late AchievementRepository achievementRepository;
  static late AnalyticsService analyticsService;
  static late AdsService adsService;
  static late IAPService iapService;
  static late List<Achievement> achievements;

  static Future<void> initialize() async {
    // Initialize persistence
    await Hive.initFlutter();

    // Create repositories
    statisticsRepository = StatisticsRepositoryImpl();
    achievementRepository = AchievementRepositoryImpl();

    // Initialize services
    analyticsService = FirebaseAnalyticsService();
    await analyticsService.initialize();

    adsService = AdMobService();
    await adsService.initialize('ca-app-pub-YOUR-APP-ID');

    iapService = StoreIAPService();
    await iapService.initialize();

    // Load achievements
    achievements = CapitalsQuizAchievements.all;

    // Initialize audio
    await AudioService.instance.initialize();
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}
```

---

## Step 7: Implement Repositories

**File:** `apps/capitals_quiz/lib/services/statistics_repository_impl.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  static const String _boxName = 'statistics';
  late Box<Map<dynamic, dynamic>> _box;

  StatisticsRepositoryImpl() {
    _box = Hive.box(_boxName);
  }

  @override
  Future<void> saveResults(QuizResults results) async {
    final key = '${results.quizId}_${results.completedAt.toIso8601String()}';
    await _box.put(key, results.toJson());
  }

  @override
  Future<List<QuizResults>> getResultsForQuiz(String quizId) async {
    final allResults = <QuizResults>[];

    for (final key in _box.keys) {
      if (key.toString().startsWith(quizId)) {
        final json = _box.get(key) as Map<dynamic, dynamic>;
        allResults.add(QuizResults.fromJson(Map<String, dynamic>.from(json)));
      }
    }

    return allResults..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<QuizResults?> getBestScore(String quizId) async {
    final results = await getResultsForQuiz(quizId);
    if (results.isEmpty) return null;

    return results.reduce((a, b) => a.score > b.score ? a : b);
  }

  @override
  Future<OverallStatistics> getOverallStatistics() async {
    // Aggregate all quiz results
    final allResults = <QuizResults>[];

    for (final key in _box.keys) {
      final json = _box.get(key) as Map<dynamic, dynamic>;
      allResults.add(QuizResults.fromJson(Map<String, dynamic>.from(json)));
    }

    return OverallStatistics(
      totalQuizzesCompleted: allResults.length,
      totalQuestionsAnswered: allResults.fold(0, (sum, r) => sum + r.totalQuestions),
      totalCorrectAnswers: allResults.fold(0, (sum, r) => sum + r.correctAnswers),
      totalTimePlayed: allResults.fold(
        Duration.zero,
        (sum, r) => sum + r.timeTaken,
      ),
      currentStreak: _calculateStreak(allResults),
      longestStreak: _calculateLongestStreak(allResults),
      lastPlayedDate: allResults.isNotEmpty
          ? allResults.map((r) => r.completedAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );
  }

  int _calculateStreak(List<QuizResults> results) {
    // Implementation for calculating current streak
    // ...
    return 0;
  }

  int _calculateLongestStreak(List<QuizResults> results) {
    // Implementation for calculating longest streak
    // ...
    return 0;
  }

  @override
  Future<QuizStatistics> getQuizStatistics(String quizId) async {
    final results = await getResultsForQuiz(quizId);

    if (results.isEmpty) {
      return QuizStatistics(
        quizId: quizId,
        timesPlayed: 0,
        averageAccuracy: 0,
        bestScore: 0,
        perfectScores: 0,
        averageTime: Duration.zero,
        lastPlayed: null,
        frequentMistakes: [],
      );
    }

    return QuizStatistics(
      quizId: quizId,
      timesPlayed: results.length,
      averageAccuracy: results.fold(0.0, (sum, r) => sum + r.accuracyPercentage) / results.length,
      bestScore: results.map((r) => r.score).reduce((a, b) => a > b ? a : b),
      perfectScores: results.where((r) => r.isPerfectScore).length,
      averageTime: Duration(
        seconds: results.fold(0, (sum, r) => sum + r.timeTaken.inSeconds) ~/ results.length,
      ),
      lastPlayed: results.map((r) => r.completedAt).reduce((a, b) => a.isAfter(b) ? a : b),
      frequentMistakes: _analyzeFrequentMistakes(results),
    );
  }

  List<WrongAnswer> _analyzeFrequentMistakes(List<QuizResults> results) {
    // Aggregate all wrong answers and find most common
    // ...
    return [];
  }
}
```

---

## Step 8: Define Achievements

**File:** `apps/capitals_quiz/lib/models/achievements.dart`

```dart
import 'package:quiz_engine_core/quiz_engine_core.dart';

class CapitalsQuizAchievements {
  static final all = [
    // Perfect score achievements
    Achievement(
      id: 'perfect_first',
      title: 'Perfect Start',
      description: 'Get 100% on your first quiz',
      iconAsset: 'assets/achievements/perfect_first.png',
      trigger: PerfectScoreTrigger(),
    ),

    Achievement(
      id: 'perfect_europe',
      title: 'European Expert',
      description: 'Get 100% on European capitals',
      iconAsset: 'assets/achievements/perfect_europe.png',
      trigger: PerfectScoreTrigger(quizId: 'capitals_europe'),
    ),

    Achievement(
      id: 'perfect_asia',
      title: 'Asian Master',
      description: 'Get 100% on Asian capitals',
      iconAsset: 'assets/achievements/perfect_asia.png',
      trigger: PerfectScoreTrigger(quizId: 'capitals_asia'),
    ),

    // Quiz count achievements
    Achievement(
      id: 'quiz_count_10',
      title: 'Getting Started',
      description: 'Complete 10 quizzes',
      iconAsset: 'assets/achievements/quiz_10.png',
      trigger: QuizCountTrigger(count: 10),
      reward: AchievementReward(
        hints: {HintType.fiftyFifty: 2},
      ),
    ),

    Achievement(
      id: 'quiz_count_50',
      title: 'Dedicated Learner',
      description: 'Complete 50 quizzes',
      iconAsset: 'assets/achievements/quiz_50.png',
      trigger: QuizCountTrigger(count: 50),
      reward: AchievementReward(
        hints: {
          HintType.fiftyFifty: 3,
          HintType.skip: 2,
        },
      ),
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Three Day Streak',
      description: 'Play for 3 consecutive days',
      iconAsset: 'assets/achievements/streak_3.png',
      trigger: StreakTrigger(days: 3),
    ),

    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Play for 7 consecutive days',
      iconAsset: 'assets/achievements/streak_7.png',
      trigger: StreakTrigger(days: 7),
      reward: AchievementReward(
        hints: {HintType.revealLetter: 5},
      ),
    ),

    // Category mastery
    Achievement(
      id: 'europe_master',
      title: 'European Geography Master',
      description: 'Maintain 90% accuracy on European capitals',
      iconAsset: 'assets/achievements/europe_master.png',
      trigger: CategoryMasteryTrigger(
        category: 'capitals_europe',
        accuracyThreshold: 0.90,
      ),
    ),
  ];
}
```

---

## Step 9: Setup Main App

**File:** `apps/capitals_quiz/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'services/app_dependencies.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app dependencies
  await AppDependencies.initialize();

  runApp(CapitalsQuizApp());
}

class CapitalsQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capitals Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: CapitalsQuizHomeScreen(),
    );
  }
}
```

---

## Step 10: Configure Platform-Specific Settings

### Android

**File:** `apps/capitals_quiz/android/app/src/main/AndroidManifest.xml`

Add AdMob app ID:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-YOUR-ANDROID-APP-ID"/>
    </application>
</manifest>
```

### iOS

**File:** `apps/capitals_quiz/ios/Runner/Info.plist`

Add AdMob app ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR-IOS-APP-ID</string>
```

---

## Summary: File Checklist

### App-Specific Files (You Create These)

- [ ] `lib/models/{domain_model}.dart` - Your domain model
- [ ] `lib/ui/home/home_screen.dart` - Home screen
- [ ] `lib/ui/category_selection/category_selection_screen.dart` - Category picker
- [ ] `lib/services/app_dependencies.dart` - Dependency injection setup
- [ ] `lib/services/statistics_repository_impl.dart` - Statistics storage
- [ ] `lib/services/achievement_repository_impl.dart` - Achievement storage
- [ ] `lib/models/achievements.dart` - App-specific achievements
- [ ] `assets/{data}.json` - Quiz data
- [ ] `assets/images/` - Images (flags, icons, etc.)

### Reusable from Core (You Don't Create These)

- [ ] `QuizWidget` - Main quiz screen (from quiz_engine)
- [ ] `QuizBloc` - Quiz logic (from quiz_engine_core)
- [ ] `QuizConfig` - Configuration model (from quiz_engine_core)
- [ ] `QuizThemeData` - Theme model (from quiz_engine)
- [ ] `StatisticsScreen` - Stats display (from quiz_engine)
- [ ] `AchievementsScreen` - Achievements display (from quiz_engine)
- [ ] All service interfaces - From shared_services

---

## Common Patterns

### Pattern 1: Different Question Types

**Image Question (flags, logos, landmarks):**
```dart
QuestionEntry(
  questionType: ImageQuestion(imagePath: 'assets/images/france.png'),
  otherOptions: {'name': 'France'},
)
```

**Text Question (trivia, definitions):**
```dart
QuestionEntry(
  questionType: TextQuestion(text: 'What is the capital of France?'),
  otherOptions: {'name': 'Paris'},
)
```

**Audio Question (songs, sounds):**
```dart
QuestionEntry(
  questionType: AudioQuestion(audioPath: 'assets/audio/dog_bark.mp3'),
  otherOptions: {'name': 'Dog'},
)
```

**Video Question (movie clips):**
```dart
QuestionEntry(
  questionType: VideoQuestion(
    videoUrl: 'https://example.com/clip.mp4',
    thumbnailPath: 'assets/thumbnails/clip.jpg',
  ),
  otherOptions: {'name': 'Movie Title'},
)
```

### Pattern 2: Different Quiz Modes

**Standard Mode:**
```dart
final config = QuizConfig(
  quizId: 'my_quiz',
  modeConfig: QuizModeConfig.standard(),
);
```

**Timed Challenge:**
```dart
final config = QuizConfig(
  quizId: 'my_quiz_timed',
  modeConfig: QuizModeConfig.timed(
    timePerQuestion: 30,
  ),
);
```

**Lives Mode:**
```dart
final config = QuizConfig(
  quizId: 'my_quiz_lives',
  modeConfig: QuizModeConfig.lives(
    lives: 3,
  ),
);
```

**Survival (Timed + Lives):**
```dart
final config = QuizConfig(
  quizId: 'my_quiz_survival',
  modeConfig: QuizModeConfig.survival(
    lives: 3,
    timePerQuestion: 20,
  ),
);
```

### Pattern 3: Mode Selection Screen

```dart
class ModeSelectionScreen extends StatelessWidget {
  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Mode')),
      body: ListView(
        children: [
          _buildModeCard(
            context,
            'Standard',
            'Take your time, no pressure',
            QuizModeConfig.standard(),
          ),
          _buildModeCard(
            context,
            'Timed',
            '30 seconds per question',
            QuizModeConfig.timed(timePerQuestion: 30),
          ),
          _buildModeCard(
            context,
            'Lives',
            '3 lives, lose one per mistake',
            QuizModeConfig.lives(lives: 3),
          ),
          _buildModeCard(
            context,
            'Survival',
            'Timed mode with lives',
            QuizModeConfig.survival(lives: 3, timePerQuestion: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    String description,
    QuizModeConfig modeConfig,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        onTap: () => _startQuiz(context, modeConfig),
      ),
    );
  }

  void _startQuiz(BuildContext context, QuizModeConfig modeConfig) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizWidget(
          config: QuizConfig(
            quizId: 'quiz_$category',
            modeConfig: modeConfig,
            // ... other config
          ),
          dataProvider: () => _loadData(),
        ),
      ),
    );
  }
}
```

---

## Estimated Time to Create New App

With this architecture:

1. **Setup (10 minutes):**
   - Run generator script
   - Configure package dependencies

2. **Domain Model (15 minutes):**
   - Create model class
   - Add `fromJson` and `toQuestionEntry`

3. **Data (30 minutes):**
   - Create/gather JSON data
   - Add assets to pubspec.yaml

4. **UI Screens (1-2 hours):**
   - Home screen
   - Category selection
   - Settings screen (optional)

5. **Dependencies (30 minutes):**
   - Setup app dependencies
   - Implement repositories
   - Define achievements

6. **Testing (1 hour):**
   - Test all modes
   - Test hints
   - Test statistics

**Total: 3-4 hours for a complete quiz app!**

---

## Next App Ideas

Using this architecture, you can create:

1. **Capitals Quiz** (this example)
2. **Landmarks Quiz** (image questions)
3. **Animal Sounds Quiz** (audio questions)
4. **Movie Clips Quiz** (video questions)
5. **Logo Quiz** (image questions)
6. **Math Facts Quiz** (text questions, programmatically generated)
7. **Language Learning Quiz** (audio questions)

All using the same core packages with minimal app-specific code!