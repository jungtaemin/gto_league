import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../data/models/tier.dart';
import 'fever_timer.dart';

/// Header section of the league screen.
/// Displays title, season info, tier icons, and status banners.
class LeagueHeader extends StatelessWidget {
  const LeagueHeader({
    super.key,
    required this.seasonId,
    required this.remainingDuration,
    required this.isFeverTime,
    required this.myTier,
    required this.realPlayerCount,
    required this.isLoggedIn,
    required this.isAssigned,
    required this.onRefresh,
  });

  final String seasonId;
  final Duration remainingDuration;
  final bool isFeverTime;
  final Tier myTier;
  final int realPlayerCount;
  final bool isLoggedIn;
  final bool isAssigned;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.w(12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white.withValues(alpha: 0.9), AppColors.leaguePromotionGold],
                        ).createShader(bounds),
                        child: Text(
                          '15인 리그',
                          style: TextStyle(fontSize: context.sp(24), fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      GestureDetector(
                        onTap: () => _showRewardDialog(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.w(4)),
                          decoration: BoxDecoration(
                            color: AppColors.leaguePromotionGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(context.r(12)),
                            border: Border.all(color: AppColors.leaguePromotionGold.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.card_giftcard, size: context.w(14), color: AppColors.leaguePromotionGold),
                              SizedBox(width: context.w(4)),
                              Text('시즌 보상', style: TextStyle(color: AppColors.leaguePromotionGold, fontSize: context.sp(10), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: context.w(2)),
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         '$seasonId · ',
                         style: TextStyle(
                           fontSize: context.sp(11),
                           color: AppColors.leagueMyHighlight,
                           fontWeight: FontWeight.bold,
                           letterSpacing: 0.5,
                         ),
                       ),
                       FeverTimer(
                         remainingDuration: remainingDuration,
                         isFeverTime: isFeverTime,
                       ),
                     ],
                   ),
                ],
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.w(5)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.r(20)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white54, size: context.w(14)),
                      SizedBox(width: context.w(4)),
                      Text(
                        '$realPlayerCount명 참여중',
                        style: TextStyle(color: Colors.white, fontSize: context.sp(11), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.w(12)),
        SizedBox(
          height: context.w(80),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: context.w(16)),
            children: Tier.values.map((t) {
              final isMe = t == myTier;
              return _buildTierIcon(context, t.emoji, t.displayName, _tierColor(t), isMe);
            }).toList(),
          ),
        ),
        SizedBox(height: context.w(8)),
        if (!isLoggedIn)
          _buildInfoBanner(context, '로그인하면 리그에 참여됩니다!', Icons.cloud_off_rounded, Colors.orange)
        else if (!isAssigned)
          _buildInfoBanner(context, '첫 게임을 완료하면 리그에 배치됩니다!', Icons.info_outline, AppColors.leagueMyHighlight),
      ],
    );
  }

  Widget _buildTierIcon(BuildContext context, String emoji, String label, Color color, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(right: context.w(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isActive ? context.w(56) : context.w(48),
            height: isActive ? context.w(56) : context.w(48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
              ),
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(
                color: isActive ? AppColors.leaguePromotionGold : Colors.white.withValues(alpha: 0.2),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Text(emoji, style: TextStyle(fontSize: isActive ? context.sp(28) : context.sp(22)))),
                if (isActive)
                  Positioned(
                    top: -8, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.w(2)),
                        decoration: BoxDecoration(
                          color: AppColors.leaguePromotionGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('나', style: TextStyle(color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.w(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: isActive ? context.sp(11) : context.sp(10),
              color: isActive ? AppColors.leaguePromotionGold : Colors.white38,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context, String text, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.w(8)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.w(16)),
            SizedBox(width: context.w(8)),
            Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: context.sp(12), fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  /// Tier-specific colors — intentionally hardcoded (not league theme colors).
  Color _tierColor(Tier t) {
    return switch (t) {
      Tier.fish => const Color(0xFF60A5FA),
      Tier.donkey => const Color(0xFFA3E635),
      Tier.callingStation => const Color(0xFFF472B6),
      Tier.pubReg => const Color(0xFFFCD34D),
      Tier.grinder => const Color(0xFF94A3B8),
      Tier.shark => const Color(0xFF22D3EE),
      Tier.gtoMachine => const Color(0xFFC084FC),
    };
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(context.w(20)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2D3A8C), Color(0xFF1A1B4B)],
            ),
            borderRadius: BorderRadius.circular(context.r(24)),
            border: Border.all(color: AppColors.leaguePromotionGold.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏆 시즌 마감 보상 안내', style: TextStyle(color: AppColors.leaguePromotionGold, fontSize: context.sp(20), fontWeight: FontWeight.bold)),
              SizedBox(height: context.w(16)),
              _buildRewardRow(context, '승급 (1~3위)', '다음 티어로 승급!\n루비 100개 + 골드 상자', Colors.amber),
              _buildRewardRow(context, '잔류 (4~10위)', '현재 티어 유지\n루비 30개 + 실버 상자', Colors.blue),
              _buildRewardRow(context, '강등 (11~15위)', '이전 티어로 강등...\n위로의 1,000 칩', Colors.redAccent),
              SizedBox(height: context.w(20)),
              Text('* 매주 목요일, 일요일 자정에 시즌이 마감됩니다.', style: TextStyle(color: Colors.white54, fontSize: context.sp(10))),
              SizedBox(height: context.w(20)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leaguePromotionGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(12))),
                ),
                child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardRow(BuildContext context, String title, String desc, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.w(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.w(12),
            height: context.w(12),
            margin: EdgeInsets.only(top: context.w(4)),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: context.sp(14), fontWeight: FontWeight.bold)),
                SizedBox(height: context.w(4)),
                Text(desc, style: TextStyle(color: Colors.white, fontSize: context.sp(12), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
