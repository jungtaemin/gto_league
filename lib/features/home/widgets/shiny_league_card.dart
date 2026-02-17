import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/tier.dart';

class ShinyLeagueCard extends StatelessWidget {
  final Tier tier;
  final int score;

  const ShinyLeagueCard({super.key, required this.tier, required this.score});

  @override
  Widget build(BuildContext context) {
    // Metal Gradient based on Tier
    final gradientColors = _getMetalGradient(tier);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Shine Effect
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradientColors.last.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Left: 3D Emblem
                  _buildEmblem(tier, gradientColors),
                  const SizedBox(width: 20),
                  
                  // Right: Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CURRENT SEASON",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            tier.displayName,
                            style: const TextStyle(
                              color: Colors.white, // Masked
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar
                        _buildProgressBar(score, tier.maxScore, gradientColors.first),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$score PT",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Ranked #4,203",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildEmblem(Tier tier, List<Color> colors) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.first,
            colors.last,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
      ),
      child: Center(
        child: Text(
          tier.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms);
  }

  Widget _buildProgressBar(int current, int max, Color activeColor) {
    final progress = (current / max).clamp(0.0, 1.0);
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.8),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getMetalGradient(Tier tier) {
    switch (tier) {
      case Tier.fish:
      case Tier.donkey:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
      case Tier.callingStation:
      case Tier.pubReg:
        return [const Color(0xFFE0E0E0), const Color(0xFF9E9E9E)]; // Silver
      case Tier.grinder:
      case Tier.shark:
        return [const Color(0xFFFFD700), const Color(0xFFFFA000)]; // Gold
      case Tier.gtoMachine:
        return [const Color(0xFF00E5FF), const Color(0xFF2979FF)]; // Diamond/Platinum
    }
  }
}
