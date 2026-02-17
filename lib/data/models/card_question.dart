/// Represents a poker push/fold decision question
class CardQuestion {
  final String position;
  final String hand;
  final double stackBb;
  final String correctAction;
  final double evBb;
  final String chartType;
  final String? opponentPosition;

  const CardQuestion({
    required this.position,
    required this.hand,
    required this.stackBb,
    required this.correctAction,
    required this.evBb,
    required this.chartType,
    this.opponentPosition,
  });

  /// Create a copy of this question with optional field overrides
  CardQuestion copyWith({
    String? position,
    String? hand,
    double? stackBb,
    String? correctAction,
    double? evBb,
    String? chartType,
    String? opponentPosition,
  }) {
    return CardQuestion(
      position: position ?? this.position,
      hand: hand ?? this.hand,
      stackBb: stackBb ?? this.stackBb,
      correctAction: correctAction ?? this.correctAction,
      evBb: evBb ?? this.evBb,
      chartType: chartType ?? this.chartType,
      opponentPosition: opponentPosition ?? this.opponentPosition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardQuestion &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          hand == other.hand &&
          stackBb == other.stackBb &&
          correctAction == other.correctAction &&
          evBb == other.evBb &&
          chartType == other.chartType &&
          opponentPosition == other.opponentPosition;

  @override
  int get hashCode =>
      position.hashCode ^
      hand.hashCode ^
      stackBb.hashCode ^
      correctAction.hashCode ^
      evBb.hashCode ^
      chartType.hashCode ^
      opponentPosition.hashCode;

  @override
  String toString() =>
      'CardQuestion(position: $position, hand: $hand, stackBb: $stackBb, correctAction: $correctAction, evBb: $evBb, chartType: $chartType, opponentPosition: $opponentPosition)';
}
