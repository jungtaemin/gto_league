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
import '../../core/utils/responsive.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  @override
  void initState() {
    super.initState();
  }

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
  Widget build(BuildContext context) {
    final gameState = ref.read(gameStateProvider);
    final displayScore = gameState.score;
    final tierColor = _getTierColor(gameState.currentTier);

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
                        '$displayScore',
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
                       _buildStatItem('Best Combo', '${gameState.combo}', delay: 300),
                       _buildStatItem('Correct %', '-', delay: 350),
                       _buildStatItem('Total', '-', delay: 400),
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
                  // Ad refill — always show for training mode
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

  Widget _buildStatItem(String label, String value, {required int delay}) {
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
}

