import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../data/models/league_player.dart';
import '../../../../../data/services/league_service.dart';

/// Unified player card for the league ranking list.
///
/// Card variant is determined by [player.rank] and [isMe]:
/// - **me** → cyan highlight with neon glow
/// - **promotion** (rank 1-3) → gold tint
/// - **demotion** (rank 11-15) → red tint + '강등' badge
/// - **normal** → subtle white
class LeaguePlayerCard extends StatelessWidget {
  const LeaguePlayerCard({
    super.key,
    required this.player,
    required this.isMe,
    this.trailingBadge,
  });

  final LeaguePlayer player;
  final bool isMe;
  final Widget? trailingBadge;

  @override
  Widget build(BuildContext context) {
    if (isMe) return _buildMeCard(context);
    if (LeagueService.isPromotion(player.rank)) return _buildPromotionCard(context);
    if (LeagueService.isDemotion(player.rank)) return _buildDemotionCard(context);
    return _buildNormalCard(context);
  }

  // ---------------------------------------------------------------------------
  // Me Card — cyan highlight, neon glow
  // ---------------------------------------------------------------------------
  Widget _buildMeCard(BuildContext context) {
    final zoneLabel = LeagueService.getZoneLabel(player.rank);
    final isPromo = LeagueService.isPromotion(player.rank);
    final zoneColor = isPromo ? AppColors.leaguePromotionGold : AppColors.leagueDemotionRed;
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.w(4)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.leagueCardGradientStart, AppColors.leagueCardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.leagueMyHighlight, width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.leagueMyHighlight.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2),
          BoxShadow(color: AppColors.leagueMyHighlight.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      child: Row(children: [
        _rankNumber(context, context.sp(22), AppColors.leagueMyHighlight,
            italic: true, shadows: [Shadow(color: AppColors.leagueMyHighlight.withValues(alpha: 0.8), blurRadius: 5)]),
        SizedBox(width: context.w(8)),
        // Avatar with "나" badge
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: context.w(44), height: context.w(44),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(child: Text(
              player.nickname.isNotEmpty ? player.nickname[0] : '?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.sp(16)),
            )),
          ),
          Positioned(top: -4, left: -4, child: Container(
            width: context.w(18), height: context.w(18),
            decoration: const BoxDecoration(color: AppColors.leagueMyHighlight, shape: BoxShape.circle),
            child: Center(child: Text('나',
                style: TextStyle(color: Colors.white, fontSize: context.sp(7), fontWeight: FontWeight.bold))),
          )),
        ]),
        SizedBox(width: context.w(12)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(player.nickname,
                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis)),
            Row(children: [
              Icon(Icons.arrow_upward, color: AppColors.leagueMyHighlight.withValues(alpha: 0.8), size: context.w(12)),
              SizedBox(width: context.w(2)),
              Text('${player.score}p', style: TextStyle(
                  color: AppColors.leagueMyHighlight.withValues(alpha: 0.9), fontSize: context.sp(16), fontWeight: FontWeight.bold)),
              if (trailingBadge != null) ...[SizedBox(width: context.w(6)), trailingBadge!],
            ]),
          ]),
          SizedBox(height: context.w(4)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (zoneLabel != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.w(2)),
                decoration: BoxDecoration(
                    color: zoneColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(context.r(6))),
                child: Text(zoneLabel,
                    style: TextStyle(color: zoneColor, fontSize: context.sp(9), fontWeight: FontWeight.bold)))
            else
              Text('안전권', style: TextStyle(
                  color: AppColors.leaguePromotionGold.withValues(alpha: 0.7), fontSize: context.sp(10), fontWeight: FontWeight.bold)),
            Text('${player.tier.emoji} ${player.tier.displayName}',
                style: TextStyle(fontSize: context.sp(10), color: Colors.white38)),
          ]),
        ])),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // Promotion Card — gold tint (rank 1-3)
  // ---------------------------------------------------------------------------
  Widget _buildPromotionCard(BuildContext context) {
    final isKing = player.rank == 1;
    final topGold = player.rank <= 3;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.leaguePromotionGold.withValues(alpha: 0.15),
          AppColors.leaguePromotionGold.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.leaguePromotionGold.withValues(alpha: isKing ? 0.3 : 0.15)),
      ),
      child: Row(children: [
        _rankNumber(context, context.sp(isKing ? 20 : 16),
            topGold ? AppColors.leaguePromotionGold : Colors.white54, italic: true),
        SizedBox(width: context.w(8)),
        _buildAvatar(context, isKing ? context.w(40) : context.w(36), AppColors.leaguePromotionGold),
        SizedBox(width: context.w(12)),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(player.nickname,
                style: TextStyle(color: Colors.white, fontSize: context.sp(14),
                    fontWeight: isKing ? FontWeight.bold : FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
            if (isKing) ...[
              SizedBox(width: context.w(6)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.w(1)),
                decoration: BoxDecoration(
                    color: AppColors.leaguePromotionGold, borderRadius: BorderRadius.circular(context.r(6))),
                child: Text('왕', style: TextStyle(
                    color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.bold))),
            ],
            if (player.isBot) ...[
              SizedBox(width: context.w(4)),
              Text('🤖', style: TextStyle(fontSize: context.sp(12))),
            ],
          ])),
          _scoreWithBadge(context, topGold
              ? AppColors.leaguePromotionGold
              : AppColors.leaguePromotionGold.withValues(alpha: 0.8), context.sp(14)),
        ])),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // Normal Card — subtle white (rank 4-10)
  // ---------------------------------------------------------------------------
  Widget _buildNormalCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        _rankNumber(context, context.sp(16), Colors.white38),
        SizedBox(width: context.w(8)),
        _buildAvatar(context, context.w(32), Colors.grey.shade700),
        SizedBox(width: context.w(12)),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(player.nickname,
                style: TextStyle(color: Colors.white38, fontSize: context.sp(14)),
                overflow: TextOverflow.ellipsis)),
            if (player.isBot) ...[
              SizedBox(width: context.w(4)),
              Text('🤖', style: TextStyle(fontSize: context.sp(10))),
            ],
          ])),
          _scoreWithBadge(context, Colors.white30, context.sp(12)),
        ])),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // Demotion Card — red tint + '강등' badge (rank 11-15)
  // ---------------------------------------------------------------------------
  Widget _buildDemotionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            AppColors.leagueDemotionRed.withValues(alpha: 0.05),
            AppColors.leagueDemotionRed.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        _rankNumber(context, context.sp(16), Colors.red.shade300.withValues(alpha: 0.8)),
        SizedBox(width: context.w(8)),
        _buildAvatar(context, context.w(32), Colors.red.shade900.withValues(alpha: 0.4)),
        SizedBox(width: context.w(12)),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(player.nickname,
                style: TextStyle(color: Colors.white60, fontSize: context.sp(14)),
                overflow: TextOverflow.ellipsis)),
            if (player.isBot) ...[
              SizedBox(width: context.w(4)),
              Text('🤖', style: TextStyle(fontSize: context.sp(10))),
            ],
            SizedBox(width: context.w(6)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.w(1)),
              decoration: BoxDecoration(
                  color: AppColors.leagueDemotionRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.r(6))),
              child: Text('강등', style: TextStyle(
                  color: AppColors.leagueDemotionRed, fontSize: context.sp(8), fontWeight: FontWeight.bold))),
          ])),
          _scoreWithBadge(context, Colors.red.shade300, context.sp(12)),
        ])),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _rankNumber(BuildContext context, double fontSize, Color color,
      {bool italic = false, List<Shadow>? shadows}) {
    return SizedBox(
      width: context.w(32),
      child: Text('${player.rank}', textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900,
              fontStyle: italic ? FontStyle.italic : null, color: color, shadows: shadows)),
    );
  }

  Widget _scoreWithBadge(BuildContext context, Color color, double fontSize) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${player.score}p',
          style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      if (trailingBadge != null) ...[SizedBox(width: context.w(6)), trailingBadge!],
    ]);
  }

  Widget _buildAvatar(BuildContext context, double size, Color bgColor) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: bgColor,
          border: Border.all(color: bgColor.withValues(alpha: 0.5))),
      child: Center(child: Text(
        player.nickname.isNotEmpty ? player.nickname[0] : '?',
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: size * 0.35),
      )),
    );
  }
}
