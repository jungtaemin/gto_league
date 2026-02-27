import 'package:flutter/material.dart';
import '../../../../core/utils/music_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import 'gto_bottom_nav.dart';
import 'stitch_colors.dart';

/// Training tab body — Deep Run entry point
class GtoTrainBody extends StatelessWidget {
  const GtoTrainBody({super.key});

  @override
  Widget build(BuildContext context) {
    final navBottomPadding =
        context.w(GtoBottomNav.designHeight) +
        context.bottomSafePadding +
        context.w(20);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Column(
        children: [
          SizedBox(height: context.w(24)),

          // Title
          Text(
            '학습 모드',
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: context.sp(32),
              color: AppColors.pureWhite,
              letterSpacing: 1.0,
              shadows: const [
                Shadow(
                  color: AppColors.deepBlack,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ),

          SizedBox(height: context.w(8)),

          Text(
            'GTO 실력을 단련하세요',
            style: TextStyle(
              color: StitchColors.blue300,
              fontSize: context.sp(13),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: context.w(32)),

          // Deep Run Card
          _DeepRunEntryCard(),

          const Spacer(),

          // Bottom spacing for nav
          SizedBox(height: navBottomPadding),
        ],
      ),
    );
  }
}

class _DeepRunEntryCard extends StatefulWidget {
  @override
  State<_DeepRunEntryCard> createState() => _DeepRunEntryCardState();
}

class _DeepRunEntryCardState extends State<_DeepRunEntryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.pushNamed(context, '/deep-run').then((_) {
          MusicManager.ensurePlaying(MusicType.lobby);
        });
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.w(20)),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A1A),
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(
              color: AppColors.neonCyan.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: AppColors.deepBlack,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Icon
                  Container(
                    width: context.w(48),
                    height: context.w(48),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(context.r(12)),
                      border: Border.all(
                        color: AppColors.neonCyan.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.neonCyan,
                      size: context.w(28),
                    ),
                  ),

                  SizedBox(width: context.w(12)),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '50-HAND DEEP RUN',
                          style: TextStyle(
                            fontFamily: 'Black Han Sans',
                            fontSize: context.sp(20),
                            color: AppColors.neonCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: context.w(2)),
                        Text(
                          '서바이벌 GTO 트레이닝',
                          style: TextStyle(
                            color: StitchColors.blue300,
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.neonCyan.withOpacity(0.6),
                    size: context.w(20),
                  ),
                ],
              ),

              SizedBox(height: context.w(16)),

              // Description
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.w(12)),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(context, '🎯', '5단계 × 10핸드 = 50핸드 서바이벌'),
                    SizedBox(height: context.w(6)),
                    _buildInfoRow(context, '❤️', '3개의 생명 — 모두 잃으면 게임 오버'),
                    SizedBox(height: context.w(6)),
                    _buildInfoRow(context, '📈', '15BB → 12BB → 10BB → 7BB → 5BB'),
                    SizedBox(height: context.w(6)),
                    _buildInfoRow(context, '🏆', '실전 GTO 데이터 108,160 시나리오'),
                  ],
                ),
              ),

              SizedBox(height: context.w(16)),

              // CTA bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: context.w(12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonCyan.withOpacity(0.2),
                      AppColors.electricBlue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(context.r(10)),
                  border: Border.all(
                    color: AppColors.neonCyan.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '도전하기',
                    style: TextStyle(
                      fontFamily: 'Black Han Sans',
                      fontSize: context.sp(18),
                      color: AppColors.neonCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, duration: 500.ms),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: context.sp(14))),
        SizedBox(width: context.w(8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.pureWhite.withOpacity(0.8),
              fontSize: context.sp(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}