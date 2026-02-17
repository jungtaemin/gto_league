import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Stitch V1 Battle Button: gold gradient, diagonal stripes, gloss overlay, speech bubble
class GtoCompPlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GtoCompPlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340, height: 90, // V2: Bigger button
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Main Button
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 80,
              // margin: const EdgeInsets.symmetric(horizontal: 16), // Adjusted in parent
              decoration: BoxDecoration(
                // Stitch: bg-button-gradient = linear-gradient(180deg, #FCD34D 0%, #F59E0B 100%)
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(24),
                // Stitch V2 shadow: 0 6px 0 #d97706, 0 15px 20px rgba(0,0,0,0.4)
                boxShadow: [
                  const BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 6), blurRadius: 0),
                  BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 15), blurRadius: 20),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Diagonal stripes
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: CustomPaint(painter: _StripePainter()),
                      ),
                    ),
                    // Gloss highlight (inset shadow simulation)
                    Positioned(
                      top: 0, left: 0, right: 0, height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.4), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Crossed swords
                          SizedBox(
                            width: 40, height: 40,
                            child: CustomPaint(painter: _CrossSwordsPainter()),
                          ),
                          const SizedBox(width: 8),
                          // Text
                          const Text("배틀 시작", style: TextStyle(
                            color: Color(0xFF5D2804),
                            fontSize: 30, fontFamily: 'Jua', fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            shadows: [Shadow(color: Colors.white24, offset: Offset(0, 1), blurRadius: 0)],
                          )),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 28, color: const Color(0xFF78350F).withOpacity(0.8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1,1), end: const Offset(1.015, 1.015), duration: 1200.ms),

          // Speech bubble (floats above the button)
          Positioned(
            top: -55, right: 8,
            child: _buildSpeechBubble(),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 1.seconds, curve: Curves.easeInOut),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0), // matching rounded-br-none
            ),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 10)],
          ),
          child: const Text("지금 바로 올인!", style: TextStyle(
            color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontFamily: 'Jua', fontSize: 14,
          )),
        ),
        // Triangle tail
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: ClipPath(
            clipper: _TailClipper(),
            child: Container(width: 10, height: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(size.width/2, size.height/2);
    canvas.rotate(math.pi / 4);
    canvas.translate(-size.width/2, -size.height/2);
    for (double i = -size.height; i < size.width * 2; i += 20) {
      canvas.drawLine(Offset(i, -size.height), Offset(i, size.height * 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrossSwordsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // Draw two swords rotated +/- 45 degrees
    _drawSword(canvas, paint, cx, cy, size.width, math.pi / 4);
    _drawSword(canvas, paint, cx, cy, size.width, -math.pi / 4);
  }

  void _drawSword(Canvas canvas, Paint paint, double cx, double cy, double size, double angle) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Dimensions
    final halfLen = size * 0.4;
    final bladeW = size * 0.08;
    final guardW = size * 0.25;
    final handleH = size * 0.15;

    // 1. Blade (Tapered)
    final path = Path();
    path.moveTo(0, -halfLen); // Tip
    path.lineTo(bladeW / 2, 0); // Base right
    path.lineTo(-bladeW / 2, 0); // Base left
    path.close();
    canvas.drawPath(path, paint);

    // 2. Guard (Rectangular bar)
    final guardRect = Rect.fromCenter(center: Offset(0, 0), width: guardW, height: bladeW * 0.6);
    canvas.drawRect(guardRect, paint);

    // 3. Handle (Rect)
    final handleRect = Rect.fromCenter(center: Offset(0, handleH / 2), width: bladeW * 0.7, height: handleH);
    canvas.drawRect(handleRect, paint);

    // 4. Pommel (Circle at bottom)
    canvas.drawCircle(Offset(0, handleH), bladeW * 0.6, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
