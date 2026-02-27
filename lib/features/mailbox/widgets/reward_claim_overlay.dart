import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../home/widgets/gto/stitch_colors.dart';

/// 보상 수령 축하 오버레이 — 컨페티 + 보상 표시 + 자동 닫기.
class RewardClaimOverlay extends StatefulWidget {
  final int chips;
  final int energy;
  final VoidCallback onComplete;

  const RewardClaimOverlay({
    super.key,
    this.chips = 0,
    this.energy = 0,
    required this.onComplete,
  });

  @override
  State<RewardClaimOverlay> createState() => _RewardClaimOverlayState();
}

class _RewardClaimOverlayState extends State<RewardClaimOverlay>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    // 3.5초 후 자동 닫기
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 컨페티 파티클
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.06,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                StitchColors.primary,
                StitchColors.cyan400,
                StitchColors.purple400,
                StitchColors.green400,
                StitchColors.yellow300,
              ],
            ),
          ),
          // 보상 정보
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '보상 획득!',
                style: TextStyle(
                  color: StitchColors.primary,
                  fontSize: context.sp(24),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: StitchColors.primary.withOpacity(0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 200.ms),
              SizedBox(height: context.w(24)),
              if (widget.chips > 0)
                _buildRewardItem(
                  context,
                  Icons.monetization_on_rounded,
                  StitchColors.yellow400,
                  '+${_formatNumber(widget.chips)}',
                  '칩',
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms)
                    .slideY(
                        begin: 0.3, duration: 300.ms, delay: 200.ms),
              if (widget.chips > 0 && widget.energy > 0)
                SizedBox(height: context.w(12)),
              if (widget.energy > 0)
                _buildRewardItem(
                  context,
                  Icons.bolt_rounded,
                  StitchColors.cyan400,
                  '+${widget.energy}',
                  '에너지',
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 300.ms)
                    .slideY(
                        begin: 0.3, duration: 300.ms, delay: 400.ms),
              SizedBox(height: context.w(32)),
              BouncingButton(
                onTap: widget.onComplete,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(32),
                    vertical: context.w(12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(context.r(24)),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: StitchColors.slate200,
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    BuildContext context,
    IconData icon,
    Color color,
    String amount,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(24),
        vertical: context.w(12),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: context.w(28)),
          SizedBox(width: context.w(12)),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: context.sp(28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: context.w(8)),
          Text(
            label,
            style: TextStyle(
              color: StitchColors.slate300,
              fontSize: context.sp(14),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: color.withOpacity(0.3));
  }
}
