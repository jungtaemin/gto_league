import 'package:flutter_test/flutter_test.dart';
import 'package:holdem_allin_fold/data/models/poker_hand.dart';
import 'package:holdem_allin_fold/data/models/position.dart';

void main() {
  group('PokerHand', () {
    test('fromNotation parses suited hands correctly', () {
      final hand = PokerHand.fromNotation('AKs');
      
      expect(hand.rank1, 'A');
      expect(hand.rank2, 'K');
      expect(hand.isSuited, true);
      expect(hand.isPair, false);
    });

    test('fromNotation parses offsuit hands correctly', () {
      final hand = PokerHand.fromNotation('AKo');
      
      expect(hand.rank1, 'A');
      expect(hand.rank2, 'K');
      expect(hand.isSuited, false);
      expect(hand.isPair, false);
    });

    test('fromNotation parses pairs correctly', () {
      final hand = PokerHand.fromNotation('AA');
      
      expect(hand.rank1, 'A');
      expect(hand.rank2, 'A');
      expect(hand.isSuited, false);
      expect(hand.isPair, true);
    });

    test('toNotation converts back correctly', () {
      expect(PokerHand.fromNotation('AKs').toNotation(), 'AKs');
      expect(PokerHand.fromNotation('72o').toNotation(), '72o');
      expect(PokerHand.fromNotation('QQ').toNotation(), 'QQ');
    });

    test('displayName returns Korean name for suited', () {
      final hand = PokerHand.fromNotation('AKs');
      expect(hand.displayName, '에이스 킹 수티드');
    });

    test('displayName returns Korean name for offsuit', () {
      final hand = PokerHand.fromNotation('72o');
      expect(hand.displayName, '세븐 듀스 오프수트');
    });

    test('displayName returns Korean name for pairs', () {
      final hand = PokerHand.fromNotation('AA');
      expect(hand.displayName, '에이스 에이스');
    });

    test('strength returns correct ranking', () {
      expect(PokerHand.fromNotation('AA').strength, 1); // Best
      expect(PokerHand.fromNotation('KK').strength, 2);
      expect(PokerHand.fromNotation('AKs').strength, 14);
      expect(PokerHand.fromNotation('72o').strength, 169); // Worst
    });

    test('strength ordering is correct (AA > KK > QQ)', () {
      final aa = PokerHand.fromNotation('AA');
      final kk = PokerHand.fromNotation('KK');
      final qq = PokerHand.fromNotation('QQ');
      
      expect(aa.strength < kk.strength, true);
      expect(kk.strength < qq.strength, true);
    });

    test('equality works correctly', () {
      final hand1 = PokerHand.fromNotation('AKs');
      final hand2 = PokerHand.fromNotation('AKs');
      final hand3 = PokerHand.fromNotation('AKo');
      
      expect(hand1, equals(hand2));
      expect(hand1, isNot(equals(hand3)));
    });
  });

  group('Position', () {
    test('displayName returns Korean names', () {
      expect(Position.btn.displayName, '버튼');
      expect(Position.sb.displayName, '스몰블라인드');
      expect(Position.bb.displayName, '빅블라인드');
      expect(Position.utg.displayName, '언더더건');
    });

    test('shortName returns abbreviations', () {
      expect(Position.btn.shortName, 'BTN');
      expect(Position.sb.shortName, 'SB');
      expect(Position.bb.shortName, 'BB');
      expect(Position.utg.shortName, 'UTG');
      expect(Position.utg1.shortName, 'UTG+1');
    });

    test('fromShortName parses correctly', () {
      expect(Position.fromShortName('BTN'), Position.btn);
      expect(Position.fromShortName('btn'), Position.btn);
      expect(Position.fromShortName('SB'), Position.sb);
      expect(Position.fromShortName('UTG'), Position.utg);
      expect(Position.fromShortName('UTG+1'), Position.utg1);
      expect(Position.fromShortName('UTG1'), Position.utg1);
    });

    test('fromShortName throws on invalid name', () {
      expect(() => Position.fromShortName('INVALID'), throwsArgumentError);
    });
  });
}
