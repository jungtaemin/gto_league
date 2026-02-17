import 'dart:math';
import '../models/card_question.dart';
import '../models/poker_hand.dart';
import '../models/position.dart';

/// Deck generation service for balanced gameplay
/// 
/// Generates question decks with:
/// - Balanced push/fold ratio (~40% push / 60% fold)
/// - Equal position distribution
/// - Defense mode integration (call chart questions)
/// - Anti-streak logic (max 3 consecutive same answers)
class DeckGenerator {
  final Random _random;

  DeckGenerator([Random? random]) : _random = random ?? Random();

  /// Generate a deck of CardQuestion with balanced distributions
  /// 
  /// [count]: Number of questions to generate
  /// [defenseRatio]: Ratio of defense mode questions (0.0-1.0, typically 0.10-0.20)
  /// 
  /// Returns a shuffled list of CardQuestion maintaining balance constraints
  List<CardQuestion> generateDeck(int count, {double defenseRatio = 0.15}) {
    if (count <= 0) {
      return [];
    }

    final deck = <CardQuestion>[];
    final defenseCount = (count * defenseRatio).round();
    final pushFoldCount = count - defenseCount;

    // Generate push/fold questions (target 40% push / 60% fold)
    final pushCount = (pushFoldCount * 0.4).round();
    final foldCount = pushFoldCount - pushCount;

    // Generate push questions
    for (var i = 0; i < pushCount; i++) {
      deck.add(_generatePushQuestion());
    }

    // Generate fold questions
    for (var i = 0; i < foldCount; i++) {
      deck.add(_generateFoldQuestion());
    }

    // Generate defense mode questions
    for (var i = 0; i < defenseCount; i++) {
      deck.add(_generateDefenseQuestion());
    }

    // Shuffle but prevent long streaks
    return _shuffleWithAntiStreak(deck);
  }

  CardQuestion _generatePushQuestion() {
    final position = _randomPosition();
    final hand = _randomPushHand(position);
    
    return CardQuestion(
      position: position.shortName,
      hand: hand.toNotation(),
      stackBb: 15,
      correctAction: 'PUSH',
      evBb: _mockEvForPush(hand),
      chartType: 'PUSH',
      opponentPosition: null,
    );
  }

  CardQuestion _generateFoldQuestion() {
    final position = _randomPosition();
    final hand = _randomFoldHand(position);
    
    return CardQuestion(
      position: position.shortName,
      hand: hand.toNotation(),
      stackBb: 15,
      correctAction: 'FOLD',
      evBb: _mockEvForFold(hand),
      chartType: 'PUSH',
      opponentPosition: null,
    );
  }

  CardQuestion _generateDefenseQuestion() {
    final opponentPos = _randomAggressorPosition();
    final hand = _randomDefenseHand();
    final isCall = _random.nextBool();
    
    return CardQuestion(
      position: 'BB', // Defense is always from BB
      hand: hand.toNotation(),
      stackBb: 15,
      correctAction: isCall ? 'CALL' : 'FOLD',
      evBb: isCall ? _mockEvForCall(hand) : _mockEvForFold(hand),
      chartType: 'CALL',
      opponentPosition: opponentPos.shortName,
    );
  }

  Position _randomPosition() {
    return Position.values[_random.nextInt(Position.values.length)];
  }

  Position _randomAggressorPosition() {
    // Defense mode: opponent can be SB, BTN, CO, or UTG
    const aggressors = [Position.sb, Position.btn, Position.co, Position.utg];
    return aggressors[_random.nextInt(aggressors.length)];
  }

  PokerHand _randomPushHand(Position position) {
    // Stronger hands for tighter positions
    final handList = <String>[];
    
    switch (position) {
      case Position.sb:
      case Position.btn:
        // Wide range
        handList.addAll([
          'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77',
          'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s',
          'AKo', 'AQo', 'AJo', 'KQs', 'KJs', 'KTs', 'QJs',
        ]);
        break;
      case Position.co:
      case Position.hj:
        // Medium range
        handList.addAll([
          'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88',
          'AKs', 'AQs', 'AJs', 'ATs', 'A9s',
          'AKo', 'AQo', 'KQs', 'KJs',
        ]);
        break;
      default:
        // Tight range
        handList.addAll([
          'AA', 'KK', 'QQ', 'JJ', 'TT',
          'AKs', 'AQs', 'AJs', 'AKo',
        ]);
    }
    
    final notation = handList[_random.nextInt(handList.length)];
    return PokerHand.fromNotation(notation);
  }

  PokerHand _randomFoldHand(Position position) {
    // Weaker hands for all positions
    const weakHands = [
      '72o', '82o', '92o', '73o', '83o', '93o', '74o', '84o', '94o',
      '75o', '85o', '95o', '76o', '86o', '96o', '32o', '42o', '52o',
      '62o', '43o', '53o', '63o', '54o', '64o', '65o',
    ];
    
    final notation = weakHands[_random.nextInt(weakHands.length)];
    return PokerHand.fromNotation(notation);
  }

  PokerHand _randomDefenseHand() {
    // Mix of calling and folding hands
    const defenseHands = [
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'AKo', 'AQo', 'AJo',
      'KQs', 'KJs', 'KTs', 'QJs', 'JTs',
      '72o', '82o', '92o', '73o', '83o', '32o', '42o', '52o',
    ];
    
    final notation = defenseHands[_random.nextInt(defenseHands.length)];
    return PokerHand.fromNotation(notation);
  }

  /// Shuffle deck while preventing streaks longer than 3
  List<CardQuestion> _shuffleWithAntiStreak(List<CardQuestion> deck) {
    // Simple shuffle first
    deck.shuffle(_random);
    
    // Then check for streaks and break them
    for (var i = 0; i < deck.length - 3; i++) {
      if (_hasFourConsecutiveSameAnswer(deck, i)) {
        // Find a different answer further ahead and swap
        for (var j = i + 3; j < deck.length; j++) {
          if (deck[j].correctAction != deck[i].correctAction) {
            final temp = deck[i + 3];
            deck[i + 3] = deck[j];
            deck[j] = temp;
            break;
          }
        }
      }
    }
    
    return deck;
  }

  bool _hasFourConsecutiveSameAnswer(List<CardQuestion> deck, int startIndex) {
    if (startIndex + 3 >= deck.length) return false;
    
    final action = deck[startIndex].correctAction;
    return deck[startIndex + 1].correctAction == action &&
        deck[startIndex + 2].correctAction == action &&
        deck[startIndex + 3].correctAction == action;
  }

  // Mock EV values (will be replaced with actual DB queries in T9)
  double _mockEvForPush(PokerHand hand) {
    return (hand.strength / 169 * 4.0) - 2.0; // Range: -2.0 to +2.0
  }

  double _mockEvForFold(PokerHand hand) {
    return -1.0 - (hand.strength / 169 * 1.0); // Range: -1.0 to -2.0
  }

  double _mockEvForCall(PokerHand hand) {
    return (hand.strength / 169 * 3.0) - 1.0; // Range: -1.0 to +2.0
  }
}
