import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LobbyTopBar extends StatelessWidget {
  const LobbyTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width to adjust layout responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. League Capsule (Fixed Width - Left)
          SizedBox(
            width: 120,
            child: _build3DCapsule(
              icon: Icons.shield_rounded,
              iconColor: const Color(0xFFCD7F32), // Bronze
              content: const Text(
                "LEAGUE 1",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Jua', // Rounded Font
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Gold Capsule (Flexible - Center)
          Expanded(
            child: _build3DCapsule(
              icon: Icons.monetization_on_rounded, // Poker Chip
              iconColor: AppColors.acidYellow, 
              centerContent: true,
              content: FittedBox(
                fit: BoxFit.scaleDown,
                child: GradientText(
                  "1,254,000",
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAB00)], // Gold Gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontFamily: 'Jua',
                    shadows: [
                       Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1,1))
                    ]
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Energy + Settings Capsule (Fixed Width - Right)
          SizedBox(
            width: 120,
            child: _build3DCapsule(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.neonCyan,
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "30/30",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Jua',
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.settings, color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCapsule({
    required IconData icon,
    required Color iconColor,
    required Widget content,
    bool centerContent = false,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30), // Dark base
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF3F3D56), // Darker border
          width: 2,
        ),
        boxShadow: [
          // Deep Drop Shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 6),
            blurRadius: 8,
          ),
          // Subtle top highlight (simulated inner glow)
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2A40),
            Color(0xFF151520),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          // Icon with Glow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(color: iconColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1), 
              ]
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          
          if (!centerContent) const SizedBox(width: 8),
          if (centerContent) const SizedBox(width: 8),
          
          Expanded(child: content),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(this.text, {super.key, required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
