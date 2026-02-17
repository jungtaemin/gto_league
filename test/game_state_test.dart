import 'package:flutter_test/flutter_test.dart';
import 'package:holdem_allin_fold/data/models/swipe_result.dart';
import 'package:holdem_allin_fold/providers/game_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('GameStateNotifier', () {
    late ProviderContainer container;
    late GameStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(gameStateNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is correct', () {
      final state = container.read(gameStateNotifierProvider);
      expect(state.score, 0);
      expect(state.hearts, 5);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
      expect(state.isFeverMode, false);
      expect(state.timeBankCount, 3);
      expect(notifier.isGameOver, false);
    });

    test('Correct answer increases score and combo', () {
      final result = SwipeResult(
        isCorrect: true,
        isSnap: false,
        pointsEarned: 0,
        evDiff: 0.5,
        factBombMessage: '',
      );

      notifier.processAnswer(result);
      final state = container.read(gameStateNotifierProvider);

      expect(state.score, 10); // Base 10
      expect(state.combo, 1);
      expect(state.currentStreak, 1);
      expect(state.hearts, 5); // Unchanged
    });

    test('Combo bonus applied correctly', () {
      // First answer: base 10
      notifier.processAnswer(_correctResult());
      expect(container.read(gameStateNotifierProvider).score, 10);

      // Second answer: base 10 + combo 2 = 12
      notifier.processAnswer(_correctResult());
      expect(container.read(gameStateNotifierProvider).score, 22);

      // Third answer: base 10 + combo 4 = 14
      notifier.processAnswer(_correctResult());
      expect(container.read(gameStateNotifierProvider).score, 36);
    });

    test('Snap bonus applies 1.5x multiplier', () {
      final snapResult = SwipeResult(
        isCorrect: true,
        isSnap: true,
        pointsEarned: 0,
        evDiff: 0.5,
        factBombMessage: '',
      );

      notifier.processAnswer(snapResult);
      final state = container.read(gameStateNotifierProvider);

      expect(state.score, 15); // 10 * 1.5 = 15
    });

    test('Incorrect answer decreases hearts and resets combo', () {
      // Build up combo first
      notifier.processAnswer(_correctResult());
      notifier.processAnswer(_correctResult());
      expect(container.read(gameStateNotifierProvider).combo, 2);

      // Then get wrong answer
      final wrongResult = SwipeResult(
        isCorrect: false,
        isSnap: false,
        pointsEarned: 0,
        evDiff: -1.5,
        factBombMessage: 'Wrong!',
      );

      notifier.processAnswer(wrongResult);
      final state = container.read(gameStateNotifierProvider);

      expect(state.hearts, 4); // 5 - 1 = 4
      expect(state.combo, 0); // Reset
      expect(state.currentStreak, 0); // Reset
    });

    test('Fever mode activates at 15 streak', () {
      // Get 15 correct answers
      for (var i = 0; i < 15; i++) {
        notifier.processAnswer(_correctResult());
      }

      final state = container.read(gameStateNotifierProvider);
      expect(state.currentStreak, 15);
      expect(state.isFeverMode, true);
    });

    test('Game over when hearts reach 0', () {
      final wrongResult = SwipeResult(
        isCorrect: false,
        isSnap: false,
        pointsEarned: 0,
        evDiff: -1.0,
        factBombMessage: 'Wrong!',
      );

      // Lose all 5 hearts
      for (var i = 0; i < 5; i++) {
        notifier.processAnswer(wrongResult);
      }

      expect(notifier.isGameOver, true);
      expect(container.read(gameStateNotifierProvider).hearts, 0);
    });

    test('Cannot process answers when game is over', () {
      // Lose all hearts
      for (var i = 0; i < 5; i++) {
        notifier.processAnswer(_wrongResult());
      }

      final scoreBefore = container.read(gameStateNotifierProvider).score;

      // Try to process answer when game over
      notifier.processAnswer(_correctResult());

      final scoreAfter = container.read(gameStateNotifierProvider).score;
      expect(scoreAfter, scoreBefore); // No change
    });

    test('useTimeBank decrements count', () {
      final success1 = notifier.useTimeBank();
      expect(success1, true);
      expect(container.read(gameStateNotifierProvider).timeBankCount, 2);

      final success2 = notifier.useTimeBank();
      expect(success2, true);
      expect(container.read(gameStateNotifierProvider).timeBankCount, 1);
    });

    test('useTimeBank fails when count is 0', () {
      // Use all 3
      notifier.useTimeBank();
      notifier.useTimeBank();
      notifier.useTimeBank();

      final success = notifier.useTimeBank();
      expect(success, false);
      expect(container.read(gameStateNotifierProvider).timeBankCount, 0);
    });

    test('refillHearts restores to 5', () {
      // Lose hearts
      notifier.processAnswer(_wrongResult());
      notifier.processAnswer(_wrongResult());
      expect(container.read(gameStateNotifierProvider).hearts, 3);

      // Refill
      notifier.refillHearts();
      expect(container.read(gameStateNotifierProvider).hearts, 5);
    });

    test('refillTimeBank adds 3 charges', () {
      // Use all
      notifier.useTimeBank();
      notifier.useTimeBank();
      notifier.useTimeBank();
      expect(container.read(gameStateNotifierProvider).timeBankCount, 0);

      // Refill
      notifier.refillTimeBank();
      expect(container.read(gameStateNotifierProvider).timeBankCount, 3);
    });

    test('reset restores initial state', () {
      // Change state
      notifier.processAnswer(_correctResult());
      notifier.processAnswer(_wrongResult());
      notifier.useTimeBank();

      // Reset
      notifier.reset();

      final state = container.read(gameStateNotifierProvider);
      expect(state.score, 0);
      expect(state.hearts, 5);
      expect(state.combo, 0);
      expect(state.currentStreak, 0);
      expect(state.timeBankCount, 3);
      expect(state.isFeverMode, false);
    });

    test('Multiplier cap at 10x (100 points max per question)', () {
      // Build up massive combo
      for (var i = 0; i < 50; i++) {
        notifier.processAnswer(_correctResult());
      }

      final scoreBefore = container.read(gameStateNotifierProvider).score;

      // Next answer should cap at 100 points
      notifier.processAnswer(_correctResult());

      final scoreAfter = container.read(gameStateNotifierProvider).score;
      final pointsEarned = scoreAfter - scoreBefore;
      expect(pointsEarned, lessThanOrEqualTo(100));
    });
  });
}

SwipeResult _correctResult() {
  return const SwipeResult(
    isCorrect: true,
    isSnap: false,
    pointsEarned: 0,
    evDiff: 0.5,
    factBombMessage: '',
  );
}

SwipeResult _wrongResult() {
  return const SwipeResult(
    isCorrect: false,
    isSnap: false,
    pointsEarned: 0,
    evDiff: -1.0,
    factBombMessage: 'Wrong!',
  );
}
