import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holdem_allin_fold/data/services/league_engine.dart';
import 'package:holdem_allin_fold/data/models/card_question.dart';

void main() {
  group('LeagueEngine', () {
    late ProviderContainer container;
    late LeagueEngine engine;

    setUp(() {
      container = ProviderContainer();
      engine = container.read(leagueEngineProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    CardQuestion _makeQuestion({String correctAction = 'push'}) {
      return CardQuestion(
        position: 'BTN',
        hand: 'AKs',
        stackBb: 15,
        correctAction: correctAction,
        evBb: 1.5,
        chartType: 'push',
      );
    }

    // ── Initial State ──────────────────────────────────────────

    test('Initial state is correct', () {
      final state = container.read(leagueEngineProvider);
      expect(state.currentLevel, 1);
      expect(state.handInLevel, 1);
      expect(state.totalHands, 1);
      expect(state.strikesRemaining, 1);
      expect(state.timeChipsRemaining, 3);
      expect(state.score, 0);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
      expect(state.isGameOver, false);
      expect(state.isVictory, false);
      expect(state.phase, LeaguePhase.playing);
    });

    test('currentBbLevel maps correctly per level', () {
      expect(container.read(leagueEngineProvider).currentBbLevel, 15);
    });

    // ── Scoring ─────────────────────────────────────────────────

    test('Correct answer awards base 10 points', () {
      engine.answerQuestion(
        isCorrect: true,
        isMixed: false,
        question: _makeQuestion(),
      );
      final state = container.read(leagueEngineProvider);
      expect(state.score, 10);
      expect(state.combo, 1);
      expect(state.currentStreak, 1);
    });

    test('Combo bonus applied correctly', () {
      // 1st: 10 + 0 = 10
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).score, 10);

      // 2nd: 10 + 2 = 12 (total 22)
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).score, 22);

      // 3rd: 10 + 4 = 14 (total 36)
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).score, 36);
    });

    test('Score capped at 100 per answer', () {
      // Build massive combo
      for (var i = 0; i < 50; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      final scoreBefore = container.read(leagueEngineProvider).score;

      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      final scoreAfter = container.read(leagueEngineProvider).score;

      expect(scoreAfter - scoreBefore, lessThanOrEqualTo(100));
    });

    // ── Strike System (1 Life) ──────────────────────────────────

    test('Incorrect answer loses the single strike and resets combo', () {
      // Build combo first
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).combo, 2);

      // Wrong answer
      engine.answerQuestion(
          isCorrect: false, isMixed: false, question: _makeQuestion());
      final state = container.read(leagueEngineProvider);
      expect(state.strikesRemaining, 0);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
    });

    test('Game over instantly on first wrong answer (1 life)', () {
      engine.answerQuestion(
          isCorrect: false, isMixed: false, question: _makeQuestion());

      final state = container.read(leagueEngineProvider);
      expect(state.strikesRemaining, 0);
      expect(state.isGameOver, true);
      expect(state.phase, LeaguePhase.gameOver);
    });

    test('Cannot answer after game over', () {
      // Deplete single strike
      engine.answerQuestion(
          isCorrect: false, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).isGameOver, true);

      final scoreBefore = container.read(leagueEngineProvider).score;
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).score, scoreBefore);
    });

    // ── Time Chips ──────────────────────────────────────────────

    test('useTimeChip consumes a chip and returns true', () {
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 3);

      final result = engine.useTimeChip();

      expect(result, true);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);
    });

    test('useTimeChip decrements correctly through all 3 chips', () {
      expect(engine.useTimeChip(), true);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);

      expect(engine.useTimeChip(), true);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 1);

      expect(engine.useTimeChip(), true);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 0);
    });

    test('useTimeChip returns false when no chips remain', () {
      // Use all 3 chips
      engine.useTimeChip();
      engine.useTimeChip();
      engine.useTimeChip();
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 0);

      final result = engine.useTimeChip();
      expect(result, false);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 0);
    });

    test('useTimeChip returns false when game is over', () {
      // End game
      engine.answerQuestion(
          isCorrect: false, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).isGameOver, true);

      final result = engine.useTimeChip();
      expect(result, false);
      // Chips should remain unchanged
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 3);
    });

    test('useTimeChip returns false during levelUp phase', () {
      // Play 20 hands to trigger level up
      for (var i = 0; i < 20; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      expect(
          container.read(leagueEngineProvider).phase, LeaguePhase.levelUp);

      final result = engine.useTimeChip();
      expect(result, false);
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 3);
    });

    test('timeChipBonus constant is 15.0', () {
      expect(LeagueEngine.timeChipBonus, 15.0);
    });

    // ── Mixed Strategy ──────────────────────────────────────────

    test('Mixed strategy always counts as correct', () {
      engine.answerQuestion(
          isCorrect: false, isMixed: true, question: _makeQuestion());
      final state = container.read(leagueEngineProvider);
      expect(state.strikesRemaining, 1); // No strike lost
      expect(state.score, 10); // Score awarded
      expect(state.combo, 1);
    });

    // ── Level Progression ───────────────────────────────────────

    test('Level up after 20 hands', () {
      // Play 20 correct hands
      for (var i = 0; i < 20; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }

      final state = container.read(leagueEngineProvider);
      expect(state.phase, LeaguePhase.levelUp);
      expect(state.isLevelingUp, true);
      expect(state.currentLevel, 1); // Still level 1 until completeLevelUp
    });

    test('completeLevelUp advances to next level', () {
      // Play 20 hands
      for (var i = 0; i < 20; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      expect(
          container.read(leagueEngineProvider).phase, LeaguePhase.levelUp);

      engine.completeLevelUp();

      final state = container.read(leagueEngineProvider);
      expect(state.currentLevel, 2);
      expect(state.handInLevel, 1);
      expect(state.phase, LeaguePhase.playing);
      expect(state.currentBbLevel, 12);
    });

    test('BB levels progress correctly: 15 -> 12 -> 10 -> 7 -> 5', () {
      final expectedBb = [15, 12, 10, 7, 5];

      for (var level = 0; level < 5; level++) {
        final state = container.read(leagueEngineProvider);
        expect(state.currentBbLevel, expectedBb[level],
            reason: 'Level ${level + 1} should be ${expectedBb[level]}BB');

        if (level < 4) {
          // Play 20 hands to advance
          for (var i = 0; i < 20; i++) {
            engine.answerQuestion(
                isCorrect: true, isMixed: false, question: _makeQuestion());
          }
          engine.completeLevelUp();
        }
      }
    });

    // ── Victory ──────────────────────────────────────────────────

    test('Victory after completing all 100 hands', () {
      // Play through all 5 levels × 20 hands
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 20; hand++) {
          engine.answerQuestion(
              isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) {
          engine.completeLevelUp();
        }
      }

      final state = container.read(leagueEngineProvider);
      expect(state.isVictory, true);
      expect(state.isGameOver, true);
      expect(state.phase, LeaguePhase.victory);
    });

    test('Time chips preserved through level ups', () {
      // Use 1 chip in level 1
      engine.useTimeChip();
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);

      // Play through level 1
      for (var i = 0; i < 20; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      engine.completeLevelUp();

      // Chips should still be 2 in level 2
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);
    });

    // ── Reset ────────────────────────────────────────────────────

    test('startGame resets to initial state', () {
      // Change state
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.useTimeChip();

      engine.startGame();

      final state = container.read(leagueEngineProvider);
      expect(state.currentLevel, 1);
      expect(state.score, 0);
      expect(state.strikesRemaining, 1);
      expect(state.timeChipsRemaining, 3);
      expect(state.combo, 0);
      expect(state.phase, LeaguePhase.playing);
    });

    test('startGame resets after game over', () {
      // Die
      engine.answerQuestion(
          isCorrect: false, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).isGameOver, true);

      engine.startGame();

      final state = container.read(leagueEngineProvider);
      expect(state.isGameOver, false);
      expect(state.strikesRemaining, 1);
      expect(state.timeChipsRemaining, 3);
      expect(state.phase, LeaguePhase.playing);
    });

    // ── Hand Counter ─────────────────────────────────────────────

    test('Hand counters increment correctly', () {
      engine.answerQuestion(
          isCorrect: true, isMixed: false, question: _makeQuestion());

      final state = container.read(leagueEngineProvider);
      expect(state.handInLevel, 2);
      expect(state.totalHands, 2);
    });
  });
}
