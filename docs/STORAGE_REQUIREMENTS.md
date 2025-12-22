# Quiz Apps Storage Requirements

## Overview

This document defines the storage architecture for the Quiz Apps monorepo, using sqflite with Repository Pattern to persist quiz sessions, questions/answers, and comprehensive statistics.

## Architecture Pattern

**Repository Pattern**: Separate data layer from business logic
- Data Sources (sqflite implementation)
- Repositories (interface between BLoC and data sources)
- Models (database entities)

## Database Tables

### 1. Quiz Sessions Table (`quiz_sessions`)

**Purpose**: Track individual quiz attempts with metadata

**Final Schema**:
```sql
CREATE TABLE quiz_sessions (
  id TEXT PRIMARY KEY,
  quiz_name TEXT NOT NULL,
  quiz_id TEXT NOT NULL,
  quiz_type TEXT NOT NULL,        -- e.g., 'flags', 'capitals', etc.
  quiz_category TEXT,              -- e.g., 'europe', 'asia', 'world', etc.
  total_questions INTEGER NOT NULL,
  total_answered INTEGER NOT NULL,
  total_correct INTEGER NOT NULL,
  total_failed INTEGER NOT NULL,
  total_skipped INTEGER NOT NULL,
  score_percentage REAL NOT NULL,
  lives_used INTEGER DEFAULT 0,    -- ✅ Track lives/hearts used
  start_time INTEGER NOT NULL,     -- Unix timestamp
  end_time INTEGER,                -- Unix timestamp, NULL if not completed
  duration_seconds INTEGER,        -- Calculated or NULL
  completion_status TEXT NOT NULL, -- 'completed', 'cancelled', 'timeout', 'failed'
  mode TEXT NOT NULL,              -- 'normal', 'timed', 'endless', etc.
  time_limit_seconds INTEGER,      -- NULL if no time limit
  hints_used_50_50 INTEGER DEFAULT 0,
  hints_used_skip INTEGER DEFAULT 0,
  app_version TEXT NOT NULL,       -- ✅ Track app version
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Design Decisions**:
- ✅ Track lives/hearts used
- ✅ Store app version for debugging/analytics
- ❌ No device/platform tracking
- ❌ No difficulty level (not needed now)
- ❌ No session hash (not needed)

---

### 2. Question Answers Table (`question_answers`)

**Purpose**: Store every question and answer for review/replay functionality

**Final Schema**:
```sql
CREATE TABLE question_answers (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  question_number INTEGER NOT NULL, -- Position in quiz (1, 2, 3...)
  question_id TEXT NOT NULL,
  question_type TEXT NOT NULL,      -- 'image', 'text', 'audio', 'video'
  question_content TEXT,            -- For text questions, or description
  question_resource_url TEXT,       -- For image/audio/video URL or asset path

  -- ✅ All answer options stored
  option_1_id TEXT NOT NULL,
  option_1_text TEXT NOT NULL,
  option_2_id TEXT NOT NULL,
  option_2_text TEXT NOT NULL,
  option_3_id TEXT NOT NULL,
  option_3_text TEXT NOT NULL,
  option_4_id TEXT NOT NULL,
  option_4_text TEXT NOT NULL,

  -- ✅ Option order as presented
  options_order TEXT NOT NULL,      -- JSON array like ["1","3","2","4"] - order presented

  correct_answer_id TEXT NOT NULL,
  correct_answer_text TEXT NOT NULL,
  user_answer_id TEXT,              -- NULL if skipped/timeout
  user_answer_text TEXT,            -- NULL if skipped/timeout
  is_correct INTEGER NOT NULL,      -- 0 or 1 (boolean)
  answer_status TEXT NOT NULL,      -- 'correct', 'incorrect', 'skipped', 'timeout'
  time_spent_seconds INTEGER,       -- Time spent on this question
  answered_at INTEGER,              -- Unix timestamp when answered
  hint_used TEXT,                   -- 'none', '50_50', 'skip'
  disabled_options TEXT,            -- JSON array of option IDs removed by 50/50

  -- ✅ Explanation for review mode
  explanation TEXT,                 -- Explanation shown after wrong answer

  created_at INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES quiz_sessions(id) ON DELETE CASCADE
);
```

**Design Decisions**:
- ✅ Store all 4 answer options with IDs and text
- ✅ Track order options were presented (for replay accuracy)
- ✅ Add explanation field for "show explanations" feature
- ❌ No difficulty rating (not needed now)
- ❌ No confidence level (not needed now)
- ❌ Asset references only, not storing images locally

---

### 3. Global Statistics Table (`global_statistics`)

**Purpose**: High-level aggregate stats across all quiz sessions

**Final Schema**:
```sql
CREATE TABLE global_statistics (
  id INTEGER PRIMARY KEY CHECK (id = 1), -- Singleton table
  total_sessions INTEGER DEFAULT 0,
  total_completed_sessions INTEGER DEFAULT 0,
  total_cancelled_sessions INTEGER DEFAULT 0,
  total_questions_answered INTEGER DEFAULT 0,
  total_correct_answers INTEGER DEFAULT 0,
  total_incorrect_answers INTEGER DEFAULT 0,
  total_skipped_questions INTEGER DEFAULT 0,
  total_time_played_seconds INTEGER DEFAULT 0,
  total_hints_50_50_used INTEGER DEFAULT 0,
  total_hints_skip_used INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  worst_score_percentage REAL DEFAULT 0,
  current_streak INTEGER DEFAULT 0,      -- Consecutive correct answers
  best_streak INTEGER DEFAULT 0,
  total_perfect_scores INTEGER DEFAULT 0, -- 100% completion sessions
  first_session_date INTEGER,            -- Unix timestamp
  last_session_date INTEGER,             -- Unix timestamp
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Design Decisions**:
- ✅ Store only aggregate totals with timestamps
- ✅ Calculate time-based stats (daily/weekly/monthly) on-demand from quiz_sessions
- ❌ No favorite category tracking
- ❌ No improvement trends (calculate from sessions when needed)
- ❌ No achievements (not needed now)

---

### 4. Quiz Type Statistics Table (`quiz_type_statistics`)

**Purpose**: Detailed stats broken down by quiz type and category

**Final Schema**:
```sql
CREATE TABLE quiz_type_statistics (
  id TEXT PRIMARY KEY,
  quiz_type TEXT NOT NULL,           -- 'flags', 'capitals', etc.
  quiz_category TEXT,                -- 'europe', 'asia', 'africa', etc. (NULL for all)
  total_sessions INTEGER DEFAULT 0,
  total_completed_sessions INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  total_correct INTEGER DEFAULT 0,
  total_incorrect INTEGER DEFAULT 0,
  total_skipped INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  best_session_id TEXT,              -- Reference to best session
  total_time_played_seconds INTEGER DEFAULT 0,
  average_time_per_question REAL DEFAULT 0,
  total_perfect_scores INTEGER DEFAULT 0,
  last_played_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (best_session_id) REFERENCES quiz_sessions(id) ON DELETE SET NULL,
  UNIQUE(quiz_type, quiz_category)   -- One row per type+category combo
);
```

**Design Decisions**:
- ✅ Track stats per quiz type + category combination
- ✅ Calculate breakdowns on-demand from quiz_sessions when needed
- ❌ No mastery level (not needed now)
- ❌ No time-of-day tracking (not needed now)
- ❌ No improvement rate (calculate on-demand if needed)

---

### 5. Daily Statistics Table (`daily_statistics`)

**Purpose**: Pre-aggregated daily statistics for fast charting and trend analysis

**Final Schema**:
```sql
CREATE TABLE daily_statistics (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL UNIQUE,         -- YYYY-MM-DD format
  sessions_played INTEGER DEFAULT 0,
  sessions_completed INTEGER DEFAULT 0,
  sessions_cancelled INTEGER DEFAULT 0,
  questions_answered INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  incorrect_answers INTEGER DEFAULT 0,
  skipped_answers INTEGER DEFAULT 0,
  time_played_seconds INTEGER DEFAULT 0,
  average_score_percentage REAL DEFAULT 0,
  best_score_percentage REAL DEFAULT 0,
  perfect_scores INTEGER DEFAULT 0,
  hints_50_50_used INTEGER DEFAULT 0,
  hints_skip_used INTEGER DEFAULT 0,
  lives_used INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Update Strategy**:
```dart
// Update daily stats after each session completes
Future<void> _updateDailyStatistics(QuizSession session) async {
  final dateStr = _formatDate(session.startTime); // YYYY-MM-DD

  await db.rawUpdate('''
    INSERT INTO daily_statistics (
      id, date, sessions_played, sessions_completed, questions_answered,
      correct_answers, time_played_seconds, average_score_percentage,
      best_score_percentage, created_at, updated_at
    ) VALUES (?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(date) DO UPDATE SET
      sessions_played = sessions_played + 1,
      sessions_completed = sessions_completed + ?,
      questions_answered = questions_answered + ?,
      correct_answers = correct_answers + ?,
      time_played_seconds = time_played_seconds + ?,
      average_score_percentage = (
        (average_score_percentage * (sessions_played - 1) + ?) / sessions_played
      ),
      best_score_percentage = MAX(best_score_percentage, ?),
      updated_at = ?
  ''', [/* params */]);
}
```

**Design Decisions**:
- ✅ One row per day for fast time-series queries
- ✅ Updated atomically after each session
- ✅ Supports charts without expensive aggregations
- ✅ Stores daily bests for leaderboard features
- ✅ Pre-calculates averages for instant display

**Benefits**:
- **Instant charts**: Just query this table, no JOINs
- **Trend analysis**: Simple date range queries
- **Performance**: No scanning thousands of sessions
- **User experience**: Fast statistics screen loading

---

### 6. User Settings Table (`user_settings`)

**Purpose**: Store user preferences and configuration

**Fields**:
```sql
CREATE TABLE user_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1), -- Singleton table
  sound_enabled INTEGER DEFAULT 1,
  haptic_enabled INTEGER DEFAULT 1,
  exit_confirmation_enabled INTEGER DEFAULT 1,
  show_hints INTEGER DEFAULT 1,
  theme_mode TEXT DEFAULT 'light',       -- 'light', 'dark', 'system'
  language TEXT DEFAULT 'en',
  hints_50_50_available INTEGER DEFAULT 3,
  hints_skip_available INTEGER DEFAULT 3,
  last_played_quiz_type TEXT,
  last_played_category TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Design Decisions**:
- ✅ Hints persist forever (no daily reset)
- ❌ No hint purchase history tracking (not needed now)
- ❌ No tutorial completion (not needed now)
- ❌ No cloud sync (local only)
- ❌ No difficulty level preference

---

## Indexes for Performance

```sql
-- Sessions - for filtering and sorting
CREATE INDEX idx_sessions_quiz_type ON quiz_sessions(quiz_type);
CREATE INDEX idx_sessions_category ON quiz_sessions(quiz_category);
CREATE INDEX idx_sessions_completion ON quiz_sessions(completion_status);
CREATE INDEX idx_sessions_start_time ON quiz_sessions(start_time DESC);
CREATE INDEX idx_sessions_quiz_id ON quiz_sessions(quiz_id);
CREATE INDEX idx_sessions_mode ON quiz_sessions(mode);

-- Question Answers - for joins and lookups
CREATE INDEX idx_answers_session ON question_answers(session_id);
CREATE INDEX idx_answers_question ON question_answers(question_id);
CREATE INDEX idx_answers_correct ON question_answers(is_correct);
CREATE INDEX idx_answers_status ON question_answers(answer_status);

-- Quiz Type Stats - for grouping
CREATE INDEX idx_type_stats_type ON quiz_type_statistics(quiz_type);
CREATE INDEX idx_type_stats_category ON quiz_type_statistics(quiz_category);
CREATE INDEX idx_type_stats_composite ON quiz_type_statistics(quiz_type, quiz_category);

-- Daily Stats - for time-series queries
CREATE INDEX idx_daily_date ON daily_statistics(date DESC);
```

---

## Repository Pattern Structure

```
packages/shared_services/
├── lib/
│   └── src/
│       └── storage/
│           ├── database/
│           │   ├── app_database.dart         # Database setup
│           │   ├── migrations/               # Schema migrations
│           │   │   └── migration_v1.dart
│           │   └── tables/                   # Table definitions
│           │       ├── quiz_sessions_table.dart
│           │       ├── question_answers_table.dart
│           │       └── statistics_table.dart
│           ├── models/                       # Data models
│           │   ├── quiz_session.dart
│           │   ├── question_answer.dart
│           │   ├── quiz_statistics.dart
│           │   └── user_settings.dart
│           ├── data_sources/                 # sqflite implementations
│           │   ├── quiz_session_data_source.dart
│           │   ├── statistics_data_source.dart
│           │   └── settings_data_source.dart
│           ├── repositories/                 # Repository interfaces & implementations
│           │   ├── quiz_session_repository.dart
│           │   ├── statistics_repository.dart
│           │   └── settings_repository.dart
│           └── storage_service.dart          # Main service interface
```

---

## Final Requirements Summary

### Data Retention & Privacy
- ✅ Keep all quiz sessions forever (no auto-deletion)
- ✅ Users can manually delete their history
- ❌ No GDPR export needed
- ❌ No data archiving/anonymization

### Performance Considerations
- ❌ No archiving (keep everything in main tables)
- ✅ Implement pagination for session history (50-100 per page)
- ✅ Cache statistics in memory for performance
- ✅ Calculate time-based stats (daily/weekly/monthly) on-demand from sessions

### Synchronization
- ❌ Local-only storage (no cloud sync for now)
- ❌ Single device support only
- ❌ No conflict resolution needed

### Analytics & Reporting
- ✅ Calculate trends on-demand from quiz_sessions timestamps
- ❌ No user comparison features
- ❌ No learning curves (keep it simple)

### Review & Replay Features
- ✅ **Users can replay any quiz session** (re-take with same questions)
- ✅ **"Practice wrong answers" mode** (quiz from frequently missed questions)
- ✅ **Show explanations for wrong answers** (stored in question_answers table)
- ❌ No bookmark/favorite questions feature

---

## Next Steps

1. **Review & Answer Questions**: Go through each section and answer the questions
2. **Finalize Schema**: Based on your answers, we'll finalize the database schema
3. **Create Migration Strategy**: Define how schema evolves over time
4. **Implement Repository Pattern**: Build the data layer
5. **Integrate with BLoC**: Connect storage to quiz engine
6. **Add to Architecture Guide**: Document as Sprint 5

---

## Notes

- All timestamps stored as Unix epoch (seconds since 1970-01-01)
- Use TEXT for UUIDs (generated with `uuid` package)
- JSON fields stored as TEXT, parsed on read
- Boolean values stored as INTEGER (0 or 1)
- Cascade deletes to maintain referential integrity
- Singleton tables use CHECK constraint for single row

---

**Created**: 2025-12-22
**Last Updated**: 2025-12-22
**Status**: ✅ FINALIZED - Ready for Implementation

---

## Summary of Final Schema

**6 Core Tables:**
1. `quiz_sessions` - Individual quiz attempts with metadata
2. `question_answers` - Every Q&A for review/replay (with all 4 options + order + explanations)
3. `global_statistics` - Aggregate stats across all sessions
4. `quiz_type_statistics` - Stats per quiz type + category
5. `daily_statistics` - ✅ **Pre-aggregated daily stats for fast charts**
6. `user_settings` - App preferences and configuration

**Removed Tables:**
- ❌ `question_performance` - Too granular, not needed
- ❌ `achievements` - Not needed now
- ❌ `leaderboards` - Not needed now
- ❌ `user_profile` - Not needed now

**Key Features:**
- ✅ Full session replay capability
- ✅ Practice mode for wrong answers
- ✅ Explanations for incorrect answers
- ✅ Comprehensive statistics with pre-aggregation for performance
- ✅ **Fast charts and trends** (daily_statistics table)
- ✅ Manual history deletion by user
- ✅ Forever data retention
- ✅ Lives/hearts tracking
- ✅ App version tracking for debugging

**Analytics Capabilities:**
- ✅ **Daily/Weekly/Monthly trends** - Instant queries from daily_statistics
- ✅ **Performance charts** - Pre-aggregated data, no expensive calculations
- ✅ **Best daily scores** - Tracked automatically
- ✅ **Time-series analysis** - Simple date range queries
- ✅ **Improvement tracking** - Compare periods easily
