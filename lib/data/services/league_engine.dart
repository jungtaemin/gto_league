import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card_question.dart';

part 'league_engine.g.dart';

// ── League Phase ──────────────────────────────────────────────

/// Phase of the League 100-Hand Survival game.
enum LeaguePhase {
  /// Actively playing hands.
  playing,

  /// Level transition cutscene in progress.
  levelUp,

  /// Player lost their single life — game over.
  gameOver,

  /// Player completed all 100 hands — victory.
  victory,
}

// ── League State ──────────────────────────────────────────────

/// Immutable state for the League Survival mode.
///
/// Identical to Deep Run but with 1 life and time chips.
/// 5 levels × 20 hands = 100 total hands.
/// 1-Strike system: wrong answer → instant game over.
/// Time chips: 3 at start, +15s each, manual activation.
class LeagueState {
  /// Current level (1–5).
  final int currentLevel;

  /// Current hand within the level (1–20, resets each level).
  final int handInLevel;

  /// Total hands played across all levels (1–100).
  final int totalHands;

  /// Remaining strikes before game over (starts at 1).
  final int strikesRemaining;

  /// Remaining time chips (starts at 3).
  final int timeChipsRemaining;

  /// Cumulative score.
  final int score;

  /// Current combo streak (resets on wrong answer).
  final int combo;

  /// Consecutive correct answers (resets on wrong answer).
  final int currentStreak;

  /// Whether the game has ended (strikes = 0 or completed 100 hands).
  final bool isGameOver;

  /// Whether the player completed all 100 hands.
  final bool isVictory;

  /// Whether a level-up cutscene is playing.
  final bool isLevelingUp;

  /// Current game phase.
  final LeaguePhase phase;

  const LeagueState({
    required this.currentLevel,
    required this.handInLevel,
    required this.totalHands,
    required this.strikesRemaining,
    required this.timeChipsRemaining,
    required this.score,
    required this.combo,
    required this.currentStreak,
    required this.isGameOver,
    required this.isVictory,
    required this.isLevelingUp,
    required this.phase,
  });

  /// Initial state: level 1, hand 1, 1 strike, 3 time chips, score 0.
  factory LeagueState.initial() {
    return const LeagueState(
      currentLevel: 1,
      handInLevel: 1,
      totalHands: 1,
      strikesRemaining: LeagueEngine._maxStrikes,
      timeChipsRemaining: LeagueEngine._initialTimeChips,
      score: 0,
      combo: 0,
      currentStreak: 0,
      isGameOver: false,
      isVictory: false,
      isLevelingUp: false,
      phase: LeaguePhase.playing,
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
  LeagueState copyWith({
    int? currentLevel,
    int? handInLevel,
    int? totalHands,
    int? strikesRemaining,
    int? timeChipsRemaining,
    int? score,
    int? combo,
    int? currentStreak,
    bool? isGameOver,
    bool? isVictory,
    bool? isLevelingUp,
    LeaguePhase? phase,
  }) {
    return LeagueState(
      currentLevel: currentLevel ?? this.currentLevel,
      handInLevel: handInLevel ?? this.handInLevel,
      totalHands: totalHands ?? this.totalHands,
      strikesRemaining: strikesRemaining ?? this.strikesRemaining,
      timeChipsRemaining: timeChipsRemaining ?? this.timeChipsRemaining,
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
      other is LeagueState &&
          runtimeType == other.runtimeType &&
          currentLevel == other.currentLevel &&
          handInLevel == other.handInLevel &&
          totalHands == other.totalHands &&
          strikesRemaining == other.strikesRemaining &&
          timeChipsRemaining == other.timeChipsRemaining &&
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
      timeChipsRemaining.hashCode ^
      score.hashCode ^
      combo.hashCode ^
      currentStreak.hashCode ^
      isGameOver.hashCode ^
      isVictory.hashCode ^
      isLevelingUp.hashCode ^
      phase.hashCode;

  @override
  String toString() =>
      'LeagueState(level: $currentLevel, hand: $handInLevel/$totalHands, '
      'strikes: $strikesRemaining, chips: $timeChipsRemaining, '
      'score: $score, combo: $combo, phase: $phase)';
}

// ── League Engine ─────────────────────────────────────────────

/// League 100-Hand Survival game loop engine.
///
/// Fork of [DeepRunEngine] with:
/// - 1 life (instant death on wrong answer)
/// - 3 time chips at start (+15s each, manual activation)
/// - Same 5 levels × 20 hands structure
/// - Same scoring system
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
class LeagueEngine extends _$LeagueEngine {
  // ── Constants ───────────────────────────────────────────────

  /// Base score per correct answer.
  static const int _baseScore = 10;

  /// Maximum points awardable for a single answer.
  static const int _maxPointsPerAnswer = 100;

  /// Maximum strikes at game start (League = 1 life).
  static const int _maxStrikes = 1;

  /// Starting time chips.
  static const int _initialTimeChips = 3;

  /// Seconds added per time chip.
  static const double timeChipBonus = 15.0;

  /// Hands per level.
  static const int _handsPerLevel = 20;

  /// Total number of levels.
  static const int _totalLevels = 5;

  /// Total hands across all levels.
  static const int _totalHands = _handsPerLevel * _totalLevels;

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  LeagueState build() {
    return LeagueState.initial();
  }

  // ── Public API ──────────────────────────────────────────────

  /// BB level for the current game level.
  int get currentBbLevel => state.currentBbLevel;

  /// Reset to initial state and start a new game.
  void startGame() {
    state = LeagueState.initial();
    debugPrint('[LeagueEngine] Game started');
  }

  /// Use a time chip to add bonus time.
  ///
  /// Returns `true` if a chip was consumed, `false` if none remain.
  /// The caller is responsible for calling `timerProvider.addTime()`.
  bool useTimeChip() {
    if (state.timeChipsRemaining <= 0) return false;
    if (state.isGameOver || state.isVictory) return false;
    if (state.phase != LeaguePhase.playing) return false;

    state = state.copyWith(
      timeChipsRemaining: state.timeChipsRemaining - 1,
    );

    debugPrint(
      '[LeagueEngine] Time chip used — '
      '${state.timeChipsRemaining} remaining',
    );
    return true;
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
    if (state.phase != LeaguePhase.playing) return;

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
        phase: LeaguePhase.gameOver,
      );
      debugPrint('[LeagueEngine] Game over — strikes depleted');
      return;
    }

    // Advance hand counters.
    final int newHandInLevel = state.handInLevel + 1;
    final int newTotalHands = state.totalHands + 1;

    // Victory: completed all 100 hands.
    if (newTotalHands > _totalHands) {
      state = state.copyWith(
        totalHands: _totalHands,
        isVictory: true,
        isGameOver: true,
        phase: LeaguePhase.victory,
      );
      debugPrint('[LeagueEngine] Victory — all $_totalHands hands completed');
      return;
    }

    // Level up: completed 20 hands in current level.
    if (newHandInLevel > _handsPerLevel &&
        state.currentLevel < _totalLevels) {
      state = state.copyWith(
        handInLevel: newHandInLevel,
        totalHands: newTotalHands,
        isLevelingUp: true,
        phase: LeaguePhase.levelUp,
      );
      debugPrint(
        '[LeagueEngine] Level ${state.currentLevel} complete — '
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
    if (state.phase != LeaguePhase.levelUp) return;

    final int nextLevel = (state.currentLevel + 1).clamp(1, _totalLevels);

    state = state.copyWith(
      currentLevel: nextLevel,
      handInLevel: 1,
      isLevelingUp: false,
      phase: LeaguePhase.playing,
    );

    debugPrint(
      '[LeagueEngine] Level $nextLevel started — '
      '${state.currentBbLevel}BB',
    );
  }

  /// Pause the game (app lifecycle).
  void pauseGame() {
    debugPrint('[LeagueEngine] Game paused');
  }

  /// Resume the game (app lifecycle).
  void resumeGame() {
    debugPrint('[LeagueEngine] Game resumed');
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