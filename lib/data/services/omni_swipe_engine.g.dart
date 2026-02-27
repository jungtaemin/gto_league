// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omni_swipe_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 30BB Omni-Swipe 4-direction game loop engine.
///
/// Single level (30BB), 50 hands, 3-strike system.
/// Uses [ActionGrade] from [action_evaluator.dart] for grading.
///
/// ## Scoring
/// - **PERFECT**: `base(10) + comboBonus(combo × 2)`, capped at 100.
///   Increments combo, streak, and perfectCount.
/// - **GOOD**: `goodScore(5) + comboBonus(combo × 1)`.
///   Combo MAINTAINED, streak incremented, goodCount incremented.
/// - **BLUNDER**: No points, strikesRemaining decremented, combo reset.
///   blunderCount incremented.
///
/// ## Game Over
/// - `strikesRemaining <= 0` → [OmniSwipePhase.gameOver]
/// - `currentHandIndex >= totalHands` → [OmniSwipePhase.victory]

@ProviderFor(OmniSwipeEngine)
final omniSwipeEngineProvider = OmniSwipeEngineProvider._();

/// 30BB Omni-Swipe 4-direction game loop engine.
///
/// Single level (30BB), 50 hands, 3-strike system.
/// Uses [ActionGrade] from [action_evaluator.dart] for grading.
///
/// ## Scoring
/// - **PERFECT**: `base(10) + comboBonus(combo × 2)`, capped at 100.
///   Increments combo, streak, and perfectCount.
/// - **GOOD**: `goodScore(5) + comboBonus(combo × 1)`.
///   Combo MAINTAINED, streak incremented, goodCount incremented.
/// - **BLUNDER**: No points, strikesRemaining decremented, combo reset.
///   blunderCount incremented.
///
/// ## Game Over
/// - `strikesRemaining <= 0` → [OmniSwipePhase.gameOver]
/// - `currentHandIndex >= totalHands` → [OmniSwipePhase.victory]
final class OmniSwipeEngineProvider
    extends $NotifierProvider<OmniSwipeEngine, OmniSwipeState> {
  /// 30BB Omni-Swipe 4-direction game loop engine.
  ///
  /// Single level (30BB), 50 hands, 3-strike system.
  /// Uses [ActionGrade] from [action_evaluator.dart] for grading.
  ///
  /// ## Scoring
  /// - **PERFECT**: `base(10) + comboBonus(combo × 2)`, capped at 100.
  ///   Increments combo, streak, and perfectCount.
  /// - **GOOD**: `goodScore(5) + comboBonus(combo × 1)`.
  ///   Combo MAINTAINED, streak incremented, goodCount incremented.
  /// - **BLUNDER**: No points, strikesRemaining decremented, combo reset.
  ///   blunderCount incremented.
  ///
  /// ## Game Over
  /// - `strikesRemaining <= 0` → [OmniSwipePhase.gameOver]
  /// - `currentHandIndex >= totalHands` → [OmniSwipePhase.victory]
  OmniSwipeEngineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'omniSwipeEngineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$omniSwipeEngineHash();

  @$internal
  @override
  OmniSwipeEngine create() => OmniSwipeEngine();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OmniSwipeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OmniSwipeState>(value),
    );
  }
}

String _$omniSwipeEngineHash() => r'29cfc6dc81dd5dffb2abec83084719427d064bae';

/// 30BB Omni-Swipe 4-direction game loop engine.
///
/// Single level (30BB), 50 hands, 3-strike system.
/// Uses [ActionGrade] from [action_evaluator.dart] for grading.
///
/// ## Scoring
/// - **PERFECT**: `base(10) + comboBonus(combo × 2)`, capped at 100.
///   Increments combo, streak, and perfectCount.
/// - **GOOD**: `goodScore(5) + comboBonus(combo × 1)`.
///   Combo MAINTAINED, streak incremented, goodCount incremented.
/// - **BLUNDER**: No points, strikesRemaining decremented, combo reset.
///   blunderCount incremented.
///
/// ## Game Over
/// - `strikesRemaining <= 0` → [OmniSwipePhase.gameOver]
/// - `currentHandIndex >= totalHands` → [OmniSwipePhase.victory]

abstract class _$OmniSwipeEngine extends $Notifier<OmniSwipeState> {
  OmniSwipeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OmniSwipeState, OmniSwipeState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OmniSwipeState, OmniSwipeState>,
        OmniSwipeState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
