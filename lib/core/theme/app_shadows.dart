import 'package:flutter/material.dart';

/// Neo-Brutalism hard shadows (no blur)
class AppShadows {
  /// Hard shadow with 8px offset, no blur (Neo-Brutalism signature)
  /// "Nano Banana" Upgrade: Bolder, deeper
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(8, 8), // Increased depth
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];
  
  /// Smaller hard shadow with 6px offset
  static const List<BoxShadow> hardShadowSmall = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(6, 6), // Increased depth
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];
  
  /// Tiny hard shadow with 3px offset (for small elements)
  static const List<BoxShadow> hardShadowTiny = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(3, 3), // Increased depth
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  // NEW SHADOWS

  /// Colored hard shadow for that "Nano Banana" pop
  static List<BoxShadow> neonHardShadow(Color color) {
    return [
      BoxShadow(
        color: color,
        offset: const Offset(6, 6),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  /// Layered shadow for premium card feel (3D effect)
  static const List<BoxShadow> layeredShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFF333333), // Dark Gray
      offset: Offset(8, 8),
      blurRadius: 0,
    ),
  ];

  /// Inner glow helper (simulated with inset shadow if Flutter supported it easily, 
  /// but here we use a soft spread shadow for container glow)
  static List<BoxShadow> innerGlow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.6),
        blurRadius: 15,
        spreadRadius: -5, // Negative spread creates inner-like feel on edges
      ),
    ];
  }
}
