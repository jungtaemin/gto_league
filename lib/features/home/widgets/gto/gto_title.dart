import 'package:flutter/material.dart';

/// Stitch V1 Title: GTO dark 3D text + LEAGUE yellow stroke + subtitle pill
class GtoTitle extends StatelessWidget {
  const GtoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. GTO text with 3D shadow effect
        Stack(
          children: [
            // Shadow layer (ghost)
            Transform.translate(
              offset: const Offset(0, -1),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E3A8A), Color(0xFF000000)],
                ).createShader(bounds),
                child: Text("GTO", style: TextStyle(
                  fontSize: 48, fontFamily: 'Jua', fontWeight: FontWeight.w900,
                  letterSpacing: -2, color: Colors.white.withOpacity(0.6),
                )),
              ),
            ),
            // Main text (dark navy)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("GTO", style: TextStyle(
                fontSize: 48, fontFamily: 'Jua', fontWeight: FontWeight.w900,
                letterSpacing: -2,
                color: const Color(0xFF0F172A),
                shadows: [
                  // Stitch: 0px 2px 0px #1e3a8a, 0px 4px 0px #172554, 0px 6px 10px rgba(0,0,0,0.5)
                  const Shadow(offset: Offset(0, 2), color: Color(0xFF1E3A8A)),
                  const Shadow(offset: Offset(0, 4), color: Color(0xFF172554)),
                  Shadow(offset: const Offset(0, 6), blurRadius: 10, color: Colors.black.withOpacity(0.5)),
                  // White inset highlight
                  Shadow(offset: const Offset(0, 2), color: Colors.white.withOpacity(0.2)),
                ],
              )),
            ),
          ],
        ),

        // 2. LEAGUE text (yellow stroke style)
        Transform.translate(
          offset: const Offset(0, -8),
          child: Text("LEAGUE", style: TextStyle(
            fontSize: 32, fontFamily: 'Jua', fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 15),
            ],
          )),
        ),

        // 3. Subtitle pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.5), blurRadius: 15),
            ],
          ),
          child: const Text("홀덤 푸시폴드 배틀", style: TextStyle(
            color: Color(0xFFDBEAFE), fontSize: 14,
            fontFamily: 'Jua', fontWeight: FontWeight.bold, letterSpacing: 1.5,
          )),
        ),
      ],
    );
  }
}
