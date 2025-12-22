# Settings System Usage Guide

This guide explains how to use the settings system in your quiz application.

## Overview

The settings system provides a comprehensive way to manage user preferences including:
- Sound effects toggle
- Background music toggle
- Haptic feedback toggle
- Answer feedback display toggle
- Theme selection (Light/Dark/System)
- Settings persistence across app restarts
- Real-time settings application

## Quick Start

### 1. Initialize SettingsService

In your app's initialization (typically in `main.dart`):

```dart
import 'package:shared_services/shared_services.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();

  runApp(MyApp(settingsService: settingsService));
}
```

### 2. Listen to Settings Changes

Make your app respond to theme changes in real-time:

```dart
class MyApp extends StatefulWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late QuizSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settingsService.currentSettings;

    // Listen to settings changes
    widget.settingsService.settingsStream.listen((settings) {
      setState(() {
        _currentSettings = settings;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _currentSettings.flutterThemeMode,
      home: HomeScreen(settingsService: widget.settingsService),
    );
  }
}
```

### 3. Navigate to Settings Screen

From anywhere in your app:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SettingsScreen(
      settingsService: settingsService,
      privacyPolicyUrl: 'https://yourapp.com/privacy',
      termsOfServiceUrl: 'https://yourapp.com/terms',
      creditsText: 'Created by Your Team',
      attributions: [
        'Flag icons by FlagPedia',
        'Sound effects by Freesound.org',
      ],
    ),
  ),
);
```

### 4. Apply Settings to Services

Integrate settings with audio and haptic services:

```dart
class QuizController {
  final SettingsService settingsService;
  final AudioService audioService;
  final HapticService hapticService;

  QuizController({
    required this.settingsService,
    required this.audioService,
    required this.hapticService,
  }) {
    // Apply initial settings
    _applySettings(settingsService.currentSettings);

    // Listen to settings changes
    settingsService.settingsStream.listen(_applySettings);
  }

  void _applySettings(QuizSettings settings) {
    // Apply audio settings
    audioService.setMuted(!settings.soundEnabled);

    // Apply haptic settings
    hapticService.setEnabled(settings.hapticEnabled);
  }

  void onCorrectAnswer() {
    // Only show feedback if enabled
    if (settingsService.currentSettings.showAnswerFeedback) {
      showFeedbackAnimation();
    }
  }
}
```

## Advanced Usage

### Programmatic Settings Updates

```dart
// Toggle individual settings
await settingsService.toggleSound();
await settingsService.toggleMusic();
await settingsService.toggleHaptic();
await settingsService.toggleAnswerFeedback();

// Set theme mode
await settingsService.setThemeMode(AppThemeMode.dark);

// Update multiple settings at once
await settingsService.updateSettings(
  settingsService.currentSettings.copyWith(
    soundEnabled: false,
    hapticEnabled: false,
    themeMode: AppThemeMode.light,
  ),
);

// Reset to defaults
await settingsService.resetToDefaults();
```

### Custom Settings Integration

If you need to add custom settings:

```dart
// Extend QuizSettings with custom fields
class MyCustomSettings extends QuizSettings {
  final bool customFeatureEnabled;

  const MyCustomSettings({
    required super.soundEnabled,
    required super.musicEnabled,
    required super.hapticEnabled,
    required super.showAnswerFeedback,
    required super.themeMode,
    required this.customFeatureEnabled,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['customFeatureEnabled'] = customFeatureEnabled;
    return json;
  }
}
```

### Observing Settings Changes

```dart
// Use StreamBuilder for reactive UI
StreamBuilder<QuizSettings>(
  stream: settingsService.settingsStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final settings = snapshot.data!;
    return Text('Sound: ${settings.soundEnabled ? "On" : "Off"}');
  },
)
```

## Settings Screen Customization

The SettingsScreen accepts several optional parameters:

```dart
SettingsScreen(
  settingsService: settingsService,

  // Optional: Add privacy policy link
  privacyPolicyUrl: 'https://yourapp.com/privacy',

  // Optional: Add terms of service link
  termsOfServiceUrl: 'https://yourapp.com/terms',

  // Optional: Custom credits text
  creditsText: 'Created with ❤️ by Your Team\n\nSpecial thanks to all contributors.',

  // Optional: List of attributions
  attributions: [
    'Country flags by FlagPedia (CC BY-SA 4.0)',
    'Sound effects by Freesound.org',
    'Icons by Material Design Icons',
  ],
)
```

## Best Practices

1. **Initialize Early**: Initialize SettingsService before runApp() to ensure settings are loaded before the app starts
2. **Single Instance**: Use a single SettingsService instance throughout your app (consider using dependency injection)
3. **Listen Once**: Set up settings listeners in your root widget to avoid memory leaks
4. **Apply Settings**: Immediately apply settings when they change to provide real-time feedback
5. **Dispose Properly**: Call `settingsService.dispose()` when the service is no longer needed (usually never in the main app)

## Platform-Specific Considerations

### iOS
- Haptic feedback requires iOS 10.0 or later
- Some haptic types may not be available on all devices

### Android
- Haptic feedback requires Android API 23 (Marshmallow) or later
- Permission for internet is required if using URL launcher for links

### Web
- Haptic feedback is not supported on web platforms
- URL launcher opens links in new tabs

### macOS
- URL launcher may require additional entitlements in release builds

## Testing

The settings system includes comprehensive unit tests. To run them:

```bash
# Test settings in shared_services
cd packages/shared_services
flutter test

# Test entire monorepo
melos run test
```

## Troubleshooting

### Settings not persisting
- Ensure `initialize()` is called before using the service
- Check that SharedPreferences has proper permissions on the platform

### Theme not updating
- Verify you're listening to `settingsStream` in your MaterialApp
- Ensure you're using `themeMode: settings.flutterThemeMode`

### Deprecation warnings
- The RadioListTile deprecation warnings are for very new Flutter versions
- They are suppressed with `// ignore: deprecated_member_use`
- The code is compatible with most Flutter versions

## Examples

See the `flagsquiz` app for a complete working example of settings integration.

## API Reference

### SettingsService

- `initialize()` - Load settings from storage
- `currentSettings` - Get current settings
- `settingsStream` - Stream of settings changes
- `updateSettings(QuizSettings)` - Update and persist settings
- `toggleSound()` - Toggle sound effects
- `toggleMusic()` - Toggle background music
- `toggleHaptic()` - Toggle haptic feedback
- `toggleAnswerFeedback()` - Toggle answer feedback
- `setThemeMode(AppThemeMode)` - Set theme mode
- `resetToDefaults()` - Reset all settings to defaults
- `dispose()` - Clean up resources

### QuizSettings

- `soundEnabled` - Whether sound effects are enabled
- `musicEnabled` - Whether background music is enabled
- `hapticEnabled` - Whether haptic feedback is enabled
- `showAnswerFeedback` - Whether answer feedback is shown
- `themeMode` - Current theme mode (light/dark/system)
- `flutterThemeMode` - Convert to Flutter ThemeMode
- `copyWith()` - Create modified copy
- `toJson()` - Serialize to JSON
- `fromJson()` - Deserialize from JSON

### AppThemeMode

- `AppThemeMode.light` - Always use light theme
- `AppThemeMode.dark` - Always use dark theme
- `AppThemeMode.system` - Follow system theme

## Support

For issues or questions, please refer to the main project documentation or open an issue on GitHub.