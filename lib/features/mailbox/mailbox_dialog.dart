import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/mail_item.dart';
import '../../../providers/mailbox_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../home/widgets/gto/stitch_colors.dart';
import 'widgets/mail_item_row.dart';
import 'widgets/mail_detail_view.dart';
import 'widgets/empty_mailbox.dart';
import 'widgets/reward_claim_overlay.dart';
import 'dart:ui';

class MailboxDialog extends ConsumerStatefulWidget {
  const MailboxDialog({super.key});

  @override
  ConsumerState<MailboxDialog> createState() => _MailboxDialogState();
}

class _MailboxDialogState extends ConsumerState<MailboxDialog>
    with TickerProviderStateMixin {
  int _tabIndex = 0; // 0: 전체, 1: 미수령
  MailItem? _selectedMail;
  bool _showRewardOverlay = false;
  int _overlayChips = 0;
  int _overlayEnergy = 0;

  @override
  void initState() {
    super.initState();
    // 백그라운드 새로고침 (로딩 스피너 없이 조용히 갱신)
    ref.read(mailboxProvider.notifier).refreshMail();
  }

  List<MailItem> _filteredMails(List<MailItem> mails) {
    if (_tabIndex == 1) {
      return mails.where((m) => m.hasReward && !m.isClaimed && !m.isExpired).toList();
    }
    return mails;
  }

  Future<void> _onClaimAll() async {
    try {
      final result = await ref.read(mailboxProvider.notifier).claimAllRewards();
      if (result != null && result.count > 0 && mounted) {
        // 수령 성공 → 유저 스탯 새로고침
        ref.read(userStatsProvider.notifier).loadFromServer();
        setState(() {
          _overlayChips = result.totalChips;
          _overlayEnergy = result.totalEnergy;
          _showRewardOverlay = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수령할 보상이 없습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MailboxDialog:_onClaimAll] 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('보상 수령에 실패했습니다. 다시 시도해 주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mailboxState = ref.watch(mailboxProvider);
    final mails = _filteredMails(mailboxState.mails);
    final unclaimedCount = ref.read(mailboxProvider.notifier).unclaimedCount;

    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(24)),
            side: BorderSide.none,
          ),
          insetPadding: EdgeInsets.all(context.w(16)),
          child: Container(
            width: double.infinity,
            height: context.h(620),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                BoxShadow(color: StitchColors.cyan500.withOpacity(0.1), blurRadius: 30, spreadRadius: 2),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildTabs(context),
                    Expanded(child: _buildBody(context, mailboxState, mails)),
                    if (unclaimedCount > 0 && _selectedMail == null)
                      _buildClaimAllBar(context, unclaimedCount, mailboxState.isLoading),
                  ],
                ),
              ),
            ),
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(duration: 200.ms),
        if (_showRewardOverlay)
          RewardClaimOverlay(
            chips: _overlayChips,
            energy: _overlayEnergy,
            onComplete: () => setState(() => _showRewardOverlay = false),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(16)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_selectedMail != null)
            BouncingButton(
              onTap: () => setState(() => _selectedMail = null),
              child: Icon(Icons.arrow_back_ios_rounded, color: StitchColors.slate300, size: context.w(20)),
            )
          else
            SizedBox(width: context.w(20)),
          Text(
            '우편함',
            style: TextStyle(
              color: StitchColors.slate100,
              fontSize: context.sp(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          BouncingButton(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.close_rounded, color: StitchColors.slate400, size: context.w(22)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    if (_selectedMail != null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        children: [
          _buildTab(context, '전체', 0),
          SizedBox(width: context.w(8)),
          _buildTab(context, '미수령', 1),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isSelected = _tabIndex == index;
    return BouncingButton(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(8)),
        decoration: BoxDecoration(
          color: isSelected ? StitchColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.r(20)),
          border: Border.all(
            color: isSelected ? StitchColors.primary : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? StitchColors.primary : StitchColors.slate400,
            fontSize: context.sp(13),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MailboxState state, List<MailItem> mails) {
    if (_selectedMail != null) {
      return MailDetailView(
        mail: _selectedMail!,
        onBack: () => setState(() => _selectedMail = null),
      );
    }

    if (state.isLoading && mails.isEmpty) {
      return Center(
        child: SizedBox(
          width: context.w(32),
          height: context.w(32),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: StitchColors.primary,
          ),
        ),
      );
    }

    if (mails.isEmpty) {
      return const EmptyMailbox();
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(12)),
      itemCount: mails.length,
      separatorBuilder: (_, __) => SizedBox(height: context.w(8)),
      itemBuilder: (context, index) {
        final mail = mails[index];
        return MailItemRow(
          mail: mail,
          onTap: () => setState(() => _selectedMail = mail),
          onClaim: mail.hasReward && !mail.isClaimed
              ? () async {
                  try {
                    final success = await ref.read(mailboxProvider.notifier).claimReward(mail.id);
                    if (success && mounted) {
                      // 수령 성공 → 유저 스탯 새로고침
                      ref.read(userStatsProvider.notifier).loadFromServer();
                      setState(() {
                        _overlayChips = mail.rewardChips ?? 0;
                        _overlayEnergy = mail.rewardEnergy ?? 0;
                        _showRewardOverlay = true;
                      });
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('보상 수령에 실패했습니다. 다시 시도해 주세요.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('[MailboxDialog:onClaim] 에러: $e');
                  }
                }
              : null,
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.1, duration: 300.ms, delay: (50 * index).ms);
      },
    );
  }

  Widget _buildClaimAllBar(BuildContext context, int count, bool isLoading) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(12)),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BouncingButton(
        onTap: isLoading ? null : _onClaimAll,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.w(14)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [StitchColors.primary, StitchColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(context.r(12)),
            boxShadow: [
              BoxShadow(color: StitchColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: context.w(20),
                    height: context.w(20),
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    '전체 수령 ($count)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}