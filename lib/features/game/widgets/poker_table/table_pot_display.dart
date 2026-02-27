import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import 'chip_stack_widget.dart';

/// A StatelessWidget that displays the pot size in the center of the poker table.
///
/// Refactored to match professional Hold'em games: a centered subtle blind text
/// and a prominent, dark glassmorphic horizontal pill for the pot amount.
class TablePotDisplay extends StatelessWidget {
  /// The pot size in BB (Big Blind) units
  final double potSize;

  /// Optional blind information string (e.g., 'SB 0.5 / BB 1')
  final String? blindInfo;

  const TablePotDisplay({
    super.key,
    required this.potSize,
    this.blindInfo,
  });

  /// Format pot amount as BB string (no decimal if whole number)
  String _formatPot(double amount) {
    if (amount == amount.truncate()) {
      return '${amount.toInt()}BB';
    }
    return '${amount.toStringAsFixed(1)}BB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Sleek Blind Info above the pill
        if (blindInfo != null) ...[
          Text(
            blindInfo!.toUpperCase().replaceAll('/', ' | '),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: context.w(12),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: context.w(6)),
        ],

        // 2. Premium Dark Pill for Pot Amount
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(18),
            vertical: context.w(6),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(context.w(32)), // full pill shape
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              // Subtle inner highlight effect
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 1,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
            children: [
              // Tiny chip icon marker
              Padding(
                padding: EdgeInsets.only(top: context.w(2.0)), // adjust stack alignment
                child: ChipStackWidget(
                  amount: potSize > 0 ? potSize : 1.0, 
                  size: ChipSize.small,
                  showText: false, // Don't show the redundant text below chips
                ),
              ),
              SizedBox(width: context.w(6)),
              // Pot Amount Text in Premium Gold
              Text(
                potSize == 0 ? 'Pot' : _formatPot(potSize),
                style: TextStyle(
                  color: const Color(0xFFFFD700), // Vibrant Gold
                  fontSize: context.w(18),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.9),
                      blurRadius: 2,
                      offset: const Offset(0, 1.5),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
