import 'package:flutter/material.dart';

/// "⚡ SNAP!" 보너스 위젯 (Stitch V1 스타일)
class SnapBonusWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onComplete;

  const SnapBonusWidget({
    super.key,
    required this.isVisible,
    this.onComplete,
  });

  @override
  State<SnapBonusWidget> createState() => _SnapBonusWidgetState();
}

class _SnapBonusWidgetState extends State<SnapBonusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  static const _cyan = Color(0xFF22D3EE);
  static const _gold = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_controller);

    _fadeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SnapBonusWidget oldWidget) {
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: _fadeAnim.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _scaleAnim.value.clamp(0.0, 2.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient Burst
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [_gold.withOpacity(0.2), Colors.transparent],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                    // Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '⚡ SNAP!',
                          style: TextStyle(
                            color: _cyan,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(color: _cyan.withOpacity(0.8), blurRadius: 20)],
                          ),
                        ),
                        Text(
                          '+1.5x',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: _gold.withOpacity(0.6), blurRadius: 12)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
