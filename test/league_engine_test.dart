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

    test('Level up after 10 hands', () {
      // Play 10 correct hands
      for (var i = 0; i < 10; i++) {
        engine.answerQuestion(
            isCorrect: true, isMixed: false, question: _makeQuestion());
      }

      final state = container.read(leagueEngineProvider);
      expect(state.phase, LeaguePhase.levelUp);
      expect(state.isLevelingUp, true);
      expect(state.currentLevel, 1); // Still level 1 until completeLevelUp
    });

    test('completeLevelUp advances to next level', () {
      // Play 10 hands
      for (var i = 0; i < 10; i++) {
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
          // Play 10 hands to advance
          for (var i = 0; i < 10; i++) {
            engine.answerQuestion(
                isCorrect: true, isMixed: false, question: _makeQuestion());
          }
          engine.completeLevelUp();
        }
      }
    });

    // ── Victory ──────────────────────────────────────────────────

    test('Victory after completing all 100 hands (normal + hard)', () {
      // Play through normal mode: 5 levels × 10 hands = 50
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(
              isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) {
          engine.completeLevelUp();
        }
      }

      // Normal mode complete → hardModeTransition
      expect(container.read(leagueEngineProvider).phase, LeaguePhase.hardModeTransition);

      // Start hard mode and play 50 more hands
      engine.startHardMode();
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
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
      expect(state.isHardMode, true);
    });

    // ── Hard Mode ─────────────────────────────────────────────

    test('isHardMode is false in initial state', () {
      final state = container.read(leagueEngineProvider);
      expect(state.isHardMode, false);
      expect(state.normalModeScore, 0);
    });

    test('Normal mode clear triggers hardModeTransition phase', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }

      final state = container.read(leagueEngineProvider);
      expect(state.phase, LeaguePhase.hardModeTransition);
      expect(state.isHardMode, false);
      expect(state.isGameOver, false);
      expect(state.isVictory, false);
    });

    test('startHardMode transitions to hard mode play', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      expect(container.read(leagueEngineProvider).phase, LeaguePhase.hardModeTransition);

      engine.startHardMode();

      final state = container.read(leagueEngineProvider);
      expect(state.isHardMode, true);
      expect(state.phase, LeaguePhase.playing);
      expect(state.currentLevel, 1);
      expect(state.handInLevel, 1);
      expect(state.totalHands, 1);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
    });

    test('startHardMode preserves time chips from normal mode', () {
      engine.useTimeChip();
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);

      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);
    });

    test('startHardMode saves normalModeScore', () {
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      final scoreBeforeHardMode = container.read(leagueEngineProvider).score;
      expect(scoreBeforeHardMode, greaterThan(0));

      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      final state = container.read(leagueEngineProvider);
      expect(state.normalModeScore, greaterThan(0));
      expect(state.score, state.normalModeScore);
    });

    test('startHardMode is no-op if not in hardModeTransition phase', () {
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(leagueEngineProvider).phase, LeaguePhase.playing);

      engine.startHardMode();

      final state = container.read(leagueEngineProvider);
      expect(state.isHardMode, false);
      expect(state.phase, LeaguePhase.playing);
    });

    test('Hard mode victory after completing all 50 hard hands', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }

      final state = container.read(leagueEngineProvider);
      expect(state.isVictory, true);
      expect(state.isGameOver, true);
      expect(state.phase, LeaguePhase.victory);
      expect(state.isHardMode, true);
    });

    test('Hard mode game over ends game (1-life rule)', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());

      final state = container.read(leagueEngineProvider);
      expect(state.isGameOver, true);
      expect(state.phase, LeaguePhase.gameOver);
      expect(state.isHardMode, true);
    });

    test('completeHardModeTransition is alias for startHardMode', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }

      engine.completeHardModeTransition();

      final state = container.read(leagueEngineProvider);
      expect(state.isHardMode, true);
      expect(state.phase, LeaguePhase.playing);
    });

    test('Time chips preserved through level ups', () {
      // Use 1 chip in level 1
      engine.useTimeChip();
      expect(container.read(leagueEngineProvider).timeChipsRemaining, 2);

      // Play through level 1
      for (var i = 0; i < 10; i++) {
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
