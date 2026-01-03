# Game Services Configuration Guide

This document provides step-by-step instructions for configuring Game Center (iOS) and Play Games (Android) for the Flags Quiz app.

**Reference:** This document is referenced by Sprint 17.7 in [PHASE_IMPLEMENTATION.md](./PHASE_IMPLEMENTATION.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Leaderboards Configuration](#leaderboards-configuration)
3. [Achievements Configuration](#achievements-configuration)
4. [App Store Connect Setup (iOS)](#app-store-connect-setup-ios)
5. [Google Play Console Setup (Android)](#google-play-console-setup-android)
6. [Code Integration](#code-integration)
7. [Testing](#testing)

---

## Overview

### What We Need to Configure

| Type | Count | Description |
|------|-------|-------------|
| Leaderboards | 6 | Global + 5 continent-specific |
| Achievements | 75 | Across 9 categories |

### ID Mapping File

After configuration, update IDs in:
```
apps/flagsquiz/lib/config/flags_game_service_config.dart
```

---

## Leaderboards Configuration

### Leaderboard List

| Internal ID | Display Name | Description | Score Format |
|-------------|--------------|-------------|--------------|
| `global` | World Champions | Overall global leaderboard for all players | Percentage (0-100) |
| `europe` | European Masters | Top scorers in European flags | Percentage (0-100) |
| `asia` | Asian Experts | Top scorers in Asian flags | Percentage (0-100) |
| `africa` | African Scholars | Top scorers in African flags | Percentage (0-100) |
| `americas` | Americas Champions | Top scorers in North & South American flags | Percentage (0-100) |
| `oceania` | Oceania Specialists | Top scorers in Oceanian flags | Percentage (0-100) |

### Leaderboard Settings

For all leaderboards:
- **Sort Order:** High to Low (higher score = better)
- **Score Format:** Integer (represents percentage 0-100)
- **Score Range:** 0 to 100
- **Submission Frequency:** Best score only (not cumulative)

---

## Achievements Configuration

### Achievement Categories Summary

| Category | Count | Description |
|----------|-------|-------------|
| Beginner | 3 | First steps achievements |
| Progress - Quizzes | 4 | Quiz completion milestones |
| Progress - Questions | 4 | Questions answered milestones |
| Progress - Correct | 3 | Correct answers milestones |
| Mastery - Perfect | 4 | Perfect score milestones |
| Mastery - High Scores | 3 | High score achievements |
| Speed | 4 | Time-based achievements |
| Streak | 4 | Consecutive correct answers |
| Challenge | 10 | Challenge mode achievements |
| Dedication - Time | 4 | Play time milestones |
| Dedication - Days | 4 | Daily play milestones |
| Skill | 6 | Special gameplay achievements |
| Flags - Exploration | 7 | Continent exploration |
| Flags - Mastery | 7 | Continent mastery |
| Flags - Dedication | 8 | Streak and daily achievements |
| **Total** | **75** | |

---

### Complete Achievement List

#### Beginner Achievements (3)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `first_quiz` | First Steps | Complete your first quiz | 10 | No |
| `first_perfect` | Perfectionist | Get 100% on any quiz | 25 | No |
| `first_challenge` | Challenger | Complete your first challenge | 15 | No |

#### Progress - Quiz Count (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `quizzes_10` | Getting Started | Complete 10 quizzes | 20 | No |
| `quizzes_50` | Quiz Enthusiast | Complete 50 quizzes | 35 | No |
| `quizzes_100` | Century Club | Complete 100 quizzes | 50 | No |
| `quizzes_500` | Quiz Master | Complete 500 quizzes | 100 | No |

#### Progress - Questions (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `questions_100` | Question Explorer | Answer 100 questions | 15 | No |
| `questions_500` | Question Seeker | Answer 500 questions | 30 | No |
| `questions_1000` | Question Master | Answer 1,000 questions | 50 | No |
| `questions_5000` | Question Legend | Answer 5,000 questions | 100 | No |

#### Progress - Correct Answers (3)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `correct_100` | Sharp Eye | Get 100 correct answers | 20 | No |
| `correct_500` | Knowledge Keeper | Get 500 correct answers | 40 | No |
| `correct_1000` | Wisdom Master | Get 1,000 correct answers | 75 | No |

#### Mastery - Perfect Scores (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `perfect_5` | Rising Star | Get 5 perfect scores | 25 | No |
| `perfect_10` | Shining Bright | Get 10 perfect scores | 40 | No |
| `perfect_25` | Golden Touch | Get 25 perfect scores | 60 | No |
| `perfect_50` | Flawless Legend | Get 50 perfect scores | 100 | No |

#### Mastery - High Scores (3)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `score_90_10` | High Achiever | Score 90%+ on 10 quizzes | 35 | No |
| `score_95_10` | Excellence | Score 95%+ on 10 quizzes | 50 | No |
| `perfect_streak_3` | Hat Trick | Get 3 perfect scores in a row | 40 | No |

#### Speed Achievements (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `speed_demon` | Speed Demon | Complete a quiz in under 30 seconds | 30 | No |
| `lightning` | Lightning Fast | Answer a question in under 1 second | 20 | Yes |
| `quick_answer_10` | Quick Thinker | Answer 10 questions in under 2 seconds each | 25 | No |
| `quick_answer_50` | Lightning Reflexes | Answer 50 questions in under 2 seconds each | 50 | No |

#### Streak Achievements (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `streak_10` | On Fire | Get 10 correct answers in a row | 20 | No |
| `streak_25` | Blazing Hot | Get 25 correct answers in a row | 40 | No |
| `streak_50` | Unstoppable | Get 50 correct answers in a row | 60 | No |
| `streak_100` | Legendary Streak | Get 100 correct answers in a row | 100 | No |

#### Challenge Achievements (10)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `survival_complete` | Survivor | Complete a survival challenge | 25 | No |
| `survival_perfect` | Perfect Survivor | Complete survival with no mistakes | 50 | No |
| `blitz_complete` | Blitz Runner | Complete a blitz challenge | 25 | No |
| `blitz_perfect` | Blitz Master | Complete blitz with perfect score | 50 | No |
| `time_attack_20` | Time Warrior | Score 20+ in time attack | 30 | No |
| `time_attack_30` | Time Champion | Score 30+ in time attack | 50 | No |
| `marathon_50` | Endurance Runner | Answer 50 questions in marathon | 35 | No |
| `marathon_100` | Marathon Legend | Answer 100 questions in marathon | 60 | No |
| `speed_run_fast` | Speed Runner | Complete speed run in record time | 40 | No |
| `all_challenges` | Challenge Champion | Complete all challenge types | 75 | No |

#### Dedication - Time (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `time_1h` | Hour of Fun | Play for 1 hour total | 15 | No |
| `time_5h` | Dedicated Player | Play for 5 hours total | 30 | No |
| `time_10h` | Committed Learner | Play for 10 hours total | 50 | No |
| `time_24h` | True Devotee | Play for 24 hours total | 100 | No |

#### Dedication - Days (4)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `days_3` | Three-Day Streak | Play 3 days in a row | 15 | No |
| `days_7` | Week Warrior | Play 7 days in a row | 30 | No |
| `days_14` | Two-Week Champion | Play 14 days in a row | 50 | No |
| `days_30` | Monthly Master | Play 30 days in a row | 100 | No |

#### Skill Achievements (6)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `no_hints` | Purist | Complete a quiz without using hints | 20 | No |
| `no_hints_10` | Independent Mind | Complete 10 quizzes without hints | 40 | No |
| `no_skip` | No Skipping | Complete a quiz without skipping | 15 | No |
| `flawless` | Flawless Victory | Perfect score, no hints, no skips | 50 | No |
| `comeback` | Comeback King | Win after being down to 1 life | 35 | Yes |
| `clutch` | Clutch Player | Perfect final 5 questions after mistakes | 30 | Yes |

#### Flags Quiz - Exploration (7)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `explore_africa` | African Explorer | Complete a quiz about African flags | 15 | No |
| `explore_asia` | Asian Explorer | Complete a quiz about Asian flags | 15 | No |
| `explore_europe` | European Explorer | Complete a quiz about European flags | 15 | No |
| `explore_north_america` | North American Explorer | Complete a quiz about North American flags | 15 | No |
| `explore_south_america` | South American Explorer | Complete a quiz about South American flags | 15 | No |
| `explore_oceania` | Oceanian Explorer | Complete a quiz about Oceanian flags | 15 | No |
| `world_traveler` | World Traveler | Complete quizzes from all continents | 50 | No |

#### Flags Quiz - Mastery (7)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `master_europe` | European Master | Get 100% on all European flags | 60 | No |
| `master_asia` | Asian Master | Get 100% on all Asian flags | 60 | No |
| `master_africa` | African Master | Get 100% on all African flags | 60 | No |
| `master_americas` | Americas Master | Get 100% on all American flags | 60 | No |
| `master_oceania` | Oceanian Master | Get 100% on all Oceanian flags | 60 | No |
| `master_world` | World Master | Get 100% on flags from all continents | 150 | No |
| `flag_collector` | Flag Collector | Correctly identify 195 unique flags | 100 | No |

#### Flags Quiz - Dedication (8)

| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `first_flame` | First Flame | Start your first streak | 10 | No |
| `week_warrior` | Week Warrior | Maintain a 7-day streak | 30 | No |
| `monthly_master` | Monthly Master | Maintain a 30-day streak | 75 | No |
| `centurion` | Centurion | Maintain a 100-day streak | 150 | No |
| `dedication` | Dedicated Scholar | Play every day for 2 weeks | 50 | No |
| `daily_devotee` | Daily Devotee | Complete 50 daily challenges | 60 | No |
| `perfect_day` | Perfect Day | Get perfect scores on all quizzes in one day | 40 | Yes |
| `early_bird` | Early Bird | Complete a quiz before 7 AM | 20 | Yes |

---

## App Store Connect Setup (iOS)

### Prerequisites

1. Apple Developer Account ($99/year)
2. App registered in App Store Connect
3. Game Center capability enabled in Xcode

### Step 1: Enable Game Center

1. Go to **App Store Connect** → Your App
2. Navigate to **App Information** → **App Capabilities**
3. Enable **Game Center**

### Step 2: Create Leaderboards

1. Go to **Features** → **Game Center** → **Leaderboards**
2. Click **+** to create a new leaderboard
3. For each leaderboard:

   **Classic Leaderboard Settings:**
   - **Reference Name:** Internal reference (e.g., "Global Leaderboard")
   - **Leaderboard ID:** Use format `grp.com.vsapps.flagsquiz.leaderboard.{id}`
     - Example: `grp.com.vsapps.flagsquiz.leaderboard.global`
   - **Score Format Type:** Integer
   - **Score Submission Type:** Best Score
   - **Sort Order:** High to Low
   - **Score Range:** 0 to 100

   **Add Localization:**
   - **Name:** Display name (e.g., "World Champions")
   - **Score Format:** "{0} %"
   - **Score Format Suffix:** (optional)

4. Repeat for all 6 leaderboards

### Step 3: Create Achievements

1. Go to **Features** → **Game Center** → **Achievements**
2. Click **+** to create a new achievement
3. For each achievement:

   **Achievement Settings:**
   - **Reference Name:** Internal reference (e.g., "First Quiz Completed")
   - **Achievement ID:** Use format `grp.com.vsapps.flagsquiz.achievement.{id}`
     - Example: `grp.com.vsapps.flagsquiz.achievement.first_quiz`
   - **Point Value:** See achievement list above (10-150)
   - **Hidden:** See "Hidden" column in achievement list
   - **Achievable More Than Once:** No (all are one-time)

   **Add Localization:**
   - **Title:** Achievement name (e.g., "First Steps")
   - **Pre-Earned Description:** What to do (e.g., "Complete your first quiz")
   - **Earned Description:** What was done (e.g., "Completed your first quiz")
   - **Image:** 512x512 PNG or 1024x1024 PNG (required)

4. Repeat for all 75 achievements

### Step 4: Achievement Images

Create achievement images for each tier:
- **Bronze** (10-20 points): Bronze-tinted badge
- **Silver** (25-40 points): Silver-tinted badge
- **Gold** (50-75 points): Gold-tinted badge
- **Platinum** (100-150 points): Platinum-tinted badge

Requirements:
- Size: 512x512 or 1024x1024 pixels
- Format: PNG
- No transparency on edges

### Step 5: Copy IDs

After creating all leaderboards and achievements, copy the IDs to update the code:

```dart
// In flags_game_service_config.dart
static GameServiceConfig production() {
  return GameServiceConfig(
    leaderboards: [
      LeaderboardConfig(
        id: 'global',
        gameCenterId: 'grp.com.vsapps.flagsquiz.leaderboard.global',
        // ...
      ),
    ],
    achievementIdMap: {
      'first_quiz': 'grp.com.vsapps.flagsquiz.achievement.first_quiz',
      // ...
    },
  );
}
```

---

## Google Play Console Setup (Android)

### Prerequisites

1. Google Play Developer Account ($25 one-time)
2. App registered in Google Play Console
3. Play Games Services enabled

### Step 1: Enable Play Games Services

1. Go to **Google Play Console** → Your App
2. Navigate to **Grow** → **Play Games Services** → **Setup and management** → **Configuration**
3. Click **Create new Play Games Services project** or link existing
4. Complete the setup wizard

### Step 2: Add Credentials

1. Go to **Credentials**
2. Add **OAuth consent screen** if not already configured
3. Add credentials for your app:
   - **Android:** Add SHA-1 fingerprint from your keystore
   - For debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`

### Step 3: Create Leaderboards

1. Go to **Leaderboards**
2. Click **Add leaderboard**
3. For each leaderboard:

   **Leaderboard Settings:**
   - **Name:** Display name (e.g., "World Champions")
   - **Score formatting:** Numeric (smaller is better: No)
   - **Limits:** Min 0, Max 100
   - **Ordering:** Larger is better
   - **Icon:** 512x512 PNG

4. After saving, copy the auto-generated **Leaderboard ID** (format: `CgkI...`)
5. Repeat for all 6 leaderboards

### Step 4: Create Achievements

1. Go to **Achievements**
2. Click **Add achievement**
3. For each achievement:

   **Achievement Settings:**
   - **Name:** Achievement name (e.g., "First Steps")
   - **Description:** What to do (e.g., "Complete your first quiz")
   - **Icon:** 512x512 PNG
   - **Points:** XP value (see Points column, Play Games uses XP differently)
   - **State:**
     - Revealed (not hidden)
     - Hidden (for hidden achievements)
   - **Incremental:** No (all are one-time achievements)

4. After saving, copy the auto-generated **Achievement ID** (format: `CgkI...`)
5. Repeat for all 75 achievements

### Step 5: Publish

1. After creating all leaderboards and achievements
2. Go to **Publishing**
3. Click **Publish** to make them available for testing
4. Note: You can test with unpublished items using tester accounts

### Step 6: Copy IDs

After creating all items, copy the Play Games IDs to update the code:

```dart
// In flags_game_service_config.dart
static GameServiceConfig production() {
  return GameServiceConfig(
    leaderboards: [
      LeaderboardConfig(
        id: 'global',
        gameCenterId: 'grp.com.vsapps.flagsquiz.leaderboard.global',
        playGamesId: 'CgkI1234567890ABCD', // Copy from Play Console
        // ...
      ),
    ],
    achievementIdMap: {
      // Use same ID for both platforms - the config maps internally
      'first_quiz': 'CgkI1234567890WXYZ', // Copy from Play Console
      // ...
    },
  );
}
```

---

## Code Integration

### Step 1: Update Configuration

After collecting all IDs from both platforms, update `flags_game_service_config.dart`:

```dart
static GameServiceConfig production() {
  return GameServiceConfig(
    isEnabled: true,
    cloudSyncEnabled: true,
    leaderboards: [
      const LeaderboardConfig(
        id: 'global',
        gameCenterId: 'grp.com.vsapps.flagsquiz.leaderboard.global',
        playGamesId: 'CgkI_global_id_here',
        scoreType: LeaderboardScoreType.highScore,
      ),
      // ... more leaderboards
    ],
    achievementIdMap: _productionAchievementIdMap,
  );
}

static const Map<String, String> _productionAchievementIdMap = {
  // Beginner
  'first_quiz': 'grp.com.vsapps.flagsquiz.achievement.first_quiz',
  // ... all 75 achievements
};
```

### Step 2: Platform-Specific ID Handling

Since iOS and Android have different ID formats, you may need separate maps:

```dart
// Option 1: Use same ID format (if you match platform format)
'first_quiz': 'platform_specific_id'

// Option 2: Create platform-aware config
static GameServiceConfig productionForPlatform() {
  if (Platform.isIOS || Platform.isMacOS) {
    return _iosConfig();
  } else if (Platform.isAndroid) {
    return _androidConfig();
  }
  return disabled;
}
```

### Step 3: Switch to Production Config

In `flags_quiz_app_provider.dart`, change:

```dart
// From:
final gameServiceConfig = FlagsGameServiceConfig.development();

// To:
final gameServiceConfig = FlagsGameServiceConfig.production(
  // Pass actual IDs
);
```

---

## Testing

### iOS Testing

1. **Sandbox Account:**
   - Create a sandbox tester in App Store Connect
   - Sign out of Game Center on device
   - Sign in with sandbox account when prompted

2. **TestFlight:**
   - Upload build to TestFlight
   - Test with sandbox testers

3. **Verification:**
   - Check Game Center shows achievements
   - Verify leaderboard scores appear
   - Confirm unlock notifications work

### Android Testing

1. **Tester Accounts:**
   - Add tester emails in Play Games Services
   - Testers must accept invitation

2. **Internal Testing:**
   - Create internal testing track
   - Upload signed APK/AAB
   - Test with tester accounts

3. **Verification:**
   - Check Play Games shows achievements
   - Verify leaderboard scores appear
   - Confirm achievement popups work

### Debug Logging

Enable debug logging to verify integration:

```dart
if (kDebugMode) {
  debugPrint('[GameService] Achievement unlocked: $achievementId');
  debugPrint('[GameService] Score submitted: $score to $leaderboardId');
}
```

---

## Checklist

### App Store Connect
- [ ] Game Center enabled
- [ ] 6 leaderboards created with localizations
- [ ] 75 achievements created with localizations
- [ ] Achievement images uploaded (512x512 or 1024x1024)
- [ ] All IDs copied to code

### Google Play Console
- [ ] Play Games Services enabled
- [ ] OAuth credentials configured
- [ ] 6 leaderboards created with icons
- [ ] 75 achievements created with icons
- [ ] Play Games Services published
- [ ] All IDs copied to code

### Code
- [ ] `FlagsGameServiceConfig` updated with production IDs
- [ ] `flags_quiz_app_provider.dart` using production config
- [ ] Tested on iOS device with sandbox account
- [ ] Tested on Android device with tester account

---

## Resources

- [Game Center Programming Guide](https://developer.apple.com/documentation/gamekit)
- [Play Games Services Documentation](https://developers.google.com/games/services)
- [games_services Flutter Package](https://pub.dev/packages/games_services)
