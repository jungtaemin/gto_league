import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card_question.dart';

part 'deep_run_engine.g.dart';

// ── Deep Run Phase ─────────────────────────────────────────────

/// Phase of the 50-Hand Deep Run Survival game.
enum DeepRunPhase {
  /// Actively playing hands.
  playing,

  /// Level transition cutscene in progress.
  levelUp,

  /// Player lost all strikes — game over.
  gameOver,

  /// Player completed all 50 hands — victory.
  victory,
}

// ── Deep Run State ─────────────────────────────────────────────

/// Immutable state for the 50-Hand Deep Run Survival mode.
///
/// 5 levels × 10 hands = 50 total hands.
/// 3-Strike system: wrong answer → lose 1 strike, 0 strikes → game over.
/// Level progression: 15BB → 12BB → 10BB → 7BB → 5BB.
class DeepRunState {
  /// Current level (1–5).
  final int currentLevel;

  /// Current hand within the level (1–10, resets each level).
  final int handInLevel;

  /// Total hands played across all levels (1–50).
  final int totalHands;

  /// Remaining strikes before game over (starts at 3).
  final int strikesRemaining;

  /// Cumulative score.
  final int score;

  /// Current combo streak (resets on wrong answer).
  final int combo;

  /// Consecutive correct answers (resets on wrong answer).
  final int currentStreak;

  /// Whether the game has ended (strikes = 0 or completed 50 hands).
  final bool isGameOver;

  /// Whether the player completed all 50 hands.
  final bool isVictory;

  /// Whether a level-up cutscene is playing.
  final bool isLevelingUp;

  /// Current game phase.
  final DeepRunPhase phase;

  const DeepRunState({
    required this.currentLevel,
    required this.handInLevel,
    required this.totalHands,
    required this.strikesRemaining,
    required this.score,
    required this.combo,
    required this.currentStreak,
    required this.isGameOver,
    required this.isVictory,
    required this.isLevelingUp,
    required this.phase,
  });

  /// Initial state: level 1, hand 1, 3 strikes, score 0.
  factory DeepRunState.initial() {
    return const DeepRunState(
      currentLevel: 1,
      handInLevel: 1,
      totalHands: 1,
      strikesRemaining: 3,
      score: 0,
      combo: 0,
      currentStreak: 0,
      isGameOver: false,
      isVictory: false,
      isLevelingUp: false,
      phase: DeepRunPhase.playing,
    );
  }

  /// BB level for the current level.
  ///
  /// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
  /// Level 4 = 7BB, Level 5 = 5BB.
  int get currentBbLevel {
    switch (currentLevel) {
      case 1:
        return 15;
      case 2:
        return 12;
      case 3:
        return 10;
      case 4:
        return 7;
      case 5:
        return 5;
      default:
        return 15;
    }
  }

  /// Create a copy with optional field overrides.
  DeepRunState copyWith({
    int? currentLevel,
    int? handInLevel,
    int? totalHands,
    int? strikesRemaining,
    int? score,
    int? combo,
    int? currentStreak,
    bool? isGameOver,
    bool? isVictory,
    bool? isLevelingUp,
    DeepRunPhase? phase,
  }) {
    return DeepRunState(
      currentLevel: currentLevel ?? this.currentLevel,
      handInLevel: handInLevel ?? this.handInLevel,
      totalHands: totalHands ?? this.totalHands,
      strikesRemaining: strikesRemaining ?? this.strikesRemaining,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      currentStreak: currentStreak ?? this.currentStreak,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      isLevelingUp: isLevelingUp ?? this.isLevelingUp,
      phase: phase ?? this.phase,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepRunState &&
          runtimeType == other.runtimeType &&
          currentLevel == other.currentLevel &&
          handInLevel == other.handInLevel &&
          totalHands == other.totalHands &&
          strikesRemaining == other.strikesRemaining &&
          score == other.score &&
          combo == other.combo &&
          currentStreak == other.currentStreak &&
          isGameOver == other.isGameOver &&
          isVictory == other.isVictory &&
          isLevelingUp == other.isLevelingUp &&
          phase == other.phase;

  @override
  int get hashCode =>
      currentLevel.hashCode ^
      handInLevel.hashCode ^
      totalHands.hashCode ^
      strikesRemaining.hashCode ^
      score.hashCode ^
      combo.hashCode ^
      currentStreak.hashCode ^
      isGameOver.hashCode ^
      isVictory.hashCode ^
      isLevelingUp.hashCode ^
      phase.hashCode;

  @override
  String toString() =>
      'DeepRunState(level: $currentLevel, hand: $handInLevel/$totalHands, '
      'strikes: $strikesRemaining, score: $score, combo: $combo, '
      'streak: $currentStreak, phase: $phase)';
}

// ── Deep Run Engine ────────────────────────────────────────────

/// 50-Hand Deep Run Survival game loop engine.
///
/// Manages 5 levels × 10 hands, 3-strike system, scoring,
/// and level transitions. Consumed by Deep Run Screen.
///
/// ## Scoring
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Cap: 100 points max per answer
/// - Mixed strategy: ALWAYS counts as correct
///
/// ## Level → BB Mapping
/// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
/// Level 4 = 7BB, Level 5 = 5BB
@Riverpod(keepAlive: true)
class DeepRunEngine extends _$DeepRunEngine {
  // ── Constants ───────────────────────────────────────────────

  /// Base score per correct answer.
  static const int _baseScore = 10;

  /// Maximum points awardable for a single answer.
  static const int _maxPointsPerAnswer = 100;

  /// Maximum strikes at game start.
  static const int _maxStrikes = 3;

  /// Hands per level.
  static const int _handsPerLevel = 10;

  /// Total number of levels.
  static const int _totalLevels = 5;

  /// Total hands across all levels.
  static const int _totalHands = _handsPerLevel * _totalLevels;

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  DeepRunState build() {
    return DeepRunState.initial();
  }

  // ── Public API ──────────────────────────────────────────────

  /// BB level for the current game level.
  int get currentBbLevel => state.currentBbLevel;

  /// Reset to initial state and start a new game.
  void startGame() {
    state = DeepRunState.initial();
    debugPrint('[DeepRunEngine] Game started');
  }

  /// Process a player's answer to a question.
  ///
  /// - [isCorrect]: whether the player's swipe matched the GTO answer.
  /// - [isMixed]: mixed-strategy hands always count as correct.
  /// - [question]: the CardQuestion that was answered.
  void answerQuestion({
    required bool isCorrect,
    required bool isMixed,
    required CardQuestion question,
  }) {
    if (state.isGameOver || state.isVictory) return;
    if (state.phase != DeepRunPhase.playing) return;

    // Mixed strategy hands are NEVER wrong.
    final bool effectiveCorrect = isMixed || isCorrect;

    if (effectiveCorrect) {
      _processCorrectAnswer();
    } else {
      _processIncorrectAnswer();
    }

    // Check terminal conditions AFTER processing the answer.
    if (state.strikesRemaining <= 0) {
      state = state.copyWith(
        isGameOver: true,
        phase: DeepRunPhase.gameOver,
      );
      debugPrint('[DeepRunEngine] Game over — strikes depleted');
      return;
    }

    // Advance hand counters.
    final int newHandInLevel = state.handInLevel + 1;
    final int newTotalHands = state.totalHands + 1;

    // Victory: completed all 50 hands.
    if (newTotalHands > _totalHands) {
      state = state.copyWith(
        totalHands: _totalHands,
        isVictory: true,
        isGameOver: true,
        phase: DeepRunPhase.victory,
      );
      debugPrint('[DeepRunEngine] Victory — all $_totalHands hands completed');
      return;
    }

    // Level up: completed 10 hands in current level.
    if (newHandInLevel > _handsPerLevel && state.currentLevel < _totalLevels) {
      state = state.copyWith(
        handInLevel: newHandInLevel,
        totalHands: newTotalHands,
        isLevelingUp: true,
        phase: DeepRunPhase.levelUp,
      );
      debugPrint(
        '[DeepRunEngine] Level ${state.currentLevel} complete — '
        'transitioning to level ${state.currentLevel + 1}',
      );
      return;
    }

    // Normal progression.
    state = state.copyWith(
      handInLevel: newHandInLevel,
      totalHands: newTotalHands,
    );
  }

  /// Called after the level-up cutscene ends.
  ///
  /// Increments level, resets hand counter, resumes play.
  void completeLevelUp() {
    if (state.phase != DeepRunPhase.levelUp) return;

    final int nextLevel = (state.currentLevel + 1).clamp(1, _totalLevels);

    state = state.copyWith(
      currentLevel: nextLevel,
      handInLevel: 1,
      isLevelingUp: false,
      phase: DeepRunPhase.playing,
    );

    debugPrint(
      '[DeepRunEngine] Level $nextLevel started — '
      '${state.currentBbLevel}BB',
    );
  }

  /// Pause the game (app lifecycle).
  void pauseGame() {
    debugPrint('[DeepRunEngine] Game paused');
  }

  /// Resume the game (app lifecycle).
  void resumeGame() {
    debugPrint('[DeepRunEngine] Game resumed');
  }

  // ── Private helpers ─────────────────────────────────────────

  void _processCorrectAnswer() {
    // Score = base(10) + comboBonus(combo × 2), capped at 100.
    final int comboBonus = state.combo * 2;
    final int earned =
        (_baseScore + comboBonus).clamp(0, _maxPointsPerAnswer);

    state = state.copyWith(
      score: state.score + earned,
      combo: state.combo + 1,
      currentStreak: state.currentStreak + 1,
    );
  }

  void _processIncorrectAnswer() {
    final int newStrikes =
        (state.strikesRemaining - 1).clamp(0, _maxStrikes);

    state = state.copyWith(
      strikesRemaining: newStrikes,
      combo: 0,
      currentStreak: 0,
    );
  }
}
