import 'dart:math';

import '../models/card_question.dart';
import '../models/swipe_result.dart';
import '../services/database_helper.dart';

/// Repository for GTO push/fold data backed by SQLite.
///
/// All queries use parameterised arguments via [DatabaseHelper] to prevent
/// SQL injection.  Empty result-sets are handled gracefully with a
/// hard-coded fallback question so callers never receive null.
class GtoRepository {
  final DatabaseHelper _dbHelper;
  final Random _random;

  GtoRepository({
    DatabaseHelper? dbHelper,
    Random? random,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  // ---------------------------------------------------------------------------
  // Fallback question (never return null / throw on empty DB)
  // ---------------------------------------------------------------------------

  static const _fallbackQuestion = CardQuestion(
    position: 'BTN',
    hand: 'AA',
    stackBb: 15,
    correctAction: 'PUSH',
    evBb: 1.5,
    chartType: 'PUSH',
  );

  // ---------------------------------------------------------------------------
  // getRandomQuestion
  // ---------------------------------------------------------------------------

  /// Fetches a single random question for the given [stackBb].
  ///
  /// When [isDefenseMode] is `false` (default) the `push_ranges` table is
  /// queried; otherwise `call_ranges`.
  Future<CardQuestion> getRandomQuestion(
    int stackBb, {
    bool isDefenseMode = false,
  }) async {
    final db = await _dbHelper.database;
    final table = isDefenseMode ? 'call_ranges' : 'push_ranges';

    final results = await db.query(
      table,
      where: 'stack_bb = ?',
      whereArgs: [stackBb],
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (results.isEmpty) return _fallbackQuestion;
    return _rowToCardQuestion(results.first, isDefenseMode: isDefenseMode);
  }

  // ---------------------------------------------------------------------------
  // checkAnswer
  // ---------------------------------------------------------------------------

  /// Evaluates the user's [userAction] against the [question]'s correct
  /// answer and returns a [SwipeResult] with an optional Korean fact-bomb
  /// message when the answer is wrong.
  SwipeResult checkAnswer(CardQuestion question, String userAction) {
    final normalizedUser = userAction.toUpperCase().trim();
    final normalizedCorrect = question.correctAction.toUpperCase().trim();
    final isCorrect = normalizedUser == normalizedCorrect;

    final evDiff = question.evBb.abs();
    final String? factBomb =
        isCorrect ? null : _generateFactBomb(question, normalizedUser);

    return SwipeResult(
      isCorrect: isCorrect,
      isSnap: false,
      pointsEarned: 0,
      evDiff: evDiff,
      factBombMessage: factBomb,
    );
  }

  // ---------------------------------------------------------------------------
  // getChartForPosition
  // ---------------------------------------------------------------------------

  /// Returns every hand row for the given [position] and [stackBb] from the
  /// `push_ranges` table.  The result is suitable for rendering a 13x13
  /// hand matrix in the UI.
  Future<List<Map<String, dynamic>>> getChartForPosition(
    String position,
    int stackBb,
  ) async {
    final db = await _dbHelper.database;
    return db.query(
      'push_ranges',
      where: 'position = ? AND stack_bb = ?',
      whereArgs: [position, stackBb],
      orderBy: 'hand ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // getDeckForSession
  // ---------------------------------------------------------------------------

  /// Builds a balanced deck of [count] questions.
  ///
  /// Target distribution:
  /// - ~40 % PUSH answers
  /// - ~60 % FOLD answers
  /// - [defenseRatio] % of questions drawn from `call_ranges`
  ///
  /// The deck is shuffled with an anti-streak guard that prevents 4+
  /// consecutive identical correct answers.
  Future<List<CardQuestion>> getDeckForSession(
    int count, {
    double defenseRatio = 0.15,
  }) async {
    if (count <= 0) return [];

    final db = await _dbHelper.database;
    final defenseCount = (count * defenseRatio).round();
    final pushFoldCount = count - defenseCount;
    final pushTargetCount = (pushFoldCount * 0.4).round();
    final foldTargetCount = pushFoldCount - pushTargetCount;

    final deck = <CardQuestion>[];

    // ---- Push questions --------------------------------------------------
    final pushRows = await db.query(
      'push_ranges',
      where: 'action = ?',
      whereArgs: ['PUSH'],
      orderBy: 'RANDOM()',
      limit: pushTargetCount,
    );
    deck.addAll(pushRows.map((r) => _rowToCardQuestion(r)));

    // ---- Fold questions --------------------------------------------------
    final foldRows = await db.query(
      'push_ranges',
      where: 'action = ?',
      whereArgs: ['FOLD'],
      orderBy: 'RANDOM()',
      limit: foldTargetCount,
    );
    deck.addAll(foldRows.map((r) => _rowToCardQuestion(r)));

    // ---- Defense (call_ranges) questions ----------------------------------
    if (defenseCount > 0) {
      final defenseRows = await db.query(
        'call_ranges',
        orderBy: 'RANDOM()',
        limit: defenseCount,
      );
      deck.addAll(
        defenseRows.map((r) => _rowToCardQuestion(r, isDefenseMode: true)),
      );
    }

    // ---- Pad with fallback if DB returned fewer rows than requested ------
    while (deck.length < count) {
      deck.add(_fallbackQuestion);
    }

    // ---- Shuffle with anti-streak ----------------------------------------
    return _shuffleWithAntiStreak(deck);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Maps a raw SQLite row to a [CardQuestion].
  CardQuestion _rowToCardQuestion(
    Map<String, dynamic> row, {
    bool isDefenseMode = false,
  }) {
    return CardQuestion(
      position: row['position'] as String,
      hand: row['hand'] as String,
      stackBb: (row['stack_bb'] as num).toDouble(),
      correctAction: row['action'] as String,
      evBb: (row['ev_bb'] as num).toDouble(),
      chartType: row['chart_type'] as String,
      opponentPosition:
          isDefenseMode ? row['opponent_position'] as String? : null,
    );
  }

  /// Generates a Korean fact-bomb explanation for a wrong answer.
  String _generateFactBomb(CardQuestion question, String userAction) {
    final pos = question.position;
    final hand = question.hand;
    final evDiff = question.evBb.abs().toStringAsFixed(1);

    // ---- Push chart mistakes ---------------------------------------------
    if (question.chartType == 'PUSH') {
      if (question.correctAction == 'PUSH' && userAction == 'FOLD') {
        return '🐔 쫄보 마인드 검거! '
            '$pos에서 $hand를 버리다니! '
            '${evDiff}BB의 수익을 허공에 버리셨습니다!';
      }
      if (question.correctAction == 'FOLD' && userAction == 'PUSH') {
        return '🚨 펍저씨 마인드 검거! '
            '$pos에서 $hand 올인은 '
            '${evDiff}BB의 확정 손실입니다!';
      }
    }

    // ---- Call chart (defense) mistakes ------------------------------------
    if (question.chartType == 'CALL') {
      final opp = question.opponentPosition ?? '앞집';
      if (question.correctAction == 'CALL' && userAction == 'FOLD') {
        return '🐔 $opp 올인에 $hand 폴드라니! '
            '${evDiff}BB를 버렸습니다!';
      }
      if (question.correctAction == 'FOLD' && userAction == 'CALL') {
        return '🚨 $opp 올인에 $hand로 콜하다니! '
            '칩 기부 감사합니다!';
      }
    }

    return '아쉽네요! GTO에서 벗어났습니다.';
  }

  /// Fisher–Yates shuffle followed by an anti-streak pass that prevents
  /// 4+ consecutive identical correct-actions.
  List<CardQuestion> _shuffleWithAntiStreak(List<CardQuestion> deck) {
    deck.shuffle(_random);

    for (var i = 0; i < deck.length - 3; i++) {
      if (_hasFourConsecutive(deck, i)) {
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

  bool _hasFourConsecutive(List<CardQuestion> deck, int start) {
    if (start + 3 >= deck.length) return false;
    final action = deck[start].correctAction;
    return deck[start + 1].correctAction == action &&
        deck[start + 2].correctAction == action &&
        deck[start + 3].correctAction == action;
  }
}
