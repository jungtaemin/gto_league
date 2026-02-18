import 'package:flutter/material.dart';
import 'dart:ui';
import 'stitch_colors.dart';

class GtoBattleBackground extends StatelessWidget {
  const GtoBattleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E1065), // #2e1065
                Color(0xFF1E1B4B), // #1e1b4b 40%
                Color(0xFF312E81), // #312e81 80%
                Color(0xFF4338CA), // #4338ca 100%
              ],
              stops: [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),

        // Blurred Blob: Top-Left (Purple)
        Positioned(
          top: -100, // estimated from top-[-10%]
          left: -50, // estimated from left-[-10%]
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Container(
            decoration: BoxDecoration(
              color: StitchColors.purple500.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Blurred Blob: Bottom-Right (Blue)
        Positioned(
          bottom: 100, // estimated from bottom-[10%]
          right: -50, // estimated from right-[-10%]
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: StitchColors.blue600.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
