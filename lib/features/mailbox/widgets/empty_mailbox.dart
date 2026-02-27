import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/responsive.dart';
import '../../home/widgets/gto/stitch_colors.dart';

/// 우편함 빈 상태 위젯 — 수령할 우편이 없을 때 표시.
class EmptyMailbox extends StatelessWidget {
  const EmptyMailbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: context.w(64),
              color: StitchColors.slate500.withOpacity(0.3),
            ),
            SizedBox(height: context.w(16)),
            Text(
              '수령할 우편이 없습니다',
              style: TextStyle(
                color: StitchColors.slate400,
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.w(8)),
            Text(
              '새로운 우편이 도착하면 알려드릴게요!',
              style: TextStyle(
                color: StitchColors.slate500,
                fontSize: context.sp(13),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, duration: 400.ms);
  }
}
