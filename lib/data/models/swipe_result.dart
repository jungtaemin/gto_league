/// Represents the result of a swipe action on a card
class SwipeResult {
  final bool isCorrect;
  final bool isSnap;
  final int pointsEarned;
  final double evDiff;
  final String? factBombMessage;

  const SwipeResult({
    required this.isCorrect,
    required this.isSnap,
    required this.pointsEarned,
    required this.evDiff,
    this.factBombMessage,
  });

  /// Create a copy of this result with optional field overrides
  SwipeResult copyWith({
    bool? isCorrect,
    bool? isSnap,
    int? pointsEarned,
    double? evDiff,
    String? factBombMessage,
  }) {
    return SwipeResult(
      isCorrect: isCorrect ?? this.isCorrect,
      isSnap: isSnap ?? this.isSnap,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      evDiff: evDiff ?? this.evDiff,
      factBombMessage: factBombMessage ?? this.factBombMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwipeResult &&
          runtimeType == other.runtimeType &&
          isCorrect == other.isCorrect &&
          isSnap == other.isSnap &&
          pointsEarned == other.pointsEarned &&
          evDiff == other.evDiff &&
          factBombMessage == other.factBombMessage;

  @override
  int get hashCode =>
      isCorrect.hashCode ^
      isSnap.hashCode ^
      pointsEarned.hashCode ^
      evDiff.hashCode ^
      factBombMessage.hashCode;

  @override
  String toString() =>
      'SwipeResult(isCorrect: $isCorrect, isSnap: $isSnap, pointsEarned: $pointsEarned, evDiff: $evDiff, factBombMessage: $factBombMessage)';
}
