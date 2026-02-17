# AGENTS.md — lib/features/game/

Most complex feature. Core gameplay loop: swipe cards, score, timer, combos, fever.

## Structure

```
game/
├── game_screen.dart              # Main game screen (ConsumerStatefulWidget)
└── widgets/
    ├── poker_card_widget.dart        # Swipeable poker hand card display
    ├── action_clock_widget.dart      # Countdown timer with visual urgency
    ├── snap_bonus_widget.dart        # "SNAP!" fast-answer bonus indicator
    ├── combo_counter_widget.dart     # Combo streak counter with animations
    ├── swipe_feedback_overlay.dart   # LEFT/RIGHT swipe direction indicator
    ├── answer_result_overlay.dart    # Correct/Wrong result with animations
    └── fact_bomb_bottom_sheet.dart   # GTO fact shown after wrong answers
```

## GameScreen Flow

1. **Init**: Load deck (DeckGenerator), reset GameStateNotifier, start timer
2. **Card Display**: `flutter_card_swiper` shows `PokerCardWidget`
3. **Swipe**: RIGHT=PUSH, LEFT=FOLD → compare with GTO correct action
4. **Result**: `processAnswer(SwipeResult)` → update score/hearts/combo
5. **Overlay**: Show correct/wrong animation → fact bomb if wrong
6. **Timer**: `TimerNotifier` counts down → auto-fold on expire → hearts--
7. **Game Over**: hearts=0 → navigate to `/game-over`

## Key Integrations

```dart
// Providers consumed in GameScreen:
ref.watch(gameStateNotifierProvider)       // GameState (score, hearts, combo, fever, tier)
ref.read(gameStateNotifierProvider.notifier) // processAnswer(), reset(), setDefenseMode()
ref.watch(timerProvider)                    // Timer countdown value
ref.read(timerProvider.notifier)            // start(), pause(), resume(), stop()
```

## Widget Details

### PokerCardWidget
- Displays: hand (e.g. "A♠ K♥"), position, chart type
- Swipeable via `flutter_card_swiper`
- Nano Banana styling: neon borders, glow on swipe direction

### ActionClockWidget
- Shows remaining time from `timerProvider`
- Visual urgency: color shifts (cyan→yellow→red), pulse animation at low time
- Timer warning sound triggers at threshold

### SnapBonusWidget
- Appears when answer within 2 seconds
- "SNAP!" text with bounce-in animation
- 1.5× score multiplier indicator

### ComboCounterWidget
- Shows current combo count
- Escalating animations per combo level
- Resets visually on wrong answer

### SwipeFeedbackOverlay
- Direction indicator while swiping (PUSH→/←FOLD)
- Opacity tied to swipe distance
- Color: green for right, red for left

### AnswerResultOverlay
- Correct: green flash + sound + haptic
- Wrong: red shake + sound + haptic
- Triggers timer pause during display

### FactBombBottomSheet
- Shows after wrong answer
- GTO explanation text (Korean)
- Nano Banana styled modal with `AppTheme` BottomSheet theme

## Timer ↔ Game Integration

- Timer pauses during answer overlay display
- Timer resumes after overlay dismissal
- `startWithCombo(combo)` adjusts speed — higher combo = faster timer
- Timer expire = auto-fold = wrong answer = hearts--
- `addTime()` available for time-bank power-up

## Defense Mode

- `setDefenseMode(true)` when card is from CALL chart (defensive position)
- Visual indicator changes on card display
- Swipe logic: LEFT=CALL(defend), RIGHT=FOLD(let go)

## dispose() Handling

- `GameScreen.dispose()`: timer stopped, fever timer cancelled
- **Must reset GameStateNotifier when re-entering from home** (already handled in T42)

## Anti-Patterns

- **NEVER** access DeckGenerator outside GameScreen — it's the deck source
- **NEVER** modify game state directly — always through `gameStateNotifierProvider.notifier`
- **NEVER** forget timer pause/resume around overlays — causes timer desync
- **flutter_card_swiper v7.2.0**: `CardSwiperDirectionChange` callback signature is `(CardSwiperDirection horizontal, CardSwiperDirection vertical)` — NOT the old single-direction API
