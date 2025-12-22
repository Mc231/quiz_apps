# Sound Effects Usage Guide

## Quick Start

The quiz_engine package includes standard sound effects that can be used by any quiz app. These sounds are automatically bundled when you use the quiz_engine package.

### Basic Usage

```dart
import 'package:shared_services/shared_services.dart';

// Initialize the audio service
final audioService = AudioService();
await audioService.initialize();

// Play a sound effect
await audioService.playSoundEffect(QuizSoundEffect.correctAnswer);
```

### Integration with Quiz BLoC

To integrate sound effects with the quiz flow, you can listen to quiz state changes:

```dart
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

class QuizWithAudio {
  final QuizBloc quizBloc;
  final AudioService audioService;
  final HapticService hapticService;

  QuizWithAudio({
    required this.quizBloc,
    required this.audioService,
    required this.hapticService,
  });

  Future<void> initialize() async {
    await audioService.initialize();

    // Preload frequently used sounds
    await audioService.preloadMultiple([
      QuizSoundEffect.correctAnswer,
      QuizSoundEffect.incorrectAnswer,
      QuizSoundEffect.buttonClick,
    ]);

    // Listen to quiz states and play appropriate sounds
    quizBloc.stream.listen((state) {
      if (state is AnswerFeedbackState) {
        _handleAnswerFeedback(state);
      }
    });
  }

  Future<void> _handleAnswerFeedback(AnswerFeedbackState state) async {
    if (state.isCorrect) {
      await audioService.playSoundEffect(QuizSoundEffect.correctAnswer);
      await hapticService.correctAnswer();
    } else {
      await audioService.playSoundEffect(QuizSoundEffect.incorrectAnswer);
      await hapticService.incorrectAnswer();
    }
  }
}
```

### Respecting User Preferences

Always allow users to control sound and haptic feedback:

```dart
import 'package:shared_services/shared_services.dart';

class FeedbackManager {
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();

  Future<void> initialize({
    required bool soundsEnabled,
    required bool hapticsEnabled,
    double volume = 1.0,
  }) async {
    await _audioService.initialize();
    _audioService.setMuted(!soundsEnabled);
    _audioService.setVolume(volume);
    _hapticService.setEnabled(hapticsEnabled);
  }

  // Update from settings
  void updateSettings({
    bool? soundsEnabled,
    bool? hapticsEnabled,
    double? volume,
  }) {
    if (soundsEnabled != null) {
      _audioService.setMuted(!soundsEnabled);
    }
    if (hapticsEnabled != null) {
      _hapticService.setEnabled(hapticsEnabled);
    }
    if (volume != null) {
      _audioService.setVolume(volume);
    }
  }

  Future<void> playCorrectAnswer() async {
    await _audioService.playSoundEffect(QuizSoundEffect.correctAnswer);
    await _hapticService.correctAnswer();
  }

  Future<void> playIncorrectAnswer() async {
    await _audioService.playSoundEffect(QuizSoundEffect.incorrectAnswer);
    await _hapticService.incorrectAnswer();
  }
}
```

### Complete Example with UIBehaviorConfig

```dart
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late QuizBloc _quizBloc;
  late AudioService _audioService;
  late HapticService _hapticService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _audioService = AudioService();
    _hapticService = HapticService();

    await _audioService.initialize();

    // Create quiz configuration with feedback enabled
    final config = QuizConfig(
      uiBehavior: UIBehaviorConfig(
        showAnswerFeedback: true,
        answerFeedbackDuration: 1500,
        playSounds: true,
        hapticFeedback: true,
      ),
    );

    // Create quiz bloc
    _quizBloc = QuizBloc(
      /* your quiz data loader */
      config: config,
    );

    // Listen to quiz states and provide feedback
    _quizBloc.stream.listen((state) {
      if (state is AnswerFeedbackState) {
        _provideFeedback(state);
      }
    });
  }

  Future<void> _provideFeedback(AnswerFeedbackState state) async {
    if (!mounted) return;

    final config = _quizBloc.config.uiBehavior;

    if (config.playSounds) {
      final sound = state.isCorrect
          ? QuizSoundEffect.correctAnswer
          : QuizSoundEffect.incorrectAnswer;
      await _audioService.playSoundEffect(sound);
    }

    if (config.hapticFeedback) {
      if (state.isCorrect) {
        await _hapticService.correctAnswer();
      } else {
        await _hapticService.incorrectAnswer();
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _quizBloc,
      child: QuizScreen(
        title: 'My Quiz',
        gameOverTitle: 'Quiz Complete!',
      ),
    );
  }
}
```

## Available Sound Effects

All sound effects are enum values from `QuizSoundEffect`:

```dart
QuizSoundEffect.correctAnswer      // When answer is correct
QuizSoundEffect.incorrectAnswer    // When answer is incorrect
QuizSoundEffect.buttonClick        // UI button clicks
QuizSoundEffect.quizComplete       // Quiz completion
QuizSoundEffect.achievement        // Perfect score/achievement
QuizSoundEffect.timerWarning       // Timer running low
QuizSoundEffect.timeOut            // Time expired
QuizSoundEffect.hintUsed           // Hint activated
QuizSoundEffect.lifeLost           // Life/chance lost
QuizSoundEffect.quizStart          // Quiz starting
```

## Customizing Sounds

To use your own custom sounds:

1. Replace the MP3 files in `packages/quiz_engine/assets/sounds/`
2. Keep the same filenames
3. Run `melos bootstrap` to update assets
4. The AudioService will automatically use your custom sounds

## Sound File Requirements

- **Format**: MP3 or OGG
- **Bitrate**: 128kbps or lower recommended
- **Duration**: 0.1s - 3s depending on the effect
- **File Size**: Under 50KB per file preferred

## Testing Sounds

Test your sound integration:

```dart
// Test all sounds
for (final effect in QuizSoundEffect.values) {
  print('Playing ${effect.name}');
  await audioService.playSoundEffect(effect);
  await Future.delayed(Duration(seconds: 1));
}
```

## Troubleshooting

### Sounds not playing

1. Check that `AudioService.initialize()` was called
2. Verify sounds are not muted: `audioService.setMuted(false)`
3. Check volume: `audioService.setVolume(1.0)`
4. Ensure sound files exist in `assets/sounds/`

### Sounds are delayed

Preload sounds before use:

```dart
await audioService.preloadMultiple([
  QuizSoundEffect.correctAnswer,
  QuizSoundEffect.incorrectAnswer,
]);
```

### Sounds overlap

The AudioService stops the previous sound before playing a new one. If you need simultaneous sounds, create multiple AudioService instances.

## Best Practices

1. **Initialize early**: Call `initialize()` during app startup
2. **Preload important sounds**: Preload correct/incorrect answer sounds
3. **Respect user settings**: Always provide mute/volume controls
4. **Test on device**: Sounds may behave differently on real devices vs simulators
5. **Keep files small**: Optimize sound files for mobile use
6. **Provide settings**: Let users control sound and haptic feedback independently

## See Also

- [README.md](./README.md) - Sound file requirements and resources
- [HapticService Documentation](../../../shared_services/lib/src/haptic/haptic_service.dart)
- [UIBehaviorConfig Documentation](../../../quiz_engine_core/lib/src/model/config/ui_behavior_config.dart)