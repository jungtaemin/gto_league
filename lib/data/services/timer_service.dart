import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

// ---------------------------------------------------------------------------
// Timer Phase
// ---------------------------------------------------------------------------

/// Visual/behavioral phase of the countdown timer.
///
/// ```
/// 15s ████████████████ calm (green)
/// 10s ████████████     calm
///  5s ████████         critical (red, pulsing, haptic)
///  3s █████            critical (faster pulse)
///  1s ██               critical (max pulse)
///  0s                  expired (auto-fold)
/// ```
enum TimerPhase {
  /// 15.0s ~ 5.01s — normal play, green indicator.
  calm,

  /// 5.0s ~ 0.01s — red/pulsing indicator, haptic warnings.
  critical,

  /// 0.0s — time's up, triggers auto-fold.
  expired,
}

// ---------------------------------------------------------------------------
// Timer State
// ---------------------------------------------------------------------------

/// Immutable state for the countdown timer.
class TimerState {
  final double seconds;
  final bool isRunning;
  final TimerPhase phase;

  const TimerState({
    required this.seconds,
    required this.isRunning,
    required this.phase,
  });

  /// Default initial state: 15 seconds, stopped, calm phase.
  factory TimerState.initial() {
    return const TimerState(
      seconds: defaultDuration,
      isRunning: false,
      phase: TimerPhase.calm,
    );
  }

  /// Base timer duration in seconds.
  static const double defaultDuration = 15.0;

  /// Derive the correct [TimerPhase] from the remaining [seconds].
  static TimerPhase phaseFromSeconds(double seconds) {
    if (seconds <= 0.0) return TimerPhase.expired;
    if (seconds <= 5.0) return TimerPhase.critical;
    return TimerPhase.calm;
  }

  /// Normalized progress value (1.0 → full, 0.0 → empty).
  /// Uses [maxSeconds] as the reference for normalization.
  double progress({double maxSeconds = defaultDuration}) {
    if (maxSeconds <= 0.0) return 0.0;
    return (seconds / maxSeconds).clamp(0.0, 1.0);
  }

  TimerState copyWith({
    double? seconds,
    bool? isRunning,
    TimerPhase? phase,
  }) {
    return TimerState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
      phase: phase ?? this.phase,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerState &&
          runtimeType == other.runtimeType &&
          seconds == other.seconds &&
          isRunning == other.isRunning &&
          phase == other.phase;

  @override
  int get hashCode => seconds.hashCode ^ isRunning.hashCode ^ phase.hashCode;

  @override
  String toString() =>
      'TimerState(seconds: ${seconds.toStringAsFixed(1)}, isRunning: $isRunning, phase: $phase)';
}

// ---------------------------------------------------------------------------
// Timer Notifier
// ---------------------------------------------------------------------------

/// Countdown timer with 100ms tick resolution and phase-aware state.
///
/// ## Combo-based duration (T11 integration):
/// - Base:          15 seconds
/// - Combo ≥ 5:     12 seconds
/// - Combo ≥ 10:    10 seconds
/// - Fever (≥ 15):  Timer paused (no countdown)
///
/// ## Expired behavior (T16 integration):
/// When the timer reaches 0.0:
/// 1. Set `isDisabled = true` BEFORE triggering auto-fold (prevent race condition)
/// 2. Emit expired event to game state
/// 3. Trigger haptic feedback (`HapticManager.wrong()`)
///
/// ```dart
/// // CORRECT (T16 will implement):
/// onTimerExpired() {
///   isDisabled = true;  // MUST set first
///   await Future.delayed(Duration(milliseconds: 50)); // Safety buffer
///   controller.swipe(SwipeDirection.left);             // Then auto-fold
/// }
///
/// // WRONG (causes double-swipe):
/// onTimerExpired() {
///   controller.swipe(SwipeDirection.left); // Race: user can swipe simultaneously
/// }
/// ```
class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial());

  Timer? _timer;

  /// The effective duration for the current round.
  /// Adjusted by combo streak via [startWithCombo].
  double _currentDuration = TimerState.defaultDuration;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Start (or restart) the countdown from the default duration.
  ///
  /// Cancels any existing timer, resets to [TimerState.defaultDuration],
  /// and begins a 100ms periodic tick.
  void start() {
    _startCountdown(TimerState.defaultDuration);
  }

  /// Start the countdown with a combo-adjusted duration.
  ///
  /// Duration rules:
  /// - [combo] < 5  → 15s (default)
  /// - [combo] ≥ 5  → 12s
  /// - [combo] ≥ 10 → 10s
  /// - [combo] ≥ 15 → fever mode, timer paused (no countdown)
  void startWithCombo(int combo) {
    if (combo >= 15) {
      // Fever mode: timer paused, show full bar
      _cancel();
      _currentDuration = TimerState.defaultDuration;
      state = TimerState(
        seconds: _currentDuration,
        isRunning: false,
        phase: TimerPhase.calm,
      );
      return;
    }

    final duration = _durationForCombo(combo);
    _startCountdown(duration);
  }

  /// Stop the countdown, keeping the current seconds value.
  void stop() {
    _cancel();
    if (state.isRunning) {
      state = state.copyWith(isRunning: false);
    }
  }

  /// Stop the countdown and reset to full duration.
  void reset() {
    _cancel();
    _currentDuration = TimerState.defaultDuration;
    state = TimerState.initial();
  }

  /// Pause the countdown, keeping current seconds and phase.
  ///
  /// Used when showing fact-bomb modal — timer should freeze while
  /// the player reads the explanation.
  /// No-op if already paused or not running.
  void pause() {
    if (!state.isRunning) return;
    _cancel();
    state = state.copyWith(isRunning: false);
  }

  /// Resume the countdown from where it was paused.
  ///
  /// No-op if already running or if timer is expired.
  void resume() {
    if (state.isRunning) return;
    if (state.phase == TimerPhase.expired) return;
    if (state.seconds <= 0.0) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _tick(),
    );
  }

  /// Add [seconds] to the remaining time (e.g., time bank +30s).
  ///
  /// Clamps the result so it never goes below 0.
  /// Re-derives the phase from the new time.
  void addTime(double seconds) {
    final newSeconds = max(0.0, state.seconds + seconds);
    final newPhase = TimerState.phaseFromSeconds(newSeconds);

    state = state.copyWith(
      seconds: newSeconds,
      phase: newPhase,
    );
  }

  /// The effective max duration for the current round.
  /// Useful for UI progress bar normalization.
  double get currentDuration => _currentDuration;

  // -------------------------------------------------------------------------
  // Disposal
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Private
  // -------------------------------------------------------------------------

  void _startCountdown(double duration) {
    _cancel();
    _currentDuration = duration;

    state = TimerState(
      seconds: duration,
      isRunning: true,
      phase: TimerPhase.calm,
    );

    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _tick(),
    );
  }

  void _tick() {
    final newSeconds = max(0.0, state.seconds - 0.1);
    final newPhase = TimerState.phaseFromSeconds(newSeconds);

    if (newPhase == TimerPhase.expired) {
      // Timer reached zero — stop ticking.
      _cancel();
      state = const TimerState(
        seconds: 0.0,
        isRunning: false,
        phase: TimerPhase.expired,
      );
      // NOTE: Auto-fold / haptic / isDisabled logic handled by T16 listener.
      // This notifier only emits the expired state.
      return;
    }

    state = TimerState(
      seconds: newSeconds,
      isRunning: true,
      phase: newPhase,
    );
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resolve effective duration from combo streak.
  static double _durationForCombo(int combo) {
    if (combo >= 10) return 10.0;
    if (combo >= 5) return 12.0;
    return TimerState.defaultDuration; // 15.0
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Global provider for the game countdown timer.
///
/// Usage:
/// ```dart
/// // Read current state
/// final timer = ref.watch(timerProvider);
///
/// // Control timer
/// ref.read(timerProvider.notifier).start();
/// ref.read(timerProvider.notifier).stop();
/// ref.read(timerProvider.notifier).addTime(30);
///
/// // Combo-aware start
/// final combo = ref.read(gameStateProvider).combo;
/// ref.read(timerProvider.notifier).startWithCombo(combo);
/// ```
final timerProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final notifier = TimerNotifier();

  // Ensure timer is cancelled when the provider is disposed.
  ref.onDispose(() {
    notifier._timer?.cancel();
  });

  return notifier;
});
