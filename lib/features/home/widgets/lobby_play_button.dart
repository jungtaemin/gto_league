import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class LobbyPlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  const LobbyPlayButton({super.key, required this.onPressed});

  @override
  State<LobbyPlayButton> createState() => _LobbyPlayButtonState();
}

class _LobbyPlayButtonState extends State<LobbyPlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 160, // Room for speech bubble + button + shadow
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Ground Shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),

          // 2. Main 3D Button
          Positioned(
            bottom: 10,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onPressed();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutQuad,
                child: Container(
                  width: 260,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFEA00), // Vivid Yellow
                        Color(0xFFFFAB00), // Deep Orange-Yellow
                      ],
                    ),
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(
                      color: const Color(0xFFFF6D00), // Thick Dark Orange Border
                      width: 6,
                    ),
                    boxShadow: [
                      // 3D Extrusion effect
                      const BoxShadow(
                        color: Color(0xFFE65100),
                        offset: Offset(0, 8),
                        blurRadius: 0,
                      ),
                      // Soft ambient shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 14),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play Icon in Circle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.acidYellow,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text
                      const Text(
                        "BATTLE START",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723), // Dark Brown
                          letterSpacing: 1.0,
                          fontFamily: 'Jua',
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(0, 1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.03, 1.03),
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                )
                .shimmer(
                  delay: 2000.ms,
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),

          // 3. Speech Bubble (Floating above)
          Positioned(
            top: 0,
            right: 0,
            child: _buildSpeechBubble()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 1200.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neonPurple, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Text(
            "Test your strategy!",
            style: TextStyle(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'Jua',
            ),
          ),
        ),
        // Triangle Arrow
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: 14,
            height: 8,
            color: AppColors.neonPurple,
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
