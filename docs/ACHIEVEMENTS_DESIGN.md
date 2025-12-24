# Achievements Design - Flags Quiz

This document defines all achievements for the Flags Quiz app.

## Achievement Categories

1. **Beginner** - First steps achievements
2. **Progress** - Cumulative milestones
3. **Mastery** - Score-based achievements
4. **Speed** - Time-based achievements
5. **Streak** - Consecutive correct answers
6. **Challenge** - Challenge mode specific
7. **Explorer** - Category/region coverage
8. **Dedication** - Consistency and time played
9. **Skill** - Special gameplay achievements

---

## All Achievements

### 1. Beginner (First Steps)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `first_quiz` | First Steps | Complete your first quiz | Complete 1 quiz | 🎯 |
| `first_perfect` | Perfectionist | Get your first perfect score | 1 perfect score | ⭐ |
| `first_europe` | European Journey | Complete a quiz about Europe | Complete Europe category | 🇪🇺 |
| `first_challenge` | Challenger | Complete your first challenge mode | Complete any challenge | 🏆 |

### 2. Progress (Cumulative Milestones)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `quizzes_10` | Getting Started | Complete 10 quizzes | 10 completed sessions | 📚 |
| `quizzes_50` | Quiz Enthusiast | Complete 50 quizzes | 50 completed sessions | 📖 |
| `quizzes_100` | Quiz Master | Complete 100 quizzes | 100 completed sessions | 🎓 |
| `quizzes_500` | Quiz Legend | Complete 500 quizzes | 500 completed sessions | 👑 |
| `questions_100` | Century | Answer 100 questions | 100 questions answered | 💯 |
| `questions_500` | Half Thousand | Answer 500 questions | 500 questions answered | 🔢 |
| `questions_1000` | Thousand Club | Answer 1000 questions | 1000 questions answered | 🏅 |
| `questions_5000` | Flag Expert | Answer 5000 questions | 5000 questions answered | 🌟 |
| `correct_100` | Sharp Eye | Get 100 correct answers | 100 correct answers | 👁️ |
| `correct_500` | Knowledge Keeper | Get 500 correct answers | 500 correct answers | 🧠 |
| `correct_1000` | Flag Scholar | Get 1000 correct answers | 1000 correct answers | 📜 |

### 3. Mastery (Score-Based)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `perfect_5` | Rising Star | Get 5 perfect scores | 5 perfect scores | ⭐ |
| `perfect_10` | Shining Bright | Get 10 perfect scores | 10 perfect scores | 🌟 |
| `perfect_25` | Constellation | Get 25 perfect scores | 25 perfect scores | ✨ |
| `perfect_50` | Galaxy | Get 50 perfect scores | 50 perfect scores | 🌌 |
| `score_90_10` | High Achiever | Score 90%+ in 10 quizzes | 10 sessions with 90%+ | 🏆 |
| `score_95_10` | Excellence | Score 95%+ in 10 quizzes | 10 sessions with 95%+ | 💎 |
| `no_mistakes_streak_3` | Flawless Run | Complete 3 quizzes in a row without mistakes | 3 consecutive perfect | 🔥 |

### 4. Speed (Time-Based)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `speed_demon` | Speed Demon | Complete a quiz in under 60 seconds | Session duration < 60s | ⚡ |
| `lightning` | Lightning Fast | Complete a quiz in under 30 seconds | Session duration < 30s | 🌩️ |
| `quick_answer_10` | Quick Thinker | Answer 10 questions in under 2 seconds each | 10 answers < 2s | 💨 |
| `quick_answer_50` | Rapid Fire | Answer 50 questions in under 2 seconds each | 50 answers < 2s (cumulative) | 🚀 |

### 5. Streak (Consecutive Correct)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `streak_10` | On Fire | Get 10 correct answers in a row | Current/best streak >= 10 | 🔥 |
| `streak_25` | Unstoppable | Get 25 correct answers in a row | Best streak >= 25 | 💪 |
| `streak_50` | Legendary | Get 50 correct answers in a row | Best streak >= 50 | 🏅 |
| `streak_100` | Mythical | Get 100 correct answers in a row | Best streak >= 100 | 🐉 |

### 6. Challenge Mode

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `survival_complete` | Survivor | Complete Survival mode | Complete survival mode | ❤️ |
| `survival_perfect` | Immortal | Complete Survival mode with all lives | Survival + 0 lives lost | 💖 |
| `blitz_complete` | Blitz Master | Complete Blitz mode | Complete blitz mode | ⚡ |
| `blitz_perfect` | Lightning God | Complete Blitz mode with perfect score | Blitz + 100% | 🌩️ |
| `time_attack_20` | Time Warrior | Answer 20+ correct in Time Attack | Time attack with 20+ correct | ⏱️ |
| `time_attack_30` | Time Lord | Answer 30+ correct in Time Attack | Time attack with 30+ correct | ⏰ |
| `marathon_50` | Endurance | Answer 50 questions in Marathon | Marathon with 50+ questions | 🏃 |
| `marathon_100` | Ultra Marathon | Answer 100 questions in Marathon | Marathon with 100+ questions | 🏃‍♂️ |
| `speed_run_fast` | Speed Runner | Complete Speed Run in under 2 minutes | Speed run < 120s | 🏎️ |
| `all_challenges` | Challenge Champion | Complete all challenge modes | Complete all 5 challenges | 🏆 |

### 7. Explorer (Category Coverage)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `explore_africa` | African Explorer | Complete a quiz about Africa | Complete Africa category | 🌍 |
| `explore_asia` | Asian Explorer | Complete a quiz about Asia | Complete Asia category | 🌏 |
| `explore_europe` | European Explorer | Complete a quiz about Europe | Complete Europe category | 🌍 |
| `explore_north_america` | North American Explorer | Complete a quiz about North America | Complete NA category | 🌎 |
| `explore_south_america` | South American Explorer | Complete a quiz about South America | Complete SA category | 🌎 |
| `explore_oceania` | Oceanian Explorer | Complete a quiz about Oceania | Complete Oceania category | 🌊 |
| `world_traveler` | World Traveler | Complete a quiz in every continent | Complete all 6 categories | 🌐 |
| `master_europe` | Europe Master | Get 5 perfect scores in Europe | 5 perfect in Europe | 🏰 |
| `master_asia` | Asia Master | Get 5 perfect scores in Asia | 5 perfect in Asia | 🏯 |
| `master_africa` | Africa Master | Get 5 perfect scores in Africa | 5 perfect in Africa | 🦁 |
| `master_all` | World Master | Get 5 perfect scores in All Countries | 5 perfect in All | 🌍 |
| `complete_all_flags` | Flag Collector | Answer every flag correctly at least once | All unique flags correct | 🚩 |

### 8. Dedication (Time & Consistency)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `time_1h` | Dedicated | Play for 1 hour total | Total time >= 1 hour | ⏰ |
| `time_5h` | Committed | Play for 5 hours total | Total time >= 5 hours | 📅 |
| `time_10h` | Devoted | Play for 10 hours total | Total time >= 10 hours | 🗓️ |
| `time_24h` | Flag Fanatic | Play for 24 hours total | Total time >= 24 hours | 🎖️ |
| `days_3` | Regular | Play 3 days in a row | 3 consecutive days | 📆 |
| `days_7` | Weekly Warrior | Play 7 days in a row | 7 consecutive days | 🗓️ |
| `days_14` | Two Week Streak | Play 14 days in a row | 14 consecutive days | 📅 |
| `days_30` | Monthly Master | Play 30 days in a row | 30 consecutive days | 🏆 |

### 9. Skill (Special Gameplay)

| ID | Name | Description | Trigger | Icon |
|----|------|-------------|---------|------|
| `no_hints` | Purist | Complete a quiz without using any hints | Session with 0 hints used | 🎯 |
| `no_hints_10` | True Expert | Complete 10 quizzes without hints | 10 sessions with 0 hints | 🔮 |
| `no_skip` | Determined | Complete a quiz without skipping | Session with 0 skips | 💪 |
| `flawless` | Flawless Victory | Complete with perfect score, no hints, no lives lost | Perfect + no hints + no lives lost | 💎 |
| `comeback` | Comeback King | Win a quiz after losing 4 lives | Complete with livesUsed >= 4 | 👑 |
| `clutch` | Clutch Player | Complete Survival with only 1 life remaining | Survival with 1 life left | 😅 |

---

## Achievement Tiers

Each achievement has a rarity/tier based on difficulty:

| Tier | Color | Examples |
|------|-------|----------|
| **Common** | Bronze 🥉 | First quiz, 10 quizzes, explore categories |
| **Uncommon** | Silver 🥈 | 50 quizzes, perfect 5, streak 10 |
| **Rare** | Gold 🥇 | 100 quizzes, perfect 25, streak 50, challenge complete |
| **Epic** | Purple 💜 | 500 quizzes, perfect 50, all challenges, world master |
| **Legendary** | Diamond 💎 | Flawless, streak 100, mythical achievements |

---

## Data Requirements

### From Existing Tables

| Achievement Type | Data Source |
|-----------------|-------------|
| Quiz count | `GlobalStatistics.totalSessions`, `totalCompletedSessions` |
| Perfect scores | `GlobalStatistics.totalPerfectScores` |
| Streaks | `GlobalStatistics.currentStreak`, `bestStreak` |
| Questions answered | `GlobalStatistics.totalQuestionsAnswered` |
| Correct answers | `GlobalStatistics.totalCorrectAnswers` |
| Time played | `GlobalStatistics.totalTimePlayedSeconds` |
| Hints used | `QuizSession.hintsUsed5050`, `hintsUsedSkip` |
| Lives used | `QuizSession.livesUsed` |
| Session duration | `QuizSession.durationSeconds` |
| Category stats | `QuizTypeStatistics` per category |
| Daily play | `DailyStatistics` for consecutive days |
| Per-question speed | `QuestionAnswer.timeSpentSeconds` |

### New Table Needed

```sql
CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    achievement_id TEXT NOT NULL UNIQUE,
    unlocked_at INTEGER NOT NULL,
    progress INTEGER DEFAULT 0,
    target INTEGER DEFAULT 1,
    notified INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);
```

### New Fields Needed (Optional Optimization)

```sql
-- Add to global_statistics table
ALTER TABLE global_statistics ADD COLUMN consecutive_days_played INTEGER DEFAULT 0;
ALTER TABLE global_statistics ADD COLUMN quick_answers_count INTEGER DEFAULT 0;
```

---

## Achievement Unlock Flow

1. **Trigger Event** - Quiz completed, answer submitted, etc.
2. **Check Conditions** - Query relevant data
3. **Unlock Achievement** - Insert into achievements table
4. **Show Notification** - Display achievement popup
5. **Update Progress** - For progressive achievements

---

## UI Components Needed

1. **Achievement Notification** - Popup when achievement unlocked
2. **Achievements Screen** - List all achievements with progress
3. **Achievement Card** - Individual achievement display
4. **Progress Indicator** - For progressive achievements (7/10)

---

## Summary

| Category | Count |
|----------|-------|
| Beginner | 4 |
| Progress | 11 |
| Mastery | 7 |
| Speed | 4 |
| Streak | 4 |
| Challenge | 10 |
| Explorer | 12 |
| Dedication | 8 |
| Skill | 6 |
| **Total** | **66** |

---

## Implementation Priority

### Phase 1 (MVP)
- Beginner achievements (4)
- Basic progress achievements (quizzes_10, quizzes_50, questions_100)
- First perfect (perfect_5)
- Basic streak (streak_10)
- Explorer achievements (categories)
- Achievement notification UI
- Achievements screen

### Phase 2
- All progress achievements
- All mastery achievements
- All streak achievements
- Challenge mode achievements

### Phase 3
- Speed achievements
- Dedication (consecutive days)
- Skill achievements
- Tiers/rarity display
