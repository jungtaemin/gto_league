import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';
import '../../../core/widgets/neo_brutalist_button.dart';

class FactBombBottomSheet extends StatefulWidget {
  final String factBombMessage;
  final String position;
  final String hand;
  final double evBb;
  final VoidCallback onDismiss;

  const FactBombBottomSheet({
    super.key,
    required this.factBombMessage,
    required this.position,
    required this.hand,
    required this.evBb,
    required this.onDismiss,
  });

  @override
  State<FactBombBottomSheet> createState() => _FactBombBottomSheetState();
}

class _FactBombBottomSheetState extends State<FactBombBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _emojiScale;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _msgSlide;
  late Animation<double> _msgFade;
  late Animation<double> _infoFade;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _emojiScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _msgFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.65)),
    );
    _msgSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.65, curve: Curves.easeOutBack)),
    );
    _infoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8)),
    );
    _btnFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );
    _btnSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChicken = widget.factBombMessage.contains("쫄보");
    final emoji = isChicken ? "🐔" : "🚨";

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.acidYellow, width: 3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              ...AppColors.neonGlow(AppColors.acidYellow, intensity: 0.3),
              ...AppShadows.neonHardShadow(AppColors.acidYellow),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji with scale animation
              Transform.scale(
                scale: _emojiScale.value,
                child: Text(emoji, style: const TextStyle(fontSize: 60)),
              ),
              const SizedBox(height: 16),

              // Title with slide + fade animation
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: const NeonText(
                    "FACT BOMB!",
                    color: AppColors.neonPink,
                    fontSize: 32,
                    strokeWidth: 2.5,
                    glowIntensity: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Message with slide + fade animation
              SlideTransition(
                position: _msgSlide,
                child: FadeTransition(
                  opacity: _msgFade,
                  child: Text(
                    widget.factBombMessage,
                    style: AppTextStyles.factBomb(color: AppColors.pureWhite),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info panel with fade animation
              FadeTransition(
                opacity: _infoFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlack,
                    border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.innerGlow(AppColors.electricBlue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoItem(widget.position, AppColors.neonCyan),
                      _buildSeparator(),
                      _buildInfoItem(widget.hand, AppColors.acidGreen),
                      _buildSeparator(),
                      _buildInfoItem(
                        "${widget.evBb >= 0 ? '+' : ''}${widget.evBb.toStringAsFixed(1)} BB",
                        widget.evBb >= 0 ? AppColors.acidGreen : AppColors.laserRed,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Button with slide + fade animation
              SlideTransition(
                position: _btnSlide,
                child: FadeTransition(
                  opacity: _btnFade,
                  child: NeoBrutalistButton(
                    label: "확인",
                    isPrimary: true,
                    color: AppColors.acidYellow,
                    textColor: AppColors.deepBlack,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String text, Color color) {
    return NeonText(
      text,
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      glowIntensity: 0.8,
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        "|",
        style: TextStyle(
          color: AppColors.darkGray.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Future<void> showFactBombModal(
  BuildContext context, {
  required String factBombMessage,
  required String position,
  required String hand,
  required double evBb,
  required VoidCallback onDismiss,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => FactBombBottomSheet(
      factBombMessage: factBombMessage,
      position: position,
      hand: hand,
      evBb: evBb,
      onDismiss: onDismiss,
    ),
  ).then((_) => onDismiss());
}
