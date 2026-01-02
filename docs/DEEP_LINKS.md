# Deep Links - Flags Quiz App

This document describes the deep link URLs supported by the Flags Quiz app.

## URL Scheme

The app uses a custom URL scheme: `flagsquiz://`

## Supported Deep Links

### Quiz Categories

Opens a quiz for a specific category (continent).

```
flagsquiz://quiz/{categoryId}
```

**Available Category IDs:**

| Category ID | Description |
|-------------|-------------|
| `all` | All countries |
| `eu` | Europe |
| `af` | Africa |
| `as` | Asia |
| `na` | North America |
| `sa` | South America |
| `oc` | Oceania |

**Examples:**
```bash
# Open Europe quiz
flagsquiz://quiz/eu

# Open Africa quiz
flagsquiz://quiz/af

# Open All countries quiz
flagsquiz://quiz/all
```

### Challenges

Opens the challenges tab and navigates to challenges.

```
flagsquiz://challenge/{challengeId}
```

**Available Challenge IDs:**

| Challenge ID | Description |
|--------------|-------------|
| `survival` | Survival mode - limited lives |
| `time_attack` | Time Attack - beat the clock |
| `speed_run` | Speed Run - fastest completion |
| `marathon` | Marathon - endurance challenge |
| `blitz` | Blitz - rapid fire questions |

**Examples:**
```bash
# Open Survival challenge
flagsquiz://challenge/survival

# Open Time Attack challenge
flagsquiz://challenge/time_attack
```

### Achievements

Opens the achievements tab.

```
flagsquiz://achievement/{achievementId}
```

**Examples:**
```bash
# Open achievements tab
flagsquiz://achievement/first_quiz
```

## Testing Deep Links

### Android (via ADB)

```bash
# Quiz deep links
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://quiz/eu"
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://quiz/af"
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://quiz/as"

# Challenge deep links
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://challenge/survival"
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://challenge/time_attack"
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://challenge/blitz"

# Achievement deep link
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://achievement/any"
```

### iOS Simulator (via xcrun)

```bash
# Quiz deep links
xcrun simctl openurl booted "flagsquiz://quiz/eu"
xcrun simctl openurl booted "flagsquiz://quiz/af"

# Challenge deep links
xcrun simctl openurl booted "flagsquiz://challenge/survival"

# Achievement deep link
xcrun simctl openurl booted "flagsquiz://achievement/any"
```

### Cold Start vs Warm Start

- **Cold Start**: App is not running. Deep link launches the app and navigates.
- **Warm Start**: App is in background. Deep link brings app to foreground and navigates.

To test cold start:
```bash
# Force stop the app first
adb shell am force-stop com.ababilo.flagsquiz

# Then send deep link
adb shell am start -a android.intent.action.VIEW -d "flagsquiz://quiz/eu"
```

## Platform Configuration

### Android

Deep links are configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="flagsquiz"/>
</intent-filter>
```

### iOS

Deep links are configured in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.vsapps.flagsquiz</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>flagsquiz</string>
        </array>
    </dict>
</array>
```

## Error Handling

Invalid deep links are handled gracefully:

- **Invalid category ID**: Logs error, stays on current screen
- **Invalid challenge ID**: Logs error, stays on current screen
- **Unknown route**: Ignored silently

Debug logs are available in debug builds:
```
FlagsQuizApp: Received deep link route: QuizRoute(categoryId: eu)
FlagsQuizApp: Navigation result: NavigationSuccess()
```

## Implementation Details

Deep link handling is implemented using:

1. **DeepLinkService** (`shared_services`): Listens for incoming deep links
2. **DeepLinkRouter** (`flagsquiz`): Parses URLs into route objects
3. **DeepLinkHandler** (`flagsquiz`): Widget that handles route events
4. **QuizNavigationProvider** (`quiz_engine`): Provides navigation capabilities

For implementation details, see:
- `apps/flagsquiz/lib/deeplink/` - App-specific deep link handling
- `packages/quiz_engine/lib/src/app/quiz_navigation.dart` - Navigation interface
- `packages/shared_services/lib/src/deeplink/` - Core deep link service
