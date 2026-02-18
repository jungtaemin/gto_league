import 'dart:math';
import 'package:flutter/material.dart';
import '../../home/widgets/gto/stitch_colors.dart';
import '../../../../core/utils/responsive.dart'; // Import Responsive

class TablePositionView extends StatelessWidget {
  final String heroPosition;
  final String? opponentPosition;
  final bool isDefenseMode;

  const TablePositionView({
    super.key,
    required this.heroPosition,
    this.opponentPosition,
    this.isDefenseMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // 반응형: 화면 폭의 60% 정도, 컨텍스트 기반 스케일링
    final tableWidth = context.w(220).clamp(180.0, 320.0);
    final tableHeight = (tableWidth * 0.55).clamp(100.0, 180.0);
    
    return Container(
      width: tableWidth,
      height: tableHeight,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(context.r(60)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: CustomPaint(
        painter: _TablePainter(
          heroPosition: heroPosition,
          opponentPosition: opponentPosition,
          isDefenseMode: isDefenseMode,
          context: context, // Pass context for responsive sizing in painter
        ),
      ),
    );
  }
}

class _TablePainter extends CustomPainter {
  final String heroPosition;
  final String? opponentPosition;
  final bool isDefenseMode;
  final BuildContext context;

  // 9-max Position Mapping (Preflop Action Order)
  static const List<String> seats = [
    'UTG', 'UTG+1', 'UTG+2', 'MP', 'HJ', 'CO', 'BTN', 'SB', 'BB'
  ];

  _TablePainter({
    required this.heroPosition,
    this.opponentPosition,
    required this.isDefenseMode,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw Table (Oval)
    final tableRect = Rect.fromCenter(
      center: center, 
      width: size.width * 0.75, 
      height: size.height * 0.65
    );

    final tablePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = context.w(2.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, Radius.circular(context.r(40))),
      tablePaint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, Radius.circular(context.r(40))),
      borderPaint
    );

    // Calculate rotation offset to put Hero at Bottom (90 degrees, pi/2)
    int heroIndex = seats.indexOf(heroPosition);
    if (heroIndex == -1) heroIndex = 6; // Default to BTN

    // Base angles for 9 seats (Clockwise from SB)
    const double anglePerSeat = 2 * pi / 9;
    
    for (int i = 0; i < seats.length; i++) {
        int relativeIndex = (i - heroIndex); 
        final double angle = (pi / 2) + (relativeIndex * anglePerSeat);
        _drawSeat(canvas, size, center, i, angle, heroIndex);
    }
  }

  void _drawSeat(Canvas canvas, Size size, Offset center, int index, double angle, int heroIndex) {
    final posName = seats[index];
    final isHero = posName == heroPosition;
    final isOpponent = isDefenseMode && posName == opponentPosition;
    final isDealer = posName == 'BTN';
    
    // Seat positioning radius
    double radiusX = size.width * 0.42;
    double radiusY = size.height * 0.42;
    
    final seatOffset = center + Offset(radiusX * cos(angle), radiusY * sin(angle));

    // 1. Draw Dealer Button
    if (isDealer) {
      final dealerOffset = seatOffset + (center - seatOffset) * 0.35;
      
      canvas.drawCircle(dealerOffset, context.w(6), Paint()..color = Colors.white);
      
      final textSpan = TextSpan(
        text: 'D',
        style: TextStyle(color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, dealerOffset - Offset(textPainter.width/2, textPainter.height/2));
    }

    final paint = Paint()..style = PaintingStyle.fill;
    
    bool isFolded = false;
    
    // Find Opponent index (if exists)
    int opponentIndex = -1;
    if (isDefenseMode && opponentPosition != null) {
      opponentIndex = seats.indexOf(opponentPosition!);
    }
    
    // Logic Implementation
    if (isDefenseMode && opponentIndex != -1) {
       if (index < opponentIndex) isFolded = true; // Before Opponent
       if (index > opponentIndex && index < heroIndex) isFolded = true; // Between
    } else {
       if (index < heroIndex) isFolded = true;
    }
    
    // Safety: Hero/Opponent never folded
    if (isHero || isOpponent) isFolded = false;

    // Drawing
    final seatRadius = context.w(8);
    final activeSeatRadius = context.w(12);

    if (isHero) {
       paint.color = StitchColors.accentCyan;
       canvas.drawCircle(seatOffset, activeSeatRadius, Paint()..color = StitchColors.accentCyan.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
       canvas.drawCircle(seatOffset, seatRadius, paint);
    } else if (isOpponent) {
       paint.color = StitchColors.glowRed;
       canvas.drawCircle(seatOffset, activeSeatRadius, Paint()..color = StitchColors.glowRed.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
       canvas.drawCircle(seatOffset, seatRadius, paint);
    } else if (isFolded) {
       paint.color = const Color(0xFF020617);
       canvas.drawCircle(seatOffset, context.w(10), paint);
       canvas.drawCircle(seatOffset, context.w(10), Paint()..style = PaintingStyle.stroke..color = const Color(0xFF334155)..strokeWidth = 1.5);
       _drawMuckedCards(canvas, seatOffset);
    } else {
       paint.color = const Color(0xFF475569); // Slate 600
       canvas.drawCircle(seatOffset, seatRadius, paint);
    }

    // Labels
    if (isHero || isOpponent) {
        // Active
        final textSpan = TextSpan(
          text: posName,
          style: TextStyle(color: Colors.white, fontSize: context.sp(11), fontWeight: FontWeight.w900, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
        );
        _drawLabel(canvas, seatOffset, center, textSpan);
    } else if (isFolded) {
        // Folded Label
        final textSpan = TextSpan(
          children: [
            TextSpan(
              text: "$posName\n",
              style: TextStyle(color: const Color(0xFF334155), fontSize: context.sp(9), fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "FOLD",
              style: TextStyle(
                color: const Color(0xFFF43F5E), // Rose 500
                fontSize: context.sp(11),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ],
        );
        _drawLabel(canvas, seatOffset, center, textSpan, isFolded: true);
    } else {
        // Waiting/Neutral Label
        final textSpan = TextSpan(
          text: posName,
          style: TextStyle(color: Colors.white38, fontSize: context.sp(10)),
        );
        _drawLabel(canvas, seatOffset, center, textSpan);
    }
  }

  void _drawMuckedCards(Canvas canvas, Offset center) {
    // Brighter Mucked Cards
    final paint = Paint()..color = const Color(0xFF475569); // Slate 600
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;
      
    final width = context.w(12.0);
    final height = context.w(17.0);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Card 1
    canvas.save();
    canvas.translate(-3, 1);
    canvas.rotate(-0.3);
    final rect1 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: width, height: height), const Radius.circular(2));
    canvas.drawRRect(rect1, paint);
    canvas.drawRRect(rect1, strokePaint); // Outline
    canvas.restore();

    // Card 2
    canvas.save();
    canvas.translate(3, -1);
    canvas.rotate(0.2);
    final rect2 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: width, height: height), const Radius.circular(2));
    canvas.drawRRect(rect2, paint);
    canvas.drawRRect(rect2, strokePaint); // Outline
    canvas.restore();
    
    canvas.restore();
  }

  void _drawLabel(Canvas canvas, Offset seatOffset, Offset center, TextSpan textSpan, {bool isFolded = false}) {
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      
      final vec = seatOffset - center;
      final dist = vec.distance;
      final unitVec = dist > 0 ? vec / dist : const Offset(0, 1);
      
      final offsetDistance = isFolded ? context.w(12) : context.w(14);
      final labelOffset = seatOffset + unitVec * offsetDistance; 
      
      textPainter.paint(
        canvas, 
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2)
      );
  }

  @override
  bool shouldRepaint(covariant _TablePainter oldDelegate) {
    return oldDelegate.heroPosition != heroPosition ||
           oldDelegate.opponentPosition != opponentPosition ||
           oldDelegate.isDefenseMode != isDefenseMode;
  }
}
