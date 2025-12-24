# Achievements Design

This document defines the achievements system architecture and all achievements.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  shared_services                                        │
│  ─────────────────────────────────────────────────────  │
│  • Achievement model                                    │
│  • AchievementRepository (database)                     │
│  • AchievementEngine (check & unlock logic)             │
│  • AchievementTrigger types                             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  quiz_engine                                            │
│  ─────────────────────────────────────────────────────  │
│  • BaseAchievements (~50 generic definitions)           │
│  • AchievementNotification widget                       │
│  • AchievementsScreen widget                            │
│  • AchievementCard widget                               │
└─────────────────────────────────────────────────────────┘
                          │
                          │ extends / adds
                          ▼
┌─────────────────────────────────────────────────────────┐
│  apps/flagsquiz (or any quiz app)                       │
│  ─────────────────────────────────────────────────────  │
│  • FlagsAchievements (app-specific definitions)         │
│  • Category-based achievements                          │
│  • Custom themed names/icons                            │
└─────────────────────────────────────────────────────────┘
```

---

## Achievement Tiers

| Tier | Color | Points | Difficulty |
|------|-------|--------|------------|
| **Common** | Bronze 🥉 | 10 | Easy, first steps |
| **Uncommon** | Silver 🥈 | 25 | Some effort required |
| **Rare** | Gold 🥇 | 50 | Significant progress |
| **Epic** | Purple 💜 | 100 | Major milestone |
| **Legendary** | Diamond 💎 | 250 | Exceptional achievement |

---

## Part 1: Generic Base Achievements

These achievements work for ANY quiz app and are defined in `quiz_engine`.

### 1.1 Beginner (First Steps)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `first_quiz` | 🎯 | First Steps | Complete your first quiz | 1 completed session | Common |
| `first_perfect` | ⭐ | Perfectionist | Get your first perfect score | 1 perfect score | Common |
| `first_challenge` | 🏆 | Challenger | Complete your first challenge mode | 1 challenge completed | Common |

### 1.2 Progress (Cumulative Milestones)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `quizzes_10` | 📚 | Getting Started | Complete 10 quizzes | 10 completed sessions | Common |
| `quizzes_50` | 📖 | Quiz Enthusiast | Complete 50 quizzes | 50 completed sessions | Uncommon |
| `quizzes_100` | 🎓 | Quiz Master | Complete 100 quizzes | 100 completed sessions | Rare |
| `quizzes_500` | 👑 | Quiz Legend | Complete 500 quizzes | 500 completed sessions | Epic |
| `questions_100` | 💯 | Century | Answer 100 questions | 100 questions answered | Common |
| `questions_500` | 🔢 | Half Thousand | Answer 500 questions | 500 questions answered | Uncommon |
| `questions_1000` | 🧮 | Thousand Club | Answer 1000 questions | 1000 questions answered | Rare |
| `questions_5000` | 🧠 | Expert | Answer 5000 questions | 5000 questions answered | Epic |
| `correct_100` | ✅ | Sharp Eye | Get 100 correct answers | 100 correct answers | Common |
| `correct_500` | 🎯 | Knowledge Keeper | Get 500 correct answers | 500 correct answers | Uncommon |
| `correct_1000` | 🏅 | Scholar | Get 1000 correct answers | 1000 correct answers | Rare |

### 1.3 Mastery (Score-Based)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `perfect_5` | ⭐ | Rising Star | Get 5 perfect scores | 5 perfect scores | Uncommon |
| `perfect_10` | 🌟 | Shining Bright | Get 10 perfect scores | 10 perfect scores | Rare |
| `perfect_25` | ✨ | Constellation | Get 25 perfect scores | 25 perfect scores | Epic |
| `perfect_50` | 💫 | Galaxy | Get 50 perfect scores | 50 perfect scores | Legendary |
| `score_90_10` | 📈 | High Achiever | Score 90%+ in 10 quizzes | 10 sessions with ≥90% | Uncommon |
| `score_95_10` | 🔥 | Excellence | Score 95%+ in 10 quizzes | 10 sessions with ≥95% | Rare |
| `perfect_streak_3` | 🔮 | Flawless Run | Get 3 perfect scores in a row | 3 consecutive perfect | Epic |

### 1.4 Speed (Time-Based)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `speed_demon` | 💨 | Speed Demon | Complete a quiz in under 60 seconds | Session duration < 60s | Uncommon |
| `lightning` | ⚡ | Lightning Fast | Complete a quiz in under 30 seconds | Session duration < 30s | Rare |
| `quick_answer_10` | 🚀 | Quick Thinker | Answer 10 questions in under 2 seconds each | 10 answers < 2s | Uncommon |
| `quick_answer_50` | 🏎️ | Rapid Fire | Answer 50 questions in under 2 seconds each | 50 quick answers (cumulative) | Rare |

### 1.5 Streak (Consecutive Correct)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `streak_10` | 🔥 | On Fire | Get 10 correct answers in a row | Best streak ≥ 10 | Uncommon |
| `streak_25` | 💪 | Unstoppable | Get 25 correct answers in a row | Best streak ≥ 25 | Rare |
| `streak_50` | 🌋 | Legendary Streak | Get 50 correct answers in a row | Best streak ≥ 50 | Epic |
| `streak_100` | 🐉 | Mythical | Get 100 correct answers in a row | Best streak ≥ 100 | Legendary |

### 1.6 Challenge Mode

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `survival_complete` | ❤️ | Survivor | Complete Survival mode | Complete survival mode | Uncommon |
| `survival_perfect` | 💖 | Immortal | Complete Survival without losing a life | Survival + 0 lives lost | Rare |
| `blitz_complete` | ⚡ | Blitz Master | Complete Blitz mode | Complete blitz mode | Uncommon |
| `blitz_perfect` | 🌩️ | Lightning God | Complete Blitz with perfect score | Blitz + 100% | Epic |
| `time_attack_20` | ⏱️ | Time Warrior | Answer 20+ correct in Time Attack | Time attack ≥ 20 correct | Uncommon |
| `time_attack_30` | ⏰ | Time Lord | Answer 30+ correct in Time Attack | Time attack ≥ 30 correct | Rare |
| `marathon_50` | 🏃 | Endurance | Answer 50 questions in Marathon | Marathon ≥ 50 questions | Uncommon |
| `marathon_100` | 🏃‍♂️ | Ultra Marathon | Answer 100 questions in Marathon | Marathon ≥ 100 questions | Rare |
| `speed_run_fast` | 🏁 | Speed Runner | Complete Speed Run in under 2 minutes | Speed run < 120s | Rare |
| `all_challenges` | 🎖️ | Challenge Champion | Complete all challenge modes | Complete all 5 challenges | Epic |

### 1.7 Dedication (Time & Consistency)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `time_1h` | ⏰ | Dedicated | Play for 1 hour total | Total time ≥ 1 hour | Common |
| `time_5h` | 🕐 | Committed | Play for 5 hours total | Total time ≥ 5 hours | Uncommon |
| `time_10h` | 🕛 | Devoted | Play for 10 hours total | Total time ≥ 10 hours | Rare |
| `time_24h` | ⌛ | Fanatic | Play for 24 hours total | Total time ≥ 24 hours | Epic |
| `days_3` | 📅 | Regular | Play 3 days in a row | 3 consecutive days | Common |
| `days_7` | 🗓️ | Weekly Warrior | Play 7 days in a row | 7 consecutive days | Uncommon |
| `days_14` | 📆 | Two Week Streak | Play 14 days in a row | 14 consecutive days | Rare |
| `days_30` | 🏛️ | Monthly Master | Play 30 days in a row | 30 consecutive days | Epic |

### 1.8 Skill (Special Gameplay)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `no_hints` | 🧩 | Purist | Complete a quiz without using hints | Session with 0 hints | Uncommon |
| `no_hints_10` | 💎 | True Expert | Complete 10 quizzes without hints | 10 sessions with 0 hints | Rare |
| `no_skip` | 🎯 | Determined | Complete a quiz without skipping | Session with 0 skips | Common |
| `flawless` | 👑 | Flawless Victory | Perfect score, no hints, no lives lost | Perfect + no hints + no lives | Legendary |
| `comeback` | 🦸 | Comeback King | Win after losing 4+ lives | Complete with ≥4 lives lost | Rare |
| `clutch` | 🎪 | Clutch Player | Complete Survival with 1 life remaining | Survival with 1 life left | Rare |

### Generic Achievements Summary

| Category | Count |
|----------|-------|
| Beginner | 3 |
| Progress | 11 |
| Mastery | 7 |
| Speed | 4 |
| Streak | 4 |
| Challenge | 10 |
| Dedication | 8 |
| Skill | 6 |
| **Total Generic** | **53** |

---

## Part 2: App-Specific Achievements (Flags Quiz)

These achievements are specific to the Flags Quiz app and are defined in `apps/flagsquiz`.

### 2.1 Explorer (Category Coverage)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `explore_africa` | 🌍 | African Explorer | Complete a quiz about Africa | Complete Africa category | Common |
| `explore_asia` | 🌏 | Asian Explorer | Complete a quiz about Asia | Complete Asia category | Common |
| `explore_europe` | 🇪🇺 | European Explorer | Complete a quiz about Europe | Complete Europe category | Common |
| `explore_north_america` | 🗽 | North American Explorer | Complete a quiz about North America | Complete NA category | Common |
| `explore_south_america` | 🌎 | South American Explorer | Complete a quiz about South America | Complete SA category | Common |
| `explore_oceania` | 🏝️ | Oceanian Explorer | Complete a quiz about Oceania | Complete Oceania category | Common |
| `world_traveler` | ✈️ | World Traveler | Complete a quiz in every continent | Complete all 6 categories | Rare |

### 2.2 Mastery (Region Mastery)

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `master_europe` | 🏰 | Europe Master | Get 5 perfect scores in Europe | 5 perfect in Europe | Rare |
| `master_asia` | 🏯 | Asia Master | Get 5 perfect scores in Asia | 5 perfect in Asia | Rare |
| `master_africa` | 🦁 | Africa Master | Get 5 perfect scores in Africa | 5 perfect in Africa | Rare |
| `master_americas` | 🦅 | Americas Master | Get 5 perfect scores in NA or SA | 5 perfect in Americas | Rare |
| `master_oceania` | 🐨 | Oceania Master | Get 5 perfect scores in Oceania | 5 perfect in Oceania | Rare |
| `master_world` | 🌐 | World Master | Get 5 perfect scores in All Countries | 5 perfect in All | Epic |

### 2.3 Collection

| ID | Icon | Name | Description | Trigger | Tier |
|----|------|------|-------------|---------|------|
| `flag_collector` | 🏳️‍🌈 | Flag Collector | Answer every flag correctly at least once | All unique flags correct | Legendary |

### Flags Quiz App-Specific Summary

| Category | Count |
|----------|-------|
| Explorer | 7 |
| Mastery | 6 |
| Collection | 1 |
| **Total App-Specific** | **14** |

---

## Total Achievements for Flags Quiz

| Source | Count |
|--------|-------|
| Generic (Base) | 53 |
| App-Specific | 14 |
| **Total** | **67** |

---

## Database Schema

### New Table: `achievements`

```sql
CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    achievement_id TEXT NOT NULL UNIQUE,
    unlocked INTEGER NOT NULL DEFAULT 0,
    unlocked_at INTEGER,
    progress INTEGER DEFAULT 0,
    target INTEGER DEFAULT 1,
    notified INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_achievements_unlocked ON achievements(unlocked);
CREATE INDEX idx_achievements_achievement_id ON achievements(achievement_id);
```

### Optional: Add to `global_statistics`

```sql
ALTER TABLE global_statistics ADD COLUMN consecutive_days_played INTEGER DEFAULT 0;
ALTER TABLE global_statistics ADD COLUMN quick_answers_count INTEGER DEFAULT 0;
ALTER TABLE global_statistics ADD COLUMN sessions_no_hints INTEGER DEFAULT 0;
ALTER TABLE global_statistics ADD COLUMN high_score_90_count INTEGER DEFAULT 0;
ALTER TABLE global_statistics ADD COLUMN high_score_95_count INTEGER DEFAULT 0;
```

---

## Implementation Code Structure

### shared_services

```
lib/src/achievements/
├── models/
│   ├── achievement.dart              # Achievement model
│   ├── achievement_tier.dart         # Tier enum (common, rare, etc.)
│   ├── achievement_trigger.dart      # Trigger types
│   └── achievement_progress.dart     # Progress tracking
├── data_sources/
│   └── achievement_data_source.dart  # Database operations
├── repositories/
│   └── achievement_repository.dart   # Repository interface
├── engine/
│   └── achievement_engine.dart       # Check & unlock logic
└── achievements_exports.dart
```

### quiz_engine

```
lib/src/achievements/
├── base_achievements.dart            # 53 generic achievement definitions
├── widgets/
│   ├── achievement_notification.dart # Popup on unlock
│   ├── achievement_card.dart         # Individual card
│   └── achievements_screen.dart      # Full list screen
└── achievements_exports.dart
```

### apps/flagsquiz

```
lib/achievements/
└── flags_achievements.dart           # 14 app-specific definitions
```

---

## Achievement Model

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;           // Emoji or asset path
  final AchievementTier tier;
  final int points;
  final AchievementTrigger trigger;
  final int target;            // For progressive (e.g., 10 quizzes)

  const Achievement({...});
}

enum AchievementTier { common, uncommon, rare, epic, legendary }

sealed class AchievementTrigger {
  const AchievementTrigger();

  // Cumulative: total count reaches target
  const factory AchievementTrigger.cumulative(String field) = CumulativeTrigger;

  // Threshold: single session meets condition
  const factory AchievementTrigger.threshold(String field, num value) = ThresholdTrigger;

  // Streak: consecutive count
  const factory AchievementTrigger.streak(int count) = StreakTrigger;

  // Category: complete specific category
  const factory AchievementTrigger.category(String categoryId) = CategoryTrigger;

  // Composite: multiple conditions
  const factory AchievementTrigger.composite(List<AchievementTrigger> triggers) = CompositeTrigger;
}
```

---

## Implementation Priority

### Phase 8.1: Foundation
- Achievement model & trigger types
- Database table & data source
- Achievement repository

### Phase 8.2: Engine
- Achievement engine (check logic)
- Integration with QuizBloc
- Unlock detection

### Phase 8.3: UI
- Achievement notification popup
- Achievements screen
- Achievement card widget

### Phase 8.4: Definitions
- Base achievements (53 generic)
- Flags achievements (14 app-specific)
- Integration in FlagsQuiz app

---

## Design Decisions (Finalized)

| Question | Decision |
|----------|----------|
| **Show locked achievements?** | Show Common/Uncommon/Rare grayed out. Hide Epic/Legendary until unlocked. |
| **Show progress?** | Yes, show progress bar (7/10) for progressive achievements |
| **Points system?** | Yes, with achievement counter (12/67) and points counter (450 pts) |
| **Sound/haptic on unlock?** | Yes, play sound effect + haptic feedback |
| **Where to show?** | New "Achievements" tab in bottom navigation |
| **Sync across devices?** | Future consideration (requires backend) |

---

## Visibility Rules

| Tier | Visibility |
|------|------------|
| Common 🥉 | Always visible (grayed if locked) |
| Uncommon 🥈 | Always visible (grayed if locked) |
| Rare 🥇 | Always visible (grayed if locked) |
| Epic 💜 | Hidden until unlocked (shows as "???") |
| Legendary 💎 | Hidden until unlocked (shows as "???") |

---

## UI Components

### Achievement Header
```
┌─────────────────────────────────────┐
│  🏆 Achievements                    │
│  ────────────────────────────────── │
│  12/67 Unlocked     ⭐ 450 pts      │
└─────────────────────────────────────┘
```

### Achievement Card (Unlocked)
```
┌─────────────────────────────────────┐
│  🎯  First Steps              🥉 10 │
│       Complete your first quiz      │
│       ✅ Unlocked                   │
└─────────────────────────────────────┘
```

### Achievement Card (In Progress)
```
┌─────────────────────────────────────┐
│  📚  Quiz Master              🥇 50 │
│       Complete 100 quizzes          │
│       ████████░░░░░░░░░░░░░  73/100 │
└─────────────────────────────────────┘
```

### Achievement Card (Locked)
```
┌─────────────────────────────────────┐
│  🔒  Rising Star              🥈 25 │
│       Get 5 perfect scores          │
│       ░░░░░░░░░░░░░░░░░░░░░   0/5   │
└─────────────────────────────────────┘
```

### Achievement Card (Hidden)
```
┌─────────────────────────────────────┐
│  ❓  Hidden Achievement       💜    │
│       Keep playing to discover!     │
└─────────────────────────────────────┘
```

### Achievement Notification (Popup)
```
┌─────────────────────────────────────┐
│  🎉 Achievement Unlocked!           │
│  ──────────────────────────────────│
│  🎯 First Steps                     │
│      Complete your first quiz       │
│                           +10 pts   │
└─────────────────────────────────────┘
```
