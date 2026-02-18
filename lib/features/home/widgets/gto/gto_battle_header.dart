import 'package:flutter/material.dart';
import '../../../../data/models/card_question.dart';
import '../../../../data/models/game_state.dart';
import 'stitch_colors.dart';

class GtoBattleHeader extends StatelessWidget {
  final GameState gameState;
  final CardQuestion question;

  const GtoBattleHeader({
    super.key,
    required this.gameState,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Position Badge (Glassmorphism)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StitchColors.blue400.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: StitchColors.blue500.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Position Icon
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: Stack(
                      children: [
                        // Table representation
                        Center(
                          child: Container(
                            width: 20, height: 12,
                            decoration: BoxDecoration(
                              color: StitchColors.green500, // green-700
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: StitchColors.green400),
                            ),
                          ),
                        ),
                        // Seat indicator (Top Right)
                        Positioned(
                          top: 0, right: 4,
                          child: Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: StitchColors.yellow400,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: StitchColors.yellow400, blurRadius: 5)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("현재 포지션", style: TextStyle(
                        color: StitchColors.blue200, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5
                      )),
                      Text(question.position, style: const TextStyle(
                        fontFamily: 'Black Han Sans', fontSize: 20, color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))],
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),

          // 2. Score Chips (Hearts & Time)
          Row(
            children: [
              _build3DChip(
                icon: Icons.favorite,
                iconColor: StitchColors.glowRed,
                value: gameState.hearts.toString(),
                glowColor: StitchColors.glowRed,
              ),
              const SizedBox(width: 8),
              _build3DChip(
                icon: Icons.hourglass_top_rounded,
                iconColor: StitchColors.yellow400,
                value: gameState.timeBankCount.toString(),
                glowColor: StitchColors.yellow400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DChip({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color glowColor,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[600]!),
        boxShadow: [
          // 3D effect shadow
          BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20, shadows: [Shadow(color: glowColor.withOpacity(0.8), blurRadius: 8)]),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(
            fontFamily: 'Black Han Sans', fontSize: 18, color: Colors.white,
          )),
        ],
      ),
    );
  }
}
