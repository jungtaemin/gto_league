import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Neo-Brutalism + Neon dark theme for holdem_allin_fold
class AppTheme {
  static ThemeData neoBrutalistTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Custom color scheme - "Nano Banana" Palette
      colorScheme: const ColorScheme.dark(
        primary: AppColors.acidYellow, // Banana Yellow as Primary
        secondary: AppColors.neonPink, // Hot Pink as Secondary
        tertiary: AppColors.neonCyan,  // Cyan as Tertiary
        surface: AppColors.deepBlack,
        error: AppColors.laserRed,
        onPrimary: AppColors.pureBlack,
        onSecondary: AppColors.pureWhite,
        onSurface: AppColors.pureWhite,
        onError: AppColors.pureWhite,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: AppColors.deepBlack,
      
      // Page Transitions - Slide + Fade for arcade feel
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Card theme - Premium Arcade Cabinet feel
      cardTheme: CardThemeData(
        color: AppColors.darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)), // Softer corners
          side: BorderSide(
            color: AppColors.pureWhite.withOpacity(0.1), // Subtle border
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated button theme (Neo-Brutalist style) - "Pressable"
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.acidYellow,
          foregroundColor: AppColors.pureBlack,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), // Taller buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.pureBlack, width: 3),
          ),
          elevation: 0, // We handle shadow manually or via container
          shadowColor: Colors.transparent,
          textStyle: AppTextStyles.button(),
        ).copyWith(
          // Add press effect via overlay color if needed, but standard material ripple is okay
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: AppTextStyles.button(color: AppColors.neonCyan),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading(),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        actionsIconTheme: const IconThemeData(color: AppColors.acidYellow),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGray,
        selectedItemColor: AppColors.acidYellow, // Banana selection
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false, // Minimalist
        showUnselectedLabels: false,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.acidYellow,
        linearTrackColor: AppColors.darkGray,
        refreshBackgroundColor: AppColors.deepBlack,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.pureWhite.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme - Fact Bomb Modal style
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.acidYellow, width: 2),
        ),
        titleTextStyle: AppTextStyles.heading(color: AppColors.acidYellow),
        contentTextStyle: AppTextStyles.body(color: AppColors.pureWhite),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkGray,
        modalBackgroundColor: AppColors.darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
