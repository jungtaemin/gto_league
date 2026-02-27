import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// 30초 원형 카운트다운 타이머 위젯
/// 
/// 포커 테이블에서 플레이어의 액션 시간을 표시합니다.
/// - 30-10초: 안전 (초록색)
/// - 10-5초: 경고 (노란색)
/// - 5-0초: 위험 (빨간색)
class TableTimerWidget extends StatefulWidget {
  /// 타이머 지속 시간 (초 단위, 기본값: 30)
  final int duration;

  /// 타이머가 0에 도달했을 때 호출되는 콜백
  final VoidCallback onTimeout;

  /// 타이머 실행 여부
  final bool isRunning;

  /// 타이머 일시 정지 여부
  final bool isPaused;

  const TableTimerWidget({
    super.key,
    this.duration = 30,
    required this.onTimeout,
    this.isRunning = false,
    this.isPaused = false,
  });

  @override
  State<TableTimerWidget> createState() => _TableTimerWidgetState();
}

class _TableTimerWidgetState extends State<TableTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    if (widget.isRunning) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeout();
      }
    });
  }

  @override
  void didUpdateWidget(TableTimerWidget old) {
    super.didUpdateWidget(old);

    // 일시 정지 처리
    if (widget.isPaused && !old.isPaused) {
      _controller.stop();
    }

    // 재개 처리
    if (!widget.isPaused && old.isPaused && widget.isRunning) {
      _controller.forward(from: _controller.value);
    }

    // 실행 시작 처리
    if (widget.isRunning && !old.isRunning) {
      _controller.forward();
    }

    // 실행 중지 처리
    if (!widget.isRunning && old.isRunning) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 남은 시간(초)을 계산합니다.
  /// 진행률(0.0~1.0)을 역으로 계산하여 남은 시간을 구합니다.
  int _getRemainingSeconds() {
    final progress = 1.0 - _controller.value;
    return (progress * widget.duration).ceil();
  }

  /// 남은 시간에 따라 타이머 색상을 결정합니다.
  Color _getTimerColor(int remainingSeconds) {
    if (remainingSeconds > 10) {
      return AppColors.pokerTableTimerSafe; // 초록색
    } else if (remainingSeconds > 5) {
      return AppColors.pokerTableTimerWarning; // 노란색
    } else {
      return AppColors.pokerTableTimerDanger; // 빨간색
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remainingSeconds = _getRemainingSeconds();
        final timerColor = _getTimerColor(remainingSeconds);
        final progress = 1.0 - _controller.value;
        final diameter = context.w(12);

        return SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원형 진행 표시기
              CircularProgressIndicator(
                value: progress,
                strokeWidth: context.w(0.8),
                backgroundColor: AppColors.darkGray,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
              // 중앙 텍스트: 남은 시간(초)
              Text(
                remainingSeconds.toString(),
                style: AppTextStyles.heading(color: timerColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
