import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/neon_text.dart';
import '../../core/widgets/neo_brutalist_button.dart';
import '../../providers/game_state_notifier.dart';
import '../../providers/game_providers.dart';
import '../../data/models/tier.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/supabase_service.dart';
import '../../core/utils/responsive.dart';

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  Color _getTierColor(Tier tier) {
    switch (tier) {
      case Tier.fish:
        return AppColors.neonCyan;
      case Tier.donkey:
        return AppColors.acidYellow;
      case Tier.callingStation:
        return AppColors.acidGreen;
      case Tier.pubReg:
        return AppColors.neonPink;
      case Tier.grinder:
        return AppColors.electricBlue;
      case Tier.shark:
        return AppColors.neonPurple;
      case Tier.gtoMachine:
        return AppColors.laserRed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final tierColor = _getTierColor(gameState.currentTier);

    // ── 리그 배정 + 점수 업데이트 (1회만 실행) ──
    _joinLeagueAndUpdateScore(context, ref, gameState.score);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [AppColors.darkPurple, AppColors.deepBlack],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.w(24.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  NeonText(
                    'GAME OVER',
                    color: AppColors.laserRed,
                    fontSize: context.sp(48),
                    strokeWidth: 3,
                    glowIntensity: 1.0,
                    fontWeight: FontWeight.w900,
                  ).animate().slideY(begin: -0.5, end: 0, duration: 600.ms, curve: Curves.elasticOut).fadeIn(),

                  SizedBox(height: context.h(32)),

                  // Score Section
                  Column(
                    children: [
                      Text(
                        'FINAL SCORE',
                        style: AppTextStyles.caption(color: AppColors.pureWhite.withOpacity(0.7)),
                      ),
                      SizedBox(height: context.h(8)),
                      NeonText(
                        '${gameState.score}',
                        color: AppColors.acidYellow,
                        fontSize: context.sp(64),
                        strokeWidth: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ).animate(delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),

                  SizedBox(height: context.h(24)),

                  // Tier Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(12)),
                    decoration: BoxDecoration(
                      color: AppColors.pureBlack.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(context.r(16)),
                      border: Border.all(color: tierColor.withOpacity(0.5), width: context.w(2)),
                      boxShadow: AppColors.neonGlow(tierColor, intensity: 0.3),
                    ),
                    child: Column(
                      children: [
                        Text(gameState.currentTier.emoji, style: TextStyle(fontSize: context.sp(32))),
                        SizedBox(height: context.h(4)),
                        NeonText(
                          gameState.currentTier.displayName,
                          color: tierColor,
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w600,
                          glowIntensity: 0.8,
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                  SizedBox(height: context.h(40)),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, 'Best Combo', '${gameState.combo}', delay: 300),
                      _buildStatItem(context, 'Correct %', '-', delay: 350),
                      _buildStatItem(context, 'Total', '-', delay: 400),
                    ],
                  ),

                  SizedBox(height: context.h(40)),

                  // Buttons
                  NeoBrutalistButton(
                    label: '다시 하기',
                    isPrimary: true,
                    color: AppColors.acidYellow,
                    textColor: AppColors.pureBlack,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).reset();
                      Navigator.of(context).pushReplacementNamed('/game');
                    },
                  ).animate(delay: 500.ms).slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                  SizedBox(height: context.h(16)),

                  NeoBrutalistButton(
                    label: '♥️ 하트 충전 (광고)',
                    color: AppColors.neonPink,
                    textColor: AppColors.pureWhite,
                    onPressed: () {
                      final adService = ref.read(adServiceProvider);
                      adService.showRewardedAd(
                        rewardType: AdRewardType.heartRefill,
                        onRewardEarned: () {
                          ref.read(gameStateProvider.notifier).refillHearts();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacementNamed('/game');
                          }
                        },
                        onAdDismissed: () {
                          adService.loadRewardedAd();
                        },
                        onAdNotReady: () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('광고 준비 중... 잠시 후 다시 시도해주세요!'),
                                backgroundColor: AppColors.darkGray,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ).animate(delay: 600.ms).slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                  SizedBox(height: context.h(24)),

                  TextButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).reset();
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Text(
                      '🏠 홈으로',
                      style: AppTextStyles.bodySmall(color: AppColors.pureWhite.withOpacity(0.7)),
                    ),
                  ).animate(delay: 700.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, {required int delay}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption(color: AppColors.pureWhite.withOpacity(0.5)),
        ),
        SizedBox(height: context.h(4)),
        Text(
          value,
          style: AppTextStyles.bodySmall(color: AppColors.pureWhite),
        ),
      ],
    ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }

  // ── 리그 배정 + 점수 업데이트 ──
  static bool _leagueJoined = false;
  
  void _joinLeagueAndUpdateScore(BuildContext context, WidgetRef ref, int score) {
    if (_leagueJoined) return;
    _leagueJoined = true;
    
    Future.microtask(() async {
      if (!SupabaseService.isLoggedIn) return;
      
      final leagueService = ref.read(leagueServiceProvider);
      
      // 1. 리그 배정 (이미 배정되어 있으면 기존 그룹 반환)
      final groupId = await leagueService.joinOrCreateLeague(score);
      
      // 2. 점수 업데이트
      await leagueService.updateScore(score);
      
      // 3. 첫 배정 시 안내 (화려한 팝업)
      if (groupId != null && context.mounted) {
        final tier = Tier.fromScore(score);
        _showLeaguePlacementDialog(context, tier);
      }
    });
  }

  void _showLeaguePlacementDialog(BuildContext context, Tier tier) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'League Placement',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) => const SizedBox(), 
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(context.w(24)),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.r(24)),
                  border: Border.all(color: AppColors.acidYellow, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.acidYellow.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LEAGUE PLACEMENT',
                      style: AppTextStyles.bodySmall(color: Colors.white54).copyWith(letterSpacing: 2.0),
                    ),
                    SizedBox(height: context.w(16)),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: context.w(100), height: context.w(100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.acidYellow.withOpacity(0.2),
                            boxShadow: [BoxShadow(color: AppColors.acidYellow.withOpacity(0.4), blurRadius: 30)],
                          ),
                        ),
                        Text(tier.emoji, style: TextStyle(fontSize: context.sp(64))),
                      ],
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
                    SizedBox(height: context.w(16)),
                    Text(
                      '${tier.displayName} 리그',
                      style: AppTextStyles.headingSmall(color: AppColors.acidYellow),
                    ),
                    SizedBox(height: context.w(8)),
                    Text(
                      '배치가 완료되었습니다!',
                      style: AppTextStyles.body(color: Colors.white),
                    ),
                    SizedBox(height: context.w(24)),
                    NeoBrutalistButton(
                      label: '확인',
                      isPrimary: true,
                      color: AppColors.acidYellow,
                      textColor: AppColors.pureBlack,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

