import 'tier.dart';

/// Immutable game state model
class GameState {
  final int score;
  final int hearts;
  final int combo;
  final int currentStreak;
  final bool isFeverMode;
  final bool isDefenseMode;
  final int timeBankCount;
  final Tier currentTier;

  const GameState({
    required this.score,
    required this.hearts,
    required this.combo,
    required this.currentStreak,
    required this.isFeverMode,
    required this.isDefenseMode,
    required this.timeBankCount,
    required this.currentTier,
  });

  /// Initial game state with default values
  factory GameState.initial() {
    return const GameState(
      score: 0,
      hearts: 3,
      combo: 0,
      currentStreak: 0,
      isFeverMode: false,
      isDefenseMode: false,
      timeBankCount: 3,
      currentTier: Tier.fish,
    );
  }

  /// Create a copy of this state with optional field overrides
  GameState copyWith({
    int? score,
    int? hearts,
    int? combo,
    int? currentStreak,
    bool? isFeverMode,
    bool? isDefenseMode,
    int? timeBankCount,
    Tier? currentTier,
  }) {
    return GameState(
      score: score ?? this.score,
      hearts: hearts ?? this.hearts,
      combo: combo ?? this.combo,
      currentStreak: currentStreak ?? this.currentStreak,
      isFeverMode: isFeverMode ?? this.isFeverMode,
      isDefenseMode: isDefenseMode ?? this.isDefenseMode,
      timeBankCount: timeBankCount ?? this.timeBankCount,
      currentTier: currentTier ?? this.currentTier,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          hearts == other.hearts &&
          combo == other.combo &&
          currentStreak == other.currentStreak &&
          isFeverMode == other.isFeverMode &&
          isDefenseMode == other.isDefenseMode &&
          timeBankCount == other.timeBankCount &&
          currentTier == other.currentTier;

  @override
  int get hashCode =>
      score.hashCode ^
      hearts.hashCode ^
      combo.hashCode ^
      currentStreak.hashCode ^
      isFeverMode.hashCode ^
      isDefenseMode.hashCode ^
      timeBankCount.hashCode ^
      currentTier.hashCode;

  @override
  String toString() =>
      'GameState(score: $score, hearts: $hearts, combo: $combo, currentStreak: $currentStreak, isFeverMode: $isFeverMode, isDefenseMode: $isDefenseMode, timeBankCount: $timeBankCount, currentTier: $currentTier)';
}
