import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'stitch_colors.dart';

class GtoBattleTimerBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int secondsLeft;

  const GtoBattleTimerBar({
    super.key,
    required this.progress,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("남은 시간", style: TextStyle(color: StitchColors.blue200, fontSize: 12, fontWeight: FontWeight.bold)),
              Text("${secondsLeft}s", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          
          // Progress Bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Gradient Fill
                    Container(
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            StitchColors.green400,
                            StitchColors.yellow400,
                            StitchColors.glowRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
