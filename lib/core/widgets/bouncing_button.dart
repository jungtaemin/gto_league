import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 모바일 게임 스타일의 터치 애니메이션(크기 축소 및 햅틱)을 제공하는 래퍼 버튼.
/// AnimatedScale(implicit animation)을 사용하므로 Ticker 충돌 없이 안전합니다.
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const BouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.9,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null && mounted) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          widget.onTap!();
          if (mounted) {
            setState(() => _isPressed = false);
          }
        }
      },
      onTapCancel: () {
        if (mounted) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
