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
        child: Row(
          children: [
            Expanded(
              child: _PokerActionButton(
                label: '폴드',
                color: AppColors.pokerTableActionFold,
                textColor: AppColors.pureWhite,
                onTap: onFold,
              ),
            ),
            Expanded(
              child: _PokerActionButton(
                label: '콜',
                subLabel: callAmount,
                color: AppColors.pokerTableActionCall,
                textColor: AppColors.pureWhite,
                onTap: onCall,
              ),
            ),
            Expanded(
              child: _PokerActionButton(
                label: '레이즈',
                color: AppColors.pokerTableActionRaise,
                textColor: AppColors.pureBlack,
                onTap: onRaise,
              ),
            ),
            Expanded(
              child: _PokerActionButton(
                label: '올인',
                color: AppColors.pokerTableActionAllin,
                textColor: AppColors.pureWhite,
                onTap: onAllin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual poker action button with press animation.
class _PokerActionButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _PokerActionButton({
    required this.label,
    this.subLabel,
    required this.color,
    required this.textColor,
    this.onTap,
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
          padding: EdgeInsets.symmetric(vertical: context.h(1.2)),
          margin: EdgeInsets.symmetric(horizontal: context.w(0.5)),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(context.w(2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodySmall(
                  color: widget.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.subLabel != null && widget.subLabel!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: context.h(0.2)),
                  child: Text(
                    widget.subLabel!,
                    style: AppTextStyles.caption(
                      color: widget.textColor.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
