// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Game state management notifier.
///
/// Handles scoring logic, hearts system, combo tracking,
/// fever mode, and game-over detection.
///
/// ## Scoring Formula
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Snap bonus: 1.5× total (answered within 2 seconds)
/// - Fever mode: 2× final score (active for 5 seconds at 15 streak)
/// - Cap: 10× base maximum per answer

@ProviderFor(GameStateNotifier)
final gameStateProvider = GameStateNotifierProvider._();

/// Game state management notifier.
///
/// Handles scoring logic, hearts system, combo tracking,
/// fever mode, and game-over detection.
///
/// ## Scoring Formula
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Snap bonus: 1.5× total (answered within 2 seconds)
/// - Fever mode: 2× final score (active for 5 seconds at 15 streak)
/// - Cap: 10× base maximum per answer
final class GameStateNotifierProvider
    extends $NotifierProvider<GameStateNotifier, GameState> {
  /// Game state management notifier.
  ///
  /// Handles scoring logic, hearts system, combo tracking,
  /// fever mode, and game-over detection.
  ///
  /// ## Scoring Formula
  /// - Base: 10 points per correct answer
  /// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
  /// - Snap bonus: 1.5× total (answered within 2 seconds)
  /// - Fever mode: 2× final score (active for 5 seconds at 15 streak)
  /// - Cap: 10× base maximum per answer
  GameStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gameStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gameStateNotifierHash();

  @$internal
  @override
  GameStateNotifier create() => GameStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameState>(value),
    );
  }
}

String _$gameStateNotifierHash() => r'6992bb90e4cc48d14d69559ca116f38d96401d7d';

/// Game state management notifier.
///
/// Handles scoring logic, hearts system, combo tracking,
/// fever mode, and game-over detection.
///
/// ## Scoring Formula
/// - Base: 10 points per correct answer
/// - Combo bonus: `combo × 2` (1st=0, 2nd=2, 3rd=4, …)
/// - Snap bonus: 1.5× total (answered within 2 seconds)
/// - Fever mode: 2× final score (active for 5 seconds at 15 streak)
/// - Cap: 10× base maximum per answer

abstract class _$GameStateNotifier extends $Notifier<GameState> {
  GameState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GameState, GameState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<GameState, GameState>, GameState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
