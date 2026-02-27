import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../models/deep_stack_scenario.dart';

// ── Action Grade ──────────────────────────────────────────────

/// Evaluation grade for a user's action in 30BB deep stack mode.
///
/// - [perfect]: User chose the highest-frequency GTO action.
/// - [good]: User chose a non-primary action with ≥5% frequency.
/// - [blunder]: User chose an action with <5% or 0% frequency.
enum ActionGrade {
  perfect,
  good,
  blunder,
}

// ── Action Evaluator ──────────────────────────────────────────

/// Evaluates the user's swipe action against the GTO-optimal strategy.
///
/// Returns an [ActionGrade] based on how the user's chosen action
/// compares to the scenario's frequency distribution.
///
/// ## Scoring Rules
/// - **PERFECT**: `userAction` has the highest frequency (ties included).
/// - **GOOD**: `userAction` is not the highest but has ≥5% frequency.
/// - **BLUNDER**: `userAction` has <5% frequency.
///
/// ## Tie Handling
/// When multiple actions share the same highest frequency,
/// ALL of them are treated as PERFECT.
ActionGrade evaluateAction(String userAction, DeepStackScenario scenario) {
  final int userFreq = scenario.getFrequency(userAction);

  // Find the maximum frequency across all actions.
  final int maxFreq = _maxFrequency(scenario);

  // PERFECT: user's action matches the highest frequency (tie-safe).
  if (userFreq == maxFreq) {
    return ActionGrade.perfect;
  }

  // GOOD: not the highest, but still a viable option (≥5%).
  if (userFreq >= 5) {
    return ActionGrade.good;
  }

  // BLUNDER: <5% frequency — wrong call.
  return ActionGrade.blunder;
}

/// Maps a [CardSwiperDirection] to its corresponding action name.
///
/// - `.left`   → `'fold'`
/// - `.bottom` → `'call'`
/// - `.right`  → `'raise'`
/// - `.top`    → `'allin'`
///
/// Returns `'fold'` as fallback for unexpected directions (e.g. `.none`).
///
/// **Note**: `CardSwiperDirection` is a class, not an enum.
/// Must use `if/else if` — `switch` is not supported.
String directionToAction(CardSwiperDirection direction) {
  if (direction == CardSwiperDirection.left) {
    return 'fold';
  } else if (direction == CardSwiperDirection.bottom) {
    return 'call';
  } else if (direction == CardSwiperDirection.right) {
    return 'raise';
  } else if (direction == CardSwiperDirection.top) {
    return 'allin';
  }
  return 'fold';
}

// ── Private Helpers ───────────────────────────────────────────

/// Returns the maximum frequency value across all 4 actions.
int _maxFrequency(DeepStackScenario scenario) {
  int max = scenario.foldFreq;
  if (scenario.callFreq > max) max = scenario.callFreq;
  if (scenario.raiseFreq > max) max = scenario.raiseFreq;
  if (scenario.allinFreq > max) max = scenario.allinFreq;
  return max;
}
