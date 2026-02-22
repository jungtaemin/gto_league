import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

/// Pulsing fever timer displayed in [LeagueHeader] subtitle area.
///
/// When [isFeverTime] is true (< 12h remaining), the text pulses red
/// to create urgency. Otherwise shows a calm countdown.
class FeverTimer extends StatelessWidget {
  const FeverTimer({
    super.key,
    required this.remainingDuration,
    required this.isFeverTime,
  });

  /// Time remaining until season ends.
  final Duration remainingDuration;

  /// True when remaining time is less than 12 hours.
  final bool isFeverTime;

  @override
  Widget build(BuildContext context) {
    final label = _formatRemaining();
    final color =
        isFeverTime ? AppColors.leagueFeverRed : AppColors.leagueMyHighlight;

    final text = Text(
      label,
      style: TextStyle(
        fontSize: context.sp(12),
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );

    if (!isFeverTime) return text;

    return Animate(
      key: const ValueKey('FeverTimer_Anim'),
      onPlay: (c) => c.repeat(reverse: true),
      effects: [
        TintEffect(color: AppColors.leagueFeverRed, duration: 800.ms),
        ScaleEffect(end: const Offset(1.03, 1.03), duration: 800.ms),
      ],
      child: text,
    );
  }

  String _formatRemaining() {
    if (remainingDuration.isNegative || remainingDuration == Duration.zero) {
      return '곧 시즌 종료 ⏳';
    }

    final days = remainingDuration.inDays;
    final hours = remainingDuration.inHours % 24;
    final minutes = remainingDuration.inMinutes % 60;

    if (days >= 1) {
      if (hours > 0) return '종료까지 $days일 $hours시간 남음 🔥';
      return '종료까지 $days일 남음 🔥';
    }

    if (hours >= 1) return '종료까지 $hours시간 $minutes분 남음 ⏰';

    if (minutes >= 1) return '종료까지 $minutes분 남음 ⚡';

    return '곧 시즌 종료 ⏳';
  }
}
