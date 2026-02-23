import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/neo_brutalist_button.dart';
import '../../providers/game_providers.dart';
import '../../data/services/league_engine.dart';
import '../../data/models/tier.dart';
import '../../data/services/supabase_service.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/haptic_manager.dart';

class LeagueGameOverScreen extends ConsumerStatefulWidget {
  const LeagueGameOverScreen({super.key});

  @override
  ConsumerState<LeagueGameOverScreen> createState() => _LeagueGameOverScreenState();
}

class _LeagueGameOverScreenState extends ConsumerState<LeagueGameOverScreen> {
  bool _opsExecuted = false;
  int _leagueScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeLeagueOps();
    });
  }

  void _executeLeagueOps() {
    if (_opsExecuted) return;
    _opsExecuted = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final score = args['leagueScore'] as int? ?? 0;
      setState(() {
        _leagueScore = score;
      });
      _joinLeagueAndUpdateScore(score);
    }
  }

  void _joinLeagueAndUpdateScore(int score) {
    Future.microtask(() async {
      if (!SupabaseService.isLoggedIn) return;

      final leagueService = ref.read(leagueServiceProvider);

      // 1. 리그 배정
      final result = await leagueService.joinOrCreateLeague(score);

      // 2. 점수 업데이트
      await leagueService.updateScore(score);

      // 3. 첫 배정 시 팝업 (필요한 경우)
      if (result != null && result.isNew && mounted) {
        final tier = Tier.fromScore(score);
        _showLeaguePlacementDialog(tier);
      }
    });
  }

  void _showLeaguePlacementDialog(Tier tier) {
    // 생략(기존 placement dialog 로직을 좀더 고급스럽게 다듬어 사용)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'League Placement',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 800),
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
                padding: EdgeInsets.all(context.w(32)),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFF331B00), Color(0xFF0F0A00)],
                    radius: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(context.r(24)),
                  border: Border.all(color: AppColors.leaguePromotionGold, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.leaguePromotionGold.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LEAGUE PLACED',
                      style: AppTextStyles.bodySmall(color: Colors.white54).copyWith(letterSpacing: 4.0),
                    ),
                    SizedBox(height: context.w(24)),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: context.w(120), height: context.w(120),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.leaguePromotionGold.withOpacity(0.15),
                            boxShadow: [BoxShadow(color: AppColors.leaguePromotionGold.withOpacity(0.5), blurRadius: 40)],
                          ),
                        ),
                        Text(tier.emoji, style: TextStyle(fontSize: context.sp(72))),
                      ],
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),
                    SizedBox(height: context.w(24)),
                    Text(
                      '${tier.displayName} 리그',
                      style: AppTextStyles.heading(color: AppColors.leaguePromotionGold),
                    ),
                    SizedBox(height: context.w(16)),
                    Text(
                      '이제 전 세계 플레이어들과\n경쟁하세요!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(color: Colors.white70),
                    ),
                    SizedBox(height: context.w(32)),
                    NeoBrutalistButton(
                      label: '토너먼트 입장',
                      isPrimary: true,
                      color: AppColors.leaguePromotionGold,
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

  @override
  Widget build(BuildContext context) {
    final currentTier = Tier.fromScore(_leagueScore);

    return Scaffold(
      backgroundColor: Colors.black, // 베이스를 깊은 검정색으로
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. VIP 카지노 테이블 스포트라이트 배경
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3), // 약간 상단에서 스포트라이트
                  radius: 1.5,
                  colors: [
                    Color(0xFF2A0000), // 극도로 깊은 크림슨/버건디 (테이블)
                    Color(0xFF0A0000),
                    Colors.black,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // 2. 파티클 애니메이션 (먼지 / 카지노 반짝임)
          ...List.generate(15, (index) {
            final random = math.Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
                width: random.nextDouble() * 4 + 2,
                height: random.nextDouble() * 4 + 2,
                decoration: BoxDecoration(
                  color: AppColors.leaguePromotionGold.withOpacity(random.nextDouble() * 0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.leaguePromotionGold, blurRadius: 5),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat())
               .fadeIn(duration: (random.nextInt(1000) + 1000).ms)
               .fadeOut(delay: (random.nextInt(1000) + 500).ms, duration: 1500.ms)
               .moveY(begin: 0, end: -50, duration: 3000.ms),
            );
          }),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.w(24.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 메탈릭 3D 헤더 (TOURNAMENT COMPLETE)
                    _buildMetallicHeader().animate().slideY(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),

                    SizedBox(height: context.h(48)),

                    // 티어 뱃지 및 스코어 보드
                    _buildPremiumScoreBoard(currentTier).animate(delay: 400.ms).scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),

                    SizedBox(height: context.h(60)),

                    // 하단 버튼 영역
                    NeoBrutalistButton(
                      label: '다시 참가하기',
                      isPrimary: true,
                      color: AppColors.leaguePromotionGold,
                      textColor: AppColors.pureBlack,
                      onPressed: () {
                        HapticManager.wrong();
                        SoundManager.play(SoundType.chipStack);
                        ref.read(leagueEngineProvider.notifier).startGame();
                        Navigator.of(context).pushReplacementNamed('/league');
                      },
                    ).animate(delay: 800.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                    SizedBox(height: context.h(20)),

                    TextButton(
                      onPressed: () {
                        HapticManager.swipe();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        '로비로 돌아가기',
                        style: AppTextStyles.body(color: Colors.white60).copyWith(letterSpacing: 1.2),
                      ),
                    ).animate(delay: 1000.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetallicHeader() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)], // 골드 메탈릭
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        'TOURNAMENT\nCOMPLETE',
        textAlign: TextAlign.center,
        style: AppTextStyles.heading(color: Colors.white).copyWith(
          fontSize: context.sp(42),
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 2.0,
          shadows: [
            // 3D 압출 섀도우 (크림슨 톤)
            const Shadow(color: Color(0xFF4A0000), offset: Offset(0, 2)),
            const Shadow(color: Color(0xFF4A0000), offset: Offset(0, 4)),
            const Shadow(color: Color(0xFF330000), offset: Offset(0, 6)),
            const Shadow(color: Color(0xFF220000), offset: Offset(0, 8)),
            // 글로우
            Shadow(color: AppColors.leaguePromotionGold.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumScoreBoard(Tier tier) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.w(32), horizontal: context.w(24)),
      decoration: BoxDecoration(
        color: const Color(0xFF110B08).withOpacity(0.8), // 극도로 다크한 우드/가죽 느낌
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: AppColors.leaguePromotionGold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, spreadRadius: 10, offset: const Offset(0, 15)),
          BoxShadow(color: AppColors.leaguePromotionGold.withOpacity(0.05), blurRadius: 40, spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
           Stack(
            alignment: Alignment.center,
            children: [
              // 글로우 백라이트
              Container(
                width: context.w(100),
                height: context.w(100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.leaguePromotionGold.withOpacity(0.4), blurRadius: 50, spreadRadius: 10),
                  ],
                ),
              ),
              Text(tier.emoji, style: TextStyle(fontSize: context.sp(80), shadows: const [Shadow(color: Colors.black54, offset: Offset(0, 5), blurRadius: 10)])),
            ],
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2000.ms, curve: Curves.easeInOutSine),
          
          SizedBox(height: context.h(24)),
          
          Text(
            'FINAL CHIPS',
            style: AppTextStyles.bodySmall(color: Colors.white54).copyWith(letterSpacing: 3.0),
          ),
          
          SizedBox(height: context.h(8)),
          
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFF5D1), Color(0xFFFFD700), Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              '$_leagueScore',
              style: AppTextStyles.heading(color: Colors.white).copyWith(
                fontSize: context.sp(64),
                fontWeight: FontWeight.w900,
                shadows: [
                   const Shadow(color: Colors.black87, offset: Offset(0, 5), blurRadius: 10),
                ],
              ),
            ),
          ),
          
          SizedBox(height: context.h(16)),

          // 셔플링 애니메이션 디테일 (업데이트 암시)
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(8)),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: context.w(16),
                  height: context.w(16),
                  child: const CircularProgressIndicator(color: AppColors.leaguePromotionGold, strokeWidth: 2),
                ),
                SizedBox(width: context.w(12)),
                Text(
                  'Updating League Standings...',
                  style: AppTextStyles.caption(color: AppColors.leaguePromotionGold.withOpacity(0.8)),
                ),
              ],
            ),
          ).animate(delay: 1500.ms).fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}
