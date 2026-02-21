import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math' as math;

/// A high-quality character display widget using Flutter's rendering capabilities.
/// Renders GTO Robot (Sci-Fi) or Ninja Girl (Cyberpunk) without image assets.
class CharacterDisplayWidget extends StatefulWidget {
  final String characterId;
  final double size;
  final bool isLocked;

  const CharacterDisplayWidget({
    super.key,
    required this.characterId,
    this.size = 200,
    this.isLocked = false,
  });

  @override
  State<CharacterDisplayWidget> createState() => _CharacterDisplayWidgetState();
}

class _CharacterDisplayWidgetState extends State<CharacterDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: _buildCharacterContent(),
            ),
            Icon(Icons.lock, size: widget.size * 0.4, color: Colors.white54),
          ],
        ),
      );
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildCharacterContent(),
    );
  }

  Widget _buildCharacterContent() {
    if (widget.characterId == 'char_robot') {
      return _buildGtoRobot();
    } else if (widget.characterId == 'char_ninja') {
      return _buildNinjaGirl();
    } else if (widget.characterId == 'char_spacemarine') {
      return _buildSpaceMarine();
    }
    // Unknown character fallback – generic silhouette
    return Icon(Icons.person_outline, size: widget.size * 0.7, color: Colors.white54);
  }

  Widget _buildGtoRobot() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Holographic Aura
            Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.acidYellow.withOpacity(0.1 + 0.1 * math.sin(_controller.value * 2 * math.pi)),
                    Colors.transparent
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Robot Head (Constructed from Icons/Shapes)
            Icon(
              Icons.android,
              size: widget.size * 0.8,
              color: const Color(0xFF22D3EE), // Cyan
            ),
            // Glowing Eyes (Overlay)
            Positioned(
              top: widget.size * 0.35,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEye(),
                  SizedBox(width: widget.size * 0.2),
                  _buildEye(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEye() {
    return Container(
      width: widget.size * 0.08,
      height: widget.size * 0.08,
      decoration: BoxDecoration(
        color: AppColors.acidYellow,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.acidYellow.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
    );
  }

  Widget _buildNinjaGirl() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Mystical Aura
            Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.1 + 0.1 * math.cos(_controller.value * 2 * math.pi)),
                    Colors.transparent
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Ninja Figure
            Icon(
              Icons.person, // Or better, combine multiple shapes
              size: widget.size * 0.8,
              color: Colors.purple.shade300,
            ),
            // Mask/Scarf (Overlay)
            Positioned(
              top: widget.size * 0.5,
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(widget.size),
                ),
              ),
            ),
            // Headband
             Positioned(
              top: widget.size * 0.2,
              child: Container(
                width: widget.size * 0.7,
                height: widget.size * 0.1,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 8)
                  ]
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpaceMarine() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Energy Shield Aura
            Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00FFFF).withOpacity(
                        0.15 + 0.1 * math.sin(_controller.value * 2 * math.pi)),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Marine Figure
            Icon(
              Icons.shield,
              size: widget.size * 0.8,
              color: const Color(0xFF00FFFF),
            ),
            // Visor Glow
            Positioned(
              top: widget.size * 0.32,
              child: Container(
                width: widget.size * 0.35,
                height: widget.size * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFFF).withOpacity(
                      0.6 + 0.3 * math.sin(_controller.value * 2 * math.pi)),
                  borderRadius: BorderRadius.circular(widget.size),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
