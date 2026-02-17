import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';

class ComboCounterWidget extends StatelessWidget {
  final int combo;
  final bool isFeverMode;

  const ComboCounterWidget({
    super.key,
    required this.combo,
    required this.isFeverMode,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == 0) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: _buildComboContent(context),
    );
  }

  Widget _buildComboContent(BuildContext context) {
    if (isFeverMode) {
      return _buildFeverBadge();
    } else if (combo >= 10) {
      return _buildHighComboBadge();
    } else if (combo >= 5) {
      return _buildMediumComboBadge();
    } else {
      return _buildSmallComboBadge();
    }
  }

  Widget _buildSmallComboBadge() {
    return Container(
      key: const ValueKey('small'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pureBlack, width: 2),
        boxShadow: [
          ...AppShadows.hardShadowTiny,
          ...AppShadows.innerGlow(AppColors.acidYellow),
        ],
      ),
      child: NeonText(
        '🔥 x$combo',
        color: AppColors.pureWhite,
        fontSize: 14,
        glowIntensity: 0.4,
      ),
    );
  }

  Widget _buildMediumComboBadge() {
    return Container(
      key: const ValueKey('medium'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.acidYellow, width: 2),
        boxShadow: [
          ...AppShadows.neonHardShadow(AppColors.acidYellow),
          ...AppColors.neonGlow(AppColors.acidYellow, intensity: 0.4),
        ],
      ),
      child: NeonText(
        '🔥 x$combo',
        color: AppColors.acidYellow,
        fontSize: 18,
        glowIntensity: 0.8,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 500.ms);
  }

  Widget _buildHighComboBadge() {
    return Container(
      key: const ValueKey('high'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pureBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonPink, width: 3),
        boxShadow: [
          ...AppShadows.layeredShadow,
          ...AppColors.neonGlow(AppColors.neonPink, intensity: 0.6),
        ],
      ),
      child: NeonText(
        '🔥 x$combo',
        color: AppColors.neonPink,
        fontSize: 22,
        glowIntensity: 1.2,
        strokeWidth: 1.5,
        animated: true,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 300.ms);
  }

  Widget _buildFeverBadge() {
    return Container(
      key: const ValueKey('fever'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.neonGradient(AppColors.neonPurple, AppColors.neonPink),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.acidYellow, width: 3),
        boxShadow: [
          ...AppColors.neonGlow(AppColors.neonPurple, intensity: 0.6),
          ...AppColors.neonGlow(AppColors.neonPink, intensity: 0.4),
        ],
      ),
      child: Stack(
        children: [
          // CRT Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.crtOverlay,
                borderRadius: BorderRadius.circular(27),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NeonText(
                '🎰 FEVER!',
                color: AppColors.acidYellow,
                fontSize: 20,
                glowIntensity: 1.5,
                strokeWidth: 2.0,
              ),
              NeonText(
                'x$combo',
                color: AppColors.pureWhite,
                fontSize: 18,
                glowIntensity: 1.0,
              ),
            ],
          ),
        ],
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .shimmer(duration: 800.ms, color: AppColors.acidYellow.withOpacity(0.4))
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms);
  }
}
