import 'package:holdem_allin_fold/data/models/mail_item.dart';

class MailFixtures {
  static List<MailItem> sampleMails() {
    final now = DateTime.now();
    return [
      // 1. system, unread, claimed reward (chips=500, claimed_at set, expires in 7 days)
      MailItem(
        id: 'mail-uuid-001',
        userId: 'test-user-uuid',
        type: MailType.system,
        title: '시스템 점검 보상',
        body: '서버 점검으로 인한 불편을 드려 죄송합니다. 보상 칩을 지급해 드립니다.',
        rewardChips: 500,
        isRead: false,
        claimedAt: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 7)),
      ),
      // 2. event, unread, unclaimed reward (chips=1000, energy=3, expires in 2 days)
      MailItem(
        id: 'mail-uuid-002',
        userId: 'test-user-uuid',
        type: MailType.event,
        title: '주말 이벤트 보상',
        body: '주말 이벤트 참여 감사합니다! 특별 보상을 드립니다.',
        rewardChips: 1000,
        rewardEnergy: 3,
        isRead: false,
        claimedAt: null,
        createdAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.add(const Duration(days: 2)),
      ),
      // 3. compensation, unread, unclaimed reward (chips=2000, expires in 1 hour — urgent!)
      MailItem(
        id: 'mail-uuid-003',
        userId: 'test-user-uuid',
        type: MailType.compensation,
        title: '서버 불안정 보상',
        body: '서버 불안정으로 인해 게임이 비정상 종료된 것에 대한 보상입니다.',
        rewardChips: 2000,
        isRead: false,
        claimedAt: null,
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.add(const Duration(hours: 1)),
      ),
      // 4. announcement, read, no reward (no expiry)
      MailItem(
        id: 'mail-uuid-004',
        userId: 'test-user-uuid',
        type: MailType.announcement,
        title: '업데이트 안내',
        body: '버전 2.0 업데이트가 적용되었습니다. 새로운 기능을 확인해보세요.',
        rewardChips: null,
        rewardEnergy: null,
        isRead: true,
        claimedAt: null,
        createdAt: now.subtract(const Duration(days: 5)),
        expiresAt: null,
      ),
      // 5. event, unread, unclaimed reward (chips=300, expires in 3 days)
      MailItem(
        id: 'mail-uuid-005',
        userId: 'test-user-uuid',
        type: MailType.event,
        title: '첫 접속 보너스',
        body: '오늘 첫 접속을 축하합니다! 보상 칩을 받으세요.',
        rewardChips: 300,
        isRead: false,
        claimedAt: null,
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(days: 3)),
      ),
      // 6. system, read, no reward (no expiry)
      MailItem(
        id: 'mail-uuid-006',
        userId: 'test-user-uuid',
        type: MailType.system,
        title: '공지사항',
        body: '리그 시즌이 시작되었습니다. 최고 순위에 도전해보세요!',
        rewardChips: null,
        rewardEnergy: null,
        isRead: true,
        claimedAt: null,
        createdAt: now.subtract(const Duration(days: 10)),
        expiresAt: null,
      ),
      // 7. compensation, read, claimed reward (chips=800, claimed)
      MailItem(
        id: 'mail-uuid-007',
        userId: 'test-user-uuid',
        type: MailType.compensation,
        title: '랭킹 집계 오류 보상',
        body: '랭킹 집계 오류로 인한 보상을 지급합니다.',
        rewardChips: 800,
        isRead: true,
        claimedAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 4)),
        expiresAt: now.add(const Duration(days: 10)),
      ),
      // 8. event, unread, unclaimed reward (energy=5, expires in 5 days)
      MailItem(
        id: 'mail-uuid-008',
        userId: 'test-user-uuid',
        type: MailType.event,
        title: '에너지 충전 이벤트',
        body: '이벤트 기간 동안 에너지를 지급합니다. 게임을 즐기세요!',
        rewardChips: null,
        rewardEnergy: 5,
        isRead: false,
        claimedAt: null,
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 5)),
      ),
    ];
  }

  static Map<String, dynamic> sampleMailJson() {
    final now = DateTime.now();
    return {
      'id': 'test-uuid-001',
      'user_id': 'test-user-uuid',
      'type': 'event',
      'title': '테스트 보상',
      'body': '테스트 메일입니다.',
      'reward_chips': 500,
      'reward_energy': null,
      'is_read': false,
      'claimed_at': null,
      'created_at': now.toIso8601String(),
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
    };
  }
}
