import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';


/// Neo-Brutalist button with arcade-style interaction
/// 
/// Features:
/// - Chunky press animation (Scale + Translate + Shadow shrink)
/// - Haptic feedback hooks
/// - Idle pulse for primary actions
/// - Disabled state styling
class NeoBrutalistButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double minWidth;
  final double minHeight;
  
  // New optional parameters
  final bool isPrimary;
  final VoidCallback? onPressDown;

  const NeoBrutalistButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color = AppColors.acidYellow,
    this.textColor = AppColors.pureBlack,
    this.borderRadius = 12,
    this.padding,
    this.minWidth = 48,
    this.minHeight = 48,
    this.isPrimary = false,
    this.onPressDown,
  });

  @override
  State<NeoBrutalistButton> createState() => _NeoBrutalistButtonState();
}

class _NeoBrutalistButtonState extends State<NeoBrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    
    // Disabled state logic
    final effectiveColor = isEnabled 
        ? widget.color 
        : AppColors.darkGray;
    
    final effectiveTextColor = isEnabled 
        ? widget.textColor 
        : AppColors.darkGray.withOpacity(0.5); // Dim text when disabled

    // Animation values
    final double scale = _isPressed ? 0.92 : 1.0;
    final double translateY = _isPressed ? 4.0 : 0.0;
    final double shadowOffset = _isPressed ? 2.0 : 8.0; // Deep shadow for arcade feel

    Widget buttonContent = Container(
      constraints: BoxConstraints(
        minWidth: widget.minWidth,
        minHeight: widget.minHeight,
      ),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: effectiveColor,
        border: Border.all(
          color: isEnabled ? AppColors.pureBlack : AppColors.darkGray,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: isEnabled 
            ? [
                BoxShadow(
                  color: AppColors.pureBlack,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                ),
                // Optional neon glow for primary buttons
                if (widget.isPrimary && !_isPressed)
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
              ] 
            : [], // No shadow when disabled
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: effectiveTextColor,
              size: 24,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: isEnabled ? [
                Shadow(
                  color: widget.color.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 0,
                )
              ] : null,
            ),
          ),
        ],
      ),
    );

    // Apply idle pulse if primary and enabled
    if (widget.isPrimary && isEnabled) {
      buttonContent = buttonContent
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 1500.ms);
    }

    return GestureDetector(
      onTapDown: isEnabled ? (_) {
        setState(() => _isPressed = true);
        widget.onPressDown?.call();
      } : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        transform: Matrix4.identity()
          ..scale(scale)
          ..translate(0.0, translateY),
        child: buttonContent,
      ),
    );
  }
}
