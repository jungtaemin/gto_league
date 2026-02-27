import 'dart:math' show pi;
import 'package:flutter/material.dart';


/// 4-way swipe direction feedback overlay (Left=FOLD, Bottom=CALL, Right=RAISE, Top=ALL-IN)
class OmniSwipeFeedbackOverlay extends StatelessWidget {
  final double horizontalProgress; // -1.0 (left) to +1.0 (right)
  final double verticalProgress; // -1.0 (top) to +1.0 (bottom)

  const OmniSwipeFeedbackOverlay({
    super.key,
    required this.horizontalProgress,
    required this.verticalProgress,
  });

  // Custom colors for specific directions as requested
  static const Color _foldRed = Color(0xFFEF4444);
  static const Color _callGreen = Color(0xFF22C55E);
  static const Color _raiseBlue = Color(0xFF2979FF);
  static const Color _allInGold = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    final double hAbs = horizontalProgress.abs();
    final double vAbs = verticalProgress.abs();

    if (hAbs < 0.05 && vAbs < 0.05) {
      return const SizedBox.shrink();
    }

    final bool isHorizontal = hAbs >= vAbs;
    final double progressAbs = isHorizontal ? hAbs : vAbs;

    final double opacity = progressAbs.clamp(0.0, 1.0);
    final double scale = 0.8 + (0.3 * Curves.easeOutBack.transform(opacity));

    return IgnorePointer(
      child: Stack(
        children: [
          if (isHorizontal && horizontalProgress < 0)
            _buildFoldBackground(opacity)
          else if (isHorizontal && horizontalProgress > 0)
            _buildRaiseBackground(opacity)
          else if (!isHorizontal && verticalProgress > 0)
            _buildCallBackground(opacity)
          else if (!isHorizontal && verticalProgress < 0)
            _buildAllInBackground(opacity),
          Align(
            alignment: _getAlignment(isHorizontal, horizontalProgress, verticalProgress),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: Curves.easeIn.transform(opacity),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildTextOverlay(isHorizontal, horizontalProgress, verticalProgress, opacity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getAlignment(bool isHorizontal, double hProg, double vProg) {
    if (isHorizontal) {
      return hProg < 0 ? Alignment.centerLeft : Alignment.centerRight;
    } else {
      return vProg < 0 ? Alignment.topCenter : Alignment.bottomCenter;
    }
  }

  Widget _buildTextOverlay(bool isHorizontal, double hProg, double vProg, double opacity) {
    if (isHorizontal) {
      if (hProg < 0) return _buildFoldText(opacity);
      return _buildRaiseText(opacity);
    } else {
      if (vProg > 0) return _buildCallText(opacity);
      return _buildAllInText(opacity);
    }
  }

  // ---------------------------------------------------------------------------
  // ⬅️ FOLD (Left)
  // ---------------------------------------------------------------------------
  Widget _buildFoldBackground(double opacity) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _foldRed.withValues(alpha: 0.9 * opacity),
              const Color(0xFF0F172A).withValues(alpha: 0.6 * opacity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildFoldText(double opacity) {
    return Transform(
      transform: Matrix4.skewX(0.12)..rotateZ(-6 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Text(
            'FOLD',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF0F172A),
              fontSize: 76,
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 15, offset: Offset(8, 8)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(2, 2)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(4, 4)),
                const Shadow(color: Color(0xFF020617), blurRadius: 0, offset: Offset(6, 6)),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE2E8F0),
                Color(0xFF94A3B8),
                Color(0xFF334155),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'FOLD',
              style: _getBaseTextStyle().copyWith(
                color: Colors.white,
                fontSize: 76,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⬇️ CALL (Bottom)
  // ---------------------------------------------------------------------------
  Widget _buildCallBackground(double opacity) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _callGreen.withValues(alpha: 0.9 * opacity),
              const Color(0xFF064E3B).withValues(alpha: 0.5 * opacity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildCallText(double opacity) {
    return Transform(
      transform: Matrix4.rotationZ(3 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Text(
            'CALL',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF064E3B),
              fontSize: 80,
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 8)),
                const Shadow(color: Color(0xFF022C22), blurRadius: 0, offset: Offset(0, 2)),
                const Shadow(color: Color(0xFF022C22), blurRadius: 0, offset: Offset(0, 4)),
                const Shadow(color: Color(0xFF022C22), blurRadius: 0, offset: Offset(0, 6)),
                Shadow(
                  color: _callGreen.withValues(alpha: 0.6 * opacity),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF86EFAC),
                Color(0xFF22C55E),
                Color(0xFF14532D),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'CALL',
              style: _getBaseTextStyle().copyWith(
                color: Colors.white,
                fontSize: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ➡️ RAISE (Right)
  // ---------------------------------------------------------------------------
  Widget _buildRaiseBackground(double opacity) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              _raiseBlue.withValues(alpha: 0.9 * opacity),
              const Color(0xFF1E3A8A).withValues(alpha: 0.5 * opacity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildRaiseText(double opacity) {
    return Transform(
      transform: Matrix4.skewX(-0.12)..rotateZ(6 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Text(
            'RAISE 2.2x',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF1E3A8A),
              fontSize: 76,
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 15, offset: Offset(-8, 8)),
                const Shadow(color: Color(0xFF172554), blurRadius: 0, offset: Offset(-2, 2)),
                const Shadow(color: Color(0xFF172554), blurRadius: 0, offset: Offset(-4, 4)),
                const Shadow(color: Color(0xFF172554), blurRadius: 0, offset: Offset(-6, 6)),
                Shadow(
                  color: _raiseBlue.withValues(alpha: 0.6 * opacity),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF93C5FD),
                Color(0xFF3B82F6),
                Color(0xFF1E3A8A),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'RAISE 2.2x',
              style: _getBaseTextStyle().copyWith(
                color: Colors.white,
                fontSize: 76,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⬆️ ALL-IN (Top)
  // ---------------------------------------------------------------------------
  Widget _buildAllInBackground(double opacity) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF7F1D1D).withValues(alpha: 0.9 * opacity),
                  const Color(0xFF450A0A).withValues(alpha: 0.5 * opacity),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.8],
              ),
            ),
          ),
        ),
        Positioned(
          top: -150 * (1 - opacity),
          left: 0,
          right: 0,
          height: 400,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.2,
                colors: [
                  _allInGold.withValues(alpha: 0.5 * opacity),
                  const Color(0xFFB45309).withValues(alpha: 0.2 * opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllInText(double opacity) {
    return Transform(
      transform: Matrix4.skewX(-0.15)..rotateZ(8 * (pi / 180)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Text(
            'ALL-IN!!',
            style: _getBaseTextStyle().copyWith(
              color: const Color(0xFF451A03),
              fontSize: 92,
              shadows: [
                const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
                const Shadow(color: Color(0xFF78350F), blurRadius: 0, offset: Offset(-2, 2)),
                const Shadow(color: Color(0xFF451A03), blurRadius: 0, offset: Offset(-4, 4)),
                const Shadow(color: Color(0xFF451A03), blurRadius: 0, offset: Offset(-6, 6)),
                const Shadow(color: Color(0xFF280A01), blurRadius: 0, offset: Offset(-8, 8)),
                const Shadow(color: Color(0xFF280A01), blurRadius: 0, offset: Offset(-10, 10)),
                const Shadow(color: Color(0xFF1A0601), blurRadius: 0, offset: Offset(-12, 12)),
                Shadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.8 * opacity),
                  blurRadius: 40,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEF3C7),
                Color(0xFFF59E0B),
                Color(0xFF92400E),
                Color(0xFFFDE68A),
              ],
              stops: [0.0, 0.4, 0.85, 1.0],
            ).createShader(bounds),
            child: Text(
              'ALL-IN!!',
              style: _getBaseTextStyle().copyWith(
                color: Colors.white,
                fontSize: 92,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getBaseTextStyle() {
    return const TextStyle(
      fontFamily: 'Black Han Sans',
      height: 1.0,
      letterSpacing: 4.0,
      fontWeight: FontWeight.w900,
    );
  }
}
