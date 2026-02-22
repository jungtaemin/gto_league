// ---------------------------------------------------------------------------
// Season Helper — Split Season Calculation Utility
// ---------------------------------------------------------------------------

/// 스플릿 시즌 계산 유틸리티
///
/// Split Season 체제:
/// - Season A: 월요일(1) ~ 목요일(4) — 4일 시즌
/// - Season B: 금요일(5) ~ 일요일(7) — 3일 시즌
///
/// seasonId 포맷: "YYYY-WXX-A" 또는 "YYYY-WXX-B"
/// 예: "2026-W08-A", "2026-W09-B"
abstract class SeasonHelper {
  /// 현재 시간 기준 seasonId 반환
  /// 월~목 → "YYYY-WXX-A", 금~일 → "YYYY-WXX-B"
  static String getSeasonId(DateTime now) {
    final weekNumber = _getIsoWeekNumber(now);
    final seasonType = _getSeasonType(now);
    return '${now.year}-W${weekNumber.toString().padLeft(2, '0')}-$seasonType';
  }

  /// 이번 시즌 종료 시각
  /// Season A → 이번 주 목요일 23:59:59
  /// Season B → 이번 주 일요일 23:59:59
  static DateTime getSeasonEndTime(DateTime now) {
    final seasonType = _getSeasonType(now);
    
    if (seasonType == 'A') {
      // Season A ends on Thursday (weekday=4) at 23:59:59
      final daysToThursday = 4 - now.weekday;
      final thursday = DateTime(now.year, now.month, now.day + daysToThursday, 23, 59, 59);
      return thursday;
    } else {
      // Season B ends on Sunday (weekday=7) at 23:59:59
      final daysToSunday = 7 - now.weekday;
      final sunday = DateTime(now.year, now.month, now.day + daysToSunday, 23, 59, 59);
      return sunday;
    }
  }

  /// 이번 시즌 시작 시각
  /// Season A → 이번 주 월요일 00:00:00
  /// Season B → 이번 주 금요일 00:00:00
  static DateTime getSeasonStartTime(DateTime now) {
    final seasonType = _getSeasonType(now);
    
    if (seasonType == 'A') {
      // Season A starts on Monday (weekday=1) at 00:00:00
      final daysToMonday = now.weekday - 1;
      final monday = DateTime(now.year, now.month, now.day - daysToMonday);
      return monday;
    } else {
      // Season B starts on Friday (weekday=5) at 00:00:00
      final daysToFriday = now.weekday - 5;
      final friday = DateTime(now.year, now.month, now.day - daysToFriday);
      return friday;
    }
  }

  /// 이번 시즌 총 Duration
  /// A: 4일, B: 3일
  static Duration getSeasonDuration(DateTime now) {
    final start = getSeasonStartTime(now);
    final end = getSeasonEndTime(now);
    return end.difference(start);
  }

  /// 시즌 경과 비율 (0.0~1.0)
  /// 페이스메이커 봇 점수 계산에 사용
  static double getElapsedRatio(DateTime now) {
    final start = getSeasonStartTime(now);
    final end = getSeasonEndTime(now);
    final total = end.difference(start).inMilliseconds.toDouble();
    final elapsed = now.difference(start).inMilliseconds.toDouble();
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// 시즌 종료까지 남은 Duration
  /// 피버 타임 판단 (< 12시간)
  static Duration getRemainingDuration(DateTime now) {
    final end = getSeasonEndTime(now);
    return end.difference(now);
  }

  // -------------------------------------------------------------------------
  // Private Helpers
  // -------------------------------------------------------------------------

  /// ISO 8601 주차 계산 (1~53)
  /// 1월 4일이 포함된 주가 1주차
  static int _getIsoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekday = date.weekday; // 1=Mon, 7=Sun
    final weekNumber = ((dayOfYear - weekday + 10) / 7).floor();
    
    // 연도 보정 (12월 말/1월 초 경계)
    if (weekNumber < 1) {
      // 이전 연도의 마지막 주
      final prevYear = date.year - 1;
      final dec31 = DateTime(prevYear, 12, 31);
      final prevYearDayOfYear = dec31.difference(DateTime(prevYear, 1, 1)).inDays;
      final prevYearWeekday = dec31.weekday;
      return ((prevYearDayOfYear - prevYearWeekday + 10) / 7).floor();
    } else if (weekNumber > 52) {
      // 실제 53주인지 확인
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < 4) {
        // 다음 연도의 1주차
        return 1;
      }
    }
    return weekNumber;
  }

  /// 시즌 타입 판단 (A 또는 B)
  /// Season A: 월~목 (weekday 1~4)
  /// Season B: 금~일 (weekday 5~7)
  static String _getSeasonType(DateTime now) {
    if (now.weekday >= 1 && now.weekday <= 4) {
      return 'A';
    } else {
      return 'B';
    }
  }
}
