import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Stitch V1 Hero Stage with CSS-robot, progress arc, podium, GTO chart mini, side buttons
class GtoHeroStage extends StatefulWidget {
  const GtoHeroStage({super.key});

  @override
  State<GtoHeroStage> createState() => _GtoHeroStageState();
}

class _GtoHeroStageState extends State<GtoHeroStage> with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 420,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. "League Progress" label
          const Positioned(
            top: 0,
            child: Text("League Progress", style: TextStyle(
              color: Color(0xFFB2EBF2), fontSize: 13, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, fontFamily: 'Jua',
              shadows: [Shadow(color: Color(0xFF22D3EE), blurRadius: 8)],
            )),
          ),

          // 2. Progress Arc (conic gradient style)
          Positioned(
            top: 25,
            child: CustomPaint(
              size: const Size(260, 130),
              painter: _ConicArcPainter(),
            ),
          ),

          // 3. Silver I marker
          const Positioned(
            top: 55, right: 15,
            child: Text("실버 I", style: TextStyle(
              color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Jua',
            )),
          ),

          // 4. Silver badge diamond
          Positioned(
            top: 60, right: 40,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF94A3B8), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: -math.pi / 4,
                    child: const Text("I", style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),

          // 5. GTO Chart mini (left side)
          Positioned(
            left: -10, top: 100,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 6, top: 4),
                      child: Text("GTO", style: TextStyle(color: Color(0xFFD8B4FE), fontSize: 7, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    // Grid of colored squares
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: List.generate(3, (row) => Row(
                          children: List.generate(4, (col) {
                            final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
                            return Container(
                              width: 10, height: 8, margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: colors[col].withOpacity(0.6 - row * 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Robot Character (CSS-built style, floating)
          Positioned(
            top: 80,
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (context, child) {
                final dy = math.sin(_floatCtrl.value * math.pi) * 10;
                final rot = math.sin(_floatCtrl.value * math.pi) * 0.035;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.rotate(angle: rot, child: child),
                );
              },
              child: _buildRobot(),
            ),
          ),

          // 7. Podium (Glass ellipses + cyan glow)
          Positioned(
            bottom: 20,
            child: _buildPodium(),
          ),
        ],
      ),
    );
  }

  /// CSS-robot recreation from Stitch HTML
  Widget _buildRobot() {
    return SizedBox(
      width: 192, height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Body (dark rounded rectangle)
          Positioned(
            bottom: 16,
            child: Container(
              width: 112, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bowtie area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left triangle
                      CustomPaint(size: const Size(12, 16), painter: _TrianglePainter(isLeft: true)),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF334155), shape: BoxShape.circle)),
                      CustomPaint(size: const Size(12, 16), painter: _TrianglePainter(isLeft: false)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // White triangle (shirt)
                  CustomPaint(size: const Size(30, 30), painter: _ShirtTrianglePainter()),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (_) => Container(
                      width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Head (light gray rounded rectangle)
          Positioned(
            top: 0,
            child: Container(
              width: 160, height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40),
                border: Border(bottom: BorderSide(color: const Color(0xFFD1D5DB), width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Screen (dark inner rectangle)
                  Center(
                    child: Container(
                      width: 144, height: 108,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20, spreadRadius: -5)],
                      ),
                      child: Stack(
                        children: [
                          // Scanline overlay (subtle)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: List.generate(20, (i) =>
                                    i % 2 == 0 ? Colors.transparent : Colors.black.withOpacity(0.1)),
                                ),
                              ),
                            ),
                          ),
                          // Eyes (cyan glowing half-circles)
                          Positioned(
                            top: 32, left: 0, right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildEye(),
                                const SizedBox(width: 16),
                                _buildEye(),
                              ],
                            ),
                          ),
                          // Mouth (small cyan bar)
                          Positioned(
                            bottom: 24, left: 0, right: 0,
                            child: Center(
                              child: Container(
                                width: 16, height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22D3EE),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                  boxShadow: [BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.6), blurRadius: 10)],
                                ),
                              ),
                            ),
                          ),
                          // Code text overlay
                          Positioned(
                            top: 10, left: 10, right: 10,
                            child: Text(
                              "const gto = (range) => { check(ev); raise(3bb); }",
                              style: TextStyle(color: Colors.green.withOpacity(0.15), fontSize: 5, fontFamily: 'monospace'),
                              maxLines: 2, overflow: TextOverflow.clip,
                            ),
                          ),
                          // Tie accent
                          Positioned(
                            top: 24, right: 20,
                            child: Transform.rotate(
                              angle: 0.1,
                              child: Container(width: 16, height: 4, color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Arms
          Positioned(
            bottom: 40, left: -8,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 32, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0F172A), width: 4),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40, right: -8,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 32, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0F172A), width: 4),
                ),
              ),
            ),
          ),

          // Legs
          Positioned(
            bottom: -8, left: 56,
            child: Container(
              width: 32, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: -8, right: 56,
            child: Container(
              width: 32, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 40, height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.8), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: const Color(0xFF0F172A).withOpacity(0.5)),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: const Color(0xFF0F172A).withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return SizedBox(
      width: 260, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow disc
          Positioned(
            bottom: 0,
            child: Container(
              width: 260, height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(130),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22D3EE).withOpacity(0.4),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          // Inner ellipse
          Positioned(
            bottom: 32,
            child: Container(
              width: 192, height: 48,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.elliptical(192, 48)),
                border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.3)),
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Outer ellipse
          Positioned(
            bottom: 16,
            child: Container(
              width: 224, height: 56,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.elliptical(224, 56)),
                border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("리그: 브론즈 III", style: TextStyle(
                    color: const Color(0xFFFDBA74), fontSize: 11,
                    fontWeight: FontWeight.bold, fontFamily: 'Jua',
                    shadows: [Shadow(color: Colors.orange.withOpacity(0.8), blurRadius: 4)],
                  )),
                ),
              ),
            ),
          ),
          // Bottom glow line
          Positioned(
            bottom: 8,
            child: Container(
              width: 240, height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border(bottom: BorderSide(color: const Color(0xFF22D3EE), width: 2)),
                boxShadow: [BoxShadow(color: const Color(0xFF22D3EE), blurRadius: 15, spreadRadius: 0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConicArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Background track
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = Colors.white.withOpacity(0.05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, math.pi, false, bgPaint,
    );

    // Active gradient arc (pink → orange/yellow)
    const sweepFraction = 0.55; // ~55% progress
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: [
          Color(0xFFEC4899), // Pink
          Color(0xFFF59E0B), // Amber/Yellow
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, math.pi * sweepFraction, false, gradientPaint,
    );

    // Glow on active arc
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = const Color(0xFFF59E0B).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, math.pi * sweepFraction, false, glowPaint,
    );

    // Tick marks
    for (int i = 0; i < 5; i++) {
      final angle = math.pi + (math.pi / 6) * i;
      final innerR = radius - 6;
      final outerR = radius + 6;
      final tickPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle)),
        Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle)),
        tickPaint,
      );
    }

    // Progress indicator (yellow dot at end of arc)
    final endAngle = math.pi + math.pi * sweepFraction;
    final dotCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final dotPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(dotCenter, 6, dotPaint);
    canvas.drawCircle(dotCenter, 4, Paint()..color = const Color(0xFFFDE047));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final bool isLeft;
  _TrianglePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E293B);
    final path = Path();
    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShirtTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.9);
    final path = Path();
    path.moveTo(size.width / 2 - 15, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + 15, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
