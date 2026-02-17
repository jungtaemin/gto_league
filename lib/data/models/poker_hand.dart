/// Poker hand model with notation parsing and Korean display names
/// 
/// Represents a single poker hand in notation format (e.g., "AKs", "QQ", "72o")
/// Supports 169 unique hands from AA (best) to 32o (worst)
class PokerHand {
  final String rank1; // Higher rank (A, K, Q, J, T, 9-2)
  final String rank2; // Lower rank
  final bool isSuited; // true = suited (s), false = offsuit (o) or pair

  const PokerHand({
    required this.rank1,
    required this.rank2,
    required this.isSuited,
  });

  /// Parse notation string (e.g., "AKs", "QQ", "72o")
  factory PokerHand.fromNotation(String notation) {
    if (notation.length < 2 || notation.length > 3) {
      throw ArgumentError('Invalid hand notation: $notation');
    }

    final rank1 = notation[0];
    final rank2 = notation[1];
    final bool isSuited;

    if (notation.length == 2) {
      // Pair (e.g., "AA", "KK")
      isSuited = false;
    } else {
      final suffix = notation[2].toLowerCase();
      if (suffix == 's') {
        isSuited = true;
      } else if (suffix == 'o') {
        isSuited = false;
      } else {
        throw ArgumentError('Invalid hand suffix: $suffix (must be s or o)');
      }
    }

    return PokerHand(rank1: rank1, rank2: rank2, isSuited: isSuited);
  }

  /// Convert to notation string
  String toNotation() {
    if (isPair) {
      return '$rank1$rank2';
    } else {
      return '$rank1$rank2${isSuited ? 's' : 'o'}';
    }
  }

  /// Korean display name (e.g., "에이스 킹 수티드", "킹 킹")
  String get displayName {
    final r1 = _koreanRankName(rank1);
    final r2 = _koreanRankName(rank2);

    if (isPair) {
      return '$r1 $r2';
    } else {
      final suitedness = isSuited ? '수티드' : '오프수트';
      return '$r1 $r2 $suitedness';
    }
  }

  /// Hand strength ranking (1 = AA, 169 = 32o)
  int get strength {
    return _handStrengthMap[toNotation()] ?? 169;
  }

  /// Check if this is a pocket pair
  bool get isPair => rank1 == rank2;

  String _koreanRankName(String rank) {
    switch (rank) {
      case 'A':
        return '에이스';
      case 'K':
        return '킹';
      case 'Q':
        return '퀸';
      case 'J':
        return '잭';
      case 'T':
        return '텐';
      case '9':
        return '나인';
      case '8':
        return '에잇';
      case '7':
        return '세븐';
      case '6':
        return '식스';
      case '5':
        return '파이브';
      case '4':
        return '포';
      case '3':
        return '트레이';
      case '2':
        return '듀스';
      default:
        return rank;
    }
  }

  /// Hand strength lookup table (169 hands ranked)
  static const Map<String, int> _handStrengthMap = {
    // Pairs (1-13)
    'AA': 1,
    'KK': 2,
    'QQ': 3,
    'JJ': 4,
    'TT': 5,
    '99': 6,
    '88': 7,
    '77': 8,
    '66': 9,
    '55': 10,
    '44': 11,
    '33': 12,
    '22': 13,
    // Suited hands (14-91)
    'AKs': 14,
    'AQs': 15,
    'AJs': 16,
    'ATs': 17,
    'A9s': 18,
    'A8s': 19,
    'A7s': 20,
    'A6s': 21,
    'A5s': 22,
    'A4s': 23,
    'A3s': 24,
    'A2s': 25,
    'KQs': 26,
    'KJs': 27,
    'KTs': 28,
    'K9s': 29,
    'K8s': 30,
    'K7s': 31,
    'K6s': 32,
    'K5s': 33,
    'K4s': 34,
    'K3s': 35,
    'K2s': 36,
    'QJs': 37,
    'QTs': 38,
    'Q9s': 39,
    'Q8s': 40,
    'Q7s': 41,
    'Q6s': 42,
    'Q5s': 43,
    'Q4s': 44,
    'Q3s': 45,
    'Q2s': 46,
    'JTs': 47,
    'J9s': 48,
    'J8s': 49,
    'J7s': 50,
    'J6s': 51,
    'J5s': 52,
    'J4s': 53,
    'J3s': 54,
    'J2s': 55,
    'T9s': 56,
    'T8s': 57,
    'T7s': 58,
    'T6s': 59,
    'T5s': 60,
    'T4s': 61,
    'T3s': 62,
    'T2s': 63,
    '98s': 64,
    '97s': 65,
    '96s': 66,
    '95s': 67,
    '94s': 68,
    '93s': 69,
    '92s': 70,
    '87s': 71,
    '86s': 72,
    '85s': 73,
    '84s': 74,
    '83s': 75,
    '82s': 76,
    '76s': 77,
    '75s': 78,
    '74s': 79,
    '73s': 80,
    '72s': 81,
    '65s': 82,
    '64s': 83,
    '63s': 84,
    '62s': 85,
    '54s': 86,
    '53s': 87,
    '52s': 88,
    '43s': 89,
    '42s': 90,
    '32s': 91,
    // Offsuit hands (92-169)
    'AKo': 92,
    'AQo': 93,
    'AJo': 94,
    'ATo': 95,
    'A9o': 96,
    'A8o': 97,
    'A7o': 98,
    'A6o': 99,
    'A5o': 100,
    'A4o': 101,
    'A3o': 102,
    'A2o': 103,
    'KQo': 104,
    'KJo': 105,
    'KTo': 106,
    'K9o': 107,
    'K8o': 108,
    'K7o': 109,
    'K6o': 110,
    'K5o': 111,
    'K4o': 112,
    'K3o': 113,
    'K2o': 114,
    'QJo': 115,
    'QTo': 116,
    'Q9o': 117,
    'Q8o': 118,
    'Q7o': 119,
    'Q6o': 120,
    'Q5o': 121,
    'Q4o': 122,
    'Q3o': 123,
    'Q2o': 124,
    'JTo': 125,
    'J9o': 126,
    'J8o': 127,
    'J7o': 128,
    'J6o': 129,
    'J5o': 130,
    'J4o': 131,
    'J3o': 132,
    'J2o': 133,
    'T9o': 134,
    'T8o': 135,
    'T7o': 136,
    'T6o': 137,
    'T5o': 138,
    'T4o': 139,
    'T3o': 140,
    'T2o': 141,
    '98o': 142,
    '97o': 143,
    '96o': 144,
    '95o': 145,
    '94o': 146,
    '93o': 147,
    '92o': 148,
    '87o': 149,
    '86o': 150,
    '85o': 151,
    '84o': 152,
    '83o': 153,
    '82o': 154,
    '76o': 155,
    '75o': 156,
    '74o': 157,
    '73o': 158,
    '72o': 169, // Worst hand
    '65o': 160,
    '64o': 161,
    '63o': 162,
    '62o': 163,
    '54o': 164,
    '53o': 165,
    '52o': 166,
    '43o': 167,
    '42o': 168,
    '32o': 169,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokerHand &&
          runtimeType == other.runtimeType &&
          rank1 == other.rank1 &&
          rank2 == other.rank2 &&
          isSuited == other.isSuited;

  @override
  int get hashCode => rank1.hashCode ^ rank2.hashCode ^ isSuited.hashCode;

  @override
  String toString() => toNotation();
}
