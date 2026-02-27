import 'dart:math' as math;

import '../models/deep_stack_scenario.dart';
import '../providers/deep_stack_data_provider.dart';

/// Utility for loading a balanced set of 30BB game scenarios.
class ScenarioLoader {
  /// Load a balanced list of [count] scenarios from [cache].
  ///
  /// Uses dynamic weight adjustment to ensure fold/action balance:
  /// - actionWeight baseline: 0.4
  /// - After fold scenario: actionWeight += 0.15 (max 0.9)
  /// - After action scenario: actionWeight resets to 0.4
  static List<DeepStackScenario> loadBalancedScenarios(
    DeepStackCache cache, {
    int count = 50,
    math.Random? random,
  }) {
    final rng = random ?? math.Random();
    final foldScenarios = List<DeepStackScenario>.from(cache.foldScenarios)
      ..shuffle(rng);
    final actionScenarios = List<DeepStackScenario>.from(cache.actionScenarios)
      ..shuffle(rng);

    final gameScenarios = <DeepStackScenario>[];
    double actionWeight = 0.4;

    int foldIndex = 0;
    int actionIndex = 0;

    // Build a balanced queue of scenarios
    for (int i = 0; i < count; i++) {
      bool pickAction = rng.nextDouble() < actionWeight;

      DeepStackScenario selected;
      // Resolve selection with fallbacks
      if (pickAction && actionIndex < actionScenarios.length) {
        selected = actionScenarios[actionIndex++];
      } else if (!pickAction && foldIndex < foldScenarios.length) {
        selected = foldScenarios[foldIndex++];
      } else if (foldIndex < foldScenarios.length) {
        selected = foldScenarios[foldIndex++];
      } else if (actionIndex < actionScenarios.length) {
        selected = actionScenarios[actionIndex++];
      } else {
        break; // Empty pools
      }

      gameScenarios.add(selected);

      // Dynamic weight adjustment for the *next* draw
      // If this one was a fold, increase the chance of pulling an action next
      if (selected.dominantAction == 'fold') {
        actionWeight = math.min(0.9, actionWeight + 0.15);
      } else {
        actionWeight = 0.4; // Reset to baseline
      }
    }

    return gameScenarios;
  }
}
