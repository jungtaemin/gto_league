import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/card_question.dart';
import '../models/gto_scenario.dart';

/// Generates shuffled decks of 10 [CardQuestion] instances per level
/// from the GTO master database for Deep Run mode.
///
/// Ensures:
/// - 70/30 push/defense ratio (7 push, 3 defense ±1)
/// - Position balance (max 3 questions from same position)
/// - Hand diversity (no duplicate hand+position combos)
/// - Anti-streak (max 3 consecutive same-answer questions)
/// - Reproducible output via optional [seed]
class DeepRunQuestionGenerator {
  static const int _deckSize = 10;
  static const int _targetPushCount = 7;
  static const int _targetDefenseCount = 3;
  // 7:3 ratio -> out of 3 defense: 2 single, 1 multi
  static const int _targetDefenseSingleCount = 2;
  static const int _targetDefenseMultiCount = 1;
  static const int _maxSamePosition = 3;
  static const int _maxConsecutiveSameAction = 3;

  /// Generate a shuffled deck of 10 [CardQuestion]s for the given BB level.
  ///
  /// [bbLevel] — the stack depth in big blinds (e.g. 10, 12, 15, 20, 25).
  /// [scenarios] — full list of [GtoScenario] from the master database.
  /// [seed] — optional RNG seed for reproducible output in tests.
  ///
  /// Returns an empty list if no scenarios match the given [bbLevel].
  List<CardQuestion> generateDeck({
    required int bbLevel,
    required List<GtoScenario> scenarios,
    int? seed,
  }) {
    final random = Random(seed);

    // 1. Filter scenarios by bbLevel
    final levelScenarios =
        scenarios.where((s) => s.bbLevel == bbLevel).toList();

    if (levelScenarios.isEmpty) {
      debugPrint(
        '[DeepRunQuestionGenerator] No scenarios found for BB level $bbLevel',
      );
      return [];
    }

    // 2. Separate into open_push, defense_single, defense_multi pools
    final pushPool =
        levelScenarios.where((s) => s.scenarioType == 'open_push').toList();
    final defenseSinglePool = levelScenarios
        .where((s) => s.scenarioType == 'defense_single')
        .toList();
    final defenseMultiPool = levelScenarios
        .where((s) => s.scenarioType == 'defense_multi')
        .toList();

    // 3. Determine actual counts — push stays at 14, defense 6 (5 single + 1 multi)
    int pushCount = _targetPushCount;
    int singleCount = _targetDefenseSingleCount;
    int multiCount = _targetDefenseMultiCount;

    // Adjust if pools are too small
    if (defenseMultiPool.length < multiCount) {
      multiCount = defenseMultiPool.length;
      singleCount = min(_targetDefenseCount - multiCount, defenseSinglePool.length);
    }
    if (defenseSinglePool.length < singleCount) {
      singleCount = defenseSinglePool.length;
      multiCount = min(_targetDefenseCount - singleCount, defenseMultiPool.length);
    }

    final defenseCount = singleCount + multiCount;

    if (pushPool.length < pushCount) {
      pushCount = pushPool.length;
    }

    final totalCount = pushCount + defenseCount;
    if (totalCount == 0) {
      debugPrint(
        '[DeepRunQuestionGenerator] Insufficient scenarios for BB level $bbLevel',
      );
      return [];
    }

    // 4. Select scenarios with position balance + hand diversity constraints
    final selectedPush = _selectWithConstraints(pushPool, pushCount, random);
    final selectedDefenseSingle =
        _selectWithConstraints(defenseSinglePool, singleCount, random);
    final selectedDefenseMulti =
        _selectWithConstraints(defenseMultiPool, multiCount, random);

    // 5. Convert GtoScenario → CardQuestion
    final deck = <CardQuestion>[
      ...selectedPush.map(_toCardQuestion),
      ...selectedDefenseSingle.map(_toCardQuestion),
      ...selectedDefenseMulti.map(_toCardQuestion),
    ];

    // 6. Shuffle the final deck
    deck.shuffle(random);

    // 7. Apply anti-streak (break runs of >3 consecutive same correctAction)
    _applyAntiStreak(deck);

    return deck;
  }

  /// Select [count] scenarios from [pool] respecting constraints:
  /// - Max [_maxSamePosition] questions from the same position
  /// - No duplicate hand+position combinations
  ///
  /// Falls back to relaxed constraints if the pool is too constrained.
  List<GtoScenario> _selectWithConstraints(
    List<GtoScenario> pool,
    int count,
    Random random,
  ) {
    if (pool.isEmpty || count <= 0) return [];

    final shuffled = List<GtoScenario>.from(pool)..shuffle(random);

    final selected = <GtoScenario>[];
    final positionCounts = <String, int>{};
    final handPositionKeys = <String>{};

    // Pass 1: strict constraints (position balance + hand diversity)
    for (final scenario in shuffled) {
      if (selected.length >= count) break;

      final posCount = positionCounts[scenario.position] ?? 0;
      if (posCount >= _maxSamePosition) continue;

      final key = '${scenario.hand}_${scenario.position}';
      if (handPositionKeys.contains(key)) continue;

      selected.add(scenario);
      positionCounts[scenario.position] = posCount + 1;
      handPositionKeys.add(key);
    }

    // Pass 2: relax position balance, keep hand diversity
    if (selected.length < count) {
      for (final scenario in shuffled) {
        if (selected.length >= count) break;

        final key = '${scenario.hand}_${scenario.position}';
        if (handPositionKeys.contains(key)) continue;

        selected.add(scenario);
        handPositionKeys.add(key);
      }
    }

    // Pass 3: last resort — fill remaining with any unused scenario
    if (selected.length < count) {
      for (final scenario in shuffled) {
        if (selected.length >= count) break;
        if (!selected.contains(scenario)) {
          selected.add(scenario);
        }
      }
    }

    return selected;
  }

  /// Convert a [GtoScenario] to a [CardQuestion].
  CardQuestion _toCardQuestion(GtoScenario scenario) {
    return CardQuestion.fromGtoScenario(
      position: scenario.position,
      hand: scenario.hand,
      stackBb: scenario.bbLevel.toDouble(),
      correctAction: scenario.correctAction,
      evBb: scenario.evBb,
      chartType: scenario.scenarioType == 'open_push' ? 'push' : 'call',
      opponentPosition: scenario.opponentPosition,
      isMixed: scenario.isMixed,
      evDiffBb: scenario.evDiffBb,
      pushFreq: scenario.pushFreq,
      foldFreq: scenario.foldFreq,
      actionHistory: scenario.actionHistory,
      scenarioType: scenario.scenarioType,
      bbLevel: scenario.bbLevel,
    );
  }

  /// Break streaks of more than [_maxConsecutiveSameAction] consecutive
  /// questions with the same [CardQuestion.correctAction].
  ///
  /// Scans left-to-right and swaps the 4th consecutive element with
  /// the nearest different-action element further in the list.
  void _applyAntiStreak(List<CardQuestion> deck) {
    for (var i = 0;
        i < deck.length - _maxConsecutiveSameAction;
        i++) {
      if (_hasStreakAt(deck, i, _maxConsecutiveSameAction + 1)) {
        // Find the nearest swap candidate after the streak
        for (var j = i + _maxConsecutiveSameAction; j < deck.length; j++) {
          if (deck[j].correctAction != deck[i].correctAction) {
            final swapIndex = i + _maxConsecutiveSameAction;
            final temp = deck[swapIndex];
            deck[swapIndex] = deck[j];
            deck[j] = temp;
            break;
          }
        }
      }
    }
  }

  /// Returns `true` if [length] consecutive elements starting at [start]
  /// all share the same [CardQuestion.correctAction].
  bool _hasStreakAt(List<CardQuestion> deck, int start, int length) {
    if (start + length > deck.length) return false;

    final action = deck[start].correctAction;
    for (var i = 1; i < length; i++) {
      if (deck[start + i].correctAction != action) return false;
    }
    return true;
  }

  /// Generate a brief fact-bomb string for a scenario.
  ///
  /// Useful for UI display alongside the question card.
  /// Examples: "Push EV: +2.3BB", "Mixed: 60% push / 40% fold".
  static String generateFactBomb(GtoScenario scenario) {
    if (scenario.isMixed) {
      final pushPct = (scenario.pushFreq * 100).round();
      final foldPct = (scenario.foldFreq * 100).round();
      return 'Mixed: $pushPct% push / $foldPct% fold';
    }

    final evSign = scenario.evBb >= 0 ? '+' : '';
    return '${scenario.correctAction} EV: '
        '$evSign${scenario.evBb.toStringAsFixed(1)}BB';
  }
}
