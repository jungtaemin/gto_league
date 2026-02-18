import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import 'stitch_colors.dart';

class GtoHeroStage extends StatefulWidget {
  const GtoHeroStage({super.key});

  @override
  State<GtoHeroStage> createState() => _GtoHeroStageState();
}

class _GtoHeroStageState extends State<GtoHeroStage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4)) // Float animation 4s
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // HTML Structure Recreated
    // Parent: relative flex-1 flex flex-col items-center justify-center -mt-8
    return SizedBox(
      width: double.infinity,
      // The Stack contains purely positioning elements relative to the center/stage
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Background Rings (HTML Lines 144-145)
          _buildRings(context),

          // 2. Silver I Badge (HTML Lines 146-151)
          // absolute top-[60px] right-[20px] -> In Flutter 360x360 box context?
          // Let's use Positioned relative to center offset or top/right of stack
          Positioned(
            top: context.w(20), right: context.w(40),
            child: _buildSilverBadge(context),
          ),

          // 3. GTO Chip Badge (HTML Lines 152-164)
          // absolute top-[80px] left-[-10px]
          Positioned(
            top: context.w(40), left: context.w(20),
            child: _buildGtoChipBadge(context),
          ),

          // 4. Robot Container (HTML Lines 174-206)
          // robot-container relative z-10 w-[200px]
          // Animation: float 4s ease-in-out infinite
          Positioned(
            top: context.w(50), // Adjust to center it visually
            child: _buildHtmlRobot(context),
          ),
          
          // 5. Speech Bubble (HTML Lines 208-213)
          // absolute bottom-[25%] right-[20px]
          Positioned(
            bottom: context.w(40), right: context.w(30), // Adjusted coordinates
            child: _buildSpeechBubble(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRings(BuildContext context) {
    final size = context.w(320); // Maintain square aspect ratio
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Faint Base Ring
          // border-[12px] border-white/5 border-t-white/10 border-l-white/10 rotate-45
          Transform.rotate(
            angle: 45 * math.pi / 180,
            child: Stack(
              children: [
                // Base faint ring
                Container(
                  width: size, height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: context.w(12)),
                  ),
                ),
                // Top-Left highlighted segment
                CustomPaint(
                  size: Size(size, size),
                  painter: _ArcPainter(color: Colors.white.withOpacity(0.1), width: context.w(12)),
                ),
              ],
            ),
          ),
          // 2. Active Blue Arc (Top-Left 90 degrees + rotation)
          Positioned(
            top: 0, left: context.w(10),
            child: Transform.rotate(
              angle: 45 * math.pi / 180,
              child: CustomPaint(
                size: Size(context.w(300), context.w(300)),
                painter: _ArcPainter(color: StitchColors.blue400, width: context.w(8), shadow: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlRobot(BuildContext context) {
    // HTML: float animation
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 0% -> 0, 50% -> -10, 100% -> 0
        final offset = -10.0 * math.sin(_controller.value * math.pi); // Simple sine for EaseInOut approx
        return Transform.translate(
          offset: Offset(0, context.h(offset)), // Scale animation offset
          child: child,
        );
      },
      child: SizedBox( // robot-container
        width: context.w(200), height: context.w(260), // Estimated total height including shadow, scaled by width
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Shadow (HTML Line 202)
            // absolute bottom-[-30px] w-[240px] h-[60px] ... opacity-80 z-[-1]
            Positioned(
              bottom: 0,
              child: Container(
                width: context.w(240), height: context.w(60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.w(100)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF1E3A8A)], // blue-900 via blue-700
                  ),
                  // border: const Border(top: BorderSide(color: StitchColors.blue400, width: 2)), // Removed
                  boxShadow: [
                    BoxShadow(color: StitchColors.blue500.withOpacity(0.5), blurRadius: context.w(30)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.w(100)),
                  child: Stack(
                    children: [
                       Positioned(
                         top: 0, left: 0, right: 0,
                         child: Container(height: context.h(2), color: StitchColors.blue400),
                       )
                    ],
                  ),
                ),
              ),
            ),
            
            // League Tag (HTML Line 203)
            // absolute bottom-[-20px]
            Positioned(
              bottom: context.h(15),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(4)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // black/60
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: StitchColors.blue500.withOpacity(0.5)),
                ),
                child: Text("리그: 브론즈 III", style: TextStyle(
                  color: StitchColors.orange300, fontWeight: FontWeight.bold, fontSize: context.sp(14),
                  fontFamily: 'Noto Sans KR',
                )),
              ),
            ),

            // Legs (HTML Line 198)
            // flex gap-4 -mt-2
            Positioned(
              bottom: context.h(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _leg(context), SizedBox(width: context.w(16)), _leg(context),
                ],
              ),
            ),


            // Lower Body (HTML Line 189)
            // w-[100px] h-[80px] bg-[#1a1b2e] rounded-[2rem] -mt-4 z-0
            Positioned(
              top: context.h(110),
              child: Container(
                width: context.w(100), height: context.w(80),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1B2E),
                  borderRadius: BorderRadius.circular(context.w(32)),
                  border: Border.all(color: StitchColors.slate600, width: context.w(2)),
                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Neck Details (top-4 flex ...)
                    Positioned(
                      top: context.h(16), left: 0, right: 0,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           // Not implementing tiny details for pixel perfect unless asked, keeping it clean
                           // Just the Tie
                        ],
                      ),
                    ),
                    // White Triangle Tie (border-l-[15px] ...)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: context.h(24)),
                        child: CustomPaint(
                          size: Size(context.w(30), context.w(30)),
                          painter: _TiePainter(),
                        ),
                      ),
                    ),
                    // Little white dash (rotate-6)
                    Positioned(
                      top: context.h(40), right: context.w(16),
                      child: Transform.rotate(
                        angle: 6 * math.pi / 180,
                        child: Container(width: context.w(16), height: context.h(4), color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Head (HTML Line 175)
            // w-[160px] h-[130px] bg-slate-200 rounded-[2.5rem] border-[6px] border-slate-300
            Positioned(
              top: 0,
              child: Container(
                width: context.w(160), height: context.w(130),
                decoration: BoxDecoration(
                  color: StitchColors.slate200,
                  borderRadius: BorderRadius.circular(context.w(40)), // 2.5rem
                  border: Border.all(color: StitchColors.slate300, width: context.w(6)),
                  boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Antenna (absolute -top-1)
                    Positioned(
                      top: -context.h(10), // -top-1 relative to container content box
                      child: Container(
                        width: context.w(32), height: context.h(8),
                        decoration: BoxDecoration(
                          color: StitchColors.slate400,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    // Screen Face (HTML Line 176)
                    // w-[130px] h-[100px] bg-[#0F1025] rounded-[1.8rem]
                    Container(
                      width: context.w(130), height: context.w(100),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1025),
                        borderRadius: BorderRadius.circular(context.w(28.8)), // 1.8rem
                        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 4, spreadRadius: 0, offset: Offset(0,2) )], // Inner shadow sim
                      ),
                      child: Stack(
                        children: [
                          // Code Text (opacity-20 text-[6px] green-400 font-mono)
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(context.w(4)),
                              child: Opacity(
                                opacity: 0.2,
                                child: Text(
                                  "const gto = (range) => { check(ev); raise(3bb); } ... fold > call\nif (pot_odds > 1.2) { call(); } else { fold(); }",
                                  style: TextStyle(
                                    color: Colors.green, fontSize: context.sp(8), fontFamily: 'monospace', height: 1.2
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Eyes & Mouth Wrapper
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _htmlEye(context),
                                    SizedBox(width: context.w(16)),
                                    _htmlEye(context),
                                  ],
                                ),
                                SizedBox(height: context.h(8)), // mt-2
                                // Mouth (arc down)
                                Container(
                                  width: context.w(16), height: context.h(8),
                                  decoration: BoxDecoration(
                                    color: StitchColors.cyan400,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.w(8))),
                                    boxShadow: const [BoxShadow(color: StitchColors.cyan400, blurRadius: 5)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _htmlEye(BuildContext context) {
    // w-8 h-5 (32x20) bg-cyan-400 rounded-t-full shadow...
    return Container(
      width: context.w(32), height: context.w(20),
      decoration: BoxDecoration(
        color: StitchColors.cyan400,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.w(20))),
        boxShadow: const [BoxShadow(color: StitchColors.cyan400, blurRadius: 10)],
      ),
    );
  }

  Widget _leg(BuildContext context) {
    // w-6 h-8 bg-[#1a1b2e] rounded-b-xl border-2 border-slate-600
    return Container(
      width: context.w(24), height: context.w(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.w(12))),
        border: Border.all(color: StitchColors.slate600, width: context.w(2)),
      ),
    );
  }

  Widget _buildSilverBadge(BuildContext context) {
    // animate-bounce duration-[3000ms]
    return Column(
      children: [
        Transform.rotate(
          angle: 12 * math.pi / 180, // rotate-12
          child: Container(
            width: context.w(40), height: context.w(40),
            decoration: BoxDecoration(
              color: StitchColors.slate300,
              shape: BoxShape.circle,
              border: Border.all(color: StitchColors.slate100, width: context.w(2)),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Center(
              child: Text("I", style: TextStyle(
                fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: context.sp(18), color: StitchColors.slate600
              )),
            ),
          ),
        ),
        SizedBox(height: context.h(4)),
        Text("실버 I", style: TextStyle(color: Colors.white, fontSize: context.sp(12), fontWeight: FontWeight.bold)),
      ],
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .moveY(begin: 0, end: -6, duration: 3.seconds);
  }

  Widget _buildGtoChipBadge(BuildContext context) {
    // glass-panel rounded-2xl p-2 w-[80px] shadow-lg border-l-4 border-l-purple-400
    // Fix: Cannot use borderRadius with non-uniform Border. 
    // Solution: Uniform border for box, and a separate bar for the left accent.
    return Container(
      width: context.w(80),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.w(16)),
        border: Border.all(color: Colors.white.withOpacity(0.15)), // Uniform border
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(16)),
        child: Stack(
          children: [
            // Left Accent Bar (The thick border simulation)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: context.w(4), color: StitchColors.purple400),
            ),
            // Content with padding
            Padding(
              padding: EdgeInsets.only(left: context.w(12), top: context.h(8), right: context.w(8), bottom: context.h(8)), // increased left padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GTO", style: TextStyle(color: StitchColors.purple200, fontSize: context.sp(10), fontWeight: FontWeight.bold)),
                  SizedBox(height: context.h(4)),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: context.w(4),
                    crossAxisSpacing: context.w(4),
                    padding: EdgeInsets.zero,
                    children: [
                      _colorDot(Colors.red, context), _colorDot(Colors.blue, context), _colorDot(Colors.green, context),
                      _colorDot(Colors.yellow, context), _colorDot(Colors.purple, context), _colorDot(Colors.orange, context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color c, BuildContext context) => Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(context.w(4))));

  Widget _buildSpeechBubble(BuildContext context) {
    // absolute bottom-[25%] right-[20px] z-20 animate-bounce
    // bg-white text-black px-4 py-3 rounded-2xl rounded-tr-sm
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.w(16)),
          bottomLeft: Radius.circular(context.w(16)),
          bottomRight: Radius.circular(context.w(16)),
          topRight: Radius.circular(context.w(2)), // rounded-tr-sm
        ),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
           Text("지금 바로 올인!", style: TextStyle(
             color: Colors.black, fontWeight: FontWeight.bold, fontSize: context.sp(14), fontFamily: 'Black Han Sans'
           )),
           // The little tail in HTML: absolute -bottom-2 right-0 w-4 h-4 bg-white rotate-45
           // Actually in Flutter we can just rely on the shape or add a positioned box.
        ],
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .moveY(begin: 0, end: -10, duration: 1.seconds); // bounce
  }
}

class _TiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // border-l-[15px] border-r-[15px] border-t-[30px] ... border-t-white
    // Inverted Triangle
    final paint = Paint()..color = Colors.white;
    final path = Path();
    path.moveTo(0, 0); // Top Left
    path.lineTo(size.width, 0); // Top Right
    path.lineTo(size.width / 2, size.height); // Bottom Center
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double width;
  final bool shadow;

  _ArcPainter({this.color = StitchColors.blue400, this.width = 8.0, this.shadow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    if (shadow) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      const startAngle = -math.pi;
      const sweepAngle = math.pi / 2;
      canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);
    }

    const startAngle = -math.pi;
    const sweepAngle = math.pi / 2;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
