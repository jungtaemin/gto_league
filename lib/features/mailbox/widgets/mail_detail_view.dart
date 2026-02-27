import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/mail_item.dart';
import '../../../providers/mailbox_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../home/widgets/gto/stitch_colors.dart';
import 'reward_claim_overlay.dart';

/// 메일 상세 보기 위젯 — 본문, 첨부 보상, 수령 버튼, 컨페티 오버레이.
class MailDetailView extends ConsumerStatefulWidget {
  final MailItem mail;
  final VoidCallback onBack;

  const MailDetailView({
    super.key,
    required this.mail,
    required this.onBack,
  });

  @override
  ConsumerState<MailDetailView> createState() => _MailDetailViewState();
}

class _MailDetailViewState extends ConsumerState<MailDetailView> {
  bool _isClaiming = false;
  bool _showReward = false;

  @override
  void initState() {
    super.initState();
    // 열람 시 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.mail.isRead) {
        ref.read(mailboxProvider.notifier).markAsRead(widget.mail.id);
      }
    });
  }

  Color _typeColor() {
    switch (widget.mail.type) {
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
    switch (widget.mail.type) {
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

  String _typeLabel() {
    switch (widget.mail.type) {
      case MailType.system:
        return '시스템';
      case MailType.event:
        return '이벤트';
      case MailType.compensation:
        return '보상';
      case MailType.announcement:
        return '공지';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onClaim() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);
    try {
      final success =
          await ref.read(mailboxProvider.notifier).claimReward(widget.mail.id);
      if (success && mounted) {
        // 수령 성공 → 유저 스탯 새로고침 (UI에 칩/에너지 반영)
        ref.read(userStatsProvider.notifier).loadFromServer();
        setState(() {
          _isClaiming = false;
          _showReward = true;
        });
      } else if (mounted) {
        setState(() => _isClaiming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('보상 수령에 실패했습니다. 다시 시도해 주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MailDetailView:_onClaim] 에러: $e');
      if (mounted) {
        setState(() => _isClaiming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네트워크 오류. 다시 시도해 주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    // Provider에서 최신 상태 감시
    final mailboxState = ref.watch(mailboxProvider);
    final currentMail = mailboxState.mails.firstWhere(
      (m) => m.id == widget.mail.id,
      orElse: () => widget.mail,
    );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(context.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타입 뱃지
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.w(4),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(context.r(6)),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(), color: color, size: context.w(14)),
                    SizedBox(width: context.w(4)),
                    Text(
                      _typeLabel(),
                      style: TextStyle(
                        color: color,
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              SizedBox(height: context.w(16)),
              // 제목
              Text(
                currentMail.title,
                style: TextStyle(
                  color: StitchColors.slate100,
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              SizedBox(height: context.w(6)),
              // 날짜
              Text(
                _formatDate(currentMail.createdAt),
                style: TextStyle(
                  color: StitchColors.slate500,
                  fontSize: context.sp(12),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
              SizedBox(height: context.w(20)),
              // 구분선
              Container(height: 1, color: Colors.white.withOpacity(0.05)),
              SizedBox(height: context.w(20)),
              // 본문
              Text(
                currentMail.body,
                style: TextStyle(
                  color: StitchColors.slate300,
                  fontSize: context.sp(14),
                  height: 1.6,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              SizedBox(height: context.w(24)),
              // 보상 영역
              if (currentMail.hasReward)
                _buildRewardSection(context, currentMail, color),
            ],
          ),
        ),
        if (_showReward)
          RewardClaimOverlay(
            chips: currentMail.rewardChips ?? 0,
            energy: currentMail.rewardEnergy ?? 0,
            onComplete: () => setState(() => _showReward = false),
          ),
      ],
    );
  }

  Widget _buildRewardSection(
    BuildContext context,
    MailItem mail,
    Color typeColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: StitchColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: StitchColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '첨부 보상',
            style: TextStyle(
              color: StitchColors.primary,
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.w(12)),
          if ((mail.rewardChips ?? 0) > 0)
            _buildRewardRow(
              context,
              Icons.monetization_on_rounded,
              StitchColors.yellow400,
              '${mail.rewardChips} 칩',
            ),
          if ((mail.rewardChips ?? 0) > 0 && (mail.rewardEnergy ?? 0) > 0)
            SizedBox(height: context.w(8)),
          if ((mail.rewardEnergy ?? 0) > 0)
            _buildRewardRow(
              context,
              Icons.bolt_rounded,
              StitchColors.cyan400,
              '${mail.rewardEnergy} 에너지',
            ),
          SizedBox(height: context.w(16)),
          _buildClaimStatus(context, mail),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 300.ms)
        .slideY(begin: 0.1, duration: 300.ms, delay: 300.ms);
  }

  Widget _buildClaimStatus(BuildContext context, MailItem mail) {
    // 미수령 + 미만료 → 수령 버튼
    if (!mail.isClaimed && !mail.isExpired) {
      return BouncingButton(
        onTap: _isClaiming ? null : _onClaim,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.w(12)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [StitchColors.primary, StitchColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(context.r(10)),
            boxShadow: [
              BoxShadow(
                color: StitchColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isClaiming
                ? SizedBox(
                    width: context.w(18),
                    height: context.w(18),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    '보상 수령',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      );
    }

    // 수령 완료
    if (mail.isClaimed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.w(12)),
        decoration: BoxDecoration(
          color: StitchColors.green400.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.r(10)),
          border: Border.all(color: StitchColors.green400.withOpacity(0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: StitchColors.green400,
                size: context.w(18),
              ),
              SizedBox(width: context.w(6)),
              Text(
                '수령 완료',
                style: TextStyle(
                  color: StitchColors.green400,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 만료
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.w(12)),
      decoration: BoxDecoration(
        color: StitchColors.red400.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: StitchColors.red400.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          '만료됨',
          style: TextStyle(
            color: StitchColors.red400,
            fontSize: context.sp(14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardRow(
    BuildContext context,
    IconData icon,
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: context.w(20)),
        SizedBox(width: context.w(8)),
        Text(
          text,
          style: TextStyle(
            color: StitchColors.slate200,
            fontSize: context.sp(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
