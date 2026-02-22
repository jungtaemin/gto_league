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

  // ---------------------------------------------------------------------------
  // League Zone Colors
  // ---------------------------------------------------------------------------
  static const Color leaguePromotionGold = Color(0xFFFBBF24);
  static const Color leaguePromotionGreen = Color(0xFF34D399);
  static const Color leagueSafeGray = Color(0xFF374151);
  static const Color leagueDemotionRed = Color(0xFFF87171);
  static const Color leagueDemotionBg = Color(0xFF7F1D1D);
  static const Color leagueCutLine = Color(0xFFDC2626);
  static const Color leagueFeverRed = Color(0xFFEF4444);
  static const Color leagueMyHighlight = Color(0xFF22D3EE);
  static const Color leagueBotAccent = Color(0xFF6B7280);
  static const Color leagueRivalTarget = Color(0xFFDC2626);
  static const Color leagueBgDark = Color(0xFF0F0C29);
  static const Color leagueCardGradientStart = Color(0xFF1E293B);
  static const Color leagueCardGradientEnd = Color(0xFF0F172A);

  // ---------------------------------------------------------------------------
  // Deep Run Level Themes (5 Levels: 15BB → 5BB)
  // ---------------------------------------------------------------------------
  // Level 1 (15BB) — Deep Blue: Cool, calm, easiest
  static const Color level1Primary = Color(0xFF0D47A1);      // Deep Blue
  static const Color level1Background = Color(0xFF0A1F4D);   // Dark Navy
  static const Color level1Accent = Color(0xFF42A5F5);       // Light Blue
  static const Color level1TextPrimary = Color(0xFFE3F2FD);  // Pale Blue
  static const Color level1ProgressBar = Color(0xFF1976D2);  // Medium Blue

  // Level 2 (12BB) — Purple: Mystical, moderate difficulty
  static const Color level2Primary = Color(0xFF6A1B9A);      // Deep Purple
  static const Color level2Background = Color(0xFF3E1F47);   // Dark Purple
  static const Color level2Accent = Color(0xFFBA68C8);       // Violet
  static const Color level2TextPrimary = Color(0xFFF3E5F5);  // Pale Purple
  static const Color level2ProgressBar = Color(0xFF8E24AA);  // Medium Purple

  // Level 3 (10BB) — Yellow/Gold: Warm, challenging
  static const Color level3Primary = Color(0xFFF9A825);      // Gold/Amber
  static const Color level3Background = Color(0xFF6D4C41);   // Dark Gold
  static const Color level3Accent = Color(0xFFFFB74D);       // Light Amber
  static const Color level3TextPrimary = Color(0xFFFFF8E1);  // Pale Gold
  static const Color level3ProgressBar = Color(0xFFFFA000);  // Orange-Gold

  // Level 4 (7BB) — Crimson: Intense, very difficult
  static const Color level4Primary = Color(0xFFB71C1C);      // Crimson Red
  static const Color level4Background = Color(0xFF5D1F1A);   // Blood Red
  static const Color level4Accent = Color(0xFFFF5252);       // Orange-Red
  static const Color level4TextPrimary = Color(0xFFFFEBEE);  // Pale Red
  static const Color level4ProgressBar = Color(0xFFD32F2F);  // Medium Red

  // Level 5 (5BB) — Pitch Black w/ Red Pulse: Extreme, hardest
  static const Color level5Primary = Color(0xFF1A0000);      // Pitch Black
  static const Color level5Background = Color(0xFF0D0000);   // Near-Black
  static const Color level5Accent = Color(0xFF8B0000);       // Deep Red
  static const Color level5TextPrimary = Color(0xFFFFCDD2);  // Pale Red
  static const Color level5ProgressBar = Color(0xFFB71C1C);  // Crimson Pulse

  static const _levelThemes = [
    LevelTheme(
      primary: level1Primary,
      background: level1Background,
      accent: level1Accent,
      textPrimary: level1TextPrimary,
      progressBarColor: level1ProgressBar,
    ),
    LevelTheme(
      primary: level2Primary,
      background: level2Background,
      accent: level2Accent,
      textPrimary: level2TextPrimary,
      progressBarColor: level2ProgressBar,
    ),
    LevelTheme(
      primary: level3Primary,
      background: level3Background,
      accent: level3Accent,
      textPrimary: level3TextPrimary,
      progressBarColor: level3ProgressBar,
    ),
    LevelTheme(
      primary: level4Primary,
      background: level4Background,
      accent: level4Accent,
      textPrimary: level4TextPrimary,
      progressBarColor: level4ProgressBar,
    ),
    LevelTheme(
      primary: level5Primary,
      background: level5Background,
      accent: level5Accent,
      textPrimary: level5TextPrimary,
      progressBarColor: level5ProgressBar,
    ),
  ];

  /// Get level theme by level number (1-5)
  static LevelTheme getLevelTheme(int level) {
    final index = (level - 1).clamp(0, 4);
    return _levelThemes[index];
  }

  /// Get all level themes
  static List<LevelTheme> get levelThemes => _levelThemes;

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


/// LevelTheme data class for Deep Run level-specific colors
class LevelTheme {
  final Color primary;
  final Color background;
  final Color accent;
  final Color textPrimary;
  final Color progressBarColor;

  const LevelTheme({
    required this.primary,
    required this.background,
    required this.accent,
    required this.textPrimary,
    required this.progressBarColor,
  });
}