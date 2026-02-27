import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// Enum for chip stack sizes
enum ChipSize {
  small,
  medium,
  large,
}

/// A StatelessWidget that displays a poker chip stack with BB amount.
/// 
/// Shows 2-3 stacked circular chips with the amount in BB units displayed below.
/// Uses poker table chip colors (Red, Blue, Green) for visual variety.
class ChipStackWidget extends StatelessWidget {
  /// The amount in BB (Big Blind) units
  final double amount;

  /// The size of the chip stack
  final ChipSize size;

  /// Whether to display the text amount below the chips
  final bool showText;

  const ChipStackWidget({
    super.key,
    required this.amount,
    this.size = ChipSize.medium,
    this.showText = true,
  });

  /// Get chip diameter based on size
  double _getChipDiameter(BuildContext context) {
    switch (size) {
      case ChipSize.small:
        return context.w(12);
      case ChipSize.medium:
        return context.w(16);
      case ChipSize.large:
        return context.w(24);
    }
  }

  /// Format amount as BB string (no decimal if whole number)
  String _formatAmount() {
    if (amount == amount.truncate()) {
      return '${amount.toInt()}BB';
    }
    return '${amount}BB';
  }

  /// Get chip colors in order (bottom to top)
  List<Color> _getChipColors() {
    return [
      AppColors.pokerTableChipRed,
      AppColors.pokerTableChipBlue,
      AppColors.pokerTableChipGreen,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chipDiameter = _getChipDiameter(context);
    final chipColors = _getChipColors();
    final spacing = chipDiameter * 0.3; // Offset between stacked chips

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stacked chips
        SizedBox(
          width: chipDiameter + spacing,
          height: chipDiameter + (spacing * 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bottom chip (Red)
              Positioned(
                bottom: 0,
                child: Container(
                  width: chipDiameter,
                  height: chipDiameter,
                  decoration: BoxDecoration(
                    color: chipColors[0],
                    shape: BoxShape.circle,
                    boxShadow: AppColors.pokerTableGlow(chipColors[0]),
                  ),
                ),
              ),
              // Middle chip (Blue)
              Positioned(
                bottom: spacing,
                child: Container(
                  width: chipDiameter,
                  height: chipDiameter,
                  decoration: BoxDecoration(
                    color: chipColors[1],
                    shape: BoxShape.circle,
                    boxShadow: AppColors.pokerTableGlow(chipColors[1]),
                  ),
                ),
              ),
              // Top chip (Green)
              Positioned(
                bottom: spacing * 2,
                child: Container(
                  width: chipDiameter,
                  height: chipDiameter,
                  decoration: BoxDecoration(
                    color: chipColors[2],
                    shape: BoxShape.circle,
                    boxShadow: AppColors.pokerTableGlow(chipColors[2]),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: context.w(1.5)),
          // Amount text
          Text(
            _formatAmount(),
            style: AppTextStyles.caption(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
