# Quiz Sound Effects

This directory contains sound effects used by the quiz engine. Apps using the quiz_engine package will have access to these standard sound effects.

## Required Sound Files

The following sound files are required for full audio feedback support:

| Filename | Purpose | Recommended Duration | Suggested Type |
|----------|---------|---------------------|----------------|
| `correctAnswer.mp3` | Played when user selects correct answer | 0.5-1s | Positive chime, bell, or success sound |
| `incorrectAnswer.mp3` | Played when user selects incorrect answer | 0.5-1s | Buzzer, error beep, or negative sound |
| `buttonClick.mp3` | General UI button click sound | 0.1-0.3s | Soft click or tap |
| `quizComplete.mp3` | Played when quiz is completed | 1-3s | Fanfare, completion jingle |
| `achievement.mp3` | Played for perfect score or achievement | 1-2s | Triumphant fanfare, victory sound |
| `timerWarning.mp3` | Countdown or timer warning | 0.5-1s | Tick, beep, or alert sound |
| `timeOut.mp3` | Played when time runs out | 1-2s | Alarm, buzzer, or timeout sound |
| `hintUsed.mp3` | Played when using a hint | 0.5-1s | Helpful chime, sparkle |
| `lifeLost.mp3` | Played when losing a life | 0.5-1s | Descending tone, loss indicator |
| `quizStart.mp3` | Played at quiz start | 1-2s | Starting fanfare, ready sound |

## Audio Format Specifications

- **Format**: MP3 (recommended) or OGG
- **Bitrate**: 128kbps or lower (to keep file sizes small)
- **Sample Rate**: 44.1kHz
- **Channels**: Mono or Stereo
- **File Size**: Keep under 50KB per file when possible

## Free Sound Resources

Here are some recommended sources for free, royalty-free sound effects:

### 1. Freesound.org
- URL: https://freesound.org
- License: Various Creative Commons licenses
- Quality: High-quality community-uploaded sounds
- Search tips: Use keywords like "game success", "button click", "quiz correct"

### 2. Mixkit Sound Effects
- URL: https://mixkit.co/free-sound-effects/game/
- License: Free for commercial and non-commercial use
- Quality: Professional game sound effects
- Categories: Game sounds, UI sounds, notifications

### 3. Zapsplat
- URL: https://www.zapsplat.com
- License: Free with attribution (or paid for no attribution)
- Quality: Professional sound library
- Categories: Game UI, Success/Fail sounds

### 4. OpenGameArt
- URL: https://opengameart.org/art-search-advanced?keys=&field_art_type_tid%5B%5D=13
- License: Various open licenses (CC0, CC-BY, etc.)
- Quality: Game-focused sounds
- Community: Game developer community

### 5. Sound Bible
- URL: https://soundbible.com
- License: Public Domain and Creative Commons
- Quality: Wide variety of sounds

## Creating Your Own Sounds

If you want to create custom sounds:

1. **Using Online Tools**:
   - JFXR: https://jfxr.frozenfractal.com/ (Browser-based retro game sound generator)
   - ChipTone: https://sfbgames.itch.io/chiptone (8-bit sound effect generator)

2. **Using Audio Software**:
   - Audacity (Free, open-source): https://www.audacityteam.org/
   - GarageBand (Mac): Built-in audio creation tool
   - FL Studio (Paid): Professional audio workstation

## Quick Start - Adding Sounds

### Option 1: Download from Freesound.org

```bash
# Example: Download a success sound
# 1. Go to freesound.org
# 2. Search for "game success" or "correct answer"
# 3. Download your chosen sound
# 4. Convert to MP3 if needed
# 5. Rename to correctAnswer.mp3
# 6. Place in this directory
```

### Option 2: Generate with JFXR

1. Visit https://jfxr.frozenfractal.com/
2. Click "Pickup/Coin" for success sounds or "Hit/Hurt" for error sounds
3. Adjust parameters as desired
4. Export as .wav
5. Convert to MP3 using online converter or ffmpeg:
   ```bash
   ffmpeg -i input.wav -b:a 128k correctAnswer.mp3
   ```

### Option 3: Use Pre-made Game Sound Packs

Search for "game UI sound pack" on:
- itch.io: https://itch.io/game-assets/tag-sound-effects
- OpenGameArt: https://opengameart.org
- Kenney.nl: https://kenney.nl/assets?q=audio

## Sample Sound Descriptions

To help you search, here are specific sound characteristics:

- **correctAnswer**: Bright, ascending chime (C to E note), cheerful
- **incorrectAnswer**: Low buzzer (descending tone), muted
- **buttonClick**: Short "tick" or "pop", neutral
- **quizComplete**: Upbeat melody, 2-4 notes, celebratory
- **achievement**: Triumphant fanfare, 3-5 notes, epic
- **timerWarning**: Repetitive beep, increasing urgency
- **timeOut**: Descending alarm or buzzer, final
- **hintUsed**: Magical chime, light sparkle effect
- **lifeLost**: Descending "whomp" or "oof" sound
- **quizStart**: Ascending ready countdown (3-2-1-go style) or simple "start" chime

## Testing Your Sounds

After adding sound files, test them using:

```dart
import 'package:shared_services/shared_services.dart';

final audioService = AudioService();
await audioService.initialize();

// Test correct answer sound
await audioService.playSoundEffect(QuizSoundEffect.correctAnswer);

// Test incorrect answer sound
await audioService.playSoundEffect(QuizSoundEffect.incorrectAnswer);
```

**Note**: Sound files must be placed in `packages/quiz_engine/assets/sounds/` and the paths are automatically resolved by the AudioService using Flutter's AssetSource.

## License Compliance

When using sounds from external sources:

1. Check the license requirements
2. Provide attribution if required (add to CREDITS.md in your app)
3. Ensure commercial use is allowed if building a commercial app
4. Keep copies of license information

## Placeholder Sounds

If you need placeholder sounds during development, you can:

1. Use text-to-speech for temporary audio cues
2. Use online tone generators to create simple beeps
3. Record yourself making sounds (seriously - developers do this!)

## Support

For questions about audio setup, refer to:
- Flutter audioplayers documentation: https://pub.dev/packages/audioplayers
- Quiz engine documentation: `/docs` directory in monorepo root