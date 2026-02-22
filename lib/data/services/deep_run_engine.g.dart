// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_run_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 100-Hand Deep Run Survival game loop engine.
///
/// Manages 5 levels × 20 hands, 3-strike system, scoring,
/// and level transitions. Consumed by Deep Run Screen.
///
/// ## Scoring
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Cap: 100 points max per answer
/// - Mixed strategy: ALWAYS counts as correct
///
/// ## Level → BB Mapping
/// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
/// Level 4 = 7BB, Level 5 = 5BB

@ProviderFor(DeepRunEngine)
final deepRunEngineProvider = DeepRunEngineProvider._();

/// 100-Hand Deep Run Survival game loop engine.
///
/// Manages 5 levels × 20 hands, 3-strike system, scoring,
/// and level transitions. Consumed by Deep Run Screen.
///
/// ## Scoring
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Cap: 100 points max per answer
/// - Mixed strategy: ALWAYS counts as correct
///
/// ## Level → BB Mapping
/// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
/// Level 4 = 7BB, Level 5 = 5BB
final class DeepRunEngineProvider
    extends $NotifierProvider<DeepRunEngine, DeepRunState> {
  /// 100-Hand Deep Run Survival game loop engine.
  ///
  /// Manages 5 levels × 20 hands, 3-strike system, scoring,
  /// and level transitions. Consumed by Deep Run Screen.
  ///
  /// ## Scoring
  /// - Base: 10 points per correct answer
  /// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
  /// - Cap: 100 points max per answer
  /// - Mixed strategy: ALWAYS counts as correct
  ///
  /// ## Level → BB Mapping
  /// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
  /// Level 4 = 7BB, Level 5 = 5BB
  DeepRunEngineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deepRunEngineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deepRunEngineHash();

  @$internal
  @override
  DeepRunEngine create() => DeepRunEngine();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepRunState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepRunState>(value),
    );
  }
}

String _$deepRunEngineHash() => r'479c48b9f64dabfc90e663c70105053b1cc05708';

/// 100-Hand Deep Run Survival game loop engine.
///
/// Manages 5 levels × 20 hands, 3-strike system, scoring,
/// and level transitions. Consumed by Deep Run Screen.
///
/// ## Scoring
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Cap: 100 points max per answer
/// - Mixed strategy: ALWAYS counts as correct
///
/// ## Level → BB Mapping
/// Level 1 = 15BB, Level 2 = 12BB, Level 3 = 10BB,
/// Level 4 = 7BB, Level 5 = 5BB

abstract class _$DeepRunEngine extends $Notifier<DeepRunState> {
  DeepRunState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DeepRunState, DeepRunState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DeepRunState, DeepRunState>,
        DeepRunState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
