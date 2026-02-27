import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/mail_item.dart';
import '../data/services/mail_service.dart';

// ---------------------------------------------------------------------------
// Mailbox State
// ---------------------------------------------------------------------------

/// 우편함 상태 — 메일 목록 + 로딩/에러 플래그.
class MailboxState {
  final List<MailItem> mails;
  final bool isLoading;
  final String? error;

  const MailboxState({
    this.mails = const [],
    this.isLoading = false,
    this.error,
  });

  MailboxState copyWith({
    List<MailItem>? mails,
    bool? isLoading,
    String? error,
  }) {
    return MailboxState(
      mails: mails ?? this.mails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailboxState &&
          runtimeType == other.runtimeType &&
          listEquals(mails, other.mails) &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hashAll([...mails, isLoading, error]);
}

// ---------------------------------------------------------------------------
// Mailbox Notifier
// ---------------------------------------------------------------------------

/// 우편함 비즈니스 로직 — 조회, 읽음 처리, 보상 수령.
class MailboxNotifier extends StateNotifier<MailboxState> {
  final _service = MailService();

  MailboxNotifier() : super(const MailboxState()) {
    fetchMail();
  }

  // ── Computed getters ────────────────────────────────────────────────────

  /// 읽지 않은 (만료 제외) 메일 수.
  int get unreadCount =>
      state.mails.where((m) => !m.isRead && !m.isExpired).length;

  /// 보상 미수령 (만료 제외) 메일 수.
  int get unclaimedCount =>
      state.mails.where((m) => m.hasReward && !m.isClaimed && !m.isExpired).length;

  // ── Actions ─────────────────────────────────────────────────────────────

  /// 강제 로딩 해제 (안전장치).
  void forceStopLoading() {
    state = state.copyWith(isLoading: false);
  }

  /// 우편함 전체 조회.
  Future<void> fetchMail() async {
    debugPrint('[MailboxNotifier:fetchMail] 시작 — isLoading: true 설정');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final mails = await _service.fetchMail();
      debugPrint('[MailboxNotifier:fetchMail] 완료 — ${mails.length}건, isLoading: false 설정');
      state = state.copyWith(mails: mails, isLoading: false);
    } catch (e) {
      debugPrint('[MailboxNotifier:fetchMail] 에러 발생: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 백그라운드 새로고침 (로딩 스피너 없이 조용히 갱신).
  Future<void> refreshMail() async {
    try {
      final mails = await _service.fetchMail();
      state = state.copyWith(mails: mails, isLoading: false);
    } catch (e) {
      debugPrint('[MailboxNotifier:refreshMail] 에러: $e');
    }
  }

  /// 단건 보상 수령. 성공 시 true.
  Future<bool> claimReward(String mailId) async {
    final updated = await _service.claimReward(mailId);
    if (updated != null) {
      final newMails =
          state.mails.map((m) => m.id == mailId ? updated : m).toList();
      state = state.copyWith(mails: newMails);
      return true;
    }
    return false;
  }

  /// 일괄 보상 수령. 성공 시 수령 건수·총 칩·총 에너지 반환.
  Future<({int count, int totalChips, int totalEnergy})?> claimAllRewards() async {
    final result = await _service.claimAllRewards();
    if (result != null) {
      await fetchMail();
    }
    return result;
  }

  /// 단건 읽음 처리.
  Future<void> markAsRead(String mailId) async {
    await _service.markAsRead(mailId);
    final newMails =
        state.mails.map((m) => m.id == mailId ? m.copyWith(isRead: true) : m).toList();
    state = state.copyWith(mails: newMails);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// 우편함 글로벌 프로바이더.
final mailboxProvider =
    StateNotifierProvider<MailboxNotifier, MailboxState>((ref) {
  return MailboxNotifier();
});
