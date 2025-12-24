# Feature: Play Screen Tabs

## Overview

The Play screen uses a tabbed interface to organize different quiz experiences. Each app can configure its own tabs with different modes and categories.

**Sprint:** 7.10 - Game Modes & Challenges

---

## Tab Structure

### Generic Structure (quiz_engine)

```
┌─────────────────────────────────────────┐
│  [Tab 1]    [Tab 2]    [Tab 3]    ...   │  ← TabbedPlayScreen
├─────────────────────────────────────────┤
│                                         │
│         Tab Content Area                │
│    (Categories / Challenges / etc)      │
│                                         │
└─────────────────────────────────────────┘
```

The `TabbedPlayScreen` widget supports:
- `CategoriesTab` - Display quiz categories
- `PracticeTab` - Practice wrong answers (async loading)
- `CustomContentTab` - Any custom widget

---

## FlagsQuiz App Configuration

### Tab 1: "Play" (Main Experience)

**Purpose:** Default quiz experience with helpful features

| Setting | Value |
|---------|-------|
| Hints | ✅ Enabled |
| Skip | ✅ Enabled |
| Lives | ❌ Disabled |
| Time Limit | ❌ None |
| Questions | All in category |

**Categories:** All region categories (Europe, Asia, Africa, etc.)

**User Flow:**
```
Play Tab → Select Category → Start Quiz (with hints/skip)
```

---

### Tab 2: "Challenges" (Competitive Modes)

**Purpose:** Different game modes for competitive/challenging play

**Display:** List with difficulty indicators

#### Challenge Modes

| Mode | Icon | Difficulty | Description |
|------|------|------------|-------------|
| **Survival** | 💀 | 🔴 Hard | 3 lives, no hints, game over on 3 mistakes |
| **Time Attack** | ⏱️ | 🟡 Medium | 60 seconds, answer as many as possible |
| **Speed Run** | 🏃 | 🟡 Medium | 20 questions, fastest time wins |
| **Marathon** | 🏃‍♂️ | 🟢 Easy | Endless mode, track your streak |
| **Blitz** | ⚡ | 🔴 Hard | 5 seconds per question, 1 life |

#### Challenge Configurations

```dart
// Survival Mode
QuizConfig(
  lives: 3,
  showHints: false,
  allowSkip: false,
  questionCount: 20,
)

// Time Attack
QuizConfig(
  totalTimeSeconds: 60,
  showHints: false,
  allowSkip: true,
  questionCount: null, // unlimited
)

// Speed Run
QuizConfig(
  trackTime: true,
  showHints: false,
  allowSkip: false,
  questionCount: 20,
)

// Marathon (Endless)
QuizConfig(
  showHints: false,
  allowSkip: false,
  questionCount: null, // unlimited
  trackStreak: true,
)

// Blitz
QuizConfig(
  lives: 1,
  questionTimeSeconds: 5,
  showHints: false,
  allowSkip: false,
  questionCount: 20,
)
```

**User Flow:**
```
Challenges Tab → Select Mode → Select Category → Start Challenge
```

---

### Tab 3: "Practice" (Learning Mode)

**Purpose:** No-pressure learning experience

| Setting | Value |
|---------|-------|
| Hints | ✅ Enabled |
| Skip | ✅ Enabled |
| Lives | ❌ Disabled |
| Time Limit | ❌ None |
| Show Explanations | ✅ Yes |
| Track Progress | ✅ Per category |

**Content:**
- Categories from wrong answers (PracticeTab with async loading)
- Or all categories in learning mode

**User Flow:**
```
Practice Tab → Shows categories with wrong answers → Select → Practice those questions
```

---

## Implementation Architecture

### quiz_engine (Generic)

Provides building blocks:
- `TabbedPlayScreen` - Tab container widget
- `PlayScreenTab` - Sealed class for tab types
- `CategoriesTab` - Category list/grid
- `PracticeTab` - Async loading for practice items
- `CustomContentTab` - Custom widgets
- `QuizConfig` - Quiz configuration options

### App-Specific (e.g., flagsquiz)

Each app configures:
- Which tabs to show
- Tab labels and icons
- Challenge modes and their configs
- Category organization
- Custom UI elements

```dart
// Example: flagsquiz configuration
QuizHomeScreen(
  config: QuizHomeScreenConfig(
    playScreenTabs: [
      // Tab 1: Play
      PlayScreenTab.categories(
        id: 'play',
        label: 'Play',
        icon: Icons.play_arrow,
        categories: allCategories,
      ),

      // Tab 2: Challenges
      PlayScreenTab.custom(
        id: 'challenges',
        label: 'Challenges',
        icon: Icons.emoji_events,
        builder: (context) => ChallengesListWidget(
          challenges: flagsQuizChallenges,
          onChallengeSelected: (challenge) => showCategoryPicker(challenge),
        ),
      ),

      // Tab 3: Practice
      PlayScreenTab.practice(
        id: 'practice',
        label: 'Practice',
        icon: Icons.school,
        onLoadWrongAnswers: () => loadWrongAnswerCategories(),
      ),
    ],
  ),
)
```

---

## UI Components Needed

### 1. ChallengeCard Widget

```
┌─────────────────────────────────────┐
│ 💀  Survival                    🔴  │
│     3 lives, no hints               │
│     Can you survive?                │
└─────────────────────────────────────┘
```

Properties:
- `icon` - Challenge icon
- `title` - Challenge name
- `description` - Short description
- `difficulty` - Easy/Medium/Hard indicator
- `onTap` - Callback

### 2. DifficultyIndicator Widget

```dart
enum ChallengeDifficulty { easy, medium, hard }

// Visual: 🟢 Easy | 🟡 Medium | 🔴 Hard
```

### 3. ChallengeListWidget

Displays list of available challenges with:
- Challenge cards
- Difficulty badges
- Optional: Best scores/times

---

## Data Models

### ChallengeMode

```dart
class ChallengeMode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ChallengeDifficulty difficulty;
  final QuizConfig config;

  const ChallengeMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.config,
  });
}
```

### ChallengeDifficulty

```dart
enum ChallengeDifficulty {
  easy,   // 🟢 Green
  medium, // 🟡 Yellow/Orange
  hard,   // 🔴 Red
}
```

---

## Implementation Checklist

### Phase 1: Challenge Infrastructure
- [ ] Create `ChallengeMode` model
- [ ] Create `ChallengeDifficulty` enum
- [ ] Create `ChallengeCard` widget
- [ ] Create `ChallengeListWidget`
- [ ] Create `DifficultyIndicator` widget

### Phase 2: FlagsQuiz Integration
- [ ] Define challenge modes for flagsquiz
- [ ] Configure Play tab with hints/skip enabled
- [ ] Configure Challenges tab with custom widget
- [ ] Configure Practice tab with wrong answers
- [ ] Add category picker after challenge selection

### Phase 3: Polish
- [ ] Add challenge icons/illustrations
- [ ] Add best score tracking per challenge
- [ ] Add difficulty-based sorting
- [ ] Localization for challenge names/descriptions

---

## Other App Examples

### Music Quiz App (hypothetical)
```
Tab 1: "Listen" - Audio recognition quizzes
Tab 2: "Speed Round" - Quick identification
Tab 3: "Learn" - Artist/song information
```

### History Quiz App (hypothetical)
```
Tab 1: "Timeline" - Chronological quizzes
Tab 2: "Challenges" - Era-specific challenges
Tab 3: "Study" - Detailed historical facts
```

---

## Notes

- Challenge modes are **app-specific** configurations
- `quiz_engine` provides generic, reusable components
- Each app defines its own challenges using `QuizConfig`
- The tab bar is hidden when only 1 tab is configured
- Statistics and history work across all modes
