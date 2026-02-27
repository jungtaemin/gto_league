import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

/// 요일별 게임 모드 배너 위젯 (Neo-Brutalism)
class ScheduleModeBanner extends StatelessWidget {
  final bool isDeepStackDay;
  final int todayWeekday; // 1=Mon ~ 7=Sun

  const ScheduleModeBanner({
    super.key,
    required this.isDeepStackDay,
    required this.todayWeekday,
  });

  @override
  Widget build(BuildContext context) {
    // 요일 데이터 구성 (일~토)
    final days = [
      {'label': '일', 'weekday': 7, 'isDeepStack': false},
      {'label': '월', 'weekday': 1, 'isDeepStack': false},
      {'label': '화', 'weekday': 2, 'isDeepStack': false},
      {'label': '수', 'weekday': 3, 'isDeepStack': true},
      {'label': '목', 'weekday': 4, 'isDeepStack': true},
      {'label': '금', 'weekday': 5, 'isDeepStack': true},
      {'label': '토', 'weekday': 6, 'isDeepStack': true},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDeepStackDay
              ? const [Color(0xFFFBBF24), Color(0xFFB45309)] // Gold gradient
              : const [Color(0xFF1E293B), Color(0xFF0F172A)], // Dark slate
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pureBlack, width: 4),
        boxShadow: const [
          BoxShadow(
            color: AppColors.pureBlack,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isDeepStackDay ? '🔥 30BB DEEP STACK' : '⚡ 15BB CLASSIC LEAGUE',
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: 24,
              color: isDeepStackDay ? AppColors.pureBlack : AppColors.pureWhite,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            isDeepStackDay ? '수목금토 딥스택 모드' : '일월화 클래식 리그',
            style: TextStyle(
              fontFamily: 'Jua',
              fontSize: 16,
              color: isDeepStackDay
                  ? AppColors.pureBlack.withValues(alpha: 0.8)
                  : AppColors.pureWhite.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          // Weekday row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = day['weekday'] == todayWeekday;
              final isDeep = day['isDeepStack'] as bool;
              final label = day['label'] as String;

              return Transform.scale(
                scale: isToday ? 1.15 : 1.0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDeep
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF374151),
                    border: Border.all(
                      color: isToday ? AppColors.pureWhite : AppColors.pureBlack,
                      width: isToday ? 2 : 1.5,
                    ),
                    boxShadow: isToday
                        ? [
                            const BoxShadow(
                              color: AppColors.pureWhite,
                              offset: Offset(0, 0),
                              blurRadius: 0, // Zero blur for Neo-Brutalism
                              spreadRadius: 2,
                            )
                          ]
                        : const [
                            BoxShadow(
                              color: AppColors.pureBlack,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            )
                          ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 14,
                      color: isDeep ? AppColors.pureBlack : AppColors.pureWhite,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.05,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );
  }
}
