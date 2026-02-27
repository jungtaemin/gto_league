/// Represents a single 30BB deep stack GTO scenario with 4-way action frequencies.
///
/// Parsed from `master_30bb.json.gz` where each hand has `[fold%, call%, raise%, allin%]`.
/// Node keys encode action history and hero position (e.g., `UTG_F__UTG1`).
class DeepStackScenario {
  final String hand;
  final String position;
  final String actionHistory;
  final int foldFreq;
  final int callFreq;
  final int raiseFreq;
  final int allinFreq;

  const DeepStackScenario({
    required this.hand,
    required this.position,
    required this.actionHistory,
    required this.foldFreq,
    required this.callFreq,
    required this.raiseFreq,
    required this.allinFreq,
  });

  /// Create a [DeepStackScenario] from a master_30bb.json node entry.
  ///
  /// [hand] — e.g. 'AKs', '77', 'T9o'
  /// [freqs] — `[fold%, call%, raise%, allin%]` integer array (0–100, sums to 100)
  /// [nodeKey] — e.g. 'UTG' (first-level) or 'UTG_F__UTG1' (action history + position)
  factory DeepStackScenario.fromNodeEntry(
    String hand,
    List<int> freqs,
    String nodeKey,
  ) {
    final parsed = _parseNodeKey(nodeKey);
    return DeepStackScenario(
      hand: hand,
      position: parsed.position,
      actionHistory: parsed.actionHistory,
      foldFreq: freqs[0],
      callFreq: freqs[1],
      raiseFreq: freqs[2],
      allinFreq: freqs[3],
    );
  }

  /// The action name with the highest frequency.
  ///
  /// Ties are resolved by priority: allin > raise > call > fold.
  String get dominantAction {
    final entries = <String, int>{
      'fold': foldFreq,
      'call': callFreq,
      'raise': raiseFreq,
      'allin': allinFreq,
    };
    int maxFreq = -1;
    String dominant = 'fold';
    // Priority order: allin > raise > call > fold (reverse iteration)
    for (final action in const ['fold', 'call', 'raise', 'allin']) {
      final freq = entries[action]!;
      if (freq >= maxFreq) {
        maxFreq = freq;
        dominant = action;
      }
    }
    return dominant;
  }

  /// Get the frequency (0–100) for a given action name.
  int getFrequency(String action) {
    switch (action) {
      case 'fold':
        return foldFreq;
      case 'call':
        return callFreq;
      case 'raise':
        return raiseFreq;
      case 'allin':
        return allinFreq;
      default:
        return 0;
    }
  }

  /// Whether this scenario has a mixed strategy (more than one action with >0 frequency).
  bool get isMixed {
    int nonZero = 0;
    if (foldFreq > 0) nonZero++;
    if (callFreq > 0) nonZero++;
    if (raiseFreq > 0) nonZero++;
    if (allinFreq > 0) nonZero++;
    return nonZero > 1;
  }

  DeepStackScenario copyWith({
    String? hand,
    String? position,
    String? actionHistory,
    int? foldFreq,
    int? callFreq,
    int? raiseFreq,
    int? allinFreq,
  }) {
    return DeepStackScenario(
      hand: hand ?? this.hand,
      position: position ?? this.position,
      actionHistory: actionHistory ?? this.actionHistory,
      foldFreq: foldFreq ?? this.foldFreq,
      callFreq: callFreq ?? this.callFreq,
      raiseFreq: raiseFreq ?? this.raiseFreq,
      allinFreq: allinFreq ?? this.allinFreq,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepStackScenario &&
          runtimeType == other.runtimeType &&
          hand == other.hand &&
          position == other.position &&
          actionHistory == other.actionHistory &&
          foldFreq == other.foldFreq &&
          callFreq == other.callFreq &&
          raiseFreq == other.raiseFreq &&
          allinFreq == other.allinFreq;

  @override
  int get hashCode =>
      hand.hashCode ^
      position.hashCode ^
      actionHistory.hashCode ^
      foldFreq.hashCode ^
      callFreq.hashCode ^
      raiseFreq.hashCode ^
      allinFreq.hashCode;

  @override
  String toString() =>
      'DeepStackScenario(hand: $hand, position: $position, '
      'actionHistory: $actionHistory, '
      'fold: $foldFreq%, call: $callFreq%, '
      'raise: $raiseFreq%, allin: $allinFreq%)';

  // ── Private Helpers ────────────────────────────────────────────

  /// Parse a node key into (actionHistory, heroPosition).
  ///
  /// First-level nodes (e.g. 'UTG') have no `__` separator:
  ///   → actionHistory = '', position = 'UTG'
  ///
  /// Multi-level nodes (e.g. 'UTG_F__UTG1') use `__` as separator:
  ///   → actionHistory = 'UTG_F', position = 'UTG1'
  ///
  /// Complex nodes (e.g. 'UTG_F.UTG1_F.UTG2_F...SB_R__BB'):
  ///   → actionHistory = 'UTG_F.UTG1_F.UTG2_F...SB_R', position = 'BB'
  static _NodeKeyParts _parseNodeKey(String nodeKey) {
    final separatorIndex = nodeKey.lastIndexOf('__');
    if (separatorIndex == -1) {
      // First-level node: key IS the position, no action history.
      return _NodeKeyParts(actionHistory: '', position: nodeKey);
    }
    return _NodeKeyParts(
      actionHistory: nodeKey.substring(0, separatorIndex),
      position: nodeKey.substring(separatorIndex + 2),
    );
  }
}

/// Internal helper for parsed node key parts.
class _NodeKeyParts {
  final String actionHistory;
  final String position;
  const _NodeKeyParts({required this.actionHistory, required this.position});
}
