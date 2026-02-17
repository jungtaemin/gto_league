import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyCharacter extends StatefulWidget {
  const LobbyCharacter({super.key});

  @override
  State<LobbyCharacter> createState() => _LobbyCharacterState();
}

class _LobbyCharacterState extends State<LobbyCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        width: 256, // w-64
        height: 256, // h-64
        decoration: BoxDecoration(
          // Drop shadow from CSS: drop-shadow-[0_25px_25px_rgba(0,242,255,0.3)]
          boxShadow: [
            BoxShadow(
              color: AppColors.stitchCyan.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 25),
            )
          ],
        ),
        child: Image.asset(
          'assets/images/lobby_character_3d.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
             return const Icon(Icons.smart_toy, size: 150, color: Colors.white);
          },
        ),
      ),
    );
  }
}
