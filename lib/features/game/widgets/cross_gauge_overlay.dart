import 'package:flutter/material.dart';

/// A cross-shaped (✚) gauge that explodes from the center showing GTO action frequencies.
/// 
/// Shows 4 directional bars (up/down/left/right) representing GTO action frequencies,
/// with a spring-explosion entrance animation.
class CrossGaugeOverlay extends StatefulWidget {
  final bool isVisible;
  final int foldFreq;
  final int callFreq;
  final int raiseFreq;
  final int allinFreq;
  final VoidCallback onComplete;

  const CrossGaugeOverlay({
    super.key,
    required this.isVisible,
    required this.foldFreq,
    required this.callFreq,
    required this.raiseFreq,
    required this.allinFreq,
    required this.onComplete,
  });

  @override
  State<CrossGaugeOverlay> createState() => _CrossGaugeOverlayState();
}

class _CrossGaugeOverlayState extends State<CrossGaugeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Phase 1 (0-100ms): Bars scale from 0 to full length with Curves.elasticOut
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.elasticOut), // 0-100ms is 0.0-0.2 of 500ms
      ),
    );

    // Phase 3 (400-500ms): Fade out (opacity 1.0→0.0) with Curves.easeOut
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut), // 400-500ms is 0.8-1.0 of 500ms
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CrossGaugeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = _opacityAnimation.value.clamp(0.0, 1.0);
          final scale = _scaleAnimation.value;

          return Opacity(
            opacity: opacity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Max bar length: ~40% of screen dimension
                final maxDimension = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                final maxBarLength = maxDimension * 0.4;

                return Stack(
                  children: [
                    // Center of screen = cross origin
                    if (widget.allinFreq > 0)
                      _buildBar(
                        context: context,
                        direction: _Direction.up,
                        frequency: widget.allinFreq,
                        color: const Color(0xFFFBBF24), // Gold
                        maxLength: maxBarLength,
                        scale: scale,
                      ),
                    if (widget.callFreq > 0)
                      _buildBar(
                        context: context,
                        direction: _Direction.down,
                        frequency: widget.callFreq,
                        color: const Color(0xFF22C55E), // Green
                        maxLength: maxBarLength,
                        scale: scale,
                      ),
                    if (widget.raiseFreq > 0)
                      _buildBar(
                        context: context,
                        direction: _Direction.right,
                        frequency: widget.raiseFreq,
                        color: const Color(0xFF2979FF), // Blue
                        maxLength: maxBarLength,
                        scale: scale,
                      ),
                    if (widget.foldFreq > 0)
                      _buildBar(
                        context: context,
                        direction: _Direction.left,
                        frequency: widget.foldFreq,
                        color: const Color(0xFFEF4444), // Red
                        maxLength: maxBarLength,
                        scale: scale,
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBar({
    required BuildContext context,
    required _Direction direction,
    required int frequency,
    required Color color,
    required double maxLength,
    required double scale,
  }) {
    final barLength = (frequency / 100.0) * maxLength * scale;
    const barWidth = 16.0;

    // Calculate position based on direction
    double? top, bottom, left, right;
    Alignment textAlignment;

    switch (direction) {
      case _Direction.up:
        bottom = MediaQuery.of(context).size.height / 2;
        left = (MediaQuery.of(context).size.width - barWidth) / 2;
        textAlignment = Alignment.topCenter;
        break;
      case _Direction.down:
        top = MediaQuery.of(context).size.height / 2;
        left = (MediaQuery.of(context).size.width - barWidth) / 2;
        textAlignment = Alignment.bottomCenter;
        break;
      case _Direction.left:
        top = (MediaQuery.of(context).size.height - barWidth) / 2;
        right = MediaQuery.of(context).size.width / 2;
        textAlignment = Alignment.centerLeft;
        break;
      case _Direction.right:
        top = (MediaQuery.of(context).size.height - barWidth) / 2;
        left = MediaQuery.of(context).size.width / 2;
        textAlignment = Alignment.centerRight;
        break;
    }

    final isVertical = direction == _Direction.up || direction == _Direction.down;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: isVertical ? barWidth : barLength,
        height: isVertical ? barLength : barWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(barWidth / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Percentage text at bar ends
            Align(
              alignment: textAlignment,
              child: FractionalTranslation(
                translation: _getTextTranslation(direction),
                child: Text(
                  '$frequency%',
                  style: TextStyle(
                    fontFamily: 'Black Han Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _getTextTranslation(_Direction direction) {
    switch (direction) {
      case _Direction.up:
        return const Offset(0, -1.2);
      case _Direction.down:
        return const Offset(0, 1.2);
      case _Direction.left:
        return const Offset(-1.2, 0);
      case _Direction.right:
        return const Offset(1.2, 0);
    }
  }
}

enum _Direction { up, down, left, right }
