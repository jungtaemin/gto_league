import 'package:flutter/material.dart';
import 'robot_avatar_painter.dart';
import 'chip_stack_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// A widget representing a single player seat at the poker table.
/// 
/// Displays the player's avatar, position, stack size, and current action.
/// Handles folded state, active turn state, and hero highlighting.
class PlayerSeatWidget extends StatelessWidget {
  /// The position name (e.g., "UTG", "SB", "BB")
  final String position;
  
  /// The seat index (0-8) used for avatar color generation
  final int seatIndex;
  
  /// The current action ('fold', 'call', 'raise', '3bet', 'push', or null)
  final String? action;
  
  /// The current bet amount in front of the player
  final double? betAmount;
  
  /// Whether this seat belongs to the hero (the user)
  final bool isHero;
  
  /// Whether it is currently this player's turn
  final bool isCurrentTurn;
  
  /// The player's current stack size in BB
  final double stackSize;

  /// Optional custom avatar asset path (e.g., equipped character)
  final String? avatarUrl;

  /// Direction vector pointing to the center of the table (for chip sliding)
  final Offset? centerVector;

  const PlayerSeatWidget({
    super.key,
    required this.position,
    required this.seatIndex,
    this.action,
    this.betAmount,
    this.isHero = false,
    this.isCurrentTurn = false,
    this.stackSize = 30.0,
    this.avatarUrl,
    this.centerVector,
  });

  /// Builds the action badge based on the current action string
  Widget _buildActionBadge(String actionStr) {
    Color badgeColor;
    String badgeText = actionStr.toUpperCase();

    switch (actionStr.toLowerCase()) {
      case 'call':
        badgeColor = AppColors.pokerTableActionCall;
        break;
      case 'raise':
        badgeColor = AppColors.pokerTableActionRaise;
        break;
      case '3bet':
        badgeColor = AppColors.pokerTableActionRaise;
        break;
      case 'push':
        badgeColor = AppColors.pokerTableActionAllin;
        badgeText = 'ALL-IN';
        break;
      default:
        badgeColor = AppColors.pokerTableFoldGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.pureBlack, width: 1),
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.caption(color: AppColors.pureWhite).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFolded = action?.toLowerCase() == 'fold';

    final double avatarSize = context.w(55); // Significantly increased size (scaled pixels, not %)
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center, // Align chips to start at the center
      children: [
        // 1. Base Layout (Avatar + Action Badges)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        // Avatar + Info Badge Stack
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Avatar with extra bottom padding to accommodate overlapping badge
            Padding(
              padding: EdgeInsets.only(bottom: context.w(3)),
              child: Container(
                decoration: isCurrentTurn
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppColors.pokerTableGlow(AppColors.pokerTableActiveGlow),
                      )
                    : null,
                child: RobotAvatarWidget(
                  seatIndex: seatIndex,
                  size: avatarSize,
                  isActive: isCurrentTurn,
                  isFolded: isFolded,
                  isHero: isHero,
                  avatarUrl: avatarUrl, // Use custom avatar URL if available
                ),
              ),
            ),
            
            // Name (Position) & Stack Badge overlapping the bottom of the avatar
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      position,
                      style: AppTextStyles.caption(
                        color: isFolded ? AppColors.pokerTableFoldGray : AppColors.pureWhite,
                      ).copyWith(fontSize: 10, height: 1.1),
                    ),
                    Text(
                      '${stackSize.toInt()}BB',
                      style: AppTextStyles.caption(
                        color: isFolded ? AppColors.pokerTableFoldGray : AppColors.pureWhite,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: context.w(1)),
        
            if (isFolded)
              Text(
                'FOLD',
                style: AppTextStyles.caption(color: AppColors.pokerTableFoldGray).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (action != null)
              _buildActionBadge(action!),
          ],
        ),
        
        // 2. Betting Chips (Sliding out towards center)
        if (betAmount != null && betAmount! > 0 && !isFolded)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, val, child) {
              // Sliding distance (scaled pixels)
              final double distance = context.w(50) * val;
              final double dx = (centerVector?.dx ?? 0) * distance;
              final double dy = (centerVector?.dy ?? 0) * distance;
              
              return Transform.translate(
                offset: Offset(dx, dy),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChipStackWidget(
                  amount: betAmount!,
                  size: ChipSize.small,
                ),
                SizedBox(height: context.w(1)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${betAmount == betAmount!.toInt() ? betAmount!.toInt() : betAmount!}BB',
                    style: AppTextStyles.caption(color: AppColors.pureWhite).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
