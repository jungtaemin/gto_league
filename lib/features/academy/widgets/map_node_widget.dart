import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/map_node_data.dart';
import '../../../core/utils/haptic_manager.dart';

class MapNodeWidget extends StatefulWidget {
  final MapNodeData node;
  final NodeStatus status;
  final VoidCallback onTap;

  const MapNodeWidget({
    super.key,
    required this.node,
    required this.status,
    required this.onTap,
  });

  @override
  State<MapNodeWidget> createState() => _MapNodeWidgetState();
}

class _MapNodeWidgetState extends State<MapNodeWidget> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.status != NodeStatus.locked) {
      setState(() => _isPressed = true);
      HapticManager.snap();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.status == NodeStatus.locked) {
      HapticManager.wrong(); 
    } else {
      setState(() => _isPressed = false);
      HapticManager.correct();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (widget.status != NodeStatus.locked) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    late Color mainColor;
    late Color shadowColor;
    late Color highlightColor;
    late IconData iconData;
    late double sizeMult;

    switch (widget.status) {
      case NodeStatus.completed:
        mainColor = const Color(0xFFFFC800);
        shadowColor = const Color(0xFFDCA900);
        highlightColor = const Color(0xFFFFDB4D);
        iconData = Icons.star_rounded;
        sizeMult = 1.0;
        break;
      case NodeStatus.current:
        mainColor = const Color(0xFF58CC02);
        shadowColor = const Color(0xFF46A302);
        highlightColor = const Color(0xFF7DE629);
        iconData = Icons.play_arrow_rounded;
        sizeMult = 1.15;
        break;
      case NodeStatus.locked:
        mainColor = const Color(0xFFE5E5E5);
        shadowColor = const Color(0xFFCECECE);
        highlightColor = const Color(0xFFF0F0F0);
        iconData = Icons.lock_rounded;
        sizeMult = 0.9;
        break;
    }

    // 눌렸을 때 Y축 및 그림자 오프셋 변화 (물리 버튼 젤리 느낌)
    final double yOffset = _isPressed ? 6.0 : 0.0;
    final double shadowHeight = _isPressed ? 0.0 : 8.0;

    Widget nodeButton = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D 젤리 버튼
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, yOffset, 0),
            child: Container(
              width: 76 * sizeMult,
              height: 76 * sizeMult + shadowHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor,
                boxShadow: [
                  // 바닥면 뎁스 그림자
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, shadowHeight),
                  ),
                  // Current 노드 글로우
                  if (widget.status == NodeStatus.current && !_isPressed)
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 상단 빛 반사 (뚱뚱한 입체감)
                  Positioned(
                    top: 6 * sizeMult,
                    child: Container(
                      width: 50 * sizeMult,
                      height: 18 * sizeMult,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(10 * sizeMult),
                      ),
                    ),
                  ),
                  // 아이콘
                  Padding(
                    padding: EdgeInsets.only(bottom: shadowHeight * 0.5),
                    child: Icon(iconData, color: Colors.white, size: 38 * sizeMult),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 귀여운 팝업 스타일 말풍선 제목
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: widget.status == NodeStatus.locked ? Colors.black.withValues(alpha: 0.2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.status == NodeStatus.locked ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              widget.node.title,
              style: TextStyle(
                color: widget.status == NodeStatus.locked ? Colors.white70 : const Color(0xFF4B4B4B),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    // 숨쉬는 애니메이션 (Current 한정)
    if (widget.status == NodeStatus.current && !_isPressed) {
      nodeButton = nodeButton.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.04, 1.04), duration: 1.seconds, curve: Curves.easeInOut);
    }

    return nodeButton;
  }
}
