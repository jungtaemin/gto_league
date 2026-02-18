import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/game_state.dart';
import '../data/models/swipe_result.dart';
import '../data/models/tier.dart';

part 'game_state_notifier.g.dart';

/// Game state management notifier.
///
/// Handles scoring logic, hearts system, combo tracking,
/// fever mode, and game-over detection.
///
/// ## Scoring Formula
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Snap bonus: 1.5× total (answered within 2 seconds)
/// - Fever mode: 2× final score (active for 5 seconds at 15 streak)
/// - Cap: 10× base maximum per answer
@Riverpod(keepAlive: true)
class GameStateNotifier extends _$GameStateNotifier {
  // ── Constants ───────────────────────────────────────────────

  /// Base score per correct answer.
  static const int _baseScore = 10;

  /// Maximum effective multiplier on a single answer.
  static const int _maxMultiplierCap = 10;

  /// Consecutive correct answers needed to trigger fever mode.
  static const int _feverStreakThreshold = 15;

  /// Duration in seconds that fever mode remains active.
  static const int _feverDurationSeconds = 5;

  /// Maximum heart count.
  static const int _maxHearts = 3;

  /// Time-bank charges added per refill.
  static const int _timeBankRefillAmount = 3;

  // ── Internal state ──────────────────────────────────────────

  Timer? _feverTimer;

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  GameState build() {
    ref.onDispose(() {
      _feverTimer?.cancel();
    });
    return GameState.initial();
  }

  // ── Public API ──────────────────────────────────────────────

  /// Whether the game is over (hearts depleted).
  bool get isGameOver => state.hearts <= 0;

  /// Process a swipe answer result.
  ///
  /// **Correct answer**: score += base(10) + comboBonus(combo×2),
  /// combo++, streak++. Snap gives 1.5×, fever gives 2×.
  ///
  /// **Incorrect answer**: hearts--, combo=0, streak=0.
  void processAnswer(SwipeResult result) {
    if (isGameOver) return;

    if (result.isCorrect) {
      _processCorrectAnswer(result);
    } else {
      _processIncorrectAnswer();
    }
  }

  /// Activate fever mode manually (e.g., power-up consumption).
  ///
  /// No-op when fever is already active.
  void useFeverMode() {
    if (state.isFeverMode) return;
    state = state.copyWith(isFeverMode: true);
    _startFeverTimer();
  }

  /// Consume one time-bank charge.
  ///
  /// Returns `true` when a charge was available and consumed,
  /// `false` when no charges remain.
  bool useTimeBank() {
    if (state.timeBankCount <= 0) return false;
    state = state.copyWith(timeBankCount: state.timeBankCount - 1);
    return true;
  }

  /// Refill hearts to maximum (ad-reward callback).
  void refillHearts() {
    state = state.copyWith(hearts: _maxHearts);
  }

  /// Add time-bank charges (ad-reward callback).
  void refillTimeBank() {
    state = state.copyWith(
      timeBankCount: state.timeBankCount + _timeBankRefillAmount,
    );
  }

  /// Update defense mode flag (true when current card is a CALL chart).
  void setDefenseMode(bool isDefense) {
    if (state.isDefenseMode == isDefense) return;
    state = state.copyWith(isDefenseMode: isDefense);
  }

  /// Reset the entire game state to initial values.
  void reset() {
    _feverTimer?.cancel();
    _feverTimer = null;
    state = GameState.initial();
  }

  // ── Private helpers ─────────────────────────────────────────

  void _processCorrectAnswer(SwipeResult result) {
    // 1. Calculate base + combo bonus.
    //    Combo bonus uses current combo BEFORE increment:
    //    1st answer → combo=0, bonus=0
    //    2nd answer → combo=1, bonus=2
    //    3rd answer → combo=2, bonus=4
    final int comboBonus = state.combo * 2;
    double points = (_baseScore + comboBonus).toDouble();

    // 2. Snap bonus: 1.5× total.
    if (result.isSnap) {
      points *= 1.5;
    }

    // 3. Fever bonus: 2× final score.
    if (state.isFeverMode) {
      points *= 2.0;
    }

    // 4. Cap at 10× base (max 100 points per answer).
    final int earnedPoints =
        points.round().clamp(0, _baseScore * _maxMultiplierCap);

    // 5. Derive new values.
    final int newCombo = state.combo + 1;
    final int newStreak = state.currentStreak + 1;
    final int newScore = state.score + earnedPoints;
    final bool shouldActivateFever =
        !state.isFeverMode && newStreak >= _feverStreakThreshold;
    final Tier newTier = Tier.fromScore(newScore);

    // 6. Emit new state.
    state = state.copyWith(
      score: newScore,
      combo: newCombo,
      currentStreak: newStreak,
      isFeverMode: state.isFeverMode || shouldActivateFever,
      currentTier: newTier,
    );

    // 7. Start fever timer if just activated.
    if (shouldActivateFever) {
      _startFeverTimer();
    }
  }

  void _processIncorrectAnswer() {
    final int newHearts = (state.hearts - 1).clamp(0, _maxHearts);

    state = state.copyWith(
      hearts: newHearts,
      combo: 0,
      currentStreak: 0,
    );
  }

  void _startFeverTimer() {
    _feverTimer?.cancel();
    _feverTimer = Timer(
      const Duration(seconds: _feverDurationSeconds),
      _deactivateFever,
    );
  }

  void _deactivateFever() {
    if (state.isFeverMode) {
      state = state.copyWith(isFeverMode: false);
    }
  }
}
