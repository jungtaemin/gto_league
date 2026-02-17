import 'package:flutter/material.dart';

/// Neo-Brutalism + Neon color palette for holdem_allin_fold
class AppColors {
  // Neon primary colors - UPDATED for "Nano Banana" vibrancy
  static const Color neonPink = Color(0xFFFF0099);      // Hotter Pink
  static const Color neonCyan = Color(0xFF00FFFF);      // Max Cyan
  static const Color acidYellow = Color(0xFFFFEA00);    // Banana Yellow (Primary Accent)
  static const Color electricBlue = Color(0xFF2979FF);  // Brighter Electric Blue
  static const Color neonPurple = Color(0xFFD500F9);    // Vivid Purple
  static const Color acidGreen = Color(0xFF00E676);     // Punchy Lime Green
  
  // Supporting neon colors
  static const Color hotPink = Color(0xFFFF1493);       // Deep Pink
  static const Color laserRed = Color(0xFFFF1744);      // Redder Red
  static const Color ultraViolet = Color(0xFF651FFF);   // Deep Violet
  static const Color hotOrange = Color(0xFFFF3D00);     // Blazing Orange
  
  // Dark backgrounds - Deep, rich darks for contrast
  static const Color deepBlack = Color(0xFF050505);     // Almost Void
  static const Color darkGray = Color(0xFF121212);      // Material Dark
  static const Color midnightBlue = Color(0xFF020024);  // Synthwave Night Sky
  static const Color darkPurple = Color(0xFF14002A);    // Deep Void Purple
  
  // Monochrome
  static const Color pureBlack = Color(0xFF000000);     // KEEP value 0xFF000000
  static const Color pureWhite = Color(0xFFFFFFFF);     // KEEP value 0xFFFFFFFF

  // NEW: Retro Arcade Textures
  static const Color crtOverlay = Color(0x0DFFFFFF);    // Subtle scanline/noise tint
  static const Color shadowBlack = Color(0x80000000);   // Semi-transparent black for depth

  // Stitch Design Colors (Lobby UI)
  static const Color stitchDarkBG = Color(0xFF120C22);
  static const Color stitchCyan = Color(0xFF00F2FF);
  static const Color stitchPink = Color(0xFFFF00E5);
  static const Color stitchPrimary = Color(0xFFF9F506); // Intense Yellow
  static const Color stitchDeepBlue = Color(0xFF1A0B3A); // Gradient Start
  static const Color stitchVoid = Color(0xFF05030A);     // Gradient End


  /// Generate neon glow effect BoxShadow list (3-Layer Upgrade)
  /// Layer 1: Core intense glow
  /// Layer 2: Mid-range bloom
  /// Layer 3: Wide atmospheric haze
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.6}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 8,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withOpacity(intensity * 0.6),
        blurRadius: 25,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: color.withOpacity(intensity * 0.3),
        blurRadius: 60,
        spreadRadius: 15,
      ),
    ];
  }

  /// NEW: Helper for animated breathing glow
  static List<BoxShadow> animatedGlow(Color color, double animationValue) {
    return neonGlow(color, intensity: 0.4 + (animationValue * 0.4));
  }

  /// NEW: Standard Neon Gradient
  static LinearGradient neonGradient(Color start, Color end) {
    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  /// NEW: Banana Split Gradient (Signature)
  static const LinearGradient bananaGradient = LinearGradient(
    colors: [acidYellow, Color(0xFFFFAB00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
