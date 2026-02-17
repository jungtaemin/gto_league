import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Stitch V1 Background: radial gradient + bokeh + floating card images
class GtoBackground extends StatefulWidget {
  const GtoBackground({super.key});

  @override
  State<GtoBackground> createState() => _GtoBackgroundState();
}

class _GtoBackgroundState extends State<GtoBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Stitch: radial-gradient(circle at 50% 30%, #4338ca 0%, #1e1b4b 50%, #0f0c29 100%)
        gradient: RadialGradient(
          center: Alignment(0.0, -0.4),
          radius: 1.2,
          colors: [
            Color(0xFF4338CA), // Indigo center
            Color(0xFF1E1B4B), // Deep indigo mid
            Color(0xFF0F0C29), // Near-black edge
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Bokeh blobs
          Positioned(
            top: 80, left: 40,
            child: _buildBokeh(const Color(0xFF3B82F6), 130),
          ),
          Positioned(
            bottom: 160, right: 40,
            child: _buildBokeh(const Color(0xFF8B5CF6), 190),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.width * 0.25,
            child: _buildBokeh(const Color(0xFF22D3EE), 100),
          ),

          // Floating card images
          _FloatingCard(
            controller: _controller,
            asset: 'assets/images/card_spade_dark.png',
            width: 48, height: 64,
            left: 40, top: 160,
            rotation: -15 * math.pi / 180,
            speed: 1.0, opacity: 0.6,
            blur: 1.0,
          ),
          _FloatingCard(
            controller: _controller,
            asset: 'assets/images/card_spade_white.png',
            width: 56, height: 80,
            right: 48, top: 128,
            rotation: 25 * math.pi / 180,
            speed: 0.8, opacity: 0.8,
            blur: 0,
          ),
          _FloatingCard(
            controller: _controller,
            asset: 'assets/images/card_heart.png',
            width: 64, height: 96,
            right: 24, bottom: 240,
            rotation: 10 * math.pi / 180,
            speed: 0.6, opacity: 0.7,
            blur: 2.0,
          ),
          _FloatingCard(
            controller: _controller,
            asset: 'assets/images/card_spade_large.png',
            width: 80, height: 112,
            left: 16, bottom: 160,
            rotation: -30 * math.pi / 180,
            speed: 1.0, opacity: 0.7,
            blur: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildBokeh(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 80, spreadRadius: 20),
        ],
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final AnimationController controller;
  final String asset;
  final double width, height;
  final double? left, right, top, bottom;
  final double rotation, speed, opacity, blur;

  const _FloatingCard({
    required this.controller, required this.asset,
    required this.width, required this.height,
    this.left, this.right, this.top, this.bottom,
    required this.rotation, required this.speed,
    required this.opacity, required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = controller.value * speed;
          final dy = math.sin(t * 2 * math.pi) * 10;
          final rot = rotation + math.sin(t * 2 * math.pi) * 0.05;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: rot,
              child: child,
            ),
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: blur > 0
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Image.asset(asset, width: width, height: height, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => SizedBox(width: width, height: height)),
                  )
                : Image.asset(asset, width: width, height: height, fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => SizedBox(width: width, height: height)),
            ),
          ),
        ),
      ),
    );
  }
}
