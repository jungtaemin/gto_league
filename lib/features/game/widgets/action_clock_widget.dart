import 'package:flutter/material.dart';
import '../../../data/services/timer_service.dart';

/// 15초 카운트다운 타이머 바 (Stitch V1 스타일)
/// game_screen.dart에서 인라인 위젯으로 대체되었지만, 재사용을 위해 유지.
class ActionClockWidget extends StatelessWidget {
  final double seconds;
  final TimerPhase phase;
  final double maxDuration;

  const ActionClockWidget({
    super.key,
    required this.seconds,
    required this.phase,
    this.maxDuration = 15.0,
  });

  static const _cyan = Color(0xFF22D3EE);
  static const _red = Color(0xFFEF4444);
  static const _purple = Color(0xFF818CF8);

  @override
  Widget build(BuildContext context) {
    final isCritical = phase == TimerPhase.critical;
    final isExpired = phase == TimerPhase.expired;
    final progress = (seconds / maxDuration).clamp(0.0, 1.0);

    Color barColor;
    if (isExpired || isCritical) {
      barColor = _red;
    } else {
      barColor = _cyan;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('남은 시간', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
              Text(
                '${seconds.toStringAsFixed(0)}s',
                style: TextStyle(
                  color: isCritical ? _red : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCritical
                          ? [_red, _red.withOpacity(0.7)]
                          : [_cyan, _purple],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: barColor.withOpacity(0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
