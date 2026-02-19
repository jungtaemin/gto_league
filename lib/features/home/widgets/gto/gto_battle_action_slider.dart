import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'stitch_colors.dart';

class GtoBattleActionSlider extends StatefulWidget {
  final VoidCallback onFold;
  final VoidCallback onAllIn;

  const GtoBattleActionSlider({
    super.key,
    required this.onFold,
    required this.onAllIn,
  });

  @override
  State<GtoBattleActionSlider> createState() => _GtoBattleActionSliderState();
}

class _GtoBattleActionSliderState extends State<GtoBattleActionSlider> {
  double _dragOffset = 0.0;
  final double _dragThreshold = 80.0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      // Clamp for visual feedback limit
      _dragOffset = _dragOffset.clamp(-120.0, 120.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset < -_dragThreshold) {
      widget.onFold();
    } else if (_dragOffset > _dragThreshold) {
      widget.onAllIn();
    }
    
    // Reset spring back
    setState(() {
      _dragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine active zone opacity
    final foldOpacity = (_dragOffset < 0 ? (-_dragOffset / _dragThreshold) : 0.0).clamp(0.0, 1.0);
    final allInOpacity = (_dragOffset > 0 ? (_dragOffset / _dragThreshold) : 0.0).clamp(0.0, 1.0);

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // 1. Background Zones
          Row(
            children: [
              // FOLD ZONE (Left)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        StitchColors.glowRed.withOpacity(0.4 * foldOpacity + 0.1),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Arrow
                      Positioned(
                        bottom: 100, left: 20,
                        child: Icon(Icons.keyboard_arrow_left_rounded, 
                          color: StitchColors.glowRed.withOpacity(0.3 + foldOpacity * 0.7), size: 60)
                          .animate(target: foldOpacity > 0 ? 0 : 1).moveX(begin: 0, end: -10, duration: 1.seconds, curve: Curves.easeInOut).fadeIn(),
                      ),
                      // Label
                      Positioned(
                        bottom: 40, left: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StitchColors.glowRed.withOpacity(0.2),
                                border: Border.all(color: StitchColors.glowRed.withOpacity(0.5)),
                                boxShadow: [BoxShadow(color: StitchColors.glowRed.withOpacity(foldOpacity), blurRadius: 20)],
                              ),
                              child: const Icon(Icons.close, color: StitchColors.glowRed, size: 24),
                            ),
                            const SizedBox(height: 8),
                            const Text("폴드", style: TextStyle(
                              fontFamily: 'Do Hyeon', fontSize: 30, color: StitchColors.glowRed, height: 1.0
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ALL-IN ZONE (Right)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        StitchColors.blue600.withOpacity(0.4 * allInOpacity + 0.1),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Arrow
                      Positioned(
                        bottom: 100, right: 20,
                        child: Icon(Icons.keyboard_arrow_right_rounded, 
                          color: StitchColors.blue400.withOpacity(0.3 + allInOpacity * 0.7), size: 60)
                          .animate(target: allInOpacity > 0 ? 0 : 1).moveX(begin: 0, end: 10, duration: 1.seconds, curve: Curves.easeInOut).fadeIn(),
                      ),
                      // Label
                      Positioned(
                        bottom: 40, right: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StitchColors.blue600.withOpacity(0.2),
                                border: Border.all(color: StitchColors.blue400.withOpacity(0.5)),
                                boxShadow: [BoxShadow(color: StitchColors.blue400.withOpacity(allInOpacity), blurRadius: 20)],
                              ),
                              child: const Icon(Icons.bolt, color: StitchColors.blue400, size: 24),
                            ),
                            const SizedBox(height: 8),
                            const Text("올인", style: TextStyle(
                              fontFamily: 'Do Hyeon', fontSize: 30, color: StitchColors.blue400, height: 1.0
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Center Drag Handle
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vertical Line
                      Container(height: 60, width: 1, 
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.white.withOpacity(0.2), Colors.transparent]
                          )
                        )
                      ),
                      // Knob
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Color(0xFF374151), Color(0xFF111827)], // gray-700 to gray-900
                          ),
                          border: Border.all(color: Colors.grey[600]!, width: 4),
                          boxShadow: [
                            const BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5)),
                            BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 0, spreadRadius: 1), // highlight ring
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft, end: Alignment.topRight,
                                  colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                                ),
                              ),
                            ),
                            const Icon(Icons.touch_app_rounded, color: Colors.white, size: 40, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("드래그하여 선택", style: TextStyle(
                        fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 2.0
                      )),
                    ],
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
