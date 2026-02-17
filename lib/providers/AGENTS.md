# AGENTS.md — lib/providers/

Riverpod state management layer. All global state lives here.

## Structure

```
providers/
├── game_state_notifier.dart    # Core game state (score, hearts, combo, fever, tier)
├── game_state_notifier.g.dart  # AUTO-GENERATED — DO NOT MODIFY
└── game_providers.dart         # Service providers (AdService, RankingService)
```

## GameStateNotifier

`@Riverpod(keepAlive: true)` — persists across navigation. Must call `reset()` explicitly.

### Provider Access
```dart
// Watch state (rebuilds on change):
final gameState = ref.watch(gameStateNotifierProvider);
// gameState.score, .hearts, .combo, .currentStreak, .isFeverMode, .isDefenseMode, .timeBankCount, .currentTier

// Call methods:
ref.read(gameStateNotifierProvider.notifier).processAnswer(result);
ref.read(gameStateNotifierProvider.notifier).reset();
```

### Public API
| Method | Effect |
|--------|--------|
| `processAnswer(SwipeResult)` | Score+combo on correct, hearts-- on wrong |
| `useFeverMode()` | Activate fever manually (2× score for 5s) |
| `useTimeBank() → bool` | Consume 1 time-bank charge |
| `refillHearts()` | Set hearts to 5 (ad reward) |
| `refillTimeBank()` | Add 3 time-bank charges (ad reward) |
| `setDefenseMode(bool)` | Toggle defense mode flag |
| `reset()` | Full reset to `GameState.initial()` |
| `isGameOver → bool` | hearts <= 0 |

### Scoring Formula
- Base: 10 points
- Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, ...)
- Snap: ×1.5 (answered within 2s)
- Fever: ×2.0 (active for 5s at 15-streak)
- Cap: 100 points max per answer (10× base)

### Fever Mode
- Auto-activates at 15 consecutive correct answers
- Lasts 5 seconds (Timer-based)
- 2× final score multiplier
- Timer cancelled on `reset()` and `dispose()`

## TimerNotifier

Defined in `data/services/timer_service.dart` but provided as:
```dart
// StateNotifierProvider<TimerNotifier, double>
final timerProvider = StateNotifierProvider<TimerNotifier, double>((ref) => TimerNotifier());
```

### Usage
```dart
final remaining = ref.watch(timerProvider);  // double: seconds remaining
ref.read(timerProvider.notifier).start();
ref.read(timerProvider.notifier).startWithCombo(combo);  // Faster at higher combos
ref.read(timerProvider.notifier).pause();
ref.read(timerProvider.notifier).resume();
ref.read(timerProvider.notifier).addTime(3.0);
```

## Service Providers

```dart
// AdService — rewarded ad lifecycle
final adService = ref.read(adServiceProvider);
adService.showRewardedAd(onRewarded: () { ... }, onFailed: () { ... });

// RankingService — ghost league + score submission  
final ranking = ref.read(rankingServiceProvider);
final league = await ranking.generateLeague(score);
await ranking.submitScore(score);
```

Both use `Provider<T>` (not StateNotifier). AdService has `ref.onDispose` for cleanup.

## Code Generation

After modifying `game_state_notifier.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```
**NEVER** edit `game_state_notifier.g.dart` manually.

## Anti-Patterns

- **NEVER** modify `.g.dart` files
- **NEVER** create providers outside this directory — centralized here
- **NEVER** use `ref.watch` in callbacks — use `ref.read` inside `onPressed`, timers, etc.
- **NEVER** forget `reset()` when re-entering game — state is `keepAlive: true`
- **NEVER** call `processAnswer()` after `isGameOver` — it no-ops but indicates logic error
