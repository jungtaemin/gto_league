import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/user_stats_provider.dart';
import '../models/map_node_data.dart';
import '../widgets/saga_map_background.dart';
import '../widgets/map_node_widget.dart';
import 'academy_screen.dart'; // 실제 학습 뷰
import '../../home/widgets/gto/gto_train_body.dart'; // 훈련하기 화면

class AcademyMapScreen extends ConsumerStatefulWidget {
  const AcademyMapScreen({super.key});

  @override
  ConsumerState<AcademyMapScreen> createState() => _AcademyMapScreenState();
}

class _AcademyMapScreenState extends ConsumerState<AcademyMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNodeTap(MapNodeData node, NodeStatus status) {
    if (status == NodeStatus.locked) return;

    // 듀오링고 스타일: 하단에서 올라오는 스테이지 정보 팝업
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 스테이지 레벨 & 아이콘
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: status == NodeStatus.completed ? const Color(0xFFFFC800) : const Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == NodeStatus.completed ? Icons.star_rounded : Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '스테이지 ${node.level}',
                          style: const TextStyle(
                            color: Color(0xFF8B8B8B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          node.title,
                          style: const TextStyle(
                            color: Color(0xFF4B4B4B),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 설명 영역
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Text(
                  node.description,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 학습 내용 순서 (타임라인)
              if (node.topics.isNotEmpty) ...[
                const Text(
                  '이 스테이지에서 배우는 내용',
                  style: TextStyle(
                    color: Color(0xFF4B4B4B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: List.generate(node.topics.length, (index) {
                      final isLast = index == node.topics.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 타임라인 인디케이터
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7FA), // 연한 민트/하늘 바탕
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF26C6DA), width: 2), // 외곽선
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF00ACC1), // 진한 청록 글씨
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 24,
                                  color: const Color(0xFFB2EBF2), // 연결 선
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // 주제 텍스트
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                node.topics[index],
                                style: const TextStyle(
                                  color: Color(0xFF4B4B4B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // 보상(XP) 배지
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '클리어 보상',
                    style: TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4CC), // 밝은 노랑
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '+${node.xpReward} XP',
                          style: const TextStyle(
                            color: Color(0xFFDCA900), // 진한 노랑
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 캐주얼한 "학습 시작" 젤리 버튼
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // 바텀시트 닫기
                  // 아카데미 진입
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AcademyScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            )),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF46A302),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '학습 시작',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              ),
            ],
          ),
        ).animate().slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(userStatsProvider);
    final userCurrentLevel = userStats.level;
    
    // 리스트를 뒤집어서 하단(레벨1)→상단(레벨10) 순으로 그리기
    final reversedNodes = dummyMapNodes.reversed.toList();

    // IndexedStack 내부에서 쓰이므로 Scaffold X, Stack으로 직접 구성
    return Stack(
      children: [
        // 1. 동적 카지노 아트웍 배경
        const Positioned.fill(
          child: SagaMapBackground(),
        ),

        // 2. 상단 헤더 (XP 표시)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 타이틀
                  const Text(
                    '학습 스테이지',
                    style: TextStyle(
                      color: Color(0xFF4B4B4B), // 진한 회색 (캐주얼 보색)
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // 경험치 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 24),
                        const SizedBox(width: 4),
                        Text(
                          '${userStats.xp}',
                          style: const TextStyle(
                            color: Color(0xFFFFC800),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. 지그재그 로드맵 리스트
        Positioned.fill(
          top: 90, // 헤더 높이
          bottom: 90, // 하단 네비게이션 바 높이
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 40),
            reverse: true, // 하단(1레벨)→상단(10레벨)
            itemCount: reversedNodes.length,
            itemBuilder: (context, index) {
              final node = reversedNodes[index];
              
              // 유저 레벨로 노드 상태 결정
              NodeStatus status;
              if (node.level < userCurrentLevel) {
                status = NodeStatus.completed;
              } else if (node.level == userCurrentLevel) {
                status = NodeStatus.current;
              } else {
                status = NodeStatus.locked;
              }

              // 지그재그 배치
              final screenWidth = MediaQuery.of(context).size.width;
              final maxOffset = (screenWidth / 2) - 80;
              final offsetX = maxOffset * node.xOffset;

              return SizedBox(
                height: 160, // 하단 배지 오버플로우 방지를 위해 높이 늘림
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 노드 연결선 (사용자 요청으로 제거함)
                    // 노드 위젯
                    Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: MapNodeWidget(
                        node: node,
                        status: status,
                        onTap: () => _onNodeTap(node, status),
                      ).animate().fadeIn(delay: (index * 100).ms, duration: 600.ms).slideY(begin: 0.3),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 4. 훈련하기 메뉴 진입 고정 아이콘 (우측 하단)
        Positioned(
          bottom: 110, // 네비게이션 바 위로 약간 띄움
          right: 20,
          child: GestureDetector(
            onTap: () {
              // 훈련하기(GtoTrainBody) 화면으로 직접 진입
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    backgroundColor: Color(0xFF0D1B2A),
                    body: SafeArea(child: GtoTrainBody()),
                  ),
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF1CB0F6), // 듀오링고 파란색 (훈련 테마)
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1899D6),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 28,
              ),
            ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
          ),
        ),
      ],
    );
  }
}

/// 노드 연결선 페인터 (베지어 곡선)
class _PathPainter extends CustomPainter {
  final double startX, startY, endX, endY;
  final bool isLocked;

  _PathPainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.isLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 캐주얼한 두툼한 라인
    final paint = Paint()
      ..color = isLocked ? const Color(0xFFE5E5E5) : const Color(0xFF58CC02)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 약간 더 입체감을 위해 선에 그림자 효과 추가
    final shadowPaint = Paint()
      ..color = isLocked ? const Color(0xFFD0D0D0) : const Color(0xFF46A302)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2 + startX, startY);
    final controlX = size.width / 2 + (startX + endX) / 2;
    path.quadraticBezierTo(controlX, (startY + endY) / 2, size.width / 2 + endX, endY);

    // 그림자 선 먼저 (살짝 아래쪽)
    final shadowPath = path.shift(const Offset(0, 6));
    canvas.drawPath(shadowPath, shadowPaint);
    // 메인 선
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.isLocked != isLocked ||
           oldDelegate.startX != startX ||
           oldDelegate.endX != endX;
  }
}
