import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyBackground extends StatelessWidget {
  final Widget child;

  const LobbyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Main Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.stitchDeepBlue, // #1a0b3a
                AppColors.stitchDarkBG,   // #0d071e (Middle via)
                AppColors.stitchVoid,     // #05030a
              ],
              stops: [0.0, 0.45, 1.0], // Adjusted stops for "via" feel
            ),
          ),
        ),

        // 2. Bokeh Lights (Large Soft Blobs)
        // Top Left Pink Bloom
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25,
          left: MediaQuery.of(context).size.width * 0.25 - 100, // Offset to center
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stitchPink.withOpacity(0.1),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        
        // Bottom Right Cyan Bloom
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25,
          right: MediaQuery.of(context).size.width * 0.25 - 120,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stitchCyan.withOpacity(0.1),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // 3. Floating Blurred Shapes (Card Suits)
        // Top Right - Cards
        Positioned(
          top: 80,
          right: 40,
          child: Transform.rotate(
            angle: 12 * 3.14159 / 180, // 12 deg
            child: Icon(
              Icons.style, // Placeholder for "playing_cards" material symbol
              size: 120,
              color: Colors.white.withOpacity(0.05), // opacity-10 implies ~0.1 or 0.05
            ),
          ),
        ),
        
        // Bottom Left - Heart Card
        Positioned(
          bottom: 160,
          left: -20,
          child: Transform.rotate(
            angle: -12 * 3.14159 / 180, // -12 deg
            child: Icon(
              Icons.favorite, // Placeholder for "credit_card_heart"
              size: 160,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        
        // Content Layer
        Positioned.fill(child: child),
      ],
    );
  }
}
