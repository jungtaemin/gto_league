import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/mail_item.dart';
import '../../home/widgets/gto/stitch_colors.dart';

/// 우편함 목록의 개별 메일 행 위젯.
/// 타입별 아이콘·색상, 미읽음 표시, 만료 카운트다운, 수령 버튼을 포함.
class MailItemRow extends StatelessWidget {
  final MailItem mail;
  final VoidCallback onTap;
  final VoidCallback? onClaim;

  const MailItemRow({
    super.key,
    required this.mail,
    required this.onTap,
    this.onClaim,
  });

  Color _typeColor() {
    switch (mail.type) {
      case MailType.system:
        return StitchColors.blue400;
      case MailType.event:
        return StitchColors.yellow400;
      case MailType.compensation:
        return StitchColors.red400;
      case MailType.announcement:
        return StitchColors.slate400;
    }
  }

  IconData _typeIcon() {
    switch (mail.type) {
      case MailType.system:
        return Icons.settings_rounded;
      case MailType.event:
        return Icons.celebration_rounded;
      case MailType.compensation:
        return Icons.card_giftcard_rounded;
      case MailType.announcement:
        return Icons.campaign_rounded;
    }
  }

  /// 만료 시간 포맷팅 (T14 인라인 구현).
  /// null → '', 만료됨, D-N, N시간 후 만료, N분 후 만료.
  String _formatExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return '만료됨';
    final diff = expiresAt.difference(now);
    if (diff.inDays > 0) return 'D-${diff.inDays}';
    if (diff.inHours > 0) return '${diff.inHours}시간 후 만료';
    return '${diff.inMinutes}분 후 만료';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    final expiry = _formatExpiry(mail.expiresAt);
    final isUrgent = mail.expiresAt != null &&
        !mail.isExpired &&
        mail.expiresAt!.difference(DateTime.now()).inHours < 24;

    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.w(12)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(mail.isRead ? 0.03 : 0.07),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(
            color: mail.isRead
                ? Colors.white.withOpacity(0.05)
                : color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // 좌측: 타입 아이콘 + 미읽음 인디케이터
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: context.w(40),
                  height: context.w(40),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(_typeIcon(), color: color, size: context.w(20)),
                ),
                if (!mail.isRead)
                  Positioned(
                    top: -context.w(2),
                    right: -context.w(2),
                    child: Container(
                      width: context.w(8),
                      height: context.w(8),
                      decoration: BoxDecoration(
                        color: StitchColors.cyan400,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: context.w(12)),
            // 중앙: 제목 + 본문 미리보기 + 만료
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mail.title,
                    style: TextStyle(
                      color: mail.isRead
                          ? StitchColors.slate400
                          : StitchColors.slate100,
                      fontSize: context.sp(14),
                      fontWeight: mail.isRead ? FontWeight.w400 : FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.w(2)),
                  Text(
                    mail.body,
                    style: TextStyle(
                      color: StitchColors.slate500,
                      fontSize: context.sp(11),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (expiry.isNotEmpty) ...[
                    SizedBox(height: context.w(4)),
                    Text(
                      expiry,
                      style: TextStyle(
                        color: isUrgent
                            ? StitchColors.red400
                            : StitchColors.slate500,
                        fontSize: context.sp(10),
                        fontWeight:
                            isUrgent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.w(8)),
            // 우측: 수령 버튼 / 수령완료 / 만료 / 화살표
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    // 보상이 있고 미수령 + 미만료 → 수령 버튼
    if (mail.hasReward && !mail.isClaimed && !mail.isExpired && onClaim != null) {
      // GestureDetector로 외부 BouncingButton의 탭 이벤트 전파를 차단
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClaim,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.w(6),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [StitchColors.primary, StitchColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(context.r(8)),
            boxShadow: [
              BoxShadow(
                color: StitchColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '수령',
            style: TextStyle(
              color: Colors.black,
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 수령 완료
    if (mail.isClaimed) {
      return Icon(
        Icons.check_circle_rounded,
        color: StitchColors.green400.withOpacity(0.6),
        size: context.w(22),
      );
    }

    // 만료
    if (mail.isExpired) {
      return Text(
        '만료',
        style: TextStyle(
          color: StitchColors.slate500,
          fontSize: context.sp(11),
        ),
      );
    }

    // 기본: 화살표
    return Icon(
      Icons.chevron_right_rounded,
      color: StitchColors.slate500,
      size: context.w(20),
    );
  }
}
