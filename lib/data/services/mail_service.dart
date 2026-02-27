import 'package:flutter/foundation.dart';
import '../models/mail_item.dart';
import 'supabase_service.dart';

// ---------------------------------------------------------------------------
// Mail Service — 우편함 데이터 액세스
// ---------------------------------------------------------------------------

/// 유저 우편함(user_mail) CRUD + RPC 보상 수령.
///
/// ## 핵심 흐름:
/// 1. 우편함 탭 → [fetchMail] → 만료되지 않은 메일 목록
/// 2. 안 읽은 메일 뱃지 → [getUnreadCount] → 미확인 건수
/// 3. 보상 수령 → [claimReward] / [claimAllRewards] → RPC 호출
/// 4. 읽음 처리 → [markAsRead] → is_read = true
/// 5. 삭제 → [deleteMail] → 단건 삭제
class MailService {
  MailService();

  // -------------------------------------------------------------------------
  // Fetch — 우편함 목록 조회
  // -------------------------------------------------------------------------

  /// 만료되지 않은 메일 전체 조회, created_at DESC 정렬.
  Future<List<MailItem>> fetchMail() async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:fetchMail] 비로그인 — 건너뜀');
      return [];
    }

    try {
      final userId = SupabaseService.currentUser!.id;
      debugPrint('[MailService:fetchMail] 쿼리 시작 userId=$userId');

      final response = await SupabaseService.client
          .from('user_mail')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      debugPrint('[MailService:fetchMail] 응답 수신: ${(response as List).length}건');

      final List<dynamic> data = response as List<dynamic>;
      final items = data
          .map((row) => MailItem.fromJson(row as Map<String, dynamic>))
          .where((item) => !item.isExpired)
          .toList();

      debugPrint('[MailService:fetchMail] ${items.length}건 로드 완료');
      return items;
    } catch (e) {
      debugPrint('[MailService:fetchMail] 에러: $e');
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // Unread Count — 미확인 메일 건수
  // -------------------------------------------------------------------------

  /// 읽지 않았거나 보상 미수령 메일 건수.
  Future<int> getUnreadCount() async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:getUnreadCount] 비로그인 — 건너뜀');
      return 0;
    }

    try {
      final userId = SupabaseService.currentUser!.id;

      final response = await SupabaseService.client
          .from('user_mail')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);

      final List<dynamic> data = response as List<dynamic>;
      final count = data
          .map((row) => MailItem.fromJson(row as Map<String, dynamic>))
          .where((item) => !item.isExpired)
          .length;

      debugPrint('[MailService:getUnreadCount] 미확인 $count건');
      return count;
    } catch (e) {
      debugPrint('[MailService:getUnreadCount] 에러: $e');
      return 0;
    }
  }

  // -------------------------------------------------------------------------
  // Claim Reward — 단건 보상 수령
  // -------------------------------------------------------------------------

  /// 단건 보상 수령. RPC 우선, 실패 시 직접 UPDATE fallback.
  /// 성공 시 갱신된 MailItem, 실패/이미 수령 시 null.
  Future<MailItem?> claimReward(String mailId) async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:claimReward] 비로그인 — 건너뜀');
      return null;
    }

    // 1차: RPC 호출 시도 (atomic)
    try {
      final result = await SupabaseService.client.rpc(
        'claim_mail_reward',
        params: {'p_mail_id': mailId},
      );

      if (result is Map<String, dynamic> && result['success'] == true) {
        final item = await _fetchSingleMail(mailId);
        if (item != null) {
          debugPrint('[MailService:claimReward] RPC 수령 완료: $mailId');
          return item;
        }
      }
      debugPrint('[MailService:claimReward] RPC 반환값 확인: $result');
    } catch (e) {
      debugPrint('[MailService:claimReward] RPC 실패, fallback 시도: $e');
    }

    // 2차: 직접 UPDATE fallback (RPC 함수가 DB에 없거나 에러 시)
    return _claimRewardFallback(mailId);
  }

  /// RPC 없이 직접 UPDATE로 보상 수령 + profiles 비용 지급.
  Future<MailItem?> _claimRewardFallback(String mailId) async {
    try {
      final userId = SupabaseService.currentUser!.id;
      final now = DateTime.now().toUtc().toIso8601String();

      // 메일 수령 처리
      await SupabaseService.client
          .from('user_mail')
          .update({'claimed_at': now})
          .eq('id', mailId)
          .eq('user_id', userId)
          .isFilter('claimed_at', null);

      final item = await _fetchSingleMail(mailId);
      if (item != null && item.isClaimed) {
        // profiles 테이블에 보상 지급
        await _applyRewardToProfiles(
          userId,
          item.rewardChips ?? 0,
          item.rewardEnergy ?? 0,
        );
        debugPrint('[MailService:claimReward] fallback 수령 완료: $mailId');
        return item;
      }

      debugPrint('[MailService:claimReward] fallback 실패 (이미 수령됨 또는 없음): $mailId');
      return null;
    } catch (e) {
      debugPrint('[MailService:claimReward] fallback 에러: $e');
      return null;
    }
  }

  /// profiles 테이블에 칩/에너지 보상 지급.
  Future<void> _applyRewardToProfiles(
    String userId,
    int chips,
    int energy,
  ) async {
    if (chips <= 0 && energy <= 0) return;

    try {
      // 현재 값 조회
      final current = await SupabaseService.client
          .from('profiles')
          .select('chips, energy')
          .eq('id', userId)
          .single();

      final currentChips = (current['chips'] as int?) ?? 0;
      final currentEnergy = (current['energy'] as int?) ?? 0;

      final updates = <String, dynamic>{};
      if (chips > 0) updates['chips'] = currentChips + chips;
      if (energy > 0) updates['energy'] = currentEnergy + energy;

      if (updates.isNotEmpty) {
        await SupabaseService.client
            .from('profiles')
            .update(updates)
            .eq('id', userId);
        debugPrint('[MailService] profiles 보상 지급: chips+$chips, energy+$energy');
      }
    } catch (e) {
      debugPrint('[MailService:_applyRewardToProfiles] 에러: $e');
    }
  }

  /// 단건 메일 조회 헬퍼.
  Future<MailItem?> _fetchSingleMail(String mailId) async {
    try {
      final mailResponse = await SupabaseService.client
          .from('user_mail')
          .select()
          .eq('id', mailId)
          .single();
      return MailItem.fromJson(mailResponse);
    } catch (e) {
      debugPrint('[MailService:_fetchSingleMail] 에러: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Claim All Rewards — 일괄 보상 수령
  // -------------------------------------------------------------------------

  /// 미수령 보상 일괄 수령. RPC 우선, 실패 시 직접 UPDATE fallback.
  Future<({int count, int totalChips, int totalEnergy})?> claimAllRewards() async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:claimAllRewards] 비로그인 — 건너뜀');
      return null;
    }

    final userId = SupabaseService.currentUser!.id;

    // 1차: RPC 호출 시도
    try {
      final result = await SupabaseService.client.rpc(
        'claim_all_mail_rewards',
        params: {'p_user_id': userId},
      );

      if (result is Map<String, dynamic> && result['success'] == true) {
        final record = (
          count: (result['claim_count'] as int?) ?? 0,
          totalChips: (result['total_chips'] as int?) ?? 0,
          totalEnergy: (result['total_energy'] as int?) ?? 0,
        );
        debugPrint(
          '[MailService:claimAllRewards] RPC 일괄 수령: '
          '${record.count}건, 칩 ${record.totalChips}, 에너지 ${record.totalEnergy}',
        );
        return record;
      }
    } catch (e) {
      debugPrint('[MailService:claimAllRewards] RPC 실패, fallback 시도: $e');
    }

    // 2차: 직접 UPDATE fallback
    return _claimAllRewardsFallback(userId);
  }

  /// RPC 없이 직접 UPDATE로 일괄 수령 + profiles 보상 지급.
  Future<({int count, int totalChips, int totalEnergy})?> _claimAllRewardsFallback(
    String userId,
  ) async {
    try {
      // 미수령 메일 목록 먼저 조회
      final unclaimedResponse = await SupabaseService.client
          .from('user_mail')
          .select()
          .eq('user_id', userId)
          .isFilter('claimed_at', null);

      final List<dynamic> unclaimed = unclaimedResponse as List<dynamic>;
      if (unclaimed.isEmpty) {
        debugPrint('[MailService:claimAllRewards] fallback: 수령 대상 없음');
        return null;
      }

      // 보상 합산
      int totalChips = 0;
      int totalEnergy = 0;
      for (final row in unclaimed) {
        final m = row as Map<String, dynamic>;
        totalChips += (m['reward_chips'] as int?) ?? 0;
        totalEnergy += (m['reward_energy'] as int?) ?? 0;
      }

      // 일괄 claimed_at 설정
      final now = DateTime.now().toUtc().toIso8601String();
      await SupabaseService.client
          .from('user_mail')
          .update({'claimed_at': now})
          .eq('user_id', userId)
          .isFilter('claimed_at', null);

      // profiles 테이블에 보상 지급
      await _applyRewardToProfiles(userId, totalChips, totalEnergy);

      final record = (
        count: unclaimed.length,
        totalChips: totalChips,
        totalEnergy: totalEnergy,
      );
      debugPrint(
        '[MailService:claimAllRewards] fallback 일괄 수령: '
        '${record.count}건, 칩 ${record.totalChips}, 에너지 ${record.totalEnergy}',
      );
      return record;
    } catch (e) {
      debugPrint('[MailService:claimAllRewards] fallback 에러: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Mark As Read — 읽음 처리
  // -------------------------------------------------------------------------

  /// 단건 메일 읽음 처리 (is_read = true).
  Future<void> markAsRead(String mailId) async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:markAsRead] 비로그인 — 건너뜀');
      return;
    }

    try {
      final userId = SupabaseService.currentUser!.id;

      await SupabaseService.client
          .from('user_mail')
          .update({'is_read': true})
          .eq('id', mailId)
          .eq('user_id', userId);

      debugPrint('[MailService:markAsRead] 읽음 처리 완료: $mailId');
    } catch (e) {
      debugPrint('[MailService:markAsRead] 에러: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Delete — 메일 삭제
  // -------------------------------------------------------------------------

  /// 단건 메일 삭제.
  Future<void> deleteMail(String mailId) async {
    if (!SupabaseService.isLoggedIn) {
      debugPrint('[MailService:deleteMail] 비로그인 — 건너뜀');
      return;
    }

    try {
      final userId = SupabaseService.currentUser!.id;

      await SupabaseService.client
          .from('user_mail')
          .delete()
          .eq('id', mailId)
          .eq('user_id', userId);

      debugPrint('[MailService:deleteMail] 삭제 완료: $mailId');
    } catch (e) {
      debugPrint('[MailService:deleteMail] 에러: $e');
    }
  }
}
