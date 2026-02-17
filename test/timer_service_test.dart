import 'package:flutter_test/flutter_test.dart';
import 'package:holdem_allin_fold/data/services/timer_service.dart';

void main() {
  group('TimerState', () {
    test('Initial state is 15 seconds, not running, calm phase', () {
      final state = TimerState.initial();

      expect(state.seconds, 15.0);
      expect(state.isRunning, false);
      expect(state.phase, TimerPhase.calm);
    });

    test('Phase transitions correctly based on seconds', () {
      expect(TimerState.phaseFromSeconds(15.0), TimerPhase.calm);
      expect(TimerState.phaseFromSeconds(10.0), TimerPhase.calm);
      expect(TimerState.phaseFromSeconds(5.0), TimerPhase.critical);
      expect(TimerState.phaseFromSeconds(3.0), TimerPhase.critical);
      expect(TimerState.phaseFromSeconds(0.0), TimerPhase.expired);
      expect(TimerState.phaseFromSeconds(-0.1), TimerPhase.expired);
    });

    test('progress calculation is correct', () {
      const state1 = TimerState(
        seconds: 15.0,
        isRunning: true,
        phase: TimerPhase.calm,
      );
      expect(state1.progress(), 1.0);

      const state2 = TimerState(
        seconds: 7.5,
        isRunning: true,
        phase: TimerPhase.calm,
      );
      expect(state2.progress(), closeTo(0.5, 0.01));

      const state3 = TimerState(
        seconds: 0.0,
        isRunning: false,
        phase: TimerPhase.expired,
      );
      expect(state3.progress(), 0.0);
    });

    test('copyWith creates new instance with changes', () {
      final state = TimerState.initial();

      final modified = state.copyWith(
        seconds: 10.0,
        isRunning: true,
      );

      expect(modified.seconds, 10.0);
      expect(modified.isRunning, true);
      expect(modified.phase, state.phase); // Unchanged
    });

    test('equality and hashCode', () {
      const a = TimerState(
        seconds: 10.0,
        isRunning: true,
        phase: TimerPhase.calm,
      );
      const b = TimerState(
        seconds: 10.0,
        isRunning: true,
        phase: TimerPhase.calm,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes formatted fields', () {
      const state = TimerState(
        seconds: 12.3,
        isRunning: true,
        phase: TimerPhase.calm,
      );
      expect(state.toString(), contains('12.3'));
      expect(state.toString(), contains('true'));
    });
  });

  group('TimerNotifier', () {
    late TimerNotifier notifier;

    setUp(() {
      notifier = TimerNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state is correct', () {
      expect(notifier.state.seconds, 15.0);
      expect(notifier.state.isRunning, false);
      expect(notifier.state.phase, TimerPhase.calm);
      expect(notifier.currentDuration, 15.0);
    });

    test('start begins countdown', () {
      notifier.start();

      expect(notifier.state.isRunning, true);
      expect(notifier.state.seconds, 15.0);
      expect(notifier.state.phase, TimerPhase.calm);
    });

    test('stop preserves seconds and sets isRunning false', () {
      notifier.start();
      notifier.stop();

      expect(notifier.state.isRunning, false);
      expect(notifier.state.seconds, 15.0);
    });

    test('reset returns to initial state', () {
      notifier.start();
      notifier.addTime(-5.0); // Simulate time passing
      notifier.reset();

      expect(notifier.state.seconds, 15.0);
      expect(notifier.state.isRunning, false);
      expect(notifier.state.phase, TimerPhase.calm);
      expect(notifier.currentDuration, 15.0);
    });

    test('addTime increases seconds correctly', () {
      notifier.start();
      notifier.addTime(30.0);

      expect(notifier.state.seconds, 45.0);
    });

    test('addTime clamps at 0 (no negative)', () {
      notifier.start();
      notifier.addTime(-100.0);

      expect(notifier.state.seconds, 0.0);
      expect(notifier.state.phase, TimerPhase.expired);
    });

    test('startWithCombo adjusts duration for combo < 5', () {
      notifier.startWithCombo(0);

      expect(notifier.currentDuration, 15.0);
      expect(notifier.state.seconds, 15.0);
      expect(notifier.state.isRunning, true);
    });

    test('startWithCombo adjusts duration for combo >= 5', () {
      notifier.startWithCombo(5);

      expect(notifier.currentDuration, 12.0);
      expect(notifier.state.seconds, 12.0);
      expect(notifier.state.isRunning, true);
    });

    test('startWithCombo adjusts duration for combo >= 10', () {
      notifier.startWithCombo(10);

      expect(notifier.currentDuration, 10.0);
      expect(notifier.state.seconds, 10.0);
      expect(notifier.state.isRunning, true);
    });

    test('startWithCombo pauses timer in fever mode (combo >= 15)', () {
      notifier.startWithCombo(15);

      expect(notifier.currentDuration, 15.0);
      expect(notifier.state.isRunning, false); // Fever mode stops timer
      expect(notifier.state.phase, TimerPhase.calm);
    });

    test('pause freezes timer, resume continues', () {
      notifier.start();
      notifier.pause();

      expect(notifier.state.isRunning, false);
      final secondsAtPause = notifier.state.seconds;

      notifier.resume();
      expect(notifier.state.isRunning, true);
      expect(notifier.state.seconds, secondsAtPause);
    });

    test('resume is no-op when already running', () {
      notifier.start();
      notifier.resume(); // Should be no-op
      expect(notifier.state.isRunning, true);
    });

    test('resume is no-op when expired', () {
      // Force expired state
      notifier.start();
      notifier.addTime(-15.0); // Go to 0
      notifier.stop();

      notifier.resume(); // Should be no-op
      expect(notifier.state.isRunning, false);
    });
  });
}
