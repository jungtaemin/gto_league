import 'package:flutter_test/flutter_test.dart';
import 'package:holdem_allin_fold/data/models/mail_item.dart';
import 'fixtures/mail_fixtures.dart';

void main() {
  // =========================================================================
  // MailItem 모델 테스트
  // =========================================================================

  group('MailItem', () {
    test('fromJson — 정상 파싱', () {
      final json = MailFixtures.sampleMailJson();
      final mail = MailItem.fromJson(json);

      expect(mail.id, 'test-uuid-001');
      expect(mail.userId, 'test-user-uuid');
      expect(mail.type, MailType.event);
      expect(mail.title, '테스트 보상');
      expect(mail.body, '테스트 메일입니다.');
      expect(mail.rewardChips, 500);
      expect(mail.rewardEnergy, isNull);
      expect(mail.isRead, false);
      expect(mail.claimedAt, isNull);
      expect(mail.createdAt, isNotNull);
      expect(mail.expiresAt, isNotNull);
    });

    test('fromJson — null 보상 필드 허용', () {
      final json = {
        'id': 'no-reward-mail',
        'user_id': 'user-1',
        'type': 'announcement',
        'title': '공지',
        'body': '내용',
        'reward_chips': null,
        'reward_energy': null,
        'is_read': true,
        'claimed_at': null,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': null,
      };
      final mail = MailItem.fromJson(json);

      expect(mail.rewardChips, isNull);
      expect(mail.rewardEnergy, isNull);
      expect(mail.hasReward, false);
    });

    test('copyWith — 일부 필드 변경', () {
      final original = MailFixtures.sampleMails().first;
      final updated = original.copyWith(isRead: true, title: '변경됨');

      expect(updated.isRead, true);
      expect(updated.title, '변경됨');
      // 변경하지 않은 필드는 유지
      expect(updated.id, original.id);
      expect(updated.body, original.body);
      expect(updated.type, original.type);
    });

    test('equality — 동일 객체 비교', () {
      final a = MailFixtures.sampleMails()[0];
      final b = a.copyWith();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality — 다른 객체 비교', () {
      final a = MailFixtures.sampleMails()[0];
      final b = MailFixtures.sampleMails()[1];

      expect(a, isNot(equals(b)));
    });

    test('isClaimed — claimedAt 기반 판별', () {
      final mails = MailFixtures.sampleMails();

      // mail-uuid-001: claimedAt 설정됨
      expect(mails[0].isClaimed, true);
      // mail-uuid-002: claimedAt null
      expect(mails[1].isClaimed, false);
    });

    test('hasReward — 칩 또는 에너지 > 0', () {
      final mails = MailFixtures.sampleMails();

      // mail-uuid-001: rewardChips=500
      expect(mails[0].hasReward, true);
      // mail-uuid-004: rewardChips=null, rewardEnergy=null
      expect(mails[3].hasReward, false);
      // mail-uuid-008: rewardEnergy=5
      expect(mails[7].hasReward, true);
    });

    test('isExpired — 만료 시각 기반 판별', () {
      final now = DateTime.now();
      final expiredMail = MailItem(
        id: 'expired',
        userId: 'user',
        type: MailType.system,
        title: '만료됨',
        body: '',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 10)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      );
      final activeMail = MailItem(
        id: 'active',
        userId: 'user',
        type: MailType.system,
        title: '유효',
        body: '',
        isRead: false,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );
      final noExpiryMail = MailItem(
        id: 'no-expiry',
        userId: 'user',
        type: MailType.announcement,
        title: '영구',
        body: '',
        isRead: false,
        createdAt: now,
        expiresAt: null,
      );

      expect(expiredMail.isExpired, true);
      expect(activeMail.isExpired, false);
      expect(noExpiryMail.isExpired, false);
    });
  });

  // =========================================================================
  // MailType 테스트
  // =========================================================================

  group('MailType', () {
    test('fromString — 유효한 값 파싱', () {
      expect(MailTypeExtension.fromString('system'), MailType.system);
      expect(MailTypeExtension.fromString('event'), MailType.event);
      expect(MailTypeExtension.fromString('compensation'), MailType.compensation);
      expect(MailTypeExtension.fromString('announcement'), MailType.announcement);
    });

    test('fromString — 잘못된 값은 system 기본값', () {
      expect(MailTypeExtension.fromString('invalid'), MailType.system);
      expect(MailTypeExtension.fromString(''), MailType.system);
    });

    test('toJson — enum을 문자열로 변환', () {
      expect(MailType.system.toJson(), 'system');
      expect(MailType.event.toJson(), 'event');
      expect(MailType.compensation.toJson(), 'compensation');
      expect(MailType.announcement.toJson(), 'announcement');
    });
  });

  // =========================================================================
  // MailFixtures 데이터 무결성 테스트
  // =========================================================================

  group('MailFixtures', () {
    test('sampleMails — 8개 메일 반환', () {
      final mails = MailFixtures.sampleMails();
      expect(mails.length, 8);
    });

    test('sampleMails — 4가지 타입 모두 포함', () {
      final mails = MailFixtures.sampleMails();
      final types = mails.map((m) => m.type).toSet();

      expect(types, contains(MailType.system));
      expect(types, contains(MailType.event));
      expect(types, contains(MailType.compensation));
      expect(types, contains(MailType.announcement));
    });

    test('sampleMails — 읽음/미읽음 믹스', () {
      final mails = MailFixtures.sampleMails();
      final readCount = mails.where((m) => m.isRead).length;
      final unreadCount = mails.where((m) => !m.isRead).length;

      expect(readCount, greaterThan(0));
      expect(unreadCount, greaterThan(0));
    });

    test('sampleMails — 수령/미수령 믹스', () {
      final mails = MailFixtures.sampleMails();
      final claimedCount = mails.where((m) => m.isClaimed).length;
      final unclaimedWithReward =
          mails.where((m) => m.hasReward && !m.isClaimed).length;

      expect(claimedCount, greaterThan(0));
      expect(unclaimedWithReward, greaterThan(0));
    });

    test('sampleMailJson — MailItem.fromJson과 호환', () {
      final json = MailFixtures.sampleMailJson();
      final mail = MailItem.fromJson(json);

      expect(mail.id, isNotEmpty);
      expect(mail.type, MailType.event);
    });
  });

  // =========================================================================
  // MailboxState 관련 로직 테스트
  // =========================================================================

  group('Mailbox computed values', () {
    test('unreadCount — 미읽음 + 미만료 메일 수', () {
      final mails = MailFixtures.sampleMails();
      final unreadCount =
          mails.where((m) => !m.isRead && !m.isExpired).length;

      // fixture에서 미읽음: uuid-001, 002, 003, 005, 008 = 5개 (미만료 기준)
      expect(unreadCount, greaterThanOrEqualTo(4));
    });

    test('unclaimedCount — 보상 미수령 + 미만료 메일 수', () {
      final mails = MailFixtures.sampleMails();
      final unclaimedCount = mails
          .where((m) => m.hasReward && !m.isClaimed && !m.isExpired)
          .length;

      // fixture에서 미수령: uuid-002, 003, 005, 008 = 4개 (미만료 기준)
      expect(unclaimedCount, greaterThanOrEqualTo(3));
    });
  });
}
