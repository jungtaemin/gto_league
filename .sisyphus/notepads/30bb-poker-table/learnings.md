# Learnings — 30bb-poker-table

## 2026-02-27 Session Start

### Project Structure
- Flutter app, Riverpod state, `lib/` based structure
- `lib/core/theme/app_colors.dart` — ALL colors must be defined here as static const, NEVER hardcoded
- `lib/core/utils/responsive.dart` — `context.w()`, `context.h()`, `context.sp()`, `context.r()` — ALL sizing must use these
- `lib/features/game/widgets/` — existing game widgets directory
- `lib/data/services/` — business logic services
- `lib/data/providers/` — Riverpod providers

### Engine Contract (CRITICAL)
- `omniSwipeEngineProvider` via `ref.read(omniSwipeEngineProvider.notifier)`
- Methods: `startGame()`, `processAnswer(ActionGrade)`, `nextHand()`
- Read state: `.score`, `.strikesRemaining`, `.combo`, `.currentHandIndex`, `.totalHands`, `.phase`
- Phase values: `OmniSwipePhase.playing`, `.gameOver`, `.victory`
- Engine file: `lib/data/services/omni_swipe_engine.dart` (DO NOT MODIFY)

### Data Model
- `DeepStackScenario`: hand, position, actionHistory, foldFreq, callFreq, raiseFreq, allinFreq
- `dominantAction` getter: returns 'fold'|'call'|'raise'|'allin'
- `actionHistory` format: "UTG_F.UTG1_R__HJ" — parsed by `TablePositionView.parseActionSequence()`
- Data provider: `deepStackDataProvider` (Future<DeepStackCache>)
- 9 positions: UTG, UTG+1, UTG+2, LJ, HJ, CO, BU, SB, BB

### Evaluation
- `evaluateAction(userAction, scenario)` → `ActionGrade` (perfect/good/blunder)
- File: `lib/data/services/action_evaluator.dart` (DO NOT MODIFY)

### Scenario Loading Algorithm (CRITICAL — preserve exactly)
- Located: `omni_swipe_screen.dart:107-158`
- actionWeight baseline: 0.4, +0.15 after fold scenario, reset to 0.4 after action scenario
- Cap at 0.9, count=50 scenarios
- Extracted to: `lib/data/services/scenario_loader.dart` (Task 2)

### Action History Parsing
- `TablePositionView.parseActionSequence(actionHistory)` returns `List<_ActionStep>`
- Each step: position + action ('fold'|'call'|'raise'|'3bet'|'push')
- Animation: 150ms interval per step

### Existing Widgets to Reuse
- `PokerHand.fromNotation(hand)` — parses 'AKs', '77' etc
- `PlayingCardView` from `playing_cards` package — card rendering
- `CardSkin` system via `cardSkinProvider` — card styling
- `SoundManager.play(SoundType.correct/wrong)` — sound
- `HapticManager.correct()/wrong()/selection()` — haptic

### AppColors Pattern
```dart
static const Color leaguePromotionGold = Color(0xFFFBBF24);  // naming pattern
static List<BoxShadow> neonGlow(Color, {double intensity}) // glow helper
```
New colors use prefix `pokerTable*`

### Bet Amount Conventions (approximations, no exact data)
- SB = 0.5BB, BB = 1BB (blinds)
- open raise = 2.2BB
- 3bet = 7BB  
- call = match previous bet
- allin = 30BB (full stack)
- pot starts: SB(0.5) + BB(1.0) = 1.5BB minimum

## PlayerSeatWidget
- Used `AppColors.pokerTableFoldGray` for folded state text and position label.
- Used `AppColors.pokerTableAction*` colors for action badges.
- Used `context.w()` for responsive sizing.
- Handled folded state by hiding chip stack and showing 'FOLD' text.
- Handled active state by adding a glowing border to the avatar.

