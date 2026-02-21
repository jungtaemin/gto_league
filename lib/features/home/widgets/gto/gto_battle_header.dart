import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/models/card_question.dart';
import '../../../../data/models/game_state.dart';
import 'stitch_colors.dart';

class GtoBattleHeader extends StatelessWidget {
  final GameState gameState;
  final CardQuestion question;
  final String tierName; // e.g. "Silver 1"
  final int currentScore;
  final int rank; // e.g. 4203

  const GtoBattleHeader({
    super.key,
    required this.gameState,
    required this.question,
    required this.tierName,
    required this.currentScore,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final nextRankScore = currentScore + 150;
    // 진행도: 현재 점수가 다음 랭크 점수 대비 어디쯤인지 (0.0 ~ 1.0)
    final progress = nextRankScore > 0 ? (currentScore / nextRankScore).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. 점수 + 랭크 영역 ──
          Expanded(child: _buildScoreSection(nextRankScore, progress)),
          const SizedBox(width: 12),
          // ── 2. 하트 + 타임뱅크 칩 ──
          _buildChips(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  점수 + 랭크 + 프로그레스 바
  // ═══════════════════════════════════════════
  Widget _buildScoreSection(int nextRankScore, double progress) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A).withOpacity(0.95),
            const Color(0xFF1E1B4B).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTierGlowColor().withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTierGlowColor().withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: 티어 뱃지 + 점수 ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 티어 뱃지 (글로우 + 아이콘)
              _buildTierBadge(),
              const SizedBox(width: 8),
              // 메인 점수
              Flexible(child: _buildMainScore()),
              const SizedBox(width: 8),
              // 순위
              _buildRankChip(),
            ],
          ),

          const SizedBox(height: 8),

          // ── Row 2: 프로그레스 바 + 다음 랭크 ──
          _buildProgressBar(nextRankScore, progress),
        ],
      ),
    );
  }

  // 티어 뱃지 (작은 아이콘 + 이름)
  Widget _buildTierBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getTierGlowColor().withOpacity(0.3), _getTierGlowColor().withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getTierGlowColor().withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTierIcon(), color: _getTierGlowColor(), size: 14),
          const SizedBox(width: 4),
          Text(
            tierName,
            style: TextStyle(
              fontSize: 10,
              color: _getTierGlowColor(),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 메인 점수 (큰 숫자 + P)
  Widget _buildMainScore() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 점수 숫자
        Text(
          "$currentScore",
          style: TextStyle(
            fontFamily: 'Black Han Sans',
            fontSize: 28,
            color: Colors.white,
            letterSpacing: -1,
            shadows: [
              Shadow(color: _getTierGlowColor().withOpacity(0.6), blurRadius: 12),
              const Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
        const SizedBox(width: 2),
        // P 단위 (작게)
        Text(
          "P",
          style: TextStyle(
            fontFamily: 'Black Han Sans',
            fontSize: 16,
            color: _getTierGlowColor().withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 순위 칩 (#4203)
  Widget _buildRankChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_rounded, color: Colors.white.withOpacity(0.5), size: 12),
          const SizedBox(width: 3),
          Text(
            "#$rank",
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 프로그레스 바 (다음 랭크까지)
  Widget _buildProgressBar(int nextRankScore, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 바 위의 라벨
        Row(
          children: [
            Icon(Icons.trending_up_rounded, color: _getTierGlowColor().withOpacity(0.6), size: 12),
            const SizedBox(width: 4),
            Text(
              "다음 랭크",
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "$nextRankScore P",
              style: TextStyle(
                fontFamily: 'Black Han Sans',
                fontSize: 11,
                color: _getTierGlowColor().withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 실제 프로그레스 바
        Stack(
          children: [
            // 바 배경
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // 바 채움
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_getTierGlowColor().withOpacity(0.8), _getTierGlowColor()],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: _getTierGlowColor().withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  하트 + 타임뱅크 칩
  // ═══════════════════════════════════════════
  Widget _buildChips() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _build3DChip(
          icon: Icons.favorite,
          iconColor: StitchColors.glowRed,
          value: gameState.hearts.toString(),
          glowColor: StitchColors.glowRed,
        ),
        const SizedBox(height: 8),
        _build3DChip(
          icon: Icons.hourglass_top_rounded,
          iconColor: StitchColors.yellow400,
          value: gameState.timeBankCount.toString(),
          glowColor: StitchColors.yellow400,
        ),
      ],
    );
  }

  Widget _build3DChip({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color glowColor,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glowColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 3), blurRadius: 6),
          BoxShadow(color: glowColor.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18, shadows: [
            Shadow(color: glowColor.withOpacity(0.8), blurRadius: 8),
          ]),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(
            fontFamily: 'Black Han Sans', fontSize: 16, color: Colors.white,
          )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  티어별 색상/아이콘 매핑
  // ═══════════════════════════════════════════
  Color _getTierGlowColor() {
    final lower = tierName.toLowerCase();
    if (lower.contains('diamond') || lower.contains('다이아')) return const Color(0xFF67E8F9); // cyan
    if (lower.contains('platinum') || lower.contains('플래티넘')) return const Color(0xFFA78BFA); // violet
    if (lower.contains('gold') || lower.contains('골드')) return const Color(0xFFFCD34D); // gold
    if (lower.contains('silver') || lower.contains('실버')) return const Color(0xFFC0C0C0); // silver
    if (lower.contains('bronze') || lower.contains('브론즈')) return const Color(0xFFCD7F32); // bronze
    return StitchColors.blue400; // default
  }

  IconData _getTierIcon() {
    final lower = tierName.toLowerCase();
    if (lower.contains('diamond') || lower.contains('다이아')) return Icons.diamond_rounded;
    if (lower.contains('platinum') || lower.contains('플래티넘')) return Icons.workspace_premium;
    if (lower.contains('gold') || lower.contains('골드')) return Icons.star_rounded;
    if (lower.contains('silver') || lower.contains('실버')) return Icons.shield_rounded;
    if (lower.contains('bronze') || lower.contains('브론즈')) return Icons.shield_outlined;
    return Icons.military_tech_rounded; // default
  }
}
