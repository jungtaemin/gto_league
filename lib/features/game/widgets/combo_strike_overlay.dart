import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ComboStrikeOverlay extends StatelessWidget {
  final bool isVisible;
  final int combo;
  final int earnedPoints;
  final bool isFever;
  final bool isSnap;

  const ComboStrikeOverlay({
    super.key,
    required this.isVisible,
    required this.combo,
    required this.earnedPoints,
    this.isFever = false,
    this.isSnap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    if (combo <= 1 && earnedPoints <= 0) return const SizedBox.shrink(); // Prevent showing if nothing to show

    // Choose base color depending on state
    Color mainColor = const Color(0xFF67E8F9); // Cyan base

    if (isFever) {
      mainColor = const Color(0xFFE879F9); // Pink/Purple for Fever
    } else if (combo >= 10) {
      mainColor = const Color(0xFFEC4899); // Deep Pink for huge combos
    } else if (combo >= 5 || isSnap) {
      mainColor = const Color(0xFFFBBF24); // Gold for medium/snap
    }

    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Combo Text (Only show if combo > 1 to avoid clutter on first hit)
            if (combo > 1)
              Transform.rotate(
                angle: -0.1, // tilt slightly upward
                child: Text(
                  isFever ? 'FEVER x$combo!' : 'COMBO x$combo!',
                  style: TextStyle(
                    fontFamily: 'Black Han Sans',
                    fontSize: isFever ? 64 : (combo >= 10 ? 56 : 48),
                    height: 1.0,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: mainColor, blurRadius: 20),
                      Shadow(color: mainColor.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10)),
                      const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ).animate()
                .scale(begin: const Offset(0.2, 0.2), duration: 300.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 100.ms)
                .shake(hz: 8, rotation: 0.1, duration: 300.ms)
                .slideY(begin: 0.2, end: -0.2, duration: 400.ms, curve: Curves.easeOutBack)
                .fadeOut(duration: 200.ms, delay: 500.ms),

            const SizedBox(height: 10),

            // Points Text
            if (earnedPoints > 0)
              Transform.rotate(
                angle: 0.05,
                child: Text(
                  '+$earnedPoints',
                  style: TextStyle(
                    fontFamily: 'Black Han Sans',
                    fontSize: 40,
                    height: 1.0,
                    color: mainColor,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 10),
                      const Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 4)),
                    ],
                  ),
                ),
              ).animate()
                .scale(begin: const Offset(0.5, 0.5), duration: 250.ms, delay: 100.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 100.ms, delay: 100.ms)
                .slideY(begin: 0.5, end: -0.5, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutQuad)
                .fadeOut(duration: 200.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
