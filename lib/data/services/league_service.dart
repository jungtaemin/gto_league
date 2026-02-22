import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/league_player.dart';
import '../models/tier.dart';
import 'supabase_service.dart';
import 'season_helper.dart';

// ---------------------------------------------------------------------------
// League Service — Supabase JIT Matching
// ---------------------------------------------------------------------------

/// 스플릿 시즌 리그 시스템 (15인 그룹, 주 2회 시즌).
///
/// ## 핵심 흐름:
/// 1. 유저가 게임 완료 → [joinOrCreateLeague] 호출 → 15명 그룹 배정
/// 2. 점수 갱신 → [updateScore] 호출 → 최고 점수만 유지
/// 3. 랭킹 탭 → [fetchLeagueRanking] 호출 → 15명 순위표
/// 4. 15명 미달 → 클라이언트에서 페이스메이커 봇 보충 ($0 서버비)
class LeagueService {
  static const int leagueSize = 15;
  static const int promotionCount = 3; // 상위 3명 승급
  static const int demotionCount = 5;  // 하위 5명 강등

  static const List<String> _botNicknames = [
    '추격하는 동크 🤖', '올인봇 🤖', '콜링머신 🤖', '블러핑봇 🤖', '리버래트 🤖',
    '샤크봇 🤖', '그라인더봇 🤖', '넛츠헌터 🤖', '밸류봇 🤖', '체크레이즈봇 🤖',
    '포벳마스터 🤖', '프리플랍봇 🤖', '턴베터 🤖', '리버킬러 🤖', '스택빌더 🤖',
  ];

  LeagueService();

  // -------------------------------------------------------------------------
  // JIT Matching — 리그 배정
  // -------------------------------------------------------------------------

  /// 게임 완료 시 호출. 같은 티어 15명 그룹에 자동 배정.
  /// Returns: JoinLeagueResult or null if not logged in
  Future<JoinLeagueResult?> joinOrCreateLeague(int score) async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[LeagueService:joinOrCreateLeague] 비로그인 — 리그 배정 건너뜀');
      return null;
    }

    try {
      final now = DateTime.now();
      final userId = SupabaseService.currentUser!.id;
      final tier = Tier.fromScore(score);
      final seasonId = SeasonHelper.getSeasonId(now);

      final result = await SupabaseService.client.rpc(
        'join_or_create_league',
        params: {
          'u_id': userId,
          'u_tier': tier.name,
          'u_season_id': seasonId,
        },
      );

      final data = result as Map<String, dynamic>;
      final groupId = data['group_id'] as String;
      final isNew = data['is_new'] as bool? ?? false;
      debugPrint('[LeagueService:joinOrCreateLeague] 리그 배정 완료: group=$groupId, isNew=$isNew, tier=${tier.name}, season=$seasonId');
      return JoinLeagueResult(groupId: groupId, isNew: isNew);
    } catch (e) {
      debugPrint('[LeagueService:joinOrCreateLeague] 리그 배정 실패: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Score Update
  // -------------------------------------------------------------------------

  /// 게임 완료 후 점수 갱신. 기존 점수보다 높을 때만 업데이트됨 (서버-사이드 GREATEST).
  Future<bool> updateScore(int score) async {
    if (!SupabaseService.isLoggedIn) return false;

    try {
      final userId = SupabaseService.currentUser!.id;
      final seasonId = SeasonHelper.getSeasonId(DateTime.now());
      await SupabaseService.client.rpc(
        'update_league_score',
        params: {
          'u_id': userId,
          'new_score': score,
          'u_season_id': seasonId,
        },
      );
      debugPrint('[LeagueService:updateScore] 점수 업데이트 완료: $score');
      return true;
    } catch (e) {
      debugPrint('[LeagueService:updateScore] 점수 업데이트 실패: $e');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Season Settlement (Phase 4)
  // -------------------------------------------------------------------------

  /// 아직 읽지 않은 시즌 정산 결과가 있는지 확인
  /// 반환 포맷: { 'season_id': text, 'tier': text(현재티어), 'settle_result': 'promotion'/'retention'/'demotion', 'settle_reward': int }
  Future<Map<String, dynamic>?> checkUnreadSeasonResult() async {
    if (!SupabaseService.isLoggedIn) return null;
    try {
      final userId = SupabaseService.currentUser!.id;
      
      // 1. 유저의 프로필 조회 (마지막으로 확인한 시즌 ID 파악)
      final profileResponse = await SupabaseService.client
          .from('profiles')
          .select('last_seen_season_id, tier')
          .eq('id', userId)
          .maybeSingle();
          
      if (profileResponse == null) return null;
      final lastSeenId = profileResponse['last_seen_season_id'] as String?;
      final currentTierName = profileResponse['tier'] as String? ?? 'fish';

      // 2. 가장 최근에 정산 완료된 리그 그룹의 내 멤버 기록 조회
      final query = SupabaseService.client
          .from('league_members')
          .select('settle_result, settle_reward, league_groups!inner(season_id, is_settled, created_at)')
          .eq('user_id', userId)
          .eq('league_groups.is_settled', true);
          
      if (lastSeenId != null && lastSeenId.isNotEmpty) {
        query.neq('league_groups.season_id', lastSeenId);
      }
          
      final resultResponse = await query
          .order('created_at', referencedTable: 'league_groups', ascending: false)
          .limit(1)
          .maybeSingle();

      if (resultResponse != null && resultResponse['settle_result'] != null) {
        final group = resultResponse['league_groups'] as Map<String, dynamic>;
        return {
          'season_id': group['season_id'],
          'tier': currentTierName,
          'settle_result': resultResponse['settle_result'],
          'settle_reward': resultResponse['settle_reward'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      debugPrint('[LeagueService:checkUnreadSeasonResult] 에러: $e');
      return null;
    }
  }

  /// 시즌 정산 결과 팝업을 닫고 보상을 받았음을 DB에 기록 (last_seen_season_id 갱신)
  Future<void> markSeasonResultAsRead(String seasonId) async {
    if (!SupabaseService.isLoggedIn) return;
    try {
      final userId = SupabaseService.currentUser!.id;
      await SupabaseService.client
          .from('profiles')
          .update({'last_seen_season_id': seasonId})
          .eq('id', userId);
    } catch (e) {
      debugPrint('[LeagueService:markSeasonResultAsRead] 에러: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Ranking Fetch
  // -------------------------------------------------------------------------

  /// 현재 스플릿 시즌에 배정된 그룹 ID 조회.
  Future<String?> getCurrentGroupId() async {
    if (!SupabaseService.isLoggedIn) return null;

    try {
      final now = DateTime.now();
      final userId = SupabaseService.currentUser!.id;
      final seasonId = SeasonHelper.getSeasonId(now);

      final response = await SupabaseService.client
          .from('league_members')
          .select('group_id, league_groups!inner(season_id)')
          .eq('user_id', userId)
          .eq('league_groups.season_id', seasonId)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return response['group_id'] as String?;
    } catch (e) {
      debugPrint('[LeagueService:getCurrentGroupId] 그룹 ID 조회 실패: $e');
      return null;
    }
  }

  /// 그룹의 멤버 15명 + 프로필 JOIN 조회. score 내림차순 정렬.
  /// 15명 미달 시 페이스메이커 봇으로 보충.
  Future<List<LeaguePlayer>> fetchLeagueRanking(String groupId) async {
    try {
      final now = DateTime.now();
      final response = await SupabaseService.client
          .from('league_members')
          .select('user_id, score, profiles!inner(username, tier)')
          .eq('group_id', groupId)
          .order('score', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final players = <LeaguePlayer>[];

      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        final userId = row['user_id'] as String;
        final profile = row['profiles'] as Map<String, dynamic>?;
        final nickname = profile?['username'] as String? ?? '플레이어${i + 1}';
        final score = row['score'] as int? ?? 0;
        final tierName = profile?['tier'] as String? ?? 'fish';

        players.add(LeaguePlayer(
          id: userId,
          nickname: nickname,
          score: score,
          tier: Tier.fromName(tierName),
          rank: i + 1,
          type: PlayerType.real,
        ));
      }

       // 15명 미달 시 페이스메이커 봇으로 보충
      if (players.length < leagueSize) {
        final baseTier = players.isNotEmpty ? players.first.tier : Tier.fromScore(0);
        _fillWithPacemakerBots(players, groupId, baseTier, now);
      }

      // 순수 점수 내림차순 정렬
      players.sort((a, b) => b.score.compareTo(a.score));

      final ranked = <LeaguePlayer>[];
      for (var i = 0; i < players.length; i++) {
        ranked.add(players[i].copyWith(rank: i + 1));
      }

      final realCount = players.where((p) => p.isReal).length;
      debugPrint('[LeagueService:fetchLeagueRanking] 랭킹 로드 완료: ${ranked.length}명 (실제: $realCount, 봇: ${ranked.length - realCount})');
      return ranked;
    } catch (e) {
      debugPrint('[LeagueService:fetchLeagueRanking] 랭킹 조회 실패: $e');
      return [];
    }
  }

  /// 리그 미배정 상태에서도 로컬 리그 생성 (비로그인/첫 게임 전)
  Future<List<LeaguePlayer>> generateLocalLeague(int playerScore) async {
    final now = DateTime.now();
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
      type: PlayerType.real,
    ));

    // 페이스메이커 봇으로 15명 채우기
    final leagueTier = Tier.fromScore(playerScore);
    _fillWithPacemakerBots(players, 'local', leagueTier, now);

    // 순수 점수 내림차순 정렬
    players.sort((a, b) => b.score.compareTo(a.score));

    final ranked = <LeaguePlayer>[];
    for (var i = 0; i < players.length; i++) {
      ranked.add(players[i].copyWith(rank: i + 1));
    }
    return ranked;
  }

  // -------------------------------------------------------------------------
  // Pacemaker Bot Generation (Private)
  // -------------------------------------------------------------------------

  void _fillWithPacemakerBots(
    List<LeaguePlayer> players,
    String groupId,
    Tier leagueTier,
    DateTime now,
  ) {
    final botsNeeded = leagueSize - players.length;
    final seasonId = SeasonHelper.getSeasonId(now);
    final elapsedRatio = SeasonHelper.getElapsedRatio(now);

    for (var botIndex = 0; botIndex < botsNeeded; botIndex++) {
      final seed = (groupId.hashCode ^ seasonId.hashCode ^ botIndex).abs();
      final seededRandom = Random(seed);
      
      // 봇의 최종 목표 성장치 (해당 티어 전체 구간의 일정 비율)
      final botMultiplier = 0.3 + (seededRandom.nextDouble() * 0.7); // 30% ~ 100% 성장 목표
      final maxGainedScore = (leagueTier.maxScore - leagueTier.minScore) * botMultiplier;
      
      // 현재 시간에 비례한 성장치
      final currentGainedScore = (elapsedRatio * maxGainedScore).round();

      // 기본 점수(minScore) + 시간 비례 획득 점수 + 소소한 역전 변수(random)
      final currentScore = leagueTier.minScore + currentGainedScore + seededRandom.nextInt(50);
      final cappedScore = min(currentScore, leagueTier.maxScore);

      players.add(LeaguePlayer(
        id: 'bot_$botIndex',
        nickname: _botNicknames[botIndex % _botNicknames.length],
        score: cappedScore,
        tier: leagueTier,
        rank: 0,
        type: PlayerType.pacemakerBot,
      ));
    }
  }

  // -------------------------------------------------------------------------
  // Helper: 승급/강등 판정
  // -------------------------------------------------------------------------

  /// 1~3위: 승급, 11~15위: 강등
  static String? getZoneLabel(int rank) {
    if (rank <= promotionCount) return '승급';
    if (rank > leagueSize - demotionCount) return '강등';
    return null;
  }

  static bool isPromotion(int rank) => rank <= promotionCount;
  static bool isDemotion(int rank) => rank > leagueSize - demotionCount;
}
