import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class JuicyBattleButton extends StatefulWidget {
  final VoidCallback onPressed;
  const JuicyBattleButton({super.key, required this.onPressed});

  @override
  State<JuicyBattleButton> createState() => _JuicyBattleButtonState();
}

class _JuicyBattleButtonState extends State<JuicyBattleButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Animation scale
    final scale = _isPressed ? 0.95 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        child: Container(
          width: 260,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD700), // Gold
                Color(0xFFFF8F00), // Dark Orange/Gold
              ],
            ),
            boxShadow: [
              // Bottom Bevel (Depth)
              const BoxShadow(
                color: Color(0xFFB75C00),
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
              // Drop Shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 12),
                blurRadius: 20,
              ),
              // Inner Glow (Top Highlight)
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: const Offset(0, 2),
                blurRadius: 2,
                spreadRadius: -1,
              ) // This needs to be Inset, but Flutter BoxShadow doesn't support inset easily without external package.
                 // We simulate it with gradient or inner container.
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shine Effect Overlay
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                height: 45,
                 child: Container(
                   decoration: BoxDecoration(
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                     gradient: LinearGradient(
                       begin: Alignment.topCenter,
                       end: Alignment.bottomCenter,
                       colors: [
                         Colors.white.withOpacity(0.4),
                         Colors.white.withOpacity(0.0),
                       ],
                     ),
                   ),
                 ),
              ),
              
              // Text Content
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFF5D2E00), size: 32), // Custom icon if available
                  const SizedBox(width: 12),
                  Text(
                    "BATTLE",
                    style: TextStyle(
                      fontFamily: 'Impact', // Or thick font
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5D2E00), // Dark Brown Text on Gold
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 0,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 1000.ms) // Breathing
    .then()
    .shimmer(duration: 1500.ms, delay: 2000.ms, color: Colors.white.withOpacity(0.6)); // Occasional shine
  }
}
