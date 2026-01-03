# iOS Game Center Integration Guide

This guide explains how to set up and use Game Center integration in your quiz app.

## Overview

The Game Center integration provides:
- **Player Authentication** - Sign in with Game Center
- **Leaderboards** - Submit and display scores
- **Achievements** - Sync achievements to Game Center

## Prerequisites

- Xcode 14+
- iOS 13.0+ or macOS 10.15+ target
- Apple Developer Program membership
- App configured in App Store Connect

## Step 1: Enable Game Center Capability

1. Open your project in Xcode
2. Select your app target (e.g., "Runner")
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **Game Center**

This will add the GameKit framework and entitlements to your project.

## Step 2: Configure Game Center in App Store Connect

### Create Leaderboards

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Services** → **Game Center**
4. Click **Leaderboards** → **+**
5. Choose **Classic Leaderboard** (or Recurring for time-based)
6. Fill in the details:
   - **Reference Name**: Internal identifier (e.g., "Overall Score")
   - **Leaderboard ID**: Unique ID used in code (e.g., `com.yourapp.overall_score`)
   - **Score Format Type**: Integer, Time, Money, etc.
   - **Score Submission Type**: Best Score or Most Recent
   - **Sort Order**: High to Low or Low to High
7. Add localizations for each language your app supports

### Create Achievements

1. In Game Center settings, click **Achievements** → **+**
2. Fill in the details:
   - **Reference Name**: Internal name (e.g., "First Quiz Completed")
   - **Achievement ID**: Unique ID used in code (e.g., `com.yourapp.first_quiz`)
   - **Point Value**: 0-100 points
   - **Hidden**: Whether to hide until unlocked
3. Add localizations with title, description, and achievement image (512x512 or 1024x1024)

### Recommended Leaderboards for Quiz Apps

| Leaderboard ID | Description |
|----------------|-------------|
| `overall_score` | Total score across all quizzes |
| `category_europe` | Score for Europe category |
| `category_asia` | Score for Asia category |
| `weekly_challenge` | Weekly challenge scores (recurring) |

### Recommended Achievements

| Achievement ID | Points | Description |
|----------------|--------|-------------|
| `first_quiz` | 10 | Complete first quiz |
| `perfect_score` | 25 | Get 100% on any quiz |
| `quiz_master_50` | 50 | Complete 50 quizzes |
| `speed_demon` | 25 | Complete quiz in under 60 seconds |
| `streak_10` | 50 | Get 10 correct answers in a row |

## Step 3: Integrate in Flutter Code

### Add Dependencies

The `games_services` package is already added to `shared_services`:

```yaml
# packages/shared_services/pubspec.yaml
dependencies:
  games_services: ^5.0.0
```

### Initialize Services

```dart
import 'package:shared_services/shared_services.dart';

// Create Game Center services
final gameCenterServices = GameCenterServices(
  achievementIdMapping: {
    // Map in-app IDs to Game Center IDs
    'first_quiz': 'com.yourapp.first_quiz',
    'perfect_score': 'com.yourapp.perfect_score',
  },
);

// Or use individual services
final gameService = GameCenterService();
final leaderboardService = GameCenterLeaderboardService();
final achievementService = GameCenterAchievementService();
```

### Sign In

```dart
final result = await gameCenterServices.signIn();

switch (result) {
  case SignInSuccess(:final playerId, :final displayName):
    print('Welcome, $displayName!');
    break;
  case SignInCancelled():
    print('Sign-in cancelled');
    break;
  case SignInFailed(:final error):
    print('Sign-in failed: $error');
    break;
  case SignInNotAuthenticated():
    print('Game Center not available or not configured');
    break;
}
```

### Submit Score

```dart
final result = await gameCenterServices.leaderboardService.submitScore(
  leaderboardId: 'com.yourapp.overall_score',
  score: 1500,
);

if (result is SubmitScoreSuccess) {
  print('Score submitted successfully');
  if (result.isNewHighScore == true) {
    print('New high score!');
  }
}
```

### Unlock Achievement

```dart
final result = await gameCenterServices.cloudAchievementService.unlockAchievement(
  'first_quiz', // In-app ID, mapped to Game Center ID
);

if (result is UnlockAchievementSuccess) {
  print('Achievement unlocked!');
}
```

### Show Native UI

```dart
// Show leaderboard
await gameCenterServices.leaderboardService.showLeaderboard(
  leaderboardId: 'com.yourapp.overall_score',
);

// Show all leaderboards
await gameCenterServices.leaderboardService.showAllLeaderboards();

// Show achievements
await gameCenterServices.cloudAchievementService.showAchievements();
```

### Get Player Info

```dart
final playerInfo = await gameCenterServices.gameService.getPlayerInfo();
if (playerInfo != null) {
  print('Player: ${playerInfo.displayName}');
  print('ID: ${playerInfo.playerId}');
}

// Get avatar
final avatarData = await gameCenterServices.gameService.getPlayerAvatar();
if (avatarData != null) {
  // Use with Image.memory(avatarData)
}
```

## Step 4: Cross-Platform Support

Use platform detection to choose the appropriate service:

```dart
import 'dart:io';

GameService createGameService() {
  if (Platform.isIOS || Platform.isMacOS) {
    return GameCenterService();
  } else if (Platform.isAndroid) {
    // Sprint 17.3 - PlayGamesService
    return NoOpGameService();
  } else {
    return NoOpGameService();
  }
}
```

## Testing

### Sandbox Testing

1. Create a Sandbox test account in App Store Connect
2. On device: Settings → Game Center → Sign out
3. Launch app and sign in with sandbox account
4. Sandbox accounts won't affect production data

### Common Issues

| Issue | Solution |
|-------|----------|
| "Not authenticated" | Ensure Game Center is enabled in device Settings |
| "Achievement not found" | Verify achievement ID matches App Store Connect |
| Sign-in freezes | Update to latest games_services version |
| Scores not appearing | Check leaderboard is configured correctly |

### Debug Logging

Enable debug logging to troubleshoot issues:

```dart
final result = await gameCenterServices.signIn();
print('Sign-in result: $result');

if (result is SignInFailed) {
  print('Error: ${result.error}');
  print('Error code: ${result.errorCode}');
}
```

## Production Checklist

- [ ] Game Center capability enabled in Xcode
- [ ] All leaderboards configured in App Store Connect
- [ ] All achievements configured with localizations
- [ ] Achievement images uploaded (512x512 or 1024x1024)
- [ ] Tested with sandbox account on real device
- [ ] Achievement ID mapping configured correctly
- [ ] Fallback to NoOp services on unsupported platforms
- [ ] Error handling for sign-in failures
- [ ] User-friendly messages for Game Center errors

## Related Documentation

- [games_services Package](https://pub.dev/packages/games_services)
- [Apple Game Center Documentation](https://developer.apple.com/game-center/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Files Reference

| File | Description |
|------|-------------|
| `packages/shared_services/lib/src/game/game_center_service.dart` | Authentication service |
| `packages/shared_services/lib/src/game/game_center_leaderboard_service.dart` | Leaderboard service |
| `packages/shared_services/lib/src/game/game_center_achievement_service.dart` | Achievement service |
| `packages/shared_services/lib/src/game/game_center_services.dart` | Combined services |
| `packages/shared_services/lib/src/game/game_exports.dart` | Barrel exports |
