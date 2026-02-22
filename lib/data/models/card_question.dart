/// Represents a poker push/fold decision question
class CardQuestion {
  final String position;
  final String hand;
  final double stackBb;
  final String correctAction;
  final double evBb;
  final String chartType;
  final String? opponentPosition;
  final bool isMixed;
  final double evDiffBb;
  final double pushFreq;
  final double foldFreq;
  final String actionHistory;
  final String scenarioType;
  final int bbLevel;

  const CardQuestion({
    required this.position,
    required this.hand,
    required this.stackBb,
    required this.correctAction,
    required this.evBb,
    required this.chartType,
    this.opponentPosition,
    this.isMixed = false,
    this.evDiffBb = 0.0,
    this.pushFreq = 1.0,
    this.foldFreq = 0.0,
    this.actionHistory = '',
    this.scenarioType = 'open_push',
    this.bbLevel = 15,
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
    bool? isMixed,
    double? evDiffBb,
    double? pushFreq,
    double? foldFreq,
    String? actionHistory,
    String? scenarioType,
    int? bbLevel,
  }) {
    return CardQuestion(
      position: position ?? this.position,
      hand: hand ?? this.hand,
      stackBb: stackBb ?? this.stackBb,
      correctAction: correctAction ?? this.correctAction,
      evBb: evBb ?? this.evBb,
      chartType: chartType ?? this.chartType,
      opponentPosition: opponentPosition ?? this.opponentPosition,
      isMixed: isMixed ?? this.isMixed,
      evDiffBb: evDiffBb ?? this.evDiffBb,
      pushFreq: pushFreq ?? this.pushFreq,
      foldFreq: foldFreq ?? this.foldFreq,
      actionHistory: actionHistory ?? this.actionHistory,
      scenarioType: scenarioType ?? this.scenarioType,
      bbLevel: bbLevel ?? this.bbLevel,
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
          opponentPosition == other.opponentPosition &&
          isMixed == other.isMixed &&
          evDiffBb == other.evDiffBb &&
          pushFreq == other.pushFreq &&
          foldFreq == other.foldFreq &&
          actionHistory == other.actionHistory &&
          scenarioType == other.scenarioType &&
          bbLevel == other.bbLevel;

  @override
  int get hashCode =>
      position.hashCode ^
      hand.hashCode ^
      stackBb.hashCode ^
      correctAction.hashCode ^
      evBb.hashCode ^
      chartType.hashCode ^
      opponentPosition.hashCode ^
      isMixed.hashCode ^
      evDiffBb.hashCode ^
      pushFreq.hashCode ^
      foldFreq.hashCode ^
      actionHistory.hashCode ^
      scenarioType.hashCode ^
      bbLevel.hashCode;

  @override
  String toString() =>
      'CardQuestion(position: $position, hand: $hand, stackBb: $stackBb, '
      'correctAction: $correctAction, evBb: $evBb, chartType: $chartType, '
      'opponentPosition: $opponentPosition, isMixed: $isMixed, '
      'evDiffBb: $evDiffBb, pushFreq: $pushFreq, foldFreq: $foldFreq, '
      'actionHistory: $actionHistory, scenarioType: $scenarioType, '
      'bbLevel: $bbLevel)';

  /// Factory constructor for creating CardQuestion from GTO scenario data
  factory CardQuestion.fromGtoScenario({
    required String position,
    required String hand,
    required double stackBb,
    required String correctAction,
    required double evBb,
    required String chartType,
    String? opponentPosition,
    bool isMixed = false,
    double evDiffBb = 0.0,
    double pushFreq = 1.0,
    double foldFreq = 0.0,
    String actionHistory = '',
    String scenarioType = 'open_push',
    int bbLevel = 15,
  }) {
    return CardQuestion(
      position: position,
      hand: hand,
      stackBb: stackBb,
      correctAction: correctAction,
      evBb: evBb,
      chartType: chartType,
      opponentPosition: opponentPosition,
      isMixed: isMixed,
      evDiffBb: evDiffBb,
      pushFreq: pushFreq,
      foldFreq: foldFreq,
      actionHistory: actionHistory,
      scenarioType: scenarioType,
      bbLevel: bbLevel,
    );
  }
}
