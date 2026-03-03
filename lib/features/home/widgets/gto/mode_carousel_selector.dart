import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

enum CarouselModeType {
  league,     // 15BB Classic League (Sun, Mon, Tue)
  omniSwipe,  // 30BB Deep Stack (Wed, Thu, Fri, Sat)
}

class ModeCarouselSelector extends StatefulWidget {
  final int todayWeekday; // 1=Mon ~ 7=Sun
  final ValueChanged<CarouselModeType> onModeChanged;
  final ValueChanged<CarouselModeType>? onPlayPressed;

  const ModeCarouselSelector({
    super.key,
    required this.todayWeekday,
    required this.onModeChanged,
    this.onPlayPressed,
  });

  @override
  State<ModeCarouselSelector> createState() => _ModeCarouselSelectorState();
}

class _ModeCarouselSelectorState extends State<ModeCarouselSelector> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 초기 페이지 설정: 오늘은 일월화 중 하나면 0(리그), 아니면 1(딥스택)
    _currentPage = [7, 1, 2].contains(widget.todayWeekday) ? 0 : 1;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.82, // 양옆 카드가 살짝 보이게
    );

    // 부모 위젯에 초기값 콜백
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onModeChanged(_currentPage == 0 ? CarouselModeType.league : CarouselModeType.omniSwipe);
      }
    });

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
        widget.onModeChanged(_currentPage == 0 ? CarouselModeType.league : CarouselModeType.omniSwipe);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.w(190),
      child: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          // 15BB 클래식 리그 카드
          _buildCard(
            context: context,
            modeType: CarouselModeType.league,
            pageIndex: 0,
            title: '⚡ 15BB 블리츠 서바이벌',
            subtitle: '0.1초의 결단! 푸쉬/폴드 마스터링',
            activeWeekdays: const [7, 1, 2], // 일, 월, 화
            daysLabels: const ['일', '월', '화'],
            gradientColors: const [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
            accentColor: const Color(0xFF38BDF8),
            imageAsset: 'assets/images/banner/15BB_swipe.webp',
          ),
          // 30BB 딥스택 마스터즈 카드
          _buildCard(
            context: context,
            modeType: CarouselModeType.omniSwipe,
            pageIndex: 1,
            title: '🔥 30BB 딥스택 마스터즈',
            subtitle: '리버까지 가는 진검승부! 포지션 전략',
            activeWeekdays: const [3, 4, 5, 6], // 수, 목, 금, 토
            daysLabels: const ['수', '목', '금', '토'],
            gradientColors: const [Color(0xFF450A0A), Color(0xFF991B1B), Color(0xFFF97316)],
            accentColor: const Color(0xFFFBBF24),
            imageAsset: 'assets/images/banner/30BB_DEEP.webp',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required CarouselModeType modeType,
    required int pageIndex,
    required String title,
    required String subtitle,
    required List<int> activeWeekdays,
    required List<String> daysLabels,
    required List<Color> gradientColors,
    required Color accentColor,
    String? imageAsset,
  }) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - pageIndex;
          value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
        } else {
          value = pageIndex == _currentPage ? 1.0 : 0.85;
        }

        final isFocused = _currentPage == pageIndex;
        final isOpenToday = activeWeekdays.contains(widget.todayWeekday);

        return Center(
          child: Transform.scale(
            scale: value,
            child: Opacity(
              opacity: isFocused ? 1.0 : 0.4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: context.w(8)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.r(24)),
                      gradient: imageAsset == null ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ) : null,
                      image: imageAsset != null ? DecorationImage(
                        image: AssetImage(imageAsset),
                        fit: BoxFit.cover,
                      ) : null,
                      border: Border.all(
                        color: isFocused ? accentColor.withOpacity(0.8) : Colors.white10,
                        width: isFocused ? 2 : 1,
                      ),
                      boxShadow: isFocused ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        )
                      ] : [],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 텍스트 영역
                          if (imageAsset == null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'Black Han Sans',
                                    fontSize: context.sp(20),
                                    color: Colors.white,
                                    height: 1.1,
                                    shadows: [
                                      Shadow(color: accentColor.withOpacity(0.5), offset: const Offset(0, 0), blurRadius: 8),
                                      const Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: context.w(6)),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Jua',
                                    fontSize: context.sp(13),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),
                          
                          // 하단: 요일 표시 영역 + 플레이 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // 기존 요일 표시 Row
                              Row(
                                children: List.generate(daysLabels.length, (index) {
                                  final dayLabel = daysLabels[index];
                                  final dayInt = activeWeekdays[index];
                                  final isToday = dayInt == widget.todayWeekday;
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(right: context.w(6)),
                                    child: Container(
                                      width: context.w(26),
                                      height: context.w(26),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isToday ? accentColor : Colors.black.withOpacity(0.4),
                                        border: Border.all(
                                          color: isToday ? Colors.white : Colors.white30,
                                          width: isToday ? 2 : 1,
                                        ),
                                        boxShadow: isToday ? [
                                          BoxShadow(color: accentColor.withOpacity(0.8), blurRadius: 8, spreadRadius: 1)
                                        ] : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontFamily: 'Jua',
                                          fontSize: context.sp(12),
                                          color: isToday ? Colors.black : Colors.white,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              
                              // 플레이 버튼 (포커스되었고 열려있을 때만 노출)
                              if (isFocused && isOpenToday)
                                GestureDetector(
                                  onTap: () {
                                    widget.onPlayPressed?.call(modeType);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(8)),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(context.r(20)),
                                      boxShadow: [
                                        BoxShadow(color: accentColor.withOpacity(0.6), blurRadius: 8, offset: const Offset(0, 4)),
                                      ],
                                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '입장하기', 
                                          style: TextStyle(
                                            fontFamily: 'Black Han Sans',
                                            fontSize: context.sp(14),
                                            color: Colors.black87,
                                          )
                                        ),
                                        SizedBox(width: context.w(4)),
                                        Icon(Icons.play_arrow_rounded, color: Colors.black87, size: context.w(18)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (!isOpenToday)
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: context.w(8)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.r(24)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.6),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, size: context.w(40), color: Colors.white60),
                                  SizedBox(height: context.w(4)),
                                  Text(
                                    "오늘은 오픈되지 않았습니다",
                                    style: TextStyle(
                                      fontFamily: 'Jua',
                                      fontSize: context.sp(14),
                                      color: Colors.white70,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
