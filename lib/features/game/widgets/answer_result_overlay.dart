import 'package:flutter/material.dart';

/// 정답/오답 결과를 보여주는 오버레이 (Stitch V1 스타일)
class AnswerResultOverlay extends StatefulWidget {
  final bool isCorrect;
  final bool isVisible;
  final VoidCallback onComplete;

  const AnswerResultOverlay({
    super.key,
    required this.isCorrect,
    required this.isVisible,
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
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void didUpdateWidget(AnswerResultOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    final color = widget.isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final emoji = widget.isCorrect ? '✅' : '❌';
    final text = widget.isCorrect ? 'NICE!' : 'MISS...';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final combinedOpacity = (_fadeIn.value * _fadeOut.value).clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: true,
          child: Stack(
            children: [
              // Background Burst
              Positioned.fill(
                child: Opacity(
                  opacity: combinedOpacity,
                  child: Transform.scale(
                    scale: 0.5 + (_controller.value * 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
                          stops: const [0.2, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Center(
                child: Opacity(
                  opacity: combinedOpacity,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 20)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
