# AGENTS.md — lib/data/

Data layer: models, services, repositories. No UI code here.

## Structure

```
data/
├── models/
│   ├── card_question.dart    # CardQuestion — a single swipeable question
│   ├── game_state.dart       # GameState — immutable game snapshot (score, hearts, combo, tier, fever)
│   ├── swipe_result.dart     # SwipeResult — answer outcome (isCorrect, isSnap, points)
│   ├── poker_hand.dart       # PokerHand — hand representation (rank, suit, display)
│   ├── position.dart         # Position — table position enum (BTN, SB, BB, etc.)
│   ├── tier.dart             # Tier — rank tier with score thresholds (fromScore factory)
│   └── league_player.dart    # LeaguePlayer — ghost ranking entry
├── services/
│   ├── timer_service.dart    # TimerNotifier (StateNotifier<double>) — countdown with combo speed
│   ├── deck_generator.dart   # DeckGenerator — MOCK card generation (currently used by game)
│   ├── database_helper.dart  # DatabaseHelper — SQLite singleton, CSV→DB migration
│   ├── ad_service.dart       # AdService — Google AdMob rewarded ad lifecycle
│   └── ranking_service.dart  # RankingService — ghost league generation + Supabase scaffold
└── repositories/
    └── gto_repository.dart   # GtoRepository — real GTO data from SQLite (EXISTS but UNUSED)
```

## Models

### GameState
```dart
GameState({
  score: 0, hearts: 5, combo: 0, currentStreak: 0,
  isFeverMode: false, isDefenseMode: false,
  timeBankCount: 3, currentTier: Tier.bronze,
})
GameState.initial()  // Factory constructor
.copyWith(...)       // Immutable updates
```

### Tier
```dart
Tier.fromScore(int score) → Tier  // Returns appropriate tier
// Tiers: bronze → silver → gold → platinum → diamond → master → grandmaster
```

### CardQuestion
Contains: hand display, position, correct action (push/fold), chart type (push/call), fact bomb text.

### SwipeResult
Contains: `isCorrect`, `isSnap` (answered within 2s), earned points.

## Services

### TimerNotifier (`timerProvider`)
```dart
// Provider: StateNotifierProvider<TimerNotifier, double>
// State value = remaining seconds (double)

pause()                  // Pause countdown
resume()                 // Resume countdown
stop()                   // Stop and reset
start()                  // Start with default duration
startWithCombo(int)      // Start with combo-adjusted speed
reset()                  // Reset to initial
addTime(double seconds)  // Add seconds to timer
```

### DeckGenerator (MOCK — currently used)
- Generates random CardQuestion instances
- **NOT using real GTO data** — critical gap for production

### DatabaseHelper
- Singleton SQLite access
- `initDatabase()` — creates tables, migrates CSV→SQLite on first run
- CSV files: `assets/db/gto_push_chart.csv`, `assets/db/gto_call_chart.csv`
- **NOT initialized in main.dart yet** — must add before using GtoRepository

### AdService
- Manages Google AdMob rewarded ad lifecycle
- `loadRewardedAd()`, `showRewardedAd({onRewarded, onFailed})`
- `dispose()` — called via ref.onDispose in provider
- **AndroidManifest missing AdMob App ID** — runtime crash without it

### RankingService
- `generateLeague(int playerScore)` → ghost players around player's score
- `submitScore(int score)` → saves locally + Supabase (TODO: Supabase not connected)
- Contains `// TODO: Enable when Supabase project is created` comments

## GtoRepository (UNUSED)
- Queries real GTO push/call data from SQLite
- Exists and is implemented but game_screen uses DeckGenerator instead
- **Must wire this before launch** — currently the #1 production gap

## Anti-Patterns

- **NEVER** put UI code (widgets, BuildContext) in this layer
- **NEVER** modify `*.g.dart` files — they are auto-generated
- Models should be immutable — always use `copyWith()` for state transitions
- Services are plain Dart classes — no Flutter dependencies except where essential (sqflite, ads)
