import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../providers/user_stats_provider.dart';
import '../../../../core/widgets/bouncing_button.dart';
import 'stitch_colors.dart';

class GtoTopBar extends ConsumerWidget {
  const GtoTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = SupabaseService.isLoggedIn;
        final displayName = SupabaseService.displayName ?? 'Guest';
        final avatarUrl = SupabaseService.avatarUrl;

        return Padding(
          // 모든 간격을 w() 기준으로 통일
          padding: EdgeInsets.fromLTRB(context.w(16), context.w(12), context.w(16), context.w(6)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. LEFT SIDE: Profile
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfileBadge(context, isLoggedIn, displayName, avatarUrl),
                  ],
                ),
              ),

              SizedBox(width: context.w(6)),

              // 2. CENTER: Chip Badge
              Flexible(
                flex: 3,
                child: _buildChipBadge(context, ref),
              ),

              SizedBox(width: context.w(6)),

              // 3. RIGHT SIDE: Energy & Settings
              Flexible(
                flex: 2,
                child: _buildRightSection(context, ref),
              ),
            ],
          ),
        );
      }
    );
  }


  Widget _buildChipBadge(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final chipText = _formatNumber(stats.chips);
    return Container(
      padding: EdgeInsets.all(context.w(3)),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: StitchColors.slate600),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(24), height: context.w(24),
            margin: EdgeInsets.only(right: context.w(6)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: Icon(Icons.savings_rounded, color: StitchColors.yellow500, size: context.w(14)),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("보유 칩", style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(9), height: 1.0)),
                Text(chipText, style: TextStyle(color: Colors.white, fontSize: context.sp(12), fontWeight: FontWeight.bold, height: 1.0)),
              ],
            ),
          ),
          SizedBox(width: context.w(4)),
          Container(
            width: context.w(20), height: context.w(20),
            decoration: BoxDecoration(
              color: StitchColors.green500,
              shape: BoxShape.circle,
              border: Border.all(color: StitchColors.green400),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Icon(Icons.add, color: Colors.white, size: context.w(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final currentEnergy = stats.calculatedEnergy;
    final isFull = currentEnergy >= stats.maxEnergy;

    // 디자인 테마: Blue 계열
    final mainColor = isFull ? StitchColors.green400 : StitchColors.blue400;
    
    // 타이머 텍스트
    String timerText = "";
    if (!isFull) {
      final remaining = stats.timeUntilNextRefill;
      if (remaining != null) {
        final min = remaining.inMinutes;
        final sec = remaining.inSeconds % 60;
        timerText = '$min:${sec.toString().padLeft(2, '0')}';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none, // 말풍선이 영역 밖으로 나가도 보이게 함
          alignment: Alignment.center,
          children: [
            // 1. 메인 에너지 바
            Container(
              height: context.w(30),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(context.r(15)),
                border: Border.all(
                  color: mainColor.withOpacity(0.6), 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(15)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(12)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 아이콘
                          Icon(
                            Icons.bolt_rounded,
                            color: isFull ? StitchColors.green400 : StitchColors.yellow300,
                            size: context.w(16),
                          )
                          .animate(target: isFull ? 1 : 0)
                          .shimmer(duration: 2.seconds, delay: 3.seconds)
                          .then()
                          .shake(hz: 4, offset: const Offset(2, 0), duration: 200.ms),

                          SizedBox(width: context.w(6)),

                          // 에너지 텍스트 (4 / 10)
                          Text(
                            isFull ? "MAX" : "$currentEnergy",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (!isFull) ...[
                            Text(
                              "/", 
                              style: TextStyle(color: Colors.white38, fontSize: context.sp(12))
                            ),
                            Text(
                              "${stats.maxEnergy}",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. 타이머 말풍선 (Tooltip) - 하단에 둥둥 떠있음
            if (!isFull)
              Positioned(
                bottom: -context.w(22), // 바 아래로 배치
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 꼬리 (위쪽 화살표)
                    Transform.translate(
                      offset: const Offset(0, 5), // 바짝 붙이기
                      child: Icon(Icons.arrow_drop_up_rounded, color: StitchColors.blue900, size: context.w(20)),
                    ),
                    // 말풍선 본체
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.w(2)),
                      decoration: BoxDecoration(
                        color: StitchColors.blue900, // 진한 파랑 배경
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                        border: Border.all(color: StitchColors.blue500.withOpacity(0.3), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, color: StitchColors.blue200, size: context.w(10)),
                          SizedBox(width: context.w(3)),
                          Text(
                            timerText,
                            style: TextStyle(
                              color: StitchColors.blue100, // 밝은 텍스트
                              fontSize: context.sp(10),
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                .animate(onPlay: (c) => c.repeat(reverse: true)) // 무한 반복
                .moveY(begin: 0, end: -3, duration: 1.5.seconds, curve: Curves.easeInOut), // 둥둥 효과
              ),
          ],
        ),

      ],
    );
  }

  Widget _buildProfileBadge(BuildContext context, bool isLoggedIn, String displayName, String? avatarUrl) {
    return BouncingButton(
      onTap: () {
        if (!isLoggedIn) {
          Navigator.pushNamed(context, '/login');
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('로그아웃 하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await SupabaseService.signOut();
                  }, 
                  child: const Text('로그아웃')
                ),
              ],
            )
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(right: context.w(10), top: context.w(3), bottom: context.w(3), left: context.w(3)),
        decoration: BoxDecoration(
          color: isLoggedIn 
              ? StitchColors.blue900.withOpacity(0.9) 
              : StitchColors.slate700.withOpacity(0.9),
          borderRadius: BorderRadius.circular(context.r(20)),
          border: Border.all(
            color: isLoggedIn ? StitchColors.blue400 : StitchColors.slate600,
            width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: isLoggedIn ? StitchColors.blue600.withOpacity(0.3) : Colors.black45,
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: context.w(28), height: context.w(28),
              margin: EdgeInsets.only(right: context.w(6)),
              decoration: BoxDecoration(
                color: StitchColors.bgDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLoggedIn ? StitchColors.blue300 : StitchColors.slate500, 
                  width: 1.5
                ),
                image: (isLoggedIn && avatarUrl != null) 
                    ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: (isLoggedIn && avatarUrl != null) 
                  ? null 
                  : Icon(
                      Icons.person_rounded, 
                      color: isLoggedIn ? StitchColors.blue200 : StitchColors.slate400, 
                      size: context.w(16)
                    ),
            ),
            
            // Text Info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoggedIn)
                    Text(
                      "플레이어", 
                      style: TextStyle(
                        color: StitchColors.blue300, 
                        fontSize: context.sp(9), 
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  Text(
                    isLoggedIn ? displayName : "로그인", 
                    style: TextStyle(
                      color: isLoggedIn ? Colors.white : StitchColors.slate300, 
                      fontSize: context.sp(12), 
                      fontWeight: FontWeight.bold, 
                      height: 1.1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 숫자를 1,000 단위 쉼표 포맷
  String _formatNumber(int n) {
    if (n < 1000) return '$n';
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
