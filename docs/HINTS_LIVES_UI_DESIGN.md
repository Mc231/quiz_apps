# Hints & Lives UI Design Document

**Sprint:** 8.14
**Status:** Draft
**Last Updated:** 2025-12-26

---

## Overview

This document defines the unified visual design for game resource buttons: **Lives**, **50/50 Hint**, and **Skip Hint**. All three resources will share the same visual component (`GameResourceButton`) with consistent styling, animations, and theming.

**Key Change:** Currently lives are shown in the AppBar and hints (50/50, Skip) are shown below it. This sprint unifies ALL resources into ONE location with an **adaptive layout** based on screen size.

---

## Design Goals

1. **Consistency**: All game resources look and behave identically
2. **Simplicity**: Single icon + badge pattern (not multiple icons)
3. **Interactivity**: All resources are tappable with callbacks
4. **Theming**: Customizable colors, sizes, and styles via `GameResourceTheme`
5. **Animations**: Delightful micro-interactions on use, depletion, and tap
6. **Adaptive Layout**: Different placement based on screen size

---

## Adaptive Layout Strategy

### Mobile Portrait
Resources shown in a dedicated row below AppBar (more touch-friendly, larger targets).

```
┌─────────────────────┐
│ Quiz Title    ⏱️ 25 │  ← Timer stays in AppBar
├─────────────────────┤
│  ❤️(3) 🎯(2) ⏭️(1)  │  ← GameResourcePanel (centered)
├─────────────────────┤
│       🇫🇷           │
│                     │
│ [France]  [Germany] │
│ [Italy]   [Spain]   │
│      12/50 ███░░    │
└─────────────────────┘
```

### Mobile Landscape
Resources inline with timer in AppBar (saves vertical space).

```
┌────────────────────────────────────────────┐
│ Quiz Title        ❤️(3) 🎯(2) ⏭️(1) ⏱️ 25 │  ← All inline
├────────────────────────────────────────────┤
│    🇫🇷     │  [France] [Germany]          │
│            │  [Italy]  [Spain]            │
│                 12/50 ████░░░░            │
└────────────────────────────────────────────┘
```

### Tablet / Desktop
Resources inline in AppBar with more spacing and optional labels.

```
┌──────────────────────────────────────────────────────────┐
│  Quiz Title              ❤️ 3   🎯 2   ⏭️ 1     ⏱️ 0:25  │
├──────────────────────────────────────────────────────────┤
│           🇫🇷               │  [France]                  │
│                             │  [Germany]                 │
│                             │  [Italy]                   │
│                             │  [Spain]                   │
│                                  12/50 ████████░░░░      │
└──────────────────────────────────────────────────────────┘
```

### Watch
Compact mode with minimal UI - just icon + count, no labels.

```
┌───────────────┐
│ Quiz    ⏱️ 25 │
├───────────────┤
│ ❤️3  🎯2  ⏭️1 │  ← Tiny, no labels
├───────────────┤
│     🇫🇷      │
│ [FR] [DE]    │
│ [IT] [ES]    │
│   5/20 ██░   │
└───────────────┘
```

### Layout Decision Logic

```dart
enum ResourcePanelPlacement {
  appBar,      // Inline with AppBar actions
  belowAppBar, // Dedicated row below AppBar
}

ResourcePanelPlacement getPlacement(BuildContext context) {
  final screenType = getDeviceType(MediaQuery.of(context).size);
  final orientation = MediaQuery.of(context).orientation;

  return switch ((screenType, orientation)) {
    (DeviceScreenType.mobile, Orientation.portrait) => ResourcePanelPlacement.belowAppBar,
    (DeviceScreenType.mobile, Orientation.landscape) => ResourcePanelPlacement.appBar,
    (DeviceScreenType.tablet, _) => ResourcePanelPlacement.appBar,
    (DeviceScreenType.desktop, _) => ResourcePanelPlacement.appBar,
    (DeviceScreenType.watch, _) => ResourcePanelPlacement.belowAppBar,
    _ => ResourcePanelPlacement.belowAppBar,
  };
}
```

---

## Visual Specification

### Component: GameResourceButton

```
┌─────────────────────┐
│  ┌───┐              │
│  │ 3 │  (badge)     │
│  └───┘              │
│    ❤️                │  ← Icon (centered)
│                     │
│   Lives             │  ← Label (optional)
└─────────────────────┘
```

### Dimensions (Responsive)

| Screen Type | Button Size | Icon Size | Badge Size | Font Size |
|-------------|-------------|-----------|------------|-----------|
| Mobile      | 56x56       | 28        | 20         | 10        |
| Tablet      | 64x64       | 32        | 24         | 12        |
| Desktop     | 64x64       | 32        | 24         | 12        |
| Watch       | 44x44       | 22        | 16         | 8         |

### Badge Position

- Top-right corner of button
- Offset: (-4, -4) from button edge
- Always visible (no overflow clipping)

### Layout Options

1. **Icon Only**: Just the icon with badge (compact)
2. **Icon + Label**: Icon above, label below (default)

---

## Resource Definitions

### Lives (Heart)

| Property | Value |
|----------|-------|
| Icon | `Icons.favorite` |
| Active Color | `Colors.red` (or theme) |
| Depleted Color | `Colors.grey` |
| Badge Color | Active: `Colors.red[700]`, Depleted: `Colors.grey[400]` |
| Label | Localized "Lives" |

**Tap Action:** Show "Get More Lives" dialog (future: IAP/Ads)

### 50/50 Hint

| Property | Value |
|----------|-------|
| Icon | `Icons.filter_2` or custom 50/50 icon |
| Active Color | `Colors.blue` (or theme) |
| Depleted Color | `Colors.grey` |
| Badge Color | Active: `Colors.blue[700]`, Depleted: `Colors.grey[400]` |
| Label | Localized "50/50" |

**Tap Action:** Use hint (eliminate 2 wrong answers)

### Skip Hint

| Property | Value |
|----------|-------|
| Icon | `Icons.skip_next` |
| Active Color | `Colors.orange` (or theme) |
| Depleted Color | `Colors.grey` |
| Badge Color | Active: `Colors.orange[700]`, Depleted: `Colors.grey[400]` |
| Label | Localized "Skip" |

**Tap Action:** Use hint (skip question without penalty)

---

## States

### 1. Active (Available)

- Full color icon and badge
- Elevation: 2
- Tappable: Yes
- Badge shows remaining count

### 2. Disabled (Used/Depleted)

- Greyed out icon and badge
- Elevation: 0
- Tappable: No (or shows "Get More" dialog for lives)
- Badge shows 0

### 3. Last One (Warning)

- Pulse animation on icon
- Badge color shifts to warning (orange/yellow)
- Still tappable

### 4. Pressed

- Scale down to 0.95
- Slight shadow reduction

---

## Animations

### 1. Scale on Tap

```dart
// On tap down
transform: Matrix4.identity()..scale(0.95)
duration: 100ms
curve: Curves.easeOut

// On tap up
transform: Matrix4.identity()
duration: 100ms
curve: Curves.easeOut
```

### 2. Pulse (Last Resource Warning)

```dart
// When count == 1
Animation: ScaleTransition
  scale: 1.0 → 1.1 → 1.0
  duration: 800ms
  repeat: infinite
  curve: Curves.easeInOut
```

### 3. Shake on Depletion

```dart
// When count goes from 1 → 0
Animation: Horizontal shake
  offset: -4px → 4px → -4px → 4px → 0
  duration: 400ms
  curve: Curves.elasticOut
```

### 4. Badge Count Animation

```dart
// When count changes
Animation: Bounce + fade
  old count fades up and out
  new count fades down and in
  scale: 1.0 → 1.3 → 1.0
  duration: 300ms
```

### 5. Glow on Use (Optional)

```dart
// When resource is successfully used
Animation: Radial glow pulse
  opacity: 0 → 0.5 → 0
  scale: 1.0 → 1.2
  duration: 300ms
  color: resource active color with 50% opacity
```

---

## Theming: GameResourceTheme

```dart
class GameResourceTheme {
  /// Button shape and size
  final double buttonSize;
  final double iconSize;
  final double badgeSize;
  final double fontSize;
  final BorderRadius borderRadius;
  final double elevation;
  final double disabledElevation;

  /// Colors
  final Color livesColor;
  final Color fiftyFiftyColor;
  final Color skipColor;
  final Color disabledColor;
  final Color badgeTextColor;
  final Color labelColor;

  /// Badge styling
  final Color badgeBorderColor;
  final double badgeBorderWidth;

  /// Animation settings
  final Duration tapScaleDuration;
  final Duration pulseDuration;
  final Duration shakeDuration;
  final Duration countChangeDuration;
  final bool enablePulseOnLastResource;
  final bool enableShakeOnDepletion;
  final bool enableGlowOnUse;

  /// Label visibility
  final bool showLabels;

  /// Spacing
  final double spacingBetweenResources;

  /// Factory constructors
  factory GameResourceTheme.standard();
  factory GameResourceTheme.compact();  // No labels, smaller size
  factory GameResourceTheme.fromColorScheme(ColorScheme scheme);
}
```

### Default Theme Values

```dart
GameResourceTheme.standard() = GameResourceTheme(
  buttonSize: 56,
  iconSize: 28,
  badgeSize: 20,
  fontSize: 10,
  borderRadius: BorderRadius.circular(12),
  elevation: 2,
  disabledElevation: 0,

  livesColor: Colors.red,
  fiftyFiftyColor: Colors.blue,
  skipColor: Colors.orange,
  disabledColor: Colors.grey,
  badgeTextColor: Colors.white,
  labelColor: Colors.white,

  badgeBorderColor: Colors.white,
  badgeBorderWidth: 2,

  tapScaleDuration: Duration(milliseconds: 100),
  pulseDuration: Duration(milliseconds: 800),
  shakeDuration: Duration(milliseconds: 400),
  countChangeDuration: Duration(milliseconds: 300),
  enablePulseOnLastResource: true,
  enableShakeOnDepletion: true,
  enableGlowOnUse: true,

  showLabels: true,
  spacingBetweenResources: 12,
);
```

---

## Widget API

### GameResourceButton

```dart
class GameResourceButton extends StatefulWidget {
  /// The icon to display
  final IconData icon;

  /// The current count (shown in badge)
  final int count;

  /// The maximum count (for progress indication, optional)
  final int? maxCount;

  /// Optional label below icon
  final String? label;

  /// Called when button is tapped (null = disabled)
  final VoidCallback? onTap;

  /// Called when button is long-pressed (e.g., show info)
  final VoidCallback? onLongPress;

  /// The active color (when count > 0)
  final Color activeColor;

  /// Override theme for this button
  final GameResourceTheme? theme;

  /// Whether this resource is currently enabled
  final bool enabled;

  /// Semantic label for accessibility
  final String? semanticLabel;

  const GameResourceButton({
    required this.icon,
    required this.count,
    this.maxCount,
    this.label,
    this.onTap,
    this.onLongPress,
    required this.activeColor,
    this.theme,
    this.enabled = true,
    this.semanticLabel,
  });
}
```

### GameResourcePanel

```dart
/// A horizontal row of game resource buttons
class GameResourcePanel extends StatelessWidget {
  /// Lives display (null = hidden)
  final GameResourceConfig? lives;

  /// 50/50 hint (null = hidden)
  final GameResourceConfig? fiftyFifty;

  /// Skip hint (null = hidden)
  final GameResourceConfig? skip;

  /// Theme for all buttons
  final GameResourceTheme? theme;

  /// Alignment of buttons
  final MainAxisAlignment alignment;

  const GameResourcePanel({
    this.lives,
    this.fiftyFifty,
    this.skip,
    this.theme,
    this.alignment = MainAxisAlignment.center,
  });
}

class GameResourceConfig {
  final int count;
  final int? maxCount;
  final VoidCallback? onTap;
  final bool enabled;

  const GameResourceConfig({
    required this.count,
    this.maxCount,
    this.onTap,
    this.enabled = true,
  });
}
```

---

## Accessibility

### Semantic Labels

```dart
// Lives button
"Lives: 3 remaining. Double tap to get more lives."

// 50/50 button (available)
"50/50 hint: 2 remaining. Double tap to eliminate two wrong answers."

// 50/50 button (disabled)
"50/50 hint: Not available."

// Skip button
"Skip hint: 1 remaining. Double tap to skip this question."
```

### Focus Order

1. Lives (leftmost)
2. 50/50
3. Skip (rightmost)

### Touch Target

Minimum 48x48dp touch target (satisfies WCAG 2.1 Level AAA)

---

## Sound Effects

| Event | Sound | Already Exists? |
|-------|-------|-----------------|
| Hint used | `hintUsed.mp3` | Yes |
| Life lost | `lifeLost.mp3` | Yes |
| Last resource warning | Subtle warning beep | No (optional) |
| Resource depleted | Low pitch thud | No (optional) |

---

## Haptic Feedback

| Event | Haptic Type |
|-------|-------------|
| Button tap | `HapticFeedbackType.selection` |
| Hint used | `HapticFeedbackType.medium` |
| Life lost | `HapticFeedbackType.heavy` |
| Resource depleted | `HapticFeedbackType.vibrate` |

---

## Integration Points

### Current Architecture (BEFORE)

```
┌─────────────────────────────────────┐
│ QuizScreen                          │
│  ├─ AppBar                          │
│  │   └─ QuizAppBarActions           │
│  │       ├─ LivesDisplay  ← HERE    │  Lives shown in AppBar
│  │       └─ TimerDisplay            │
│  └─ Body                            │
│      └─ QuizLayout                  │
│          ├─ HintsPanel    ← HERE    │  Hints shown below AppBar
│          ├─ Question                │
│          ├─ Answers                 │
│          └─ Progress                │
└─────────────────────────────────────┘
```

### New Architecture (AFTER)

```
┌─────────────────────────────────────┐
│ QuizScreen                          │
│  ├─ AppBar                          │
│  │   └─ QuizAppBarActions           │
│  │       ├─ GameResourcePanel ← ADAPTIVE (landscape/tablet/desktop)
│  │       └─ TimerDisplay            │
│  └─ Body                            │
│      └─ QuizLayout                  │
│          ├─ GameResourcePanel ← ADAPTIVE (portrait/watch)
│          ├─ Question                │
│          ├─ Answers                 │
│          └─ Progress                │
└─────────────────────────────────────┘
```

### Implementation Approach

1. **Create `AdaptiveResourcePanel`** - A wrapper that decides placement based on screen
2. **Update `QuizScreen`** - Pass resource panel to both locations
3. **Resource panel shows in only ONE place** - Logic determines which

```dart
class AdaptiveResourcePanel extends StatelessWidget {
  final GameResourcePanelData data;
  final ResourcePanelPlacement currentPlacement;
  final ResourcePanelPlacement targetPlacement;

  @override
  Widget build(BuildContext context) {
    // Only render if this is the correct placement for current screen
    if (currentPlacement != targetPlacement) {
      return const SizedBox.shrink();
    }
    return GameResourcePanel(data: data);
  }
}
```

### Current LivesDisplay

**Before:**
```dart
// Shows multiple heart icons in AppBar
Row(
  children: List.generate(totalLives, (index) {
    return Icon(index < remainingLives ? Icons.favorite : Icons.favorite_border);
  }),
)
```

**After:**
```dart
// Single icon + badge, placement determined by screen size
GameResourceButton(
  icon: Icons.favorite,
  count: remainingLives,
  maxCount: totalLives,
  label: l10n.lives,
  activeColor: theme.livesColor,
  onTap: onLivesTapped,
)
```

### Current HintsPanel

**Before:**
```dart
// Two separate ElevatedButton widgets below AppBar
Row(
  children: [
    _buildHintButton(label: "50/50", icon: Icons.filter_2, ...),
    _buildHintButton(label: "Skip", icon: Icons.skip_next, ...),
  ],
)
```

**After:**
```dart
// Unified panel with all resources, adaptive placement
GameResourcePanel(
  lives: GameResourceConfig(count: lives, onTap: onLivesTapped),
  fiftyFifty: GameResourceConfig(count: fiftyFifty, onTap: onUse5050),
  skip: GameResourceConfig(count: skips, onTap: onUseSkip),
)
```

---

## File Structure

```
packages/quiz_engine/lib/src/
├── theme/
│   └── game_resource_theme.dart          # Theme class
├── widgets/
│   ├── game_resource_button.dart         # Single resource button
│   ├── game_resource_panel.dart          # Panel with all resources
│   ├── adaptive_resource_panel.dart      # Adaptive placement wrapper
│   ├── lives_display.dart                # DEPRECATED - kept for backward compat
│   ├── hints_panel.dart                  # DEPRECATED - kept for backward compat
│   └── quiz_app_bar_actions.dart         # Updated to use GameResourcePanel
├── quiz/
│   └── quiz_layout.dart                  # Updated to use GameResourcePanel
```

---

## Localization Strings

Add to `quiz_engine_en.arb`:

```json
{
  "lives": "Lives",
  "livesRemaining": "{count} lives remaining",
  "getMoreLives": "Get More Lives",
  "hint5050": "50/50",
  "hintSkip": "Skip",
  "hintsRemaining": "{count} hints remaining",
  "hintNotAvailable": "Hint not available",
  "lastResourceWarning": "Last one!",
  "resourceDepleted": "No more available"
}
```

---

## Implementation Checklist

- [ ] Create `GameResourceTheme` class
- [ ] Create `GameResourceButton` widget with animations
- [ ] Create `GameResourcePanel` wrapper widget
- [ ] Refactor `LivesDisplay` to use new component
- [ ] Refactor `HintsPanel` to use new component
- [ ] Add accessibility labels
- [ ] Add haptic feedback
- [ ] Add sound effects on actions
- [ ] Write widget tests
- [ ] Update exports in `quiz_engine.dart`

---

## Design Decisions (Approved)

| Question | Decision |
|----------|----------|
| "Get More" dialog | Stub callback in 8.14, full dialog in 8.15 (IAP/Ads) |
| Long-press tooltip | Yes, show explanation of what resource does |
| Disabled buttons | Show greyed out with "0" badge (consistent visual) |
| Labels vs Badges | **Badges only (no labels)** - saves space, icons are self-explanatory |

### Label Strategy

**Decision:** Use icon + count badge only. No text labels.

**Rationale:**
- Icons are universally understood (❤️ = lives, ⏭️ = skip)
- Saves horizontal space, especially important in AppBar
- Cleaner, more modern look
- Long-press tooltip provides explanation if needed

**Visual comparison:**

```
WITH LABELS (rejected):        BADGES ONLY (approved):
┌─────────────────────┐        ┌─────────────────────┐
│  ❤️(3) 🎯(2) ⏭️(1)  │        │  ❤️(3) 🎯(2) ⏭️(1)  │
│ Lives 50/50 Skip    │        │                     │
└─────────────────────┘        └─────────────────────┘
       80px height                   48px height
```

---

## Hint Visibility Rules

### Play Mode vs Challenge Mode

Resources (hints and skip) are shown differently based on the game mode:

| Mode | Lives | 50/50 Hints | Skip |
|------|-------|-------------|------|
| **Play Tab** | ✅ Shown (if configured) | ✅ Shown | ✅ Shown |
| **Challenges** | ✅ Shown (if configured) | ❌ Hidden | ❌ Hidden |

### How It Works

1. **Play Mode**: Uses `HintConfig` with `initialHints` that specify counts for each hint type. Resources with `count > 0` are displayed.

2. **Challenge Mode**: Uses `HintConfig.noHints()` which sets `initialHints = {}` (empty). Since there are no initial hints configured, the hint buttons are not shown.

### Visibility Logic

A resource button is shown only when:
- `hintState != null` (hints system is enabled)
- `initialHints[hintType] > 0` (that specific hint type was initially configured)

```dart
// Only show 50/50 if initially configured
final initialFiftyFifty = config.hintConfig.initialHints[HintType.fiftyFifty] ?? 0;
if (hintState != null && initialFiftyFifty > 0) {
  // Show 50/50 button
}
```

### Persistence During Answer Feedback

Resource buttons remain visible during the answer feedback phase (when showing correct/incorrect animations). This provides:
- Consistent visual layout (no elements appearing/disappearing)
- Clear indication of remaining resources for the next question
- Better user experience with stable UI

The `AnswerFeedbackState` includes `hintState` to maintain resource visibility.

### Challenge Mode Configuration

Challenges use `ChallengeMode.showHints = false` which results in:
```dart
final hintConfig = challenge.showHints
    ? const HintConfig()           // Default hints
    : HintConfig.noHints();        // No hints (empty initialHints)
```

---

## Approval

- [x] Design reviewed
- [x] Implementation approach approved
- [x] Adaptive layout (Option C) approved
- [x] Badges only (no labels) approved
- [x] Hint visibility rules documented
- [x] Ready for development