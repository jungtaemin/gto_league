import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 스와이프 방향 피드백 오버레이 (Premium Hold'em/Casino Concept)
/// 이모지 등 아케이드 요소를 배제하고, 무겁고 진지한 하이롤러 카지노 감성의 타이포그래피와 조명을 구현합니다.
class SwipeFeedbackOverlay extends StatelessWidget {
  final double dragProgress; // -1.0 (full left/fold) to +1.0 (full right/all-in), 0.0 = center

  const SwipeFeedbackOverlay({
    super.key,
    required this.dragProgress,
  });

  @override
  Widget build(BuildContext context) {
    final double progressAbs = dragProgress.abs();
    
    if (progressAbs < 0.05) {
      return const SizedBox.shrink();
    }

    final bool isFold = dragProgress < 0;
    
    // Scale animation kicks in hard toward the end of the drag for a "snapping" feel
    final double opacity = progressAbs.clamp(0.0, 1.0);
    // Smooth, heavy scale curve that suddenly feels explosive
    final double scale = 0.8 + (0.3 * Curves.easeOutBack.transform(opacity)); 
    
    final Alignment alignment = isFold ? Alignment.centerLeft : Alignment.centerRight;

    return IgnorePointer(
      child: Stack(
        children: [
          // 1. Casino Spotlight / Edge Burn Background
          if (isFold)
            _buildFoldShadows(opacity)
          else
            Positioned.fill(
              child: _buildAllInSpotlight(opacity),
            ),

          // 2. Heavy 3D Typography Overlay
          Align(
            alignment: alignment,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: Curves.easeIn.transform(opacity),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: isFold ? _buildFoldText(opacity) : _buildAllInText(opacity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 폴드(Fold) 시 뒤로 스러지는 듯한 깊고 다크한 그림자 연출
  Widget _buildFoldShadows(double opacity) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF020617).withOpacity(0.95 * opacity), // Deep slate black
              const Color(0xFF0F172A).withOpacity(0.6 * opacity),  // Dark navy
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
      ),
    );
  }

  /// 올인(All-in) 시 강렬한 크림슨 레드(Crimson Red)와 골드 스포트라이트 폭발 연출
  Widget _buildAllInSpotlight(double opacity) {
    return Stack(
      children: [
        // Base crimson edge burn (피처럼 붉은 긴장감)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  const Color(0xFF7F1D1D).withOpacity(0.9 * opacity), // Dark crimson
                  const Color(0xFF450A0A).withOpacity(0.5 * opacity),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.8],
              ),
            ),
          ),
        ),
        // Sharp gold spotlight highlight (딜러 테이블의 스포트라이트 조명)
        Positioned(
          right: -150 * (1 - opacity), // 드래그 할수록 빛이 들어오는 느낌
          top: 0,
          bottom: 0,
          width: 400,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.5, 0), // 터지는 지점 살짝 위
                radius: 1.2,
                colors: [
                  const Color(0xFFFBBF24).withOpacity(0.5 * opacity), // Gold highlight
                  const Color(0xFFB45309).withOpacity(0.2 * opacity), // Amber spread
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ALL-IN: 무겁고 반짝이는 메탈릭 골드(Metallic Gold) 베이스 3D 글씨
  Widget _buildAllInText(double opacity) {
    return Transform(
      // 공격성을 나타내는 전방 기울임
      transform: Matrix4.skewX(-0.15)..rotateZ(8 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // 3D Extrusion Shadows (Heavy block behind the text)
          // 여러 겹의 단단한 그림자로 글씨의 물리적 두께감을 구현
          Text(
            'ALL-IN',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF451A03), // Dark brown/black edge
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
                const Shadow(color: Color(0xFF78350F), blurRadius: 0, offset: Offset(-2, 2)),
                const Shadow(color: Color(0xFF451A03), blurRadius: 0, offset: Offset(-4, 4)),
                const Shadow(color: Color(0xFF451A03), blurRadius: 0, offset: Offset(-6, 6)),
                const Shadow(color: Color(0xFF280A01), blurRadius: 0, offset: Offset(-8, 8)),
                // Red ambient glow surrounding the heavy text
                Shadow(
                  color: const Color(0xFFEF4444).withOpacity(0.8 * opacity), 
                  blurRadius: 40, 
                  offset: const Offset(0, 0)
                ), 
              ],
            ),
          ),
          // Metallic Gradient Face (순금빛 텍스처)
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEF3C7), // Light catch top (거의 화이트)
                Color(0xFFF59E0B), // Core gold
                Color(0xFF92400E), // Heavy shadow bottom
                Color(0xFFFDE68A), // Rim light kick at the absolute bottom
              ],
              stops: [0.0, 0.4, 0.85, 1.0],
            ).createShader(bounds),
            // Text stroke (외곽선 느낌을 주기 위해 약간 두꺼운 브라운 베이스)
            child: Text(
              'ALL-IN',
              style: _getBaseTextStyle().copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// FOLD: 게임을 포기하고 뒤로 빠지는 차갑고 묵직한 다크 메탈 텍스트
  Widget _buildFoldText(double opacity) {
    return Transform(
      // 방어/물러남을 의미하는 후방 기울임
      transform: Matrix4.skewX(0.12)..rotateZ(-6 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // Deep shadows dropping back into the dark
          Text(
            'FOLD',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF0F172A), // Very dark slate
              fontSize: 76, // 올인보다 살짝 작은 크기 (위축감)
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 15, offset: Offset(8, 8)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(2, 2)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(4, 4)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(6, 6)),
              ],
            ),
          ),
          // Clean, cold grey metallic gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE2E8F0), 
                Color(0xFF94A3B8), 
                Color(0xFF334155), 
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'FOLD',
              style: _getBaseTextStyle().copyWith(
                color: Colors.white,
                fontSize: 76,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getBaseTextStyle() {
    return const TextStyle(
      fontFamily: 'Black Han Sans', // 두껍고 압도적인 무게감
      fontSize: 92,
      height: 1.0,
      letterSpacing: 4.0,
      fontWeight: FontWeight.w900,
    );
  }
}

