/// Pure utility class for deriving player bet amounts and pot size from action history.
///
/// Parses action history strings (e.g., "UTG_F.UTG1_R__HJ") and derives:
/// - Individual player bet amounts in BB units
/// - Total pot size in BB units
///
/// Standard poker amounts:
/// - SB = 0.5 BB
/// - BB = 1.0 BB
/// - Open raise = 2.2 BB
/// - 3-bet = 7.0 BB
/// - All-in = 30.0 BB
class BetAmountHelper {
  // Standard bet amounts in BB units
  static const double _sb = 0.5;
  static const double _bb = 1.0;
  static const double _openRaise = 2.2;
  static const double _threeBet = 7.0;
  static const double _allin = 30.0;

  /// Derives individual player bet amounts from action history.
  ///
  /// Returns a map of position → final bet amount in BB.
  /// Always includes SB=0.5 and BB=1.0 as base blinds.
  ///
  /// Action codes:
  /// - F = fold (no bet added)
  /// - C = call (match current highest bet)
  /// - R = raise (2.2 BB first time, 7.0 BB second time / 3-bet)
  /// - A = push/all-in (30.0 BB)
  static Map<String, double> derivePlayerBets(String actionHistory) {
    final bets = <String, double>{
      'SB': _sb,
      'BB': _bb,
    };

    if (actionHistory.isEmpty) {
      return bets;
    }

    final actions = _parseActions(actionHistory);
    double currentHighestBet = _bb;

    for (final action in actions) {
      final position = action.position;
      final actionCode = action.action;

      switch (actionCode) {
        case 'fold':
          // Fold: no bet added
          break;
        case 'call':
          // Call: match current highest bet
          bets[position] = currentHighestBet;
          break;
        case 'raise':
          // First raise: 2.2 BB
          bets[position] = _openRaise;
          currentHighestBet = _openRaise;
          break;
        case '3bet':
          // Second raise (3-bet): 7.0 BB
          bets[position] = _threeBet;
          currentHighestBet = _threeBet;
          break;
        case 'push':
          // All-in: 30.0 BB
          bets[position] = _allin;
          currentHighestBet = _allin;
          break;
      }
    }

    return bets;
  }

  /// Derives total pot size from action history.
  ///
  /// Returns the sum of all player bets in BB units.
  static double derivePotSize(String actionHistory) {
    final bets = derivePlayerBets(actionHistory);
    return bets.values.fold(0.0, (sum, bet) => sum + bet);
  }

  /// Parses action history string into individual action steps.
  ///
  /// Format: "UTG_F.UTG1_R__HJ" (dot-separated, each part is "POSITION_ACTIONCODE")
  /// Action codes: F=fold, C=call, R=raise, A=push/allin
  ///
  /// Returns list of ({position, action}) records.
  static List<({String position, String action})> _parseActions(
    String actionHistory,
  ) {
    final steps = <({String position, String action})>[];

    if (actionHistory.isEmpty) return steps;

    // Parse new format: "UTG_F.UTG1_R__HJ"
    if (actionHistory.contains('_') && !actionHistory.contains('pushes')) {
      final parts = actionHistory.split('.');
      bool hasRaised = false;

      for (final part in parts) {
        final pair = part.split('_');
        if (pair.length == 2) {
          final pos = pair[0];
          final actionCode = pair[1];

          String actionStr;
          switch (actionCode) {
            case 'F':
              actionStr = 'fold';
              break;
            case 'C':
              actionStr = 'call';
              break;
            case 'R':
              actionStr = hasRaised ? '3bet' : 'raise';
              hasRaised = true;
              break;
            case 'A':
              actionStr = 'push';
              hasRaised = true;
              break;
            default:
              actionStr = 'call';
          }

          steps.add((position: _normalizePos(pos), action: actionStr));
        }
      }
    } else {
      // Legacy format: "UTG pushes, UTG+1 calls"
      for (final part in actionHistory.split(', ')) {
        final trimmed = part.trim();
        if (trimmed.contains('pushes')) {
          final pos = trimmed.split(' ').first;
          steps.add((position: _normalizePos(pos), action: 'push'));
        } else if (trimmed.contains('calls')) {
          final pos = trimmed.split(' ').first;
          steps.add((position: _normalizePos(pos), action: 'call'));
        }
      }
    }

    return steps;
  }

  /// Normalizes position names to standard format.
  ///
  /// Examples: "UTG" → "UTG", "UTG+1" → "UTG+1", "SB" → "SB"
  static String _normalizePos(String pos) {
    switch (pos.toUpperCase()) {
      case 'BTN': return 'BU';
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      default: return pos.toUpperCase();
    }
  }
}
