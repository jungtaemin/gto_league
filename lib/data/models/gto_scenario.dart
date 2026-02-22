/// Represents a single GTO training scenario from the master database
class GtoScenario {
  final String hand;
  final String position;
  final int bbLevel;
  final String scenarioType;
  final String correctAction;
  final double evBb;
  final double evDiffBb;
  final bool isMixed;
  final double pushFreq;
  final double foldFreq;
  final String actionHistory;
  final String? opponentPosition;

  const GtoScenario({
    required this.hand,
    required this.position,
    required this.bbLevel,
    required this.scenarioType,
    required this.correctAction,
    required this.evBb,
    required this.evDiffBb,
    required this.isMixed,
    required this.pushFreq,
    required this.foldFreq,
    required this.actionHistory,
    this.opponentPosition,
  });

  /// Create a GtoScenario from JSON
  factory GtoScenario.fromJson(Map<String, dynamic> json) {
    return GtoScenario(
      hand: json['hand'] as String,
      position: json['position'] as String,
      bbLevel: json['bbLevel'] as int,
      scenarioType: json['scenarioType'] as String,
      correctAction: json['correctAction'] as String,
      evBb: (json['evBb'] as num).toDouble(),
      evDiffBb: (json['evDiffBb'] as num).toDouble(),
      isMixed: json['isMixed'] as bool,
      pushFreq: (json['pushFreq'] as num).toDouble(),
      foldFreq: (json['foldFreq'] as num).toDouble(),
      actionHistory: json['actionHistory'] as String,
      opponentPosition: json['opponentPosition'] as String?,
    );
  }

  /// Convert this GtoScenario to JSON
  Map<String, dynamic> toJson() {
    return {
      'hand': hand,
      'position': position,
      'bbLevel': bbLevel,
      'scenarioType': scenarioType,
      'correctAction': correctAction,
      'evBb': evBb,
      'evDiffBb': evDiffBb,
      'isMixed': isMixed,
      'pushFreq': pushFreq,
      'foldFreq': foldFreq,
      'actionHistory': actionHistory,
      'opponentPosition': opponentPosition,
    };
  }

  /// Create a copy of this scenario with optional field overrides
  GtoScenario copyWith({
    String? hand,
    String? position,
    int? bbLevel,
    String? scenarioType,
    String? correctAction,
    double? evBb,
    double? evDiffBb,
    bool? isMixed,
    double? pushFreq,
    double? foldFreq,
    String? actionHistory,
    String? opponentPosition,
  }) {
    return GtoScenario(
      hand: hand ?? this.hand,
      position: position ?? this.position,
      bbLevel: bbLevel ?? this.bbLevel,
      scenarioType: scenarioType ?? this.scenarioType,
      correctAction: correctAction ?? this.correctAction,
      evBb: evBb ?? this.evBb,
      evDiffBb: evDiffBb ?? this.evDiffBb,
      isMixed: isMixed ?? this.isMixed,
      pushFreq: pushFreq ?? this.pushFreq,
      foldFreq: foldFreq ?? this.foldFreq,
      actionHistory: actionHistory ?? this.actionHistory,
      opponentPosition: opponentPosition ?? this.opponentPosition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GtoScenario &&
          runtimeType == other.runtimeType &&
          hand == other.hand &&
          position == other.position &&
          bbLevel == other.bbLevel &&
          scenarioType == other.scenarioType &&
          correctAction == other.correctAction &&
          evBb == other.evBb &&
          evDiffBb == other.evDiffBb &&
          isMixed == other.isMixed &&
          pushFreq == other.pushFreq &&
          foldFreq == other.foldFreq &&
          actionHistory == other.actionHistory &&
          opponentPosition == other.opponentPosition;

  @override
  int get hashCode =>
      hand.hashCode ^
      position.hashCode ^
      bbLevel.hashCode ^
      scenarioType.hashCode ^
      correctAction.hashCode ^
      evBb.hashCode ^
      evDiffBb.hashCode ^
      isMixed.hashCode ^
      pushFreq.hashCode ^
      foldFreq.hashCode ^
      actionHistory.hashCode ^
      opponentPosition.hashCode;

  @override
  String toString() =>
      'GtoScenario(hand: $hand, position: $position, bbLevel: $bbLevel, scenarioType: $scenarioType, correctAction: $correctAction, evBb: $evBb, evDiffBb: $evDiffBb, isMixed: $isMixed, pushFreq: $pushFreq, foldFreq: $foldFreq, actionHistory: $actionHistory, opponentPosition: $opponentPosition)';
}
