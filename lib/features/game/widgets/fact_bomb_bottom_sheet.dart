import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';
import '../../../core/widgets/neo_brutalist_button.dart';

class FactBombBottomSheet extends StatelessWidget {
  final String factBombMessage;
  final String position;
  final String hand;
  final double evBb;
  final VoidCallback onDismiss;

  const FactBombBottomSheet({
    super.key,
    required this.factBombMessage,
    required this.position,
    required this.hand,
    required this.evBb,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isChicken = factBombMessage.contains("쫄보");
    final emoji = isChicken ? "🐔" : "🚨";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.acidYellow, width: 3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          ...AppColors.neonGlow(AppColors.acidYellow, intensity: 0.3),
          ...AppShadows.neonHardShadow(AppColors.acidYellow),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 60),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const NeonText(
            "FACT BOMB!",
            color: AppColors.neonPink,
            fontSize: 32,
            strokeWidth: 2.5,
            glowIntensity: 1.2,
            fontWeight: FontWeight.w900,
          ).animate().fadeIn().slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            factBombMessage,
            style: AppTextStyles.factBomb(color: AppColors.pureWhite),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.innerGlow(AppColors.electricBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoItem(position, AppColors.neonCyan),
                _buildSeparator(),
                _buildInfoItem(hand, AppColors.acidGreen),
                _buildSeparator(),
                _buildInfoItem(
                  "${evBb >= 0 ? '+' : ''}${evBb.toStringAsFixed(1)} BB",
                  evBb >= 0 ? AppColors.acidGreen : AppColors.laserRed,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          NeoBrutalistButton(
            label: "확인",
            isPrimary: true,
            color: AppColors.acidYellow,
            textColor: AppColors.deepBlack,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, Color color) {
    return NeonText(
      text,
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      glowIntensity: 0.8,
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        "|",
        style: TextStyle(
          color: AppColors.darkGray.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Future<void> showFactBombModal(
  BuildContext context, {
  required String factBombMessage,
  required String position,
  required String hand,
  required double evBb,
  required VoidCallback onDismiss,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => FactBombBottomSheet(
      factBombMessage: factBombMessage,
      position: position,
      hand: hand,
      evBb: evBb,
      onDismiss: onDismiss,
    ),
  ).then((_) => onDismiss());
}
