// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// League 50-Hand Survival game loop engine.
///
/// Fork of [DeepRunEngine] with:
/// - 1 life (instant death on wrong answer)
/// - 3 time chips at start (+15s each, manual activation)
/// - Same 5 levels × 10 hands structure
/// - Same scoring system
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

@ProviderFor(LeagueEngine)
final leagueEngineProvider = LeagueEngineProvider._();

/// League 50-Hand Survival game loop engine.
///
/// Fork of [DeepRunEngine] with:
/// - 1 life (instant death on wrong answer)
/// - 3 time chips at start (+15s each, manual activation)
/// - Same 5 levels × 10 hands structure
/// - Same scoring system
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
final class LeagueEngineProvider
    extends $NotifierProvider<LeagueEngine, LeagueState> {
  /// League 50-Hand Survival game loop engine.
  ///
  /// Fork of [DeepRunEngine] with:
  /// - 1 life (instant death on wrong answer)
  /// - 3 time chips at start (+15s each, manual activation)
  /// - Same 5 levels × 10 hands structure
  /// - Same scoring system
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
  LeagueEngineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'leagueEngineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$leagueEngineHash();

  @$internal
  @override
  LeagueEngine create() => LeagueEngine();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeagueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeagueState>(value),
    );
  }
}

String _$leagueEngineHash() => r'95daeff708fea57b4d881f991c1b1a42d2f711e6';

/// League 50-Hand Survival game loop engine.
///
/// Fork of [DeepRunEngine] with:
/// - 1 life (instant death on wrong answer)
/// - 3 time chips at start (+15s each, manual activation)
/// - Same 5 levels × 10 hands structure
/// - Same scoring system
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

abstract class _$LeagueEngine extends $Notifier<LeagueState> {
  LeagueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LeagueState, LeagueState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LeagueState, LeagueState>, LeagueState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
