import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/league_player.dart';
import '../models/tier.dart';
import 'supabase_service.dart';

// ---------------------------------------------------------------------------
// Ghost Name Pool (Korean poker nicknames for filling under-20 groups)
// ---------------------------------------------------------------------------

const _ghostNicknames = [
  '올인맨', '폴드왕', '블러퍼', '콜링머신', '리버래트',
  '샤크킹', '피쉬사냥꾼', '팟컨트롤러', '넛츠헌터', '밸류벳왕',
  '체크레이즈', '쓰리벳러', '포벳마스터', '프리플랍신', '턴벳왕',
  '리버킬러', '스택빌더', '칩리더', 'ICM머신', '버블보이',
  '파이널이스트', '딜러킬러', '바운티헌터', '레이트렉', '얼리렉',
  'GTO초보', '착한피쉬', '동키브레인', '펍레전드', '그라인더맨',
];

// ---------------------------------------------------------------------------
// League Service — Supabase JIT Matching
// ---------------------------------------------------------------------------

/// 듀오링고 스타일 주간 리그 시스템.
/// 
/// ## 핵심 흐름:
/// 1. 유저가 게임 완료 → [joinOrCreateLeague] 호출 → 20명 그룹 배정
/// 2. 점수 갱신 → [updateScore] 호출 → 최고 점수만 유지
/// 3. 랭킹 탭 → [fetchLeagueRanking] 호출 → 20명 순위표
/// 4. 20명 미달 → 클라이언트에서 고스트 보충 표시
class LeagueService {
  static const int leagueSize = 20;
  static const int promotionCount = 5; // 상위 5명 승급
  static const int demotionCount = 5;  // 하위 5명 강등
  
  final Random _random;
  final Uuid _uuid;
  
  LeagueService({Random? random})
      : _random = random ?? Random(),
        _uuid = const Uuid();

  // -------------------------------------------------------------------------
  // Week Number (ISO 8601)
  // -------------------------------------------------------------------------

  /// ISO 8601 기준 주차 계산 (예: 202607 = 2026년 7주차)
  int getWeekNumber() {
    final now = DateTime.now();
    // ISO 8601: 1월 4일이 포함된 주가 1주차
    final jan4 = DateTime(now.year, 1, 4);
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final weekday = now.weekday; // 1=Mon, 7=Sun
    final weekNumber = ((dayOfYear - weekday + 10) / 7).floor();
    
    // 연도 보정 (12월 말/1월 초 경계)
    int year = now.year;
    if (weekNumber < 1) {
      year--;
      return year * 100 + 52;
    } else if (weekNumber > 52) {
      // 실제 53주인지 확인
      final dec31 = DateTime(year, 12, 31);
      if (dec31.weekday < 4) {
        return (year + 1) * 100 + 1;
      }
    }
    return year * 100 + weekNumber;
  }

  // -------------------------------------------------------------------------
  // JIT Matching — 리그 배정
  // -------------------------------------------------------------------------

  /// 게임 완료 시 호출. 같은 티어 20명 그룹에 자동 배정.
  /// 이미 배정된 경우 기존 그룹 ID 반환.
  /// 
  /// Returns: group_id (UUID string) or null if not logged in
  Future<String?> joinOrCreateLeague(int score) async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[LeagueService] 비로그인 — 리그 배정 건너뜀');
      return null;
    }

    try {
      final userId = SupabaseService.currentUser!.id;
      final tier = Tier.fromScore(score);
      final weekNumber = getWeekNumber();

      final result = await SupabaseService.client.rpc(
        'join_or_create_league',
        params: {
          'u_id': userId,
          'u_tier': tier.name,
          'u_week': weekNumber,
        },
      );

      final groupId = result as String?;
      debugPrint('[LeagueService] 리그 배정 완료: group=$groupId, tier=${tier.name}, week=$weekNumber');
      return groupId;
    } catch (e) {
      debugPrint('[LeagueService] 리그 배정 실패: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Score Update
  // -------------------------------------------------------------------------

  /// 게임 완료 후 점수 갱신. 기존 점수보다 높을 때만 업데이트됨 (서버-사이드 GREATEST).
  Future<void> updateScore(int score) async {
    if (!SupabaseService.isLoggedIn) return;

    try {
      final userId = SupabaseService.currentUser!.id;
      await SupabaseService.client.rpc(
        'update_league_score',
        params: {
          'u_id': userId,
          'new_score': score,
        },
      );
      debugPrint('[LeagueService] 점수 업데이트 완료: $score');
    } catch (e) {
      debugPrint('[LeagueService] 점수 업데이트 실패: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Ranking Fetch
  // -------------------------------------------------------------------------

  /// 현재 주차에 배정된 그룹 ID 조회.
  Future<String?> getCurrentGroupId() async {
    if (!SupabaseService.isLoggedIn) return null;

    try {
      final userId = SupabaseService.currentUser!.id;
      final weekNumber = getWeekNumber();

      final response = await SupabaseService.client
          .from('league_members')
          .select('group_id, league_groups!inner(week_number)')
          .eq('user_id', userId)
          .eq('league_groups.week_number', weekNumber)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return response['group_id'] as String?;
    } catch (e) {
      debugPrint('[LeagueService] 그룹 ID 조회 실패: $e');
      return null;
    }
  }

  /// 그룹의 멤버 20명 + 프로필 JOIN 조회. score 내림차순 정렬.
  /// 20명 미달 시 고스트로 보충.
  Future<List<LeaguePlayer>> fetchLeagueRanking(String groupId) async {
    try {
      final response = await SupabaseService.client
          .from('league_members')
          .select('user_id, score, updated_at, profiles!inner(username, avatar_url, tier)')
          .eq('group_id', groupId)
          .order('score', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final myId = SupabaseService.currentUser?.id;
      final players = <LeaguePlayer>[];
      final usedNames = <String>{};

      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        final userId = row['user_id'] as String;
        final profile = row['profiles'] as Map<String, dynamic>?;
        final nickname = profile?['username'] as String? ?? '플레이어${i + 1}';
        final score = row['score'] as int? ?? 0;
        final tierName = profile?['tier'] as String? ?? 'fish';

        usedNames.add(nickname);
        players.add(LeaguePlayer(
          id: userId,
          nickname: nickname,
          score: score,
          tier: Tier.fromName(tierName),
          rank: i + 1,
          isGhost: false,
        ));
      }

      // 20명 미달 시 빈 슬롯 보충 ("매칭 중..." 상태)
      if (players.length < leagueSize) {
        // 기존 고스트 대신 빈 슬롯으로 채움
        _fillWithEmptySlots(players, groupId);
      }

      // 최종 순위 다시 매기기
      // 전략: 빈 슬롯을 상위(1~N위)에 배치하되, UI에서는 "매칭 중"으로 표시.
      // 실제 유저는 하위(N+1~20위)에 배치되어 강등권 위기감을 조성.
      players.sort((a, b) {
        if (a.isEmptySlot && !b.isEmptySlot) return -1; // 빈 슬롯이 위
        if (!a.isEmptySlot && b.isEmptySlot) return 1;  // 실제 유저가 아래
        return b.score.compareTo(a.score); // 점수 내림차순
      });

      final ranked = <LeaguePlayer>[];
      for (var i = 0; i < players.length; i++) {
        ranked.add(players[i].copyWith(rank: i + 1));
      }

      debugPrint('[LeagueService] 랭킹 로드 완료: ${ranked.length}명 (실제: ${data.length}, 빈슬롯: ${ranked.length - data.length})');
      return ranked;
    } catch (e) {
      debugPrint('[LeagueService] 랭킹 조회 실패: $e');
      return [];
    }
  }

  /// 리그 미배정 상태에서도 로컬 고스트 리그 생성 (비로그인/첫 게임 전)
  Future<List<LeaguePlayer>> generateLocalLeague(int playerScore) async {
    final players = <LeaguePlayer>[];
    String myNickname = '나';
    if (SupabaseService.isLoggedIn) {
      try {
        final userId = SupabaseService.currentUser!.id;
        final profile = await SupabaseService.client
            .from('profiles')
            .select('username')
            .eq('id', userId)
            .maybeSingle();
        myNickname = profile?['username'] as String? ?? SupabaseService.displayName ?? '나';
      } catch (_) {}
    }
    
    players.add(LeaguePlayer(
      id: SupabaseService.currentUser?.id ?? 'local',
      nickname: myNickname,
      score: playerScore,
      tier: Tier.fromScore(playerScore),
      rank: 0,
      isGhost: false,
    ));

    // 로컬 리그도 동일하게 빈 슬롯으로 채움 (20년차 개발자의 일관성)
    _fillWithEmptySlots(players, 'local');

    players.sort((a, b) {
      if (a.isEmptySlot && !b.isEmptySlot) return -1;
      if (!a.isEmptySlot && b.isEmptySlot) return 1;
      return b.score.compareTo(a.score);
    });
    
    final ranked = <LeaguePlayer>[];
    for (var i = 0; i < players.length; i++) {
      ranked.add(players[i].copyWith(rank: i + 1));
    }
    return ranked;
  }

  // -------------------------------------------------------------------------
  // Empty Slot Generation (Private)
  // -------------------------------------------------------------------------

  void _fillWithEmptySlots(List<LeaguePlayer> players, String groupId) {
    final ghostsNeeded = leagueSize - players.length;
    // 빈 슬롯은 현재 리그 티어를 따라가야 자연스러움. 
    // 유저가 하나라도 있으면 그 유저 티어, 없으면 Fish.
    final baseTier = players.isNotEmpty ? players.first.tier : Tier.fish;

    for (var i = 0; i < ghostsNeeded; i++) {
      players.add(LeaguePlayer(
        id: 'empty_$i',
        nickname: '매칭 중...', // UI에서 처리하겠지만 기본값 설정
        score: 0,
        tier: baseTier,
        rank: 0,
        isGhost: false,
        isEmptySlot: true,
      ));
    }
  }

  // -------------------------------------------------------------------------
  // Helper: 승급/강등 판정
  // -------------------------------------------------------------------------

  /// 1~5위: 승급, 16~20위: 강등
  static String? getZoneLabel(int rank) {
    if (rank <= promotionCount) return '승급';
    if (rank > leagueSize - demotionCount) return '강등';
    return null;
  }

  static bool isPromotion(int rank) => rank <= promotionCount;
  static bool isDemotion(int rank) => rank > leagueSize - demotionCount;
}
