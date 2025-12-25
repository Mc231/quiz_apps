# Achievements Testing Guide

**Purpose:** Manual testing checklist for all 67 achievements in Flags Quiz.

**Last Updated:** 2025-12-25

**Instructions:**
1. Test each achievement by performing the trigger action
2. Mark with `[x]` when verified working
3. Add notes for any issues found

---

## Testing Summary

| Category | Total | Tested | Status |
|----------|-------|--------|--------|
| Beginner | 3 | 0 | Not Started |
| Progress | 11 | 0 | Not Started |
| Mastery | 7 | 0 | Not Started |
| Speed | 4 | 0 | Not Started |
| Streak | 4 | 0 | Not Started |
| Challenge | 10 | 0 | Not Started |
| Dedication | 8 | 0 | Not Started |
| Skill | 6 | 0 | Not Started |
| Flags Explorer | 7 | 0 | Not Started |
| Flags Mastery | 6 | 0 | Not Started |
| Flags Collection | 1 | 0 | Not Started |
| **Total** | **67** | **0** | **Not Started** |

---

## Part 1: Generic Base Achievements (53)

### 1.1 Beginner (3)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `first_quiz` | 🎯 | First Steps | 1 completed session | Complete any quiz |
| [ ] | `first_perfect` | ⭐ | Perfectionist | 1 perfect score | Complete a quiz with 100% score |
| [ ] | `first_challenge` | 🏆 | Challenger | 1 challenge completed | Complete any challenge mode |

**Notes:**
-

---

### 1.2 Progress (11)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `quizzes_10` | 📚 | Getting Started | 10 completed sessions | Complete 10 quizzes total |
| [ ] | `quizzes_50` | 📖 | Quiz Enthusiast | 50 completed sessions | Complete 50 quizzes total |
| [ ] | `quizzes_100` | 🎓 | Quiz Master | 100 completed sessions | Complete 100 quizzes total |
| [ ] | `quizzes_500` | 👑 | Quiz Legend | 500 completed sessions | Complete 500 quizzes total |
| [ ] | `questions_100` | 💯 | Century | 100 questions answered | Answer 100 questions total |
| [ ] | `questions_500` | 🔢 | Half Thousand | 500 questions answered | Answer 500 questions total |
| [ ] | `questions_1000` | 🧮 | Thousand Club | 1000 questions answered | Answer 1000 questions total |
| [ ] | `questions_5000` | 🧠 | Expert | 5000 questions answered | Answer 5000 questions total |
| [ ] | `correct_100` | ✅ | Sharp Eye | 100 correct answers | Get 100 correct answers total |
| [ ] | `correct_500` | 🎯 | Knowledge Keeper | 500 correct answers | Get 500 correct answers total |
| [ ] | `correct_1000` | 🏅 | Scholar | 1000 correct answers | Get 1000 correct answers total |

**Notes:**
- These are cumulative achievements - progress carries across sessions
- Check GlobalStatistics for current counts

---

### 1.3 Mastery (7)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `perfect_5` | ⭐ | Rising Star | 5 perfect scores | Get 5 quizzes with 100% score |
| [ ] | `perfect_10` | 🌟 | Shining Bright | 10 perfect scores | Get 10 quizzes with 100% score |
| [ ] | `perfect_25` | ✨ | Constellation | 25 perfect scores | Get 25 quizzes with 100% score |
| [ ] | `perfect_50` | 💫 | Galaxy | 50 perfect scores | Get 50 quizzes with 100% score |
| [ ] | `score_90_10` | 📈 | High Achiever | 10 sessions with ≥90% | Score 90%+ in 10 quizzes |
| [ ] | `score_95_10` | 🔥 | Excellence | 10 sessions with ≥95% | Score 95%+ in 10 quizzes |
| [ ] | `perfect_streak_3` | 🔮 | Flawless Run | 3 consecutive perfect | Get 3 perfect scores in a row |

**Notes:**
- Perfect score = 100% correct answers
- `perfect_streak_3` requires consecutive sessions, not cumulative

---

### 1.4 Speed (4)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `speed_demon` | 💨 | Speed Demon | Session duration < 60s | Complete a quiz in under 60 seconds |
| [ ] | `lightning` | ⚡ | Lightning Fast | Session duration < 30s | Complete a quiz in under 30 seconds |
| [ ] | `quick_answer_10` | 🚀 | Quick Thinker | 10 answers < 2s | Answer 10 questions in under 2 seconds each (single session) |
| [ ] | `quick_answer_50` | 🏎️ | Rapid Fire | 50 quick answers cumulative | Answer 50 questions in under 2 seconds each (across all sessions) |

**Notes:**
- Use a small category (e.g., Oceania) for faster testing
- Timer starts when question appears

---

### 1.5 Streak (4)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `streak_10` | 🔥 | On Fire | Best streak ≥ 10 | Get 10 correct answers in a row |
| [ ] | `streak_25` | 💪 | Unstoppable | Best streak ≥ 25 | Get 25 correct answers in a row |
| [ ] | `streak_50` | 🌋 | Legendary Streak | Best streak ≥ 50 | Get 50 correct answers in a row |
| [ ] | `streak_100` | 🐉 | Mythical | Best streak ≥ 100 | Get 100 correct answers in a row |

**Notes:**
- Streak tracks consecutive correct answers within a session
- Best streak is persisted in GlobalStatistics
- Can span across question replenishment in Endless mode

---

### 1.6 Challenge Mode (10)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `survival_complete` | ❤️ | Survivor | Complete Survival mode | Complete any Survival challenge |
| [ ] | `survival_perfect` | 💖 | Immortal | Survival + 0 lives lost | Complete Survival without losing any life |
| [ ] | `blitz_complete` | ⚡ | Blitz Master | Complete Blitz mode | Complete any Blitz challenge |
| [ ] | `blitz_perfect` | 🌩️ | Lightning God | Blitz + 100% | Complete Blitz with perfect score |
| [ ] | `time_attack_20` | ⏱️ | Time Warrior | Time Attack ≥ 20 correct | Answer 20+ correct in Time Attack |
| [ ] | `time_attack_30` | ⏰ | Time Lord | Time Attack ≥ 30 correct | Answer 30+ correct in Time Attack |
| [ ] | `marathon_50` | 🏃 | Endurance | Marathon ≥ 50 questions | Answer 50 questions in Marathon |
| [ ] | `marathon_100` | 🏃‍♂️ | Ultra Marathon | Marathon ≥ 100 questions | Answer 100 questions in Marathon |
| [ ] | `speed_run_fast` | 🏁 | Speed Runner | Speed Run < 120s | Complete Speed Run in under 2 minutes |
| [ ] | `all_challenges` | 🎖️ | Challenge Champion | Complete all 5 challenges | Complete Survival, Blitz, Time Attack, Marathon, Speed Run |

**Notes:**
- Each challenge mode has specific rules
- Survival: 3 lives, lose one on wrong answer
- Blitz: 5 seconds per question
- Time Attack: 60 seconds total, answer as many as possible
- Marathon: Endless mode, track total questions
- Speed Run: 20 questions, fastest time wins

---

### 1.7 Dedication (8)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `time_1h` | ⏰ | Dedicated | Total time ≥ 1 hour | Play for 1 hour total |
| [ ] | `time_5h` | 🕐 | Committed | Total time ≥ 5 hours | Play for 5 hours total |
| [ ] | `time_10h` | 🕛 | Devoted | Total time ≥ 10 hours | Play for 10 hours total |
| [ ] | `time_24h` | ⌛ | Fanatic | Total time ≥ 24 hours | Play for 24 hours total |
| [ ] | `days_3` | 📅 | Regular | 3 consecutive days | Play 3 days in a row |
| [ ] | `days_7` | 🗓️ | Weekly Warrior | 7 consecutive days | Play 7 days in a row |
| [ ] | `days_14` | 📆 | Two Week Streak | 14 consecutive days | Play 14 days in a row |
| [ ] | `days_30` | 🏛️ | Monthly Master | 30 consecutive days | Play 30 days in a row |

**Notes:**
- Time is cumulative across all sessions
- Consecutive days require at least 1 completed quiz per day
- Day resets at midnight local time

---

### 1.8 Skill (6)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `no_hints` | 🧩 | Purist | Session with 0 hints | Complete a quiz without using any hints |
| [ ] | `no_hints_10` | 💎 | True Expert | 10 sessions with 0 hints | Complete 10 quizzes without hints |
| [ ] | `no_skip` | 🎯 | Determined | Session with 0 skips | Complete a quiz without skipping any question |
| [ ] | `flawless` | 👑 | Flawless Victory | Perfect + no hints + no lives | Get 100%, use 0 hints, lose 0 lives |
| [ ] | `comeback` | 🦸 | Comeback King | Complete with ≥4 lives lost | Win a quiz after losing 4+ lives (requires 5+ lives mode) |
| [ ] | `clutch` | 🎪 | Clutch Player | Survival with 1 life left | Complete Survival with exactly 1 life remaining |

**Notes:**
- `flawless` is Legendary tier - very difficult
- `comeback` requires a mode with 5+ lives
- `clutch` requires completing Survival after losing 2 lives

---

## Part 2: Flags Quiz Specific Achievements (14)

### 2.1 Explorer (7)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `explore_africa` | 🌍 | African Explorer | Complete Africa category | Complete any Africa quiz |
| [ ] | `explore_asia` | 🌏 | Asian Explorer | Complete Asia category | Complete any Asia quiz |
| [ ] | `explore_europe` | 🇪🇺 | European Explorer | Complete Europe category | Complete any Europe quiz |
| [ ] | `explore_north_america` | 🗽 | North American Explorer | Complete NA category | Complete any North America quiz |
| [ ] | `explore_south_america` | 🌎 | South American Explorer | Complete SA category | Complete any South America quiz |
| [ ] | `explore_oceania` | 🏝️ | Oceanian Explorer | Complete Oceania category | Complete any Oceania quiz |
| [ ] | `world_traveler` | ✈️ | World Traveler | Complete all 6 categories | Complete at least one quiz in each continent |

**Notes:**
- Each explorer achievement triggers on first completion of that category
- World Traveler requires all 6 continents completed

---

### 2.2 Flags Mastery (6)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `master_europe` | 🏰 | Europe Master | 5 perfect in Europe | Get 5 perfect scores in Europe quizzes |
| [ ] | `master_asia` | 🏯 | Asia Master | 5 perfect in Asia | Get 5 perfect scores in Asia quizzes |
| [ ] | `master_africa` | 🦁 | Africa Master | 5 perfect in Africa | Get 5 perfect scores in Africa quizzes |
| [ ] | `master_americas` | 🦅 | Americas Master | 5 perfect in NA or SA | Get 5 perfect scores in North or South America |
| [ ] | `master_oceania` | 🐨 | Oceania Master | 5 perfect in Oceania | Get 5 perfect scores in Oceania quizzes |
| [ ] | `master_world` | 🌐 | World Master | 5 perfect in All Countries | Get 5 perfect scores in "All Countries" category |

**Notes:**
- Requires 100% score (perfect) in the specific category
- Americas counts both North and South America together

---

### 2.3 Flags Collection (1)

| Status | ID | Icon | Name | Trigger | How to Test |
|--------|-----|------|------|---------|-------------|
| [ ] | `flag_collector` | 🏳️‍🌈 | Flag Collector | All unique flags correct | Answer every flag correctly at least once |

**Notes:**
- Legendary tier - requires answering all ~195 flags correctly
- Progress tracked per unique flag ID
- May need to play multiple times to encounter all flags

---

## Testing Tips

### Quick Testing
1. **First achievements**: Start with Beginner category - complete one quiz
2. **Streak testing**: Use Oceania (27 flags) for manageable streak testing
3. **Speed testing**: Use smaller categories with flags you know well

### Database Inspection
Check SQLite database for:
- `global_statistics` table: cumulative counts, best streak
- `achievements` table: unlocked status, progress
- `quiz_sessions` table: session data

### Reset for Testing
To reset achievements:
1. Clear app data (Settings > Apps > Flags Quiz > Clear Data)
2. Or delete the SQLite database file

### Common Issues to Check
- [ ] Achievement notification appears on unlock
- [ ] Sound effect plays on unlock
- [ ] Haptic feedback triggers on unlock
- [ ] Progress bar updates correctly
- [ ] Hidden achievements reveal on unlock
- [ ] Points counter updates
- [ ] Achievement counter updates

---

## Test Log

### Session 1: [Date]
**Tester:**
**Device:**
**App Version:**

**Achievements Tested:**
-

**Issues Found:**
-

---

### Session 2: [Date]
**Tester:**
**Device:**
**App Version:**

**Achievements Tested:**
-

**Issues Found:**
-

---

## Known Issues

| Achievement | Issue | Status |
|-------------|-------|--------|
| - | - | - |

---

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| QA Tester | | | |
