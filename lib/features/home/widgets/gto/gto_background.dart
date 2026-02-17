import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

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
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // HTML Background:
    // bg-main-gradient (Linear 180deg #2D3A8C -> #1A1B4B)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF2D3A8C), Color(0xFF1A1B4B)],
        ),
      ),
      child: Stack(
        children: [
          // 1. Blurred Circles (HTML lines 95-96)
          // top-[-10%] left-[-20%] w-[500px] h-[500px] bg-blue-500/20 blur-[100px]
          Positioned(
            top: -50, left: -100,
            child: _buildBlurCircle(const Color(0xFF3B82F6), 500, 100),
          ),
          // bottom-[-10%] right-[-20%] w-[400px] h-[400px] bg-purple-600/20 blur-[80px]
          Positioned(
            bottom: -50, right: -80,
            child: _buildBlurCircle(const Color(0xFF9333EA), 400, 80),
          ),

          // 2. Background Icons (HTML lines 97-108)
          // style (top 20% left 10% rotate -15)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.1,
            child: _buildBgIcon(Icons.style, Colors.blue.shade300, 60, -15),
          ),
          // favorite (top 25% right 15% rotate 25)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.15,
            child: _buildBgIcon(Icons.favorite, Colors.pink.shade300, 48, 25),
          ),
          // view_agenda (bottom 30% left 5% rotate 45)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.05,
            child: _buildBgIcon(Icons.view_agenda, Colors.blue.shade200, 72, 45),
          ),
          // crop_portrait (bottom 35% right 8% rotate -10)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.08,
            child: _buildBgIcon(Icons.crop_portrait, Colors.red.shade300, 60, -10),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size, double blur) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildBgIcon(IconData icon, Color color, double size, double angleDeg) {
    // Add simple float animation
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offset = math.sin(t * 2 * math.pi) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.rotate(
            angle: angleDeg * math.pi / 180,
            child: Icon(icon, color: color.withOpacity(0.4), size: size), // Opacity from HTML
          ),
        );
      },
    );
  }
}
