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
    // Mock Ghost Score: Just a bit higher than current to motivate
    final ghostScore = currentScore + 150; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. League Rank & Ghost Score Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ghost (Next Target)
                Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: Colors.white.withOpacity(0.3), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "$ghostScore PT",
                      style: TextStyle(
                        fontFamily: 'Black Han Sans',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Next Rank",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.3, end: 0.6, duration: 2.seconds),

                const SizedBox(height: 4),

                // Current Score & Rank
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StitchColors.blue500.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: StitchColors.blue500.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rank Icon/Text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: StitchColors.blue600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tierName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Score
                      Text(
                        "$currentScore PT",
                        style: const TextStyle(
                          fontFamily: 'Black Han Sans',
                          fontSize: 22,
                          color: Colors.white,
                          shadows: [Shadow(color: StitchColors.blue500, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rank Text
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Text(
                    "현재 순위 #$rank",
                    style: TextStyle(
                      color: StitchColors.blue200.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
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
