import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 9-player oval poker table widget.
///
/// Uses [LayoutBuilder] to fill its parent constraints exactly,
/// preventing overflow. Seats are positioned around an ellipse
/// using angle-based math with [FractionalTranslation] centering.
class PokerTableWidget extends StatelessWidget {
  final Widget Function(BuildContext context, int index, Offset centerDir) seatBuilder;
  final Widget potDisplay;
  final Widget? timerWidget;
  final int heroSeatIndex;

  const PokerTableWidget({
    super.key,
    required this.seatBuilder,
    required this.potDisplay,
    this.timerWidget,
    this.heroSeatIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cw = constraints.maxWidth;
        final ch = constraints.maxHeight;

        final centerY = ch * 0.45;

        // Visual offsets for 9 seats around an oval table
        // Index 0 is always Bottom Center (Hero). Clockwise from there.
        const List<Offset> visualOffsets = [
          Offset(0.50, 0.81), // 0: Bottom Center (Hero)
          Offset(0.18, 0.68), // 1: Bottom Left
          Offset(0.08, 0.42), // 2: Left
          Offset(0.20, 0.18), // 3: Top Left
          Offset(0.38, 0.10), // 4: Top Mid-Left
          Offset(0.62, 0.10), // 5: Top Mid-Right
          Offset(0.80, 0.18), // 6: Top Right
          Offset(0.92, 0.42), // 7: Right
          Offset(0.82, 0.68), // 8: Bottom Right
        ];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Table background image (vertical oval)
            Positioned.fill(
              child: Image.asset(
                'assets/images/poker_table_bg_30bb.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.pokerTableBg,
                ),
              ),
            ),

            // Pot display (center of table)
            Positioned(
              left: 0,
              right: 0,
              top: centerY,
              child: Center(child: potDisplay),
            ),

            // Optional timer (above pot)
            if (timerWidget != null)
              Positioned(
                left: 0,
                right: 0,
                top: centerY - ch * 0.12,
                child: Center(child: timerWidget!),
              ),

            // 9 seats positioned manually for perspective layout
            ...List.generate(9, (i) {
              final visualIndex = (i - heroSeatIndex + 9) % 9;
              final offset = visualOffsets[visualIndex];
              
              // Calculate vector towards center (0.5, 0.45)
              final dirX = 0.5 - offset.dx;
              final dirY = 0.45 - offset.dy;
              final len = math.sqrt(dirX * dirX + dirY * dirY);
              final normDir = len > 0 ? Offset(dirX / len, dirY / len) : Offset.zero;

              return Positioned(
                left: cw * offset.dx,
                top: ch * offset.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: seatBuilder(context, i, normDir),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
