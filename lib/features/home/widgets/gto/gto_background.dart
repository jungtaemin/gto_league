import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../decorate/providers/decorate_provider.dart';
import '../../../decorate/widgets/character_display_widget.dart';

class GtoBackground extends ConsumerWidget {
  const GtoBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for equipped character
    final decorateState = ref.watch(decorateProvider);
    final characterId = decorateState.equipped?.characterId ?? 'char_robot';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D3A8C), Color(0xFF1A1B4B)],
        ),
      ),
      child: Stack(
        children: [
          // 1. Ambient Circles (no BackdropFilter — perf-friendly)
          Positioned(
            top: -50,
            left: -100,
            child: _buildSoftCircle(const Color(0xFF3B82F6), 500),
          ),
          Positioned(
            bottom: -50,
            right: -80,
            child: _buildSoftCircle(const Color(0xFF9333EA), 400),
          ),

          // 2. Main Character (Centered in Background)
          Center(
            child: Opacity(
              opacity: 0.6,
              child: Transform.scale(
                scale: 1.5,
                child: CharacterDisplayWidget(
                  characterId: characterId,
                  size: 300,
                  isLocked: false,
                ),
              ),
            ),
          ),

          // 3. Static Floating Icons (no AnimationController)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.1,
            child: _buildBgIcon(Icons.style, Colors.blue.shade300, 60, -15),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.15,
            child: _buildBgIcon(Icons.favorite, Colors.pink.shade300, 48, 25),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.05,
            child: _buildBgIcon(Icons.view_agenda, Colors.blue.shade200, 72, 45),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.08,
            child: _buildBgIcon(Icons.crop_portrait, Colors.red.shade300, 60, -10),
          ),
        ],
      ),
    );
  }

  /// BackdropFilter 대신 단순한 radial gradient로 부드러운 원 표현
  Widget _buildSoftCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.05), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// 정적 아이콘 (AnimationController 제거)
  Widget _buildBgIcon(IconData icon, Color color, double size, double angleDeg) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Icon(icon, color: color.withOpacity(0.4), size: size),
    );
  }
}
