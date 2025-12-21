# Quiz App Creation Template

## Quick Start Guide

### 1. Generate New App
```bash
cd scripts
./create_quiz_app.sh "Capital Quiz" "capital_quiz" "com.yourcompany.capitalquiz"
```

### 2. Create Your Domain Model

**Example: Capital Quiz**

```dart
// lib/models/capital.dart
import 'package:quiz_engine_core/quiz_engine_core.dart';

class Capital {
  final String countryName;
  final String capitalName;
  final String countryCode;
  final String region;

  String get flagImage => 'assets/images/$countryCode.png';

  Capital.fromJson(Map json)
      : countryName = json['country'] as String,
        capitalName = json['capital'] as String,
        countryCode = json['code'] as String,
        region = json['region'] as String;

  QuestionEntry get toQuestionEntry {
    return QuestionEntry(
      type: ImageQuestion(flagImage),  // Show flag
      otherOptions: {
        "id": countryCode,
        "name": capitalName,  // Answer options show capital names
        "correctAnswer": capitalName,
        "region": region,
      },
    );
  }
}
```

### 3. Create Data Provider

```dart
// lib/data/capitals_provider.dart
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:capital_quiz/models/capital.dart';

class CapitalsProvider {
  static Future<List<Capital>> loadCapitals() async {
    final jsonString = await rootBundle.loadString('assets/data/capitals.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Capital.fromJson(json)).toList();
  }

  static Future<List<Capital>> loadByRegion(String region) async {
    final capitals = await loadCapitals();
    return capitals.where((c) => c.region == region).toList();
  }
}
```

### 4. Create Data File

```json
// assets/data/capitals.json
[
  {
    "country": "France",
    "capital": "Paris",
    "code": "FR",
    "region": "Europe"
  },
  {
    "country": "Japan",
    "capital": "Tokyo",
    "code": "JP",
    "region": "Asia"
  }
  // ... more entries
]
```

### 5. Create Main Screen

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:capital_quiz/data/capitals_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const CapitalQuizApp());
}

class CapitalQuizApp extends StatelessWidget {
  const CapitalQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capital Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        // Add more locales
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capital Quiz')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startQuiz(context),
          child: const Text('Start Quiz'),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) async {
    final capitals = await CapitalsProvider.loadCapitals();
    final entries = capitals.map((c) => c.toQuestionEntry).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizWidget(
          entries: entries,
          title: 'Guess the Capital',
          gameOverTitle: 'Quiz Complete!',
        ),
      ),
    );
  }
}
```

## 🎯 Quick Reference: Question Types

### Image Question (Show image, guess from text options)
```dart
QuestionEntry(
  type: ImageQuestion('assets/images/flag.png'),
  otherOptions: {
    "id": "US",
    "name": "United States",  // Text shown in answer buttons
  },
)
```

### Text Question (Show text, guess from text options)
```dart
QuestionEntry(
  type: TextQuestion('What is the capital of France?'),
  otherOptions: {
    "id": "question_1",
    "name": "Paris",  // Answer options
  },
)
```

### Audio Question (Play audio, guess from text options)
```dart
QuestionEntry(
  type: AudioQuestion('assets/audio/dog_bark.mp3'),
  otherOptions: {
    "id": "dog",
    "name": "Dog",  // Answer options
  },
)
```

### Video Question (Show video, guess from text options)
```dart
QuestionEntry(
  type: VideoQuestion('assets/videos/landmark.mp4',
    thumbnailPath: 'assets/images/thumbnail.jpg'),
  otherOptions: {
    "id": "eiffel",
    "name": "Eiffel Tower",  // Answer options
  },
)
```

## 📁 Required Assets Structure

```
assets/
├── data/
│   └── your_data.json
├── images/
│   ├── item1.png
│   └── item2.png
├── audio/          # Optional
│   └── sound.mp3
└── videos/         # Optional
    └── clip.mp4
```

## 🌍 Localization Setup

1. Copy `l10n.yaml` from flagsquiz
2. Create `lib/l10n/app_en.arb` with your strings
3. Add translations: `lib/l10n/app_es.arb`, etc.
4. Run `flutter gen-l10n` to generate

## ✅ Testing Template

```dart
// test/models/your_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_quiz/models/your_model.dart';

void main() {
  group('YourModel', () {
    test('fromJson creates valid model', () {
      final json = {
        'name': 'Test',
        'id': '123',
      };

      final model = YourModel.fromJson(json);

      expect(model.name, 'Test');
      expect(model.id, '123');
    });

    test('toQuestionEntry creates valid entry', () {
      final model = YourModel(name: 'Test', id: '123');
      final entry = model.toQuestionEntry;

      expect(entry.type, isA<ImageQuestion>());
      expect(entry.otherOptions['id'], '123');
    });
  });
}
```

## 🚀 Publishing Checklist

- [ ] Update app name in pubspec.yaml
- [ ] Update bundle ID (iOS)
- [ ] Update application ID (Android)
- [ ] Add app icons
- [ ] Add splash screens
- [ ] Test on all platforms
- [ ] Add privacy policy
- [ ] Add terms of service
- [ ] Create app store screenshots
- [ ] Write app descriptions
- [ ] Set up analytics
- [ ] Configure ads/monetization

## 💡 Content Ideas by Question Type

### Image-based
- Geography (flags, landmarks, maps)
- Nature (animals, plants, minerals)
- History (artifacts, historical figures)
- Entertainment (movie posters, celebrities)
- Food (dishes, ingredients)
- Architecture (buildings, monuments)
- Art (paintings, sculptures)
- Brands (logos, products)

### Audio-based
- Music (genres, instruments, artists)
- Nature (animal sounds, bird calls)
- Languages (word pronunciation, phrases)
- Sound effects (movies, games)

### Video-based
- Movies (scenes, trailers)
- Sports (famous plays, athletes)
- Nature (animal behavior)
- How-to (skills demonstration)

### Text-based
- Trivia (general knowledge)
- Math (equations, problems)
- Language (vocabulary, grammar)
- Science (facts, formulas)
- History (dates, events)
