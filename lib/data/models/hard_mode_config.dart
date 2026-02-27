/// Immutable hard mode configuration model
class HardModeConfig {
  final double evDiffBbThreshold;
  final double baseDuration;
  final double defenseRatio;
  final int targetPushCount;
  final int targetDefenseCount;
  final Map<int, double> comboTimerThresholds;

  HardModeConfig({
    required this.evDiffBbThreshold,
    required this.baseDuration,
    required this.defenseRatio,
    required this.targetPushCount,
    required this.targetDefenseCount,
    required this.comboTimerThresholds,
  });

  /// Hard mode configuration with challenging difficulty parameters
  factory HardModeConfig.defaults() {
    return HardModeConfig(
      evDiffBbThreshold: 0.7,
      baseDuration: 12.0,
      defenseRatio: 0.25,
      targetPushCount: 7,
      targetDefenseCount: 3,
      comboTimerThresholds: {5: 10.0, 10: 8.0, 15: 0.0},
    );
  }

  /// Normal mode configuration for comparison and testing
  factory HardModeConfig.normal() {
    return HardModeConfig(
      evDiffBbThreshold: double.infinity,
      baseDuration: 15.0,
      defenseRatio: 0.15,
      targetPushCount: 7,
      targetDefenseCount: 3,
      comboTimerThresholds: {5: 12.0, 10: 10.0, 15: 0.0},
    );
  }

  /// Create a copy of this configuration with optional field overrides
  HardModeConfig copyWith({
    double? evDiffBbThreshold,
    double? baseDuration,
    double? defenseRatio,
    int? targetPushCount,
    int? targetDefenseCount,
    Map<int, double>? comboTimerThresholds,
  }) {
    return HardModeConfig(
      evDiffBbThreshold: evDiffBbThreshold ?? this.evDiffBbThreshold,
      baseDuration: baseDuration ?? this.baseDuration,
      defenseRatio: defenseRatio ?? this.defenseRatio,
      targetPushCount: targetPushCount ?? this.targetPushCount,
      targetDefenseCount: targetDefenseCount ?? this.targetDefenseCount,
      comboTimerThresholds: comboTimerThresholds ?? this.comboTimerThresholds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardModeConfig &&
          runtimeType == other.runtimeType &&
          evDiffBbThreshold == other.evDiffBbThreshold &&
          baseDuration == other.baseDuration &&
          defenseRatio == other.defenseRatio &&
          targetPushCount == other.targetPushCount &&
          targetDefenseCount == other.targetDefenseCount &&
          comboTimerThresholds == other.comboTimerThresholds;

  @override
  int get hashCode =>
      evDiffBbThreshold.hashCode ^
      baseDuration.hashCode ^
      defenseRatio.hashCode ^
      targetPushCount.hashCode ^
      targetDefenseCount.hashCode ^
      comboTimerThresholds.hashCode;

  @override
  String toString() =>
      'HardModeConfig(evDiffBbThreshold: $evDiffBbThreshold, baseDuration: $baseDuration, defenseRatio: $defenseRatio, targetPushCount: $targetPushCount, targetDefenseCount: $targetDefenseCount, comboTimerThresholds: $comboTimerThresholds)';
}
