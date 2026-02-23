import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 정답/오답 결과를 보여주는 오버레이 (Premium Hold'em/Casino Concept)
/// 유저의 액션(올인/폴드)과 정답 여부에 따라 홀덤 용어로 피드백을 표시합니다.
class AnswerResultOverlay extends StatefulWidget {
  final bool isCorrect;
  final bool isVisible;
  final bool wasFold; // true = 유저가 폴드함, false = 유저가 올인함
  final VoidCallback onComplete;

  const AnswerResultOverlay({
    super.key,
    required this.isCorrect,
    required this.isVisible,
    required this.wasFold,
    required this.onComplete,
  });

  @override
  State<AnswerResultOverlay> createState() => _AnswerResultOverlayState();
}

class _AnswerResultOverlayState extends State<AnswerResultOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // K-Casual의 짧고 강렬한 체공시간
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.15, curve: Curves.easeIn)),
    );
    // 초고수 관점: 정답일 때 더 강한 바운드, 오답일 때 무겁게 쿵
    _scale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: Interval(0.0, 0.35, curve: widget.isCorrect ? Curves.elasticOut : Curves.easeOutBack)
      ),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeInQuad)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnswerResultOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the animation curve dynamically based on isCorrect if it changed
    if (widget.isCorrect != oldWidget.isCorrect) {
      _scale = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller, 
          curve: Interval(0.0, 0.35, curve: widget.isCorrect ? Curves.elasticOut : Curves.easeOutBack)
        ),
      );
    }
    
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final combinedOpacity = (_fadeIn.value * _fadeOut.value).clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: true,
          child: Stack(
            children: [
              // 1. Background Casino Glow
              Positioned.fill(
                child: Opacity(
                  opacity: combinedOpacity,
                  child: Transform.scale(
                    scale: 0.8 + (_controller.value * 0.4), // 서서히 커지는 스포트라이트
                    child: widget.isCorrect ? _buildNiceGlow() : _buildMissShadow(),
                  ),
                ),
              ),

              // 2. Heavy 3D Typography
              Center(
                child: Opacity(
                  opacity: combinedOpacity,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: widget.isCorrect ? _buildNiceText() : _buildMissText(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 정답: 잭팟 아우라 (싱글 컨테이너로 최적화)
  Widget _buildNiceGlow() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.35),
            const Color(0xFF10B981).withOpacity(0.4),
            const Color(0xFF047857).withOpacity(0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.6, 1.0],
          radius: 1.3,
        ),
      ),
    );
  }

  /// 오답: 심연의 섀도우 (싱글 컨테이너로 최적화)
  Widget _buildMissShadow() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF020617).withOpacity(0.9),
            const Color(0xFF7F1D1D).withOpacity(0.2),
            const Color(0xFF0F172A).withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
          radius: 1.5,
        ),
      ),
    );
  }

  /// 정답 텍스트: 골드 스트로크 + 에메랄드 코어 (2레이어로 최적화)
  Widget _buildNiceText() {
    final text = widget.wasFold ? '굿 폴드!' : '굿 올인!';
    return Transform(
      transform: Matrix4.skewX(-0.15)..rotateZ(4 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // 1. 골드 메탈릭 스트로크 + 3D 압출 Shadow
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDE047), // Light Gold
                Color(0xFFB45309), // Dark Bronze
                Color(0xFFFEF08A), // Bright Gold
                Color(0xFF78350F), // Deep Brown
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: _getBaseTextStyle().copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 9.0
                  ..strokeJoin = StrokeJoin.round,
                shadows: [
                  // 3D 압출 효과를 Shadow로 처리 (Positioned 대신)
                  const Shadow(color: Color(0xFF022C22), blurRadius: 0, offset: Offset(-5, 7)),
                  const Shadow(color: Color(0xFF064E3B), blurRadius: 0, offset: Offset(-3, 4)),
                  const Shadow(color: Color(0xFF047857), blurRadius: 0, offset: Offset(-1, 2)),
                  // 뒤쪽 블루밍 아우라
                  Shadow(color: const Color(0xFF10B981).withOpacity(0.7), blurRadius: 30, offset: const Offset(0, 0)),
                ],
              ),
            ),
          ),
          // 2. 에메랄드 쥬얼 코어 필
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD1FAE5), // 반사되는 하이라이트
                Color(0xFF10B981), // 에메랄드 코어
                Color(0xFF047857), // 하단 그림자
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: _getBaseTextStyle().copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 오답 텍스트: 스틸 스트로크 + 슬레이트 코어 (2레이어로 최적화)
  Widget _buildMissText() {
    final text = widget.wasFold ? '배드 폴드!' : '배드 올인!';
    return Transform(
      transform: Matrix4.skewX(0.15)..rotateZ(-5 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // 1. 콜드 스틸 스트로크 + 3D 압출 Shadow
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF94A3B8), // Bright Iron
                Color(0xFF334155), // Dark Steel
                Color(0xFFCBD5E1), // Light Silver
                Color(0xFF0F172A), // Deep Navy
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: _getBaseTextStyle().copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 9.0
                  ..strokeJoin = StrokeJoin.round,
                shadows: [
                  // 무겁게 아래로 찍어누르는 3D Shadow
                  const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(6, 10)),
                  const Shadow(color: Color(0xFF0B1120), blurRadius: 0, offset: Offset(4, 6)),
                  const Shadow(color: Color(0xFF1E293B), blurRadius: 0, offset: Offset(2, 3)),
                  // 다크 아우라
                  Shadow(color: const Color(0xFF0F172A).withOpacity(0.8), blurRadius: 25, offset: const Offset(0, 5)),
                ],
              ),
            ),
          ),
          // 2. 얼어붙은 슬레이트 코어 필
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE2E8F0), // Frozen top
                Color(0xFF475569), // Slate core
                Color(0xFF1E293B), // Dark shadow
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              text,
              style: _getBaseTextStyle().copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getBaseTextStyle() {
    return const TextStyle(
      fontFamily: 'Black Han Sans',
      fontSize: 92,
      height: 1.0,
      letterSpacing: 2.0,
      fontWeight: FontWeight.w900,
    );
  }
}
