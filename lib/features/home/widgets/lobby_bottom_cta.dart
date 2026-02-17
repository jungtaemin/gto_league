import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyBottomCTA extends StatelessWidget {
  final VoidCallback onPressed;

  const LobbyBottomCTA({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.stitchPrimary, // #f9f506
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          // Outer Gold Glow Layer (primary/40 blur-40)
           BoxShadow(
             color: AppColors.stitchPrimary.withOpacity(0.4),
             blurRadius: 40,
             offset: const Offset(0, 10),
           ),
           // Inner Highlight
           BoxShadow(
             color: Colors.white.withOpacity(0.5),
             blurRadius: 2,
             offset: const Offset(0, 1),
             inset: true, // Not supported directly in BoxShadow, simulated via gradient in child
           )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            children: [
              // 1. Diagonal Stripes (Simulated with CustomPainter or Gradient)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: CustomPaint(
                    painter: _DiagonalStripesPainter(),
                  ),
                ),
              ),
              
              // 2. Verified Top Gradient (Gloss)
              Positioned(
                top: 0, left: 0, right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                     gradient: LinearGradient(
                       begin: Alignment.topCenter,
                       end: Alignment.bottomCenter,
                       colors: [
                         Colors.white.withOpacity(0.4),
                         Colors.transparent,
                       ],
                     ),
                  ),
                ),
              ),

              // 3. Text and Icon
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '배틀 시작',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3A3701), // Dark contrast text
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 32,
                      color: Color(0xFF3A3701),
                    ),
                  ],
                ),
              ),
              
              // 4. Subtle Border
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw stripes
    // Simple implementation: lines at 45 deg
    const stripeWidth = 10.0;
    const gap = 10.0;
    
    canvas.save();
    // Optimization: clip
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(40)));
    
    // Draw logic simplified for visual effect
    for (double i = -size.height; i < size.width; i += (stripeWidth + gap)) {
       // Draw a path for stripe
       final path = Path();
       path.moveTo(i, 0);
       path.lineTo(i + stripeWidth, 0);
       path.lineTo(i + stripeWidth - size.height, size.height);
       path.lineTo(i - size.height, size.height);
       path.close();
       canvas.drawPath(path, paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
