import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

/// 🎯 Rival targeting badge — shows point gap to overtake the player above.
/// Appears as a trailing widget on the rival's league card row.
class RivalBadge extends StatelessWidget {
  const RivalBadge({
    super.key,
    required this.pointGap,
  });

  /// Points needed to overtake the rival ranked just above.
  final int pointGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(8),
        vertical: context.w(3),
      ),
      decoration: BoxDecoration(
        color: AppColors.leagueRivalTarget.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(
          color: AppColors.leagueRivalTarget.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        '🎯 역전까지 -$pointGap점!',
        style: TextStyle(
          color: AppColors.leagueRivalTarget,
          fontSize: context.sp(9),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
