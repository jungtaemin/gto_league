import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';


/// Neo-Brutalist card widget with premium game feel
/// 
/// Features:
/// - 4px black border
/// - Dynamic shadow depth (press animation)
/// - Inner gradient lighting
/// - Optional neon glow
/// - Idle floating animation
class NeoBrutalistCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? glowColor; // New: Optional neon glow
  final bool enableHoverEffect; // New: For mouse users

  const NeoBrutalistCard({
    super.key,
    required this.child,
    this.color = AppColors.darkGray,
    this.padding,
    this.borderRadius = 12,
    this.onTap,
    this.width,
    this.height,
    this.glowColor,
    this.enableHoverEffect = false,
  });

  @override
  State<NeoBrutalistCard> createState() => _NeoBrutalistCardState();
}

class _NeoBrutalistCardState extends State<NeoBrutalistCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Shadow logic: 8px default, 2px pressed
    final double shadowOffset = _isPressed ? 2.0 : 8.0;
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: MouseRegion(
        onEnter: widget.enableHoverEffect ? (_) => setState(() => _isHovered = true) : null,
        onExit: widget.enableHoverEffect ? (_) => setState(() => _isHovered = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: 200.ms,
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: 100.ms,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isPressed 
                  ? Color.lerp(widget.color, Colors.white, 0.1) // Brighten on press
                  : widget.color,
              border: Border.all(
                color: AppColors.pureBlack,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                // Hard shadow
                BoxShadow(
                  color: AppColors.pureBlack,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                ),
                // Optional neon glow
                if (widget.glowColor != null)
                  BoxShadow(
                    color: widget.glowColor!.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Inner gradient for depth (light top-left to dark bottom-right)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius - 4),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                widget.child,
              ],
            ),
          ),
        ),
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .moveY(begin: -2, end: 2, duration: 3000.ms, curve: Curves.easeInOutSine) // Idle float
      .animate() // Entrance
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.05, duration: 400.ms, curve: Curves.easeOutQuad),
    );
  }
}
