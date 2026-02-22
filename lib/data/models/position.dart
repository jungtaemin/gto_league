/// Poker table position enum with Korean display names
enum Position {
  utg,
  utg1,
  utg2,
  lj,
  hj,
  co,
  bu,
  sb,
  bb;

  /// Korean display name
  String get displayName {
    switch (this) {
      case Position.utg:
        return '언더더건';
      case Position.utg1:
        return '언더더건+1';
      case Position.utg2:
        return '언더더건+2';
      case Position.lj:
        return '로우잭';
      case Position.hj:
        return '하이잭';
      case Position.co:
        return '컷오프';
      case Position.bu:
        return '버튼';
      case Position.sb:
        return '스몰블라인드';
      case Position.bb:
        return '빅블라인드';
    }
  }

  /// Short name for charts (e.g., "BU", "SB")
  String get shortName {
    switch (this) {
      case Position.utg:
        return 'UTG';
      case Position.utg1:
        return 'UTG+1';
      case Position.utg2:
        return 'UTG+2';
      case Position.lj:
        return 'LJ';
      case Position.hj:
        return 'HJ';
      case Position.co:
        return 'CO';
      case Position.bu:
        return 'BU';
      case Position.sb:
        return 'SB';
      case Position.bb:
        return 'BB';
    }
  }

  /// Parse from short name string (case-insensitive)
  static Position fromShortName(String name) {
    final upper = name.toUpperCase();
    switch (upper) {
      case 'UTG':
        return Position.utg;
      case 'UTG+1':
      case 'UTG1':
        return Position.utg1;
      case 'UTG+2':
      case 'UTG2':
        return Position.utg2;
      case 'LJ':
        return Position.lj;
      case 'HJ':
        return Position.hj;
      case 'CO':
        return Position.co;
      case 'BTN':
      case 'BU':
        return Position.bu;
      case 'SB':
        return Position.sb;
      case 'BB':
        return Position.bb;
      default:
        throw ArgumentError('Invalid position name: $name');
    }
  }

  /// Map player index (0-8) to position for 9-max tables
  static Position fromPlayerIndex(int index) {
    if (index < 0 || index > 8) {
      throw ArgumentError('Player index must be 0-8, got $index');
    }
    return Position.values[index];
  }
}
