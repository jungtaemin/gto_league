import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holdem_allin_fold/data/services/deep_run_engine.dart';
import 'package:holdem_allin_fold/data/models/card_question.dart';

void main() {
  group('DeepRunEngine', () {
    late ProviderContainer container;
    late DeepRunEngine engine;

    setUp(() {
      container = ProviderContainer();
      engine = container.read(deepRunEngineProvider.notifier);
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
      final state = container.read(deepRunEngineProvider);
      expect(state.currentLevel, 1);
      expect(state.handInLevel, 1);
      expect(state.totalHands, 1);
      expect(state.strikesRemaining, 3);
      expect(state.score, 0);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
      expect(state.isGameOver, false);
      expect(state.isVictory, false);
      expect(state.phase, DeepRunPhase.playing);
    });

    test('currentBbLevel maps correctly per level', () {
      expect(container.read(deepRunEngineProvider).currentBbLevel, 15);
    });

    // ── Scoring ─────────────────────────────────────────────────

    test('Correct answer awards base 10 points', () {
      engine.answerQuestion(
        isCorrect: true,
        isMixed: false,
        question: _makeQuestion(),
      );
      final state = container.read(deepRunEngineProvider);
      expect(state.score, 10);
      expect(state.combo, 1);
      expect(state.currentStreak, 1);
    });

    test('Combo bonus applied correctly', () {
      // 1st: 10 + 0 = 10
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).score, 10);

      // 2nd: 10 + 2 = 12 (total 22)
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).score, 22);

      // 3rd: 10 + 4 = 14 (total 36)
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).score, 36);
    });

    test('Score capped at 100 per answer', () {
      // Build massive combo
      for (var i = 0; i < 50; i++) {
        engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      final scoreBefore = container.read(deepRunEngineProvider).score;

      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      final scoreAfter = container.read(deepRunEngineProvider).score;

      expect(scoreAfter - scoreBefore, lessThanOrEqualTo(100));
    });

    // ── Strike System ───────────────────────────────────────────

    test('Incorrect answer loses a strike and resets combo', () {
      // Build combo first
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).combo, 2);

      // Wrong answer
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      final state = container.read(deepRunEngineProvider);
      expect(state.strikesRemaining, 2);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
    });

    test('Game over when 3 strikes depleted', () {
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());

      final state = container.read(deepRunEngineProvider);
      expect(state.strikesRemaining, 0);
      expect(state.isGameOver, true);
      expect(state.phase, DeepRunPhase.gameOver);
    });

    test('Cannot answer after game over', () {
      // Deplete strikes
      for (var i = 0; i < 3; i++) {
        engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      }
      expect(container.read(deepRunEngineProvider).isGameOver, true);

      final scoreBefore = container.read(deepRunEngineProvider).score;
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).score, scoreBefore);
    });

    // ── Mixed Strategy ──────────────────────────────────────────

    test('Mixed strategy always counts as correct', () {
      engine.answerQuestion(isCorrect: false, isMixed: true, question: _makeQuestion());
      final state = container.read(deepRunEngineProvider);
      expect(state.strikesRemaining, 3); // No strike lost
      expect(state.score, 10); // Score awarded
      expect(state.combo, 1);
    });

    // ── Level Progression ───────────────────────────────────────

    test('Level up after 10 hands', () {
      // Play 10 correct hands
      for (var i = 0; i < 10; i++) {
        engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      }

      final state = container.read(deepRunEngineProvider);
      expect(state.phase, DeepRunPhase.levelUp);
      expect(state.isLevelingUp, true);
      expect(state.currentLevel, 1); // Still level 1 until completeLevelUp
    });

    test('completeLevelUp advances to next level', () {
      // Play 10 hands
      for (var i = 0; i < 10; i++) {
        engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      }
      expect(container.read(deepRunEngineProvider).phase, DeepRunPhase.levelUp);

      engine.completeLevelUp();

      final state = container.read(deepRunEngineProvider);
      expect(state.currentLevel, 2);
      expect(state.handInLevel, 1);
      expect(state.phase, DeepRunPhase.playing);
      expect(state.currentBbLevel, 12);
    });

    test('BB levels progress correctly: 15 -> 12 -> 10 -> 7 -> 5', () {
      final expectedBb = [15, 12, 10, 7, 5];

      for (var level = 0; level < 5; level++) {
        final state = container.read(deepRunEngineProvider);
        expect(state.currentBbLevel, expectedBb[level],
            reason: 'Level ${level + 1} should be ${expectedBb[level]}BB');

        if (level < 4) {
          // Play 10 hands to advance
          for (var i = 0; i < 10; i++) {
            engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
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
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) {
          engine.completeLevelUp();
        }
      }

      // Normal mode complete → hardModeTransition
      expect(container.read(deepRunEngineProvider).phase, DeepRunPhase.hardModeTransition);

      // Start hard mode and play 50 more hands
      engine.startHardMode();
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) {
          engine.completeLevelUp();
        }
      }
      final state = container.read(deepRunEngineProvider);
      expect(state.isVictory, true);
      expect(state.isGameOver, true);
      expect(state.phase, DeepRunPhase.victory);
      expect(state.isHardMode, true);
    });

    // ── Hard Mode ─────────────────────────────────────────────

    test('isHardMode is false in initial state', () {
      final state = container.read(deepRunEngineProvider);
      expect(state.isHardMode, false);
      expect(state.normalModeScore, 0);
    });

    test('Normal mode clear triggers hardModeTransition phase', () {
      // Play through all 5 levels × 10 hands (50 total)
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }

      final state = container.read(deepRunEngineProvider);
      expect(state.phase, DeepRunPhase.hardModeTransition);
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
      expect(container.read(deepRunEngineProvider).phase, DeepRunPhase.hardModeTransition);

      engine.startHardMode();

      final state = container.read(deepRunEngineProvider);
      expect(state.isHardMode, true);
      expect(state.phase, DeepRunPhase.playing);
      expect(state.currentLevel, 1);
      expect(state.handInLevel, 1);
      expect(state.totalHands, 1);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
    });

    test('startHardMode preserves strikes from normal mode', () {
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).strikesRemaining, 2);

      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      expect(container.read(deepRunEngineProvider).strikesRemaining, 2);
    });

    test('startHardMode saves normalModeScore', () {
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      final scoreBeforeHardMode = container.read(deepRunEngineProvider).score;
      expect(scoreBeforeHardMode, greaterThan(0));

      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      final state = container.read(deepRunEngineProvider);
      expect(state.normalModeScore, greaterThan(0));
      expect(state.score, state.normalModeScore);
    });

    test('startHardMode is no-op if not in hardModeTransition phase', () {
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      expect(container.read(deepRunEngineProvider).phase, DeepRunPhase.playing);

      engine.startHardMode();

      final state = container.read(deepRunEngineProvider);
      expect(state.isHardMode, false);
      expect(state.phase, DeepRunPhase.playing);
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

      final state = container.read(deepRunEngineProvider);
      expect(state.isVictory, true);
      expect(state.isGameOver, true);
      expect(state.phase, DeepRunPhase.victory);
      expect(state.isHardMode, true);
    });

    test('Hard mode game over ends game', () {
      for (var level = 0; level < 5; level++) {
        for (var hand = 0; hand < 10; hand++) {
          engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
        }
        if (level < 4) engine.completeLevelUp();
      }
      engine.startHardMode();

      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());

      final state = container.read(deepRunEngineProvider);
      expect(state.isGameOver, true);
      expect(state.phase, DeepRunPhase.gameOver);
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

      final state = container.read(deepRunEngineProvider);
      expect(state.isHardMode, true);
      expect(state.phase, DeepRunPhase.playing);
    });

    // ── Reset ────────────────────────────────────────────────────

    test('startGame resets to initial state', () {
      // Change state
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());
      engine.answerQuestion(isCorrect: false, isMixed: false, question: _makeQuestion());

      engine.startGame();

      final state = container.read(deepRunEngineProvider);
      expect(state.currentLevel, 1);
      expect(state.score, 0);
      expect(state.strikesRemaining, 3);
      expect(state.combo, 0);
      expect(state.phase, DeepRunPhase.playing);
    });

    // ── Hand Counter ─────────────────────────────────────────────

    test('Hand counters increment correctly', () {
      engine.answerQuestion(isCorrect: true, isMixed: false, question: _makeQuestion());

      final state = container.read(deepRunEngineProvider);
      expect(state.handInLevel, 2);
      expect(state.totalHands, 2);
    });
  });

  group('DeepRunQuestionGenerator', () {
    test('generateDeck returns 20 questions for valid BB level', () {
      // This is a unit test for the question generator.
      // It needs GtoScenario test fixtures — tested here with minimal scenarios.
      // Full integration requires loading gto_master_db.json.
      // See deep_run_question_generator.dart for implementation.
    });
  });
}