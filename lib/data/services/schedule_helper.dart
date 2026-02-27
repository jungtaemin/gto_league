/// Game mode types for the weekly schedule.
enum GameModeType {
  /// 15BB classic league (일, 월, 화 — Sun, Mon, Tue).
  classic,

  /// 30BB deep stack mode (수, 목, 금, 토 — Wed, Thu, Fri, Sat).
  deepStack,
}

// ── Game Mode Schedule ────────────────────────────────────────

/// Weekly game mode schedule based on KST (Korea Standard Time).
///
/// - 일(Sun), 월(Mon), 화(Tue) → 15BB Classic League
/// - 수(Wed), 목(Thu), 금(Fri), 토(Sat) → 30BB Deep Stack
///
/// All time calculations use UTC+9 (KST) regardless of device timezone.
class GameModeSchedule {
  /// KST offset from UTC.
  static const Duration _kstOffset = Duration(hours: 9);

  /// Deep stack weekdays (Dart: 1=Mon, 2=Tue, ..., 7=Sun).
  /// Wed=3, Thu=4, Fri=5, Sat=6.
  static const Set<int> _deepStackWeekdays = {3, 4, 5, 6};

  /// Classic weekdays: Sun=7, Mon=1, Tue=2.
  static const Set<int> _classicWeekdays = {7, 1, 2};

  /// Current date/time in KST.
  DateTime get nowKst => DateTime.now().toUtc().add(_kstOffset);

  /// Today's weekday in KST (1=Mon, 2=Tue, ..., 7=Sun).
  int get todayWeekday => nowKst.weekday;

  /// The current active game mode based on KST weekday.
  GameModeType get currentMode {
    return isDeepStackDay ? GameModeType.deepStack : GameModeType.classic;
  }

  /// Whether today is a deep stack day (수, 목, 금, 토).
  bool get isDeepStackDay => _deepStackWeekdays.contains(todayWeekday);

  /// Whether today is a classic league day (일, 월, 화).
  bool get isClassicDay => _classicWeekdays.contains(todayWeekday);

  /// Get the [GameModeType] for a specific weekday.
  ///
  /// [weekday] uses Dart convention: 1=Mon, 2=Tue, ..., 7=Sun.
  GameModeType modeForWeekday(int weekday) {
    return _deepStackWeekdays.contains(weekday)
        ? GameModeType.deepStack
        : GameModeType.classic;
  }

  /// Full week schedule as a list of (weekday, mode) pairs.
  ///
  /// Ordered Mon(1) → Sun(7) following Dart's [DateTime.weekday] convention.
  List<({int weekday, GameModeType mode})> get weekSchedule {
    return [
      for (int day = 1; day <= 7; day++)
        (weekday: day, mode: modeForWeekday(day)),
    ];
  }

  /// Korean single-character label for a weekday.
  ///
  /// [weekday] uses Dart convention: 1=Mon, 2=Tue, ..., 7=Sun.
  static String weekdayLabelKr(int weekday) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return labels[(weekday - 1).clamp(0, 6)];
  }
}
