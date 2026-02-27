import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'action_evaluator.dart';

part 'omni_swipe_engine.g.dart';

// ── Omni Swipe Phase ─────────────────────────────────────────

/// Phase of the 30BB Omni-Swipe game.
enum OmniSwipePhase {
  /// Actively playing hands.
  playing,

  /// Player lost all strikes — game over.
  gameOver,

  /// Player completed all hands — victory.
  victory,
}

// ── Omni Swipe State ─────────────────────────────────────────

/// Immutable state for the 30BB Omni-Swipe 4-direction mode.
///
/// Single level (30BB), 50 hands, 3-strike system.
/// Scoring: PERFECT / GOOD / BLUNDER grades from [ActionGrade].
class OmniSwipeState {
  /// Current game phase.
  final OmniSwipePhase phase;

  /// Cumulative score (starts at 0).
  final int score;

  /// Remaining strikes before game over (starts at 3).
  final int strikesRemaining;

  /// Current combo streak (resets on blunder).
  final int combo;

  /// Longest consecutive correct streak tracker.
  final int currentStreak;

  /// Which hand we're on (0-based index).
  final int currentHandIndex;

  /// Total hands in the game (default 50).
  final int totalHands;

  /// Number of PERFECT judgments.
  final int perfectCount;

  /// Number of GOOD judgments.
  final int goodCount;

  /// Number of BLUNDER judgments.
  final int blunderCount;

  const OmniSwipeState({
    required this.phase,
    required this.score,
    required this.strikesRemaining,
    required this.combo,
    required this.currentStreak,
    required this.currentHandIndex,
    required this.totalHands,
    required this.perfectCount,
    required this.goodCount,
    required this.blunderCount,
  });

  /// Initial state: playing, 0 score, 3 strikes, 50 hands.
  factory OmniSwipeState.initial() {
    return const OmniSwipeState(
      phase: OmniSwipePhase.playing,
      score: 0,
      strikesRemaining: OmniSwipeEngine._maxStrikes,
      combo: 0,
      currentStreak: 0,
      currentHandIndex: 0,
      totalHands: OmniSwipeEngine._defaultTotalHands,
      perfectCount: 0,
      goodCount: 0,
      blunderCount: 0,
    );
  }

  /// Create a copy with optional field overrides.
  OmniSwipeState copyWith({
    OmniSwipePhase? phase,
    int? score,
    int? strikesRemaining,
    int? combo,
    int? currentStreak,
    int? currentHandIndex,
    int? totalHands,
    int? perfectCount,
    int? goodCount,
    int? blunderCount,
  }) {
    return OmniSwipeState(
      phase: phase ?? this.phase,
      score: score ?? this.score,
      strikesRemaining: strikesRemaining ?? this.strikesRemaining,
      combo: combo ?? this.combo,
      currentStreak: currentStreak ?? this.currentStreak,
      currentHandIndex: currentHandIndex ?? this.currentHandIndex,
      totalHands: totalHands ?? this.totalHands,
      perfectCount: perfectCount ?? this.perfectCount,
      goodCount: goodCount ?? this.goodCount,
      blunderCount: blunderCount ?? this.blunderCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmniSwipeState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          score == other.score &&
          strikesRemaining == other.strikesRemaining &&
          combo == other.combo &&
          currentStreak == other.currentStreak &&
          currentHandIndex == other.currentHandIndex &&
          totalHands == other.totalHands &&
          perfectCount == other.perfectCount &&
          goodCount == other.goodCount &&
          blunderCount == other.blunderCount;

  @override
  int get hashCode =>
      phase.hashCode ^
      score.hashCode ^
      strikesRemaining.hashCode ^
      combo.hashCode ^
      currentStreak.hashCode ^
      currentHandIndex.hashCode ^
      totalHands.hashCode ^
      perfectCount.hashCode ^
      goodCount.hashCode ^
      blunderCount.hashCode;

  @override
  String toString() =>
      'OmniSwipeState(phase: $phase, score: $score, '
      'strikes: $strikesRemaining, combo: $combo, '
      'streak: $currentStreak, hand: $currentHandIndex/$totalHands, '
      'perfect: $perfectCount, good: $goodCount, blunder: $blunderCount)';
}

// ── Omni Swipe Engine ────────────────────────────────────────

/// 30BB Omni-Swipe 4-direction game loop engine.
///
/// Single level (30BB), 50 hands, 3-strike system.
/// Uses [ActionGrade] from [action_evaluator.dart] for grading.
///
/// ## Scoring
/// - **PERFECT**: `base(10) + comboBonus(combo × 2)`, capped at 100.
///   Increments combo, streak, and perfectCount.
/// - **GOOD**: `goodScore(5) + comboBonus(combo × 1)`.
///   Combo MAINTAINED, streak incremented, goodCount incremented.
/// - **BLUNDER**: No points, strikesRemaining decremented, combo reset.
///   blunderCount incremented.
///
/// ## Game Over
/// - `strikesRemaining <= 0` → [OmniSwipePhase.gameOver]
/// - `currentHandIndex >= totalHands` → [OmniSwipePhase.victory]
@Riverpod(keepAlive: true)
class OmniSwipeEngine extends _$OmniSwipeEngine {
  // ── Constants ───────────────────────────────────────────────

  /// Base score per PERFECT answer.
  static const int _baseScore = 10;

  /// Base score per GOOD answer.
  static const int _goodScoreMultiplier = 5;

  /// Maximum points awardable for a single answer.
  static const int _maxPointsPerAnswer = 100;

  /// Maximum strikes at game start.
  static const int _maxStrikes = 3;

  /// Default total hands in a game.
  static const int _defaultTotalHands = 50;

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  OmniSwipeState build() {
    return OmniSwipeState.initial();
  }

  // ── Public API ──────────────────────────────────────────────

  /// Reset to initial state and start a new game.
  void startGame() {
    state = OmniSwipeState.initial();
    debugPrint('[OmniSwipeEngine] Game started');
  }

  /// Process a player's answer with the given [ActionGrade].
  ///
  /// - **PERFECT**: score += base(10) + comboBonus(combo×2), capped at 100.
  ///   combo++, streak++, perfectCount++.
  /// - **GOOD**: score += goodScore(5) + comboBonus(combo×1).
  ///   combo MAINTAINED, streak++, goodCount++.
  /// - **BLUNDER**: strikesRemaining--, combo reset to 0, blunderCount++.
  ///   If strikesRemaining <= 0 → phase = gameOver.
  void processAnswer(ActionGrade grade) {
    if (state.phase != OmniSwipePhase.playing) return;

    switch (grade) {
      case ActionGrade.perfect:
        _processPerfect();
      case ActionGrade.good:
        _processGood();
      case ActionGrade.blunder:
        _processBlunder();
    }

    // Check game over after blunder.
    if (state.strikesRemaining <= 0) {
      state = state.copyWith(
        phase: OmniSwipePhase.gameOver,
      );
      debugPrint('[OmniSwipeEngine] Game over — strikes depleted');
      return;
    }
  }

  /// Advance to the next hand.
  ///
  /// If `currentHandIndex >= totalHands` → phase = victory.
  void nextHand() {
    if (state.phase != OmniSwipePhase.playing) return;

    final int newIndex = state.currentHandIndex + 1;

    if (newIndex >= state.totalHands) {
      state = state.copyWith(
        currentHandIndex: newIndex,
        phase: OmniSwipePhase.victory,
      );
      debugPrint(
        '[OmniSwipeEngine] Victory — completed all ${state.totalHands} hands',
      );
      return;
    }

    state = state.copyWith(
      currentHandIndex: newIndex,
    );
  }

  /// Whether the game ended due to strikes depletion.
  bool get isGameOver => state.phase == OmniSwipePhase.gameOver;

  /// Whether the player completed all hands.
  bool get isVictory => state.phase == OmniSwipePhase.victory;

  // ── Private helpers ─────────────────────────────────────────

  void _processPerfect() {
    // Score = base(10) + comboBonus(combo × 2), capped at 100.
    final int comboBonus = state.combo * 2;
    final int earned =
        (_baseScore + comboBonus).clamp(0, _maxPointsPerAnswer);

    state = state.copyWith(
      score: state.score + earned,
      combo: state.combo + 1,
      currentStreak: state.currentStreak + 1,
      perfectCount: state.perfectCount + 1,
    );
  }

  void _processGood() {
    // Score = goodScore(5) + comboBonus(combo × 1).
    final int comboBonus = state.combo * 1;
    final int earned =
        (_goodScoreMultiplier + comboBonus).clamp(0, _maxPointsPerAnswer);

    state = state.copyWith(
      score: state.score + earned,
      // Combo MAINTAINED — not incremented, not reset.
      currentStreak: state.currentStreak + 1,
      goodCount: state.goodCount + 1,
    );
  }

  void _processBlunder() {
    final int newStrikes =
        (state.strikesRemaining - 1).clamp(0, _maxStrikes);

    state = state.copyWith(
      strikesRemaining: newStrikes,
      combo: 0,
      blunderCount: state.blunderCount + 1,
    );
  }
}
