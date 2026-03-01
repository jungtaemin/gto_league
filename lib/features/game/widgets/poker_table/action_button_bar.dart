import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/haptic_manager.dart';

/// Bottom action button bar with 4 poker action buttons.
///
/// Displays Fold / Call / Raise / All-in buttons in a horizontal row.
/// Buttons are disabled (opacity 0.3, no interaction) when [isEnabled] is false.
class ActionButtonBar extends StatelessWidget {
  final VoidCallback? onFold;
  final VoidCallback? onCall;
  final VoidCallback? onRaise;
  final VoidCallback? onAllin;

  /// Whether buttons are interactive (YOUR TURN state)
  final bool isEnabled;

  /// Optional call amount label (e.g., '1BB', '2.2BB')
  final String? callAmount;

  const ActionButtonBar({
    super.key,
    this.onFold,
    this.onCall,
    this.onRaise,
    this.onAllin,
    required this.isEnabled,
    this.callAmount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(8),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3), // Subtle backdrop
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _PokerActionButton(
                  label: '폴드',
                  gradientColors: const [Color(0xFF3b3d40), Color(0xFF1c1d1e)],
                  textColor: Colors.white.withValues(alpha: 0.7),
                  onTap: onFold,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: _PokerActionButton(
                  label: '콜',
                  subLabel: callAmount,
                  gradientColors: const [Color(0xFF2C5A96), Color(0xFF142B4D)],
                  textColor: Colors.white,
                  onTap: onCall,
                  isHighlight: true, // blue glow
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: _PokerActionButton(
                  label: '레이즈',
                  gradientColors: const [Color(0xFFd4943f), Color(0xFF6b420f)],
                  textColor: Colors.white,
                  onTap: onRaise,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: _PokerActionButton(
                  label: '올인',
                  gradientColors: const [Color(0xFFC02A2A), Color(0xFF5A1010)],
                  textColor: Colors.white,
                  onTap: onAllin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium individual poker action button with press animation, 
/// gradients, and inner stroke beveled effect.
class _PokerActionButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final List<Color> gradientColors;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isHighlight;

  const _PokerActionButton({
    required this.label,
    this.subLabel,
    required this.gradientColors,
    required this.textColor,
    this.onTap,
    this.isHighlight = false,
  });

  @override
  State<_PokerActionButton> createState() => _PokerActionButtonState();
}

class _PokerActionButtonState extends State<_PokerActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticManager.swipe();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          // Correct logical pixel scale sizing
          padding: EdgeInsets.symmetric(vertical: context.h(16), horizontal: context.w(4)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.w(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.gradientColors,
            ),
            boxShadow: [
              // Outer drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
              // Inner top highlight for 3D metallic feel
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                offset: const Offset(0, 1.5),
                blurRadius: 1,
                spreadRadius: -1,
              ),
              // Light glow if highlighted
              if (widget.isHighlight)
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
            // Outer stroke
            border: Border.all(
              color: widget.isHighlight 
                ? Colors.white.withValues(alpha: 0.3) 
                : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Optional Value Text above the main text (like reference image where 1BB is above Call)
              if (widget.subLabel != null && widget.subLabel!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: context.h(4)),
                  child: Text(
                    widget.subLabel!,
                    style: TextStyle(
                      color: widget.textColor.withValues(alpha: 0.8),
                      fontSize: context.w(12),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Main Action Text (Call, Fold, Raise)
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: context.w(18),
                  fontWeight: FontWeight.w800, // Very bold for actions
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      offset: const Offset(0, 1.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
