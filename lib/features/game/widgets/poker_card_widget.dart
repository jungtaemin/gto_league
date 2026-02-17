import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/card_question.dart';
import '../../../data/models/poker_hand.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';

class PokerCardWidget extends StatelessWidget {
  final CardQuestion question;

  const PokerCardWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final pokerHand = PokerHand.fromNotation(question.hand);
    final isDefense = question.chartType == 'CALL';
    
    // Determine position color for theming
    final positionColor = _getPositionColor(question.position);

    // Generate visual suits
    final suits = _generateSuits(pokerHand);
    final suit1 = suits[0];
    final suit2 = suits[1];

    return Animate(
      effects: [
        FadeEffect(duration: 350.ms),
        ScaleEffect(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pureBlack, width: 4),
          boxShadow: [
            ...AppShadows.layeredShadow,
            ...AppColors.neonGlow(positionColor, intensity: 0.4),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // Inner radius to match border
          child: Stack(
            children: [
              // 1. Inner Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. CRT Texture Overlay
              Positioned.fill(
                child: Container(color: AppColors.crtOverlay),
              ),

              // 3. Main Content
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section: Position Badges
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPositionBadge(question.position),
                        if (isDefense) _buildDefenseBadge(),
                      ],
                    ),
                  ),

                  // Center Section: Hand Display
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Huge Hand Notation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCardText(pokerHand.rank1, suit1),
                              const SizedBox(width: 12),
                              _buildCardText(pokerHand.rank2, suit2),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Korean Display Name
                          NeonText(
                            pokerHand.displayName,
                            style: AppTextStyles.heading(),
                            fontSize: 24,
                            glowIntensity: 0.4,
                            color: AppColors.pureWhite,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section: Stack Size (BB)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      gradient: AppColors.bananaGradient,
                      border: Border(
                        top: BorderSide(color: AppColors.pureBlack, width: 3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Poker Chip Icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.pureBlack, width: 2),
                            boxShadow: AppShadows.hardShadowTiny,
                          ),
                          child: const Center(
                            child: Icon(Icons.circle, color: AppColors.acidYellow, size: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${question.stackBb.toStringAsFixed(0)} BB',
                          style: AppTextStyles.button(color: AppColors.pureBlack).copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 4. Defense Alert Banner
              if (isDefense && question.opponentPosition != null)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Animate(
                    effects: [
                      ShimmerEffect(duration: 800.ms),
                      ShakeEffect(hz: 2, offset: const Offset(1.5, 0), duration: 600.ms),
                    ],
                    onPlay: (c) => c.repeat(reverse: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.laserRed,
                        boxShadow: AppColors.neonGlow(AppColors.laserRed, intensity: 0.4),
                      ),
                      child: Text(
                        '🚨 ${question.opponentPosition} 올인! 방어하라!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingSmall(color: AppColors.pureWhite),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(String position) {
    if (['BTN', 'SB', 'CO'].contains(position)) {
      return AppColors.acidGreen;
    } else if (['UTG', 'UTG+1', 'UTG+2'].contains(position)) {
      return AppColors.laserRed;
    } else {
      return AppColors.electricBlue;
    }
  }

  Widget _buildPositionBadge(String position) {
    final color = _getPositionColor(position);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pureBlack, width: 3),
        boxShadow: [
          ...AppShadows.neonHardShadow(color),
          ...AppColors.neonGlow(color, intensity: 0.3),
        ],
      ),
      child: Text(
        position,
        style: AppTextStyles.button(color: AppColors.pureBlack),
      ),
    );
  }

  Widget _buildDefenseBadge() {
    return Animate(
      onPlay: (c) => c.repeat(reverse: true),
      effects: [
        ScaleEffect(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 800.ms),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pureBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.laserRed, width: 2),
          boxShadow: AppColors.neonGlow(AppColors.laserRed, intensity: 0.3),
        ),
        child: const NeonText(
          '🛡️ DEFENSE',
          color: AppColors.laserRed,
          fontSize: 12,
          glowIntensity: 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardText(String rank, String suit) {
    final isRed = suit == '♥' || suit == '♦';
    final suitColor = isRed ? AppColors.neonPink : AppColors.neonCyan;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        NeonText(
          rank,
          fontSize: 72,
          color: AppColors.pureWhite,
          strokeWidth: 2.5,
          glowIntensity: 0.9,
          style: AppTextStyles.display(),
        ),
        const SizedBox(width: 4),
        NeonText(
          suit,
          fontSize: 72,
          color: suitColor,
          animated: true,
          glowIntensity: 0.9,
          style: AppTextStyles.display(),
        ),
      ],
    );
  }

  List<String> _generateSuits(PokerHand hand) {
    final suits = ['♠', '♣', '♥', '♦'];
    final random = Random();
    
    if (hand.isSuited) {
      final suit = suits[random.nextInt(suits.length)];
      return [suit, suit];
    } else {
      // Pair or Offsuit (logic is same: two different suits)
      final suit1 = suits[random.nextInt(suits.length)];
      var suit2 = suits[random.nextInt(suits.length)];
      while (suit1 == suit2) {
        suit2 = suits[random.nextInt(suits.length)];
      }
      return [suit1, suit2];
    }
  }
}
