import 'package:flutter/material.dart';

/// ☁️ 귀엽고 캐주얼한 "게임 스테이지" 배경 (K-Casual / 듀오링고 스타일)
/// 
/// 밝고 스카이블루/민트 계열의 부드러운 그라데이션.
/// 배경에 반투명한 둥근 구름과 물방울 패턴이 천천히 위로 올라가는 애니메이션.
class SagaMapBackground extends StatefulWidget {
  const SagaMapBackground({super.key});

  @override
  State<SagaMapBackground> createState() => _SagaMapBackgroundState();
}

class _SagaMapBackgroundState extends State<SagaMapBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CasualCloudPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CasualCloudPainter extends CustomPainter {
  final double animationValue;

  _CasualCloudPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 부드러운 파스텔 하늘 배경 (연하늘 -> 민트)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFE0F7FA), // 매우 밝은 연하늘
        Color(0xFFB2EBF2), // 밝은 민트
        Color(0xFF80DEEA), // 듀오링고스러운 쨍한 하늘색
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // 2. 동글동글한 오버레이 패턴 (구름 혹은 물방울 느낌)
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // 여러 개의 원을 위로 천천히 띄움
    _drawShape(canvas, size, paint, xOffset: 0.2, startYOffset: 0.1, radius: 40, speed: 1.0);
    _drawShape(canvas, size, paint, xOffset: 0.8, startYOffset: 0.4, radius: 60, speed: 0.6);
    _drawShape(canvas, size, paint, xOffset: 0.5, startYOffset: 0.8, radius: 30, speed: 1.2);
    _drawShape(canvas, size, paint, xOffset: 0.1, startYOffset: 0.7, radius: 80, speed: 0.4);
    _drawShape(canvas, size, paint, xOffset: 0.9, startYOffset: 0.0, radius: 50, speed: 0.8);
  }

  void _drawShape(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double xOffset,
    required double startYOffset,
    required double radius,
    required double speed,
  }) {
    // 위로 이동하는 애니메이션
    final movingY = (startYOffset - (animationValue * speed)) % 1.0;
    // 매끄러운 루프를 위해 범위를 벗어나면 반대편에서 나타나도록
    final y = movingY < 0 ? size.height * (1.0 + movingY) : size.height * movingY;
    final x = size.width * xOffset;

    // 약간 둥글둥글 겹친 구름 형태
    canvas.drawCircle(Offset(x, y), radius, paint);
    canvas.drawCircle(Offset(x + radius * 0.8, y + radius * 0.2), radius * 0.7, paint);
    canvas.drawCircle(Offset(x - radius * 0.6, y + radius * 0.3), radius * 0.9, paint);
  }

  @override
  bool shouldRepaint(covariant _CasualCloudPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
