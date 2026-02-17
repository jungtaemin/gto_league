/// Poker table position enum with Korean display names
enum Position {
  utg,
  utg1,
  mp,
  hj,
  co,
  btn,
  sb,
  bb;

  /// Korean display name
  String get displayName {
    switch (this) {
      case Position.utg:
        return '언더더건';
      case Position.utg1:
        return '언더더건+1';
      case Position.mp:
        return '미들';
      case Position.hj:
        return '하이잭';
      case Position.co:
        return '컷오프';
      case Position.btn:
        return '버튼';
      case Position.sb:
        return '스몰블라인드';
      case Position.bb:
        return '빅블라인드';
    }
  }

  /// Short name for charts (e.g., "BTN", "SB")
  String get shortName {
    switch (this) {
      case Position.utg:
        return 'UTG';
      case Position.utg1:
        return 'UTG+1';
      case Position.mp:
        return 'MP';
      case Position.hj:
        return 'HJ';
      case Position.co:
        return 'CO';
      case Position.btn:
        return 'BTN';
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
      case 'MP':
        return Position.mp;
      case 'HJ':
        return Position.hj;
      case 'CO':
        return Position.co;
      case 'BTN':
      case 'BU':
        return Position.btn;
      case 'SB':
        return Position.sb;
      case 'BB':
        return Position.bb;
      default:
        throw ArgumentError('Invalid position name: $name');
    }
  }
}
