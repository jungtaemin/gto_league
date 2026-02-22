import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../data/models/tier.dart';

enum LeagueResultType { promotion, retention, demotion }

class LeagueResultDialog extends StatelessWidget {
  const LeagueResultDialog({
    super.key,
    required this.type,
    required this.previousTier,
    required this.currentTier,
    required this.rewardChips,
    required this.onClaim,
  });

  final LeagueResultType type;
  final Tier previousTier;
  final Tier currentTier;
  final int rewardChips;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isPromotion = type == LeagueResultType.promotion;
    final isDemotion = type == LeagueResultType.demotion;

    final String title = isPromotion ? '🎉 리그 승급!' : (isDemotion ? '💧 리그 강등...' : '🛡️ 리그 잔류');
    final Color mainColor = isPromotion ? AppColors.leaguePromotionGold : (isDemotion ? Colors.redAccent : Colors.blueAccent);
    final String subtitle = isPromotion 
        ? '축하합니다! 상위 리그로 승급하셨습니다.' 
        : (isDemotion ? '아쉽게도 하위 리그로 강등되었습니다.' : '치열한 경쟁 속에서 자리를 지켜냈습니다!');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Container(
        padding: EdgeInsets.all(context.w(24)),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(color: mainColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: mainColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(28),
                fontWeight: FontWeight.w900,
                color: mainColor,
                shadows: [Shadow(color: Colors.black54, offset: const Offset(0, 2), blurRadius: 4)],
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            
            SizedBox(height: context.w(8)),
            
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: context.sp(14)),
            ).animate().fadeIn(delay: 300.ms),
            
            SizedBox(height: context.w(24)),
            
            // Tier transition animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTierIcon(context, previousTier, Colors.white38),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: context.w(24))
                      .animate(onPlay: (c) => c.repeat())
                      .moveX(begin: -5, end: 5, duration: 600.ms)
                      .fadeIn(duration: 600.ms),
                ),
                _buildTierIcon(context, currentTier, mainColor)
                    .animate(delay: 600.ms)
                    .scale(duration: 500.ms, curve: Curves.bounceOut)
                    .shimmer(duration: 1000.ms, color: Colors.white),
              ],
            ),
            
            SizedBox(height: context.w(30)),
            
            // Reward Box
            Container(
              padding: EdgeInsets.symmetric(vertical: context.w(16), horizontal: context.w(20)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(context.r(16)),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Text('시즌 보상', style: TextStyle(color: Colors.white54, fontSize: context.sp(12))),
                  SizedBox(height: context.w(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.diamond, color: Colors.amber, size: context.w(24)),
                      SizedBox(width: context.w(8)),
                      Text(
                        '+$rewardChips 칩',
                        style: TextStyle(color: Colors.amber, fontSize: context.sp(22), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5, end: 0),
            
            SizedBox(height: context.w(24)),
            
            // Claim Button
            SizedBox(
              width: double.infinity,
              height: context.w(56),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClaim();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
                  elevation: 5,
                ),
                child: Text(
                  '보상 받기',
                  style: TextStyle(fontSize: context.sp(18), fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            ).animate().fadeIn(delay: 1500.ms).scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierIcon(BuildContext context, Tier tier, Color borderColor) {
    return Container(
      width: context.w(70),
      height: context.w(70),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tier.emoji, style: TextStyle(fontSize: context.sp(32))),
          SizedBox(height: context.w(4)),
          Text(tier.displayName, style: TextStyle(color: Colors.white, fontSize: context.sp(10), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
