import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles for holdem_allin_fold
class AppTextStyles {
  /// Display style - Black Han Sans with neon glow
  /// "Nano Banana" Upgrade: Massive, glowing, eye-catching
  static TextStyle display({Color color = AppColors.pureWhite}) {
    return GoogleFonts.blackHanSans(
      fontSize: 56, // Bigger impact
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: -1.5, // Tight packing for logo feel
      shadows: [
        const Shadow(
          color: AppColors.neonPink,
          blurRadius: 2,
          offset: Offset(2, 2),
        ),
        Shadow(
          color: AppColors.neonPink.withOpacity(0.8),
          blurRadius: 15,
        ),
        Shadow(
          color: AppColors.neonCyan.withOpacity(0.5),
          blurRadius: 30,
        ),
      ],
    );
  }
  
  /// Display medium
  static TextStyle displayMedium({Color color = AppColors.pureWhite}) {
    return GoogleFonts.blackHanSans(
      fontSize: 40, // Bumped up
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: -0.5,
      shadows: [
        const Shadow(
          color: AppColors.deepBlack,
          offset: Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }
  
  /// Heading style - Jua (playful, bouncy)
  static TextStyle heading({Color color = AppColors.pureWhite}) {
    return GoogleFonts.jua(
      fontSize: 28, // Bouncier
      fontWeight: FontWeight.w400,
      color: color,
      shadows: [
        Shadow(
          color: AppColors.deepBlack.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }
  
  /// Heading small
  static TextStyle headingSmall({Color color = AppColors.pureWhite}) {
    return GoogleFonts.jua(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
  
  /// Body style - Noto Sans KR
  static TextStyle body({Color color = AppColors.pureWhite}) {
    return GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.w600, // Increased weight for readability on dark
      color: color,
      height: 1.4,
    );
  }
  
  /// Body small
  static TextStyle bodySmall({Color color = AppColors.pureWhite}) {
    return GoogleFonts.notoSansKr(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.3,
    );
  }
  
  /// Caption style
  static TextStyle caption({Color color = AppColors.pureWhite}) {
    return GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color.withOpacity(0.8),
    );
  }
  
  /// Button style - Jua with bold
  static TextStyle button({Color color = AppColors.pureBlack}) {
    return GoogleFonts.jua(
      fontSize: 20, // Larger touch target feel
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.5,
      shadows: [
        Shadow(
          color: color.withOpacity(0.2),
          offset: const Offset(0, 1),
          blurRadius: 0,
        ),
      ],
    );
  }

  // NEW STYLES (Bonus)

  /// Score display - Monospaced or heavy impact
  static TextStyle score({Color color = AppColors.acidYellow}) {
    return GoogleFonts.blackHanSans(
      fontSize: 64,
      color: color,
      shadows: AppColors.neonGlow(color),
    );
  }

  /// Tier badge text
  static TextStyle tier({Color color = AppColors.pureWhite}) {
    return GoogleFonts.blackHanSans(
      fontSize: 14,
      color: color,
      letterSpacing: 1.0,
    );
  }

  /// Fact Bomb / Modal text
  static TextStyle factBomb({Color color = AppColors.pureWhite}) {
    return GoogleFonts.jua(
      fontSize: 26,
      color: color,
      height: 1.2,
    );
  }
}
