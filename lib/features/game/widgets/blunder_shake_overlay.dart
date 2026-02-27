import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_manager.dart';

class BlunderShakeOverlay extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onComplete;

  const BlunderShakeOverlay({
    super.key,
    required this.isVisible,
    required this.onComplete,
  });

  @override
  State<BlunderShakeOverlay> createState() => _BlunderShakeOverlayState();
}

class _BlunderShakeOverlayState extends State<BlunderShakeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    if (widget.isVisible) {
      HapticManager.wrong();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant BlunderShakeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      HapticManager.wrong();
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
    if (!widget.isVisible && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double baseOffset = Tween<double>(begin: 0, end: 10).evaluate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
          );
          final double shakeOffset = baseOffset * sin(_controller.value * pi * 6);
          final double opacity = (0.3 * (1 - _controller.value)).clamp(0.0, 1.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Container(
                    // ignore: deprecated_member_use
                    color: const Color(0xFFEF4444).withOpacity(opacity),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
