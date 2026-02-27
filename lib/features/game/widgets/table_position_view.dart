import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../home/widgets/gto/stitch_colors.dart';
import '../../../../core/utils/responsive.dart';

/// Animated poker table that plays action history step-by-step.
///
/// For 30BB mode: each action appears sequentially (150ms intervals),
/// then highlights the hero's position as "YOUR TURN".
class TablePositionView extends StatefulWidget {
  final String heroPosition;
  final String? opponentPosition;
  final bool isDefenseMode;
  final String actionHistory;

  const TablePositionView({
    super.key,
    required this.heroPosition,
    this.opponentPosition,
    this.isDefenseMode = false,
    this.actionHistory = '',
  });

  // ── Parsing helpers (static, reusable) ──────────────────────

  /// Parse actionHistory into an ordered list of (position, action) steps.
  static List<_ActionStep> parseActionSequence(String actionHistory) {
    final steps = <_ActionStep>[];
    if (actionHistory.isEmpty) return steps;

    if (actionHistory.contains('_') && !actionHistory.contains('pushes')) {
      final parts = actionHistory.split('.');
      bool hasRaised = false;
      for (final part in parts) {
        final pair = part.split('_');
        if (pair.length == 2) {
          final pos = pair[0];
          final actionCode = pair[1];
          String actionStr;
          switch (actionCode) {
            case 'F': actionStr = 'fold'; break;
            case 'C': actionStr = 'call'; break;
            case 'R':
              actionStr = hasRaised ? '3bet' : 'raise';
              hasRaised = true;
              break;
            case 'A':
              actionStr = 'push';
              hasRaised = true;
              break;
            default: actionStr = 'call';
          }
          steps.add(_ActionStep(_normalizePos(pos), actionStr));
        }
      }
    } else {
      // Legacy 15BB format
      for (final part in actionHistory.split(', ')) {
        final trimmed = part.trim();
        if (trimmed.contains('pushes')) {
          steps.add(_ActionStep(_normalizePos(trimmed.split(' ').first), 'push'));
        } else if (trimmed.contains('calls')) {
          steps.add(_ActionStep(_normalizePos(trimmed.split(' ').first), 'call'));
        }
      }
    }
    return steps;
  }

  /// Build a cumulative map from steps[0..stepIndex].
  static Map<String, String> buildPositionsAtStep(List<_ActionStep> steps, int stepIndex) {
    final result = <String, String>{};
    for (int i = 0; i <= stepIndex && i < steps.length; i++) {
      result[steps[i].position] = steps[i].action;
    }
    return result;
  }

  static String _normalizePos(String pos) {
    switch (pos.toUpperCase()) {
      case 'BTN': return 'BU';
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      default: return pos.toUpperCase();
    }
  }

  @override
  State<TablePositionView> createState() => _TablePositionViewState();
}

class _ActionStep {
  final String position;
  final String action;
  const _ActionStep(this.position, this.action);
}

class _TablePositionViewState extends State<TablePositionView>
    with SingleTickerProviderStateMixin {
  late List<_ActionStep> _steps;
  int _currentStep = -1; // -1 = initial state (no actions shown)
  Timer? _timer;
  bool _animationDone = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Faster sequence for K-Casual feel
  static const _stepDuration = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _steps = TablePositionView.parseActionSequence(widget.actionHistory);
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _bounceController.addListener(() => setState(() {}));

    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant TablePositionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionHistory != widget.actionHistory ||
        oldWidget.heroPosition != widget.heroPosition) {
      _timer?.cancel();
      _steps = TablePositionView.parseActionSequence(widget.actionHistory);
      _currentStep = -1;
      _animationDone = false;
      _bounceController.stop();
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (_steps.isEmpty) {
      setState(() => _animationDone = true);
      return;
    }
    
    // Skip to immediately before the final action
    setState(() {
      _currentStep = max(-1, _steps.length - 2);
    });

    _timer = Timer.periodic(_stepDuration, (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _currentStep++;
        // Trigger bounce for the final step
        _bounceController.forward(from: 0.0);
        
        if (_currentStep >= _steps.length - 1) {
          timer.cancel();
          // Slight delay before hero "YOUR TURN" flash
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _animationDone = true);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableWidth = context.w(220).clamp(180.0, 320.0);
    final tableHeight = (tableWidth * 0.55).clamp(100.0, 180.0);

    final activePositions = <String, String>{};
    final ghostedPositions = <String>{};

    if (_currentStep >= 0) {
      for (int i = 0; i <= _currentStep; i++) {
        final step = _steps[i];
        activePositions[step.position] = step.action;
        
        // Ghost any step that is not the final step of the hand
        if (i < _steps.length - 1) {
          ghostedPositions.add(step.position);
        } else {
          ghostedPositions.remove(step.position);
        }
      }
    }
        
    // Identify the position that just acted to apply the bounce scale
    final String? bouncingPosition = _currentStep >= 0 && _currentStep < _steps.length
        ? _steps[_currentStep].position
        : null;

    return Container(
      width: tableWidth,
      height: tableHeight,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(context.r(60)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: CustomPaint(
        painter: _TablePainter(
          heroPosition: widget.heroPosition,
          opponentPosition: widget.opponentPosition,
          isDefenseMode: widget.isDefenseMode,
          activePositions: activePositions,
          ghostedPositions: ghostedPositions,
          animationDone: _animationDone,
          bouncingPosition: bouncingPosition,
          bounceScale: _bounceAnimation.value,
          context: context,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Table Painter (unchanged drawing logic, with animationDone flag)
// ═══════════════════════════════════════════════════════════════

class _TablePainter extends CustomPainter {
  final String heroPosition;
  final String? opponentPosition;
  final bool isDefenseMode;
  final Map<String, String> activePositions;
  final Set<String> ghostedPositions;
  final bool animationDone;
  final String? bouncingPosition;
  final double bounceScale;
  final BuildContext context;

  static const List<String> seats = [
    'UTG', 'UTG+1', 'UTG+2', 'LJ', 'HJ', 'CO', 'BU', 'SB', 'BB'
  ];

  static String _normalizePosition(String pos) {
    switch (pos.toUpperCase()) {
      case 'BTN': return 'BU';
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      default: return pos.toUpperCase();
    }
  }

  _TablePainter({
    required this.heroPosition,
    this.opponentPosition,
    required this.isDefenseMode,
    this.activePositions = const {},
    this.ghostedPositions = const {},
    this.animationDone = false,
    this.bouncingPosition,
    this.bounceScale = 1.0,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final tableRect = Rect.fromCenter(
        center: center, width: size.width * 0.75, height: size.height * 0.65);

    canvas.drawRRect(
        RRect.fromRectAndRadius(tableRect, Radius.circular(context.r(40))),
        Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);
    canvas.drawRRect(
        RRect.fromRectAndRadius(tableRect, Radius.circular(context.r(40))),
        Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = context.w(2.0));

    int heroIndex = seats.indexOf(_normalizePosition(heroPosition));
    if (heroIndex == -1) heroIndex = 6;

    const double anglePerSeat = 2 * pi / 9;
    for (int i = 0; i < seats.length; i++) {
      int relativeIndex = (i - heroIndex);
      final double angle = (pi / 2) + (relativeIndex * anglePerSeat);
      _drawSeat(canvas, size, center, i, angle, heroIndex);
    }
  }

  void _drawSeat(Canvas canvas, Size size, Offset center, int index,
      double angle, int heroIndex) {
    final posName = seats[index];
    final normalizedHero = _normalizePosition(heroPosition);
    final isHero = posName == normalizedHero;
    final activeAction = activePositions[posName];
    
    // Determine if this specific seat is currently bouncing (just updated)
    final bool isBouncing = posName == bouncingPosition;
    final double currentScale = isBouncing ? bounceScale : 1.0;

    final isActiveOpponent = !isHero &&
        (activeAction == 'push' ||
            activeAction == 'call' ||
            activeAction == 'raise' ||
            activeAction == '3bet');
    final isMainOpponent = isDefenseMode && posName == opponentPosition;
    final isOpponent = isMainOpponent || isActiveOpponent;
    final isDealer = posName == 'BU';

    double radiusX = size.width * 0.42;
    double radiusY = size.height * 0.42;
    final seatOffset = center + Offset(radiusX * cos(angle), radiusY * sin(angle));

    // Dealer button
    if (isDealer) {
      final dealerOffset = seatOffset + (center - seatOffset) * 0.35;
      canvas.drawCircle(dealerOffset, context.w(6), Paint()..color = Colors.white);
      final tp = TextPainter(
        text: TextSpan(text: 'D', style: TextStyle(color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, dealerOffset - Offset(tp.width / 2, tp.height / 2));
    }

    final paint = Paint()..style = PaintingStyle.fill;
    bool isFolded = false;

    if (activeAction == 'fold') {
      isFolded = true;
    } else if (activePositions.isNotEmpty) {
      if (!isHero && !isOpponent && activeAction == null && index < heroIndex) {
        isFolded = true;
      }
    } else {
      int opponentIndex = -1;
      if (isDefenseMode && opponentPosition != null) {
        opponentIndex = seats.indexOf(_normalizePosition(opponentPosition!));
      }
      if (isDefenseMode && opponentIndex != -1) {
        if (index < opponentIndex) isFolded = true;
        if (index > opponentIndex && index < heroIndex) isFolded = true;
      } else {
        if (index < heroIndex) isFolded = true;
      }
    }

    // Safety: Hero/Opponent never folded
    if (isHero || isOpponent) isFolded = false;

    final bool isGhosted = ghostedPositions.contains(_normalizePosition(posName)) || 
                          (isHero && ghostedPositions.contains(_normalizePosition(heroPosition)));

    final seatRadius = context.w(8);
    final activeSeatRadius = isGhosted ? context.w(10) : context.w(12);

    // --- APPLY BOUNCE SCALE ---
    canvas.save();
    canvas.translate(seatOffset.dx, seatOffset.dy);
    canvas.scale(currentScale);
    canvas.translate(-seatOffset.dx, -seatOffset.dy);

    if (isHero) {
      final baseColor = StitchColors.accentCyan;
      paint.color = isGhosted ? baseColor.withOpacity(0.5) : baseColor;
      canvas.drawCircle(seatOffset, activeSeatRadius,
          Paint()..color = (isGhosted ? baseColor.withOpacity(0.15) : baseColor.withOpacity(animationDone ? 0.5 : 0.3))
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, animationDone ? 10 : 6));
      canvas.drawCircle(seatOffset, seatRadius, paint);
    } else if (isOpponent) {
      final isAggressive = activeAction == 'push' || activeAction == 'raise' || activeAction == '3bet';
      final baseColor = isAggressive ? StitchColors.glowRed : const Color(0xFFFBBF24);
      final oppColor = isGhosted ? baseColor.withOpacity(0.5) : baseColor;
      
      paint.color = oppColor;
      if (!isGhosted) {
        canvas.drawCircle(seatOffset, activeSeatRadius,
            Paint()..color = oppColor.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      } else {
        canvas.drawCircle(seatOffset, activeSeatRadius,
            Paint()..style = PaintingStyle.stroke..color = oppColor.withOpacity(0.5)..strokeWidth = 1.0);
      }
      canvas.drawCircle(seatOffset, seatRadius, paint);
    } else if (isFolded) {
      paint.color = const Color(0xFF020617);
      canvas.drawCircle(seatOffset, context.w(10), paint);
      canvas.drawCircle(seatOffset, context.w(10),
          Paint()..style = PaintingStyle.stroke..color = const Color(0xFF334155)..strokeWidth = 1.5);
      _drawMuckedCards(canvas, seatOffset);
    } else {
      paint.color = const Color(0xFF475569);
      canvas.drawCircle(seatOffset, seatRadius, paint);
    }

    // ── Labels ──────────────────────────────────
    if (isOpponent) {
      final isAggressive = activeAction == 'push' || activeAction == 'raise' || activeAction == '3bet';
      String labelText = 'CALL';
      if (activeAction == 'push') labelText = 'ALL-IN';
      if (activeAction == 'raise') labelText = 'RAISE';
      if (activeAction == '3bet') labelText = '3BET';

      final labelBaseColor = isAggressive ? const Color(0xFFFBBF24) : const Color(0xFF60A5FA);
      final labelColor = isGhosted ? labelBaseColor.withOpacity(0.5) : labelBaseColor;
      final nameColor = isGhosted ? Colors.white54 : Colors.white;

      final List<TextSpan> children = [
        TextSpan(text: "$posName\n", style: TextStyle(color: nameColor, fontSize: context.sp(isGhosted ? 8 : 9), fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
        TextSpan(text: labelText, style: TextStyle(color: labelColor, fontSize: context.sp(isGhosted ? 9 : 10), fontWeight: FontWeight.w900, letterSpacing: 0.5,
            shadows: [const Shadow(color: Colors.black, blurRadius: 2), Shadow(color: labelColor.withOpacity(0.6), blurRadius: 6)])),
      ];

      if (activeAction == 'raise') {
        children.add(TextSpan(text: " x2.2", style: TextStyle(color: isGhosted ? const Color(0xFFFFD700).withOpacity(0.5) : const Color(0xFFFFD700), fontSize: context.sp(isGhosted ? 8 : 9), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)])));
      }
      if (activeAction == '3bet') {
        children.add(TextSpan(text: " x3", style: TextStyle(color: isGhosted ? const Color(0xFFFCA5A5).withOpacity(0.5) : const Color(0xFFFCA5A5), fontSize: context.sp(isGhosted ? 8 : 9), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)])));
      }

      _drawLabel(canvas, seatOffset, center, TextSpan(children: children), isFolded: true);
    } else if (isHero) {
      final nameColor = isGhosted ? Colors.white54 : Colors.white;
      final List<TextSpan> heroChildren = [
        TextSpan(text: posName, style: TextStyle(color: nameColor, fontSize: context.sp(isGhosted ? 10 : 11), fontWeight: FontWeight.w900,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
      ];
      
      // If hero had a past action in this hand, show it!
      if (activeAction != null) {
        final isAggressive = activeAction == 'push' || activeAction == 'raise' || activeAction == '3bet';
        String labelText = 'CALL';
        if (activeAction == 'push') labelText = 'ALL-IN';
        if (activeAction == 'raise') labelText = 'RAISE';
        if (activeAction == '3bet') labelText = '3BET';

        final labelBaseColor = isAggressive ? const Color(0xFFFBBF24) : const Color(0xFF60A5FA);
        final labelColor = isGhosted ? labelBaseColor.withOpacity(0.5) : labelBaseColor;
        
        heroChildren.add(TextSpan(text: "\n$labelText", style: TextStyle(color: labelColor, fontSize: context.sp(isGhosted ? 9 : 10), fontWeight: FontWeight.w900, letterSpacing: 0.5,
            shadows: [const Shadow(color: Colors.black, blurRadius: 2), Shadow(color: labelColor.withOpacity(0.6), blurRadius: 6)])));
            
        if (activeAction == 'raise') {
          heroChildren.add(TextSpan(text: " x2.2", style: TextStyle(color: isGhosted ? const Color(0xFFFFD700).withOpacity(0.5) : const Color(0xFFFFD700), fontSize: context.sp(isGhosted ? 8 : 9), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)])));
        }
        if (activeAction == '3bet') {
          heroChildren.add(TextSpan(text: " x3", style: TextStyle(color: isGhosted ? const Color(0xFFFCA5A5).withOpacity(0.5) : const Color(0xFFFCA5A5), fontSize: context.sp(isGhosted ? 8 : 9), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)])));
        }
      }
      
      // Hero label — show "YOUR TURN" when animation is done
      if (animationDone) {
        // If there was a past action, we append the ? next to it or on a new line
        final String prefix = activeAction != null ? " " : "\n";
        heroChildren.add(TextSpan(text: "$prefix?", style: TextStyle(
          color: StitchColors.accentCyan,
          fontSize: context.sp(isGhosted ? 11 : 12),
          fontWeight: FontWeight.w900,
          shadows: [const Shadow(color: Colors.black, blurRadius: 2), Shadow(color: StitchColors.accentCyan.withOpacity(0.8), blurRadius: 8)],
        )));
      }
      
      // If Hero did an action before OR their turn is up, it takes up more space like a folded/opponent label
      final bool needsExtraOffset = isFolded || activeAction != null || animationDone;
      _drawLabel(canvas, seatOffset, center, TextSpan(children: heroChildren), isFolded: needsExtraOffset);
    } else if (isFolded) {
      _drawLabel(canvas, seatOffset, center, TextSpan(children: [
        TextSpan(text: "$posName\n", style: TextStyle(color: const Color(0xFF334155), fontSize: context.sp(9), fontWeight: FontWeight.bold)),
        TextSpan(text: "FOLD", style: TextStyle(color: const Color(0xFFF43F5E), fontSize: context.sp(11), fontWeight: FontWeight.w900, letterSpacing: 0.5,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)])),
      ]), isFolded: true);
    } else {
      _drawLabel(canvas, seatOffset, center,
          TextSpan(text: posName, style: TextStyle(color: Colors.white38, fontSize: context.sp(10))));
    }
    
    canvas.restore(); // Restore after drawing this seat
  }

  void _drawMuckedCards(Canvas canvas, Offset center) {
    final paint = Paint()..color = const Color(0xFF475569);
    final strokePaint = Paint()..style = PaintingStyle.stroke..color = const Color(0xFF1E293B)..strokeWidth = 1.0;
    final width = context.w(12.0);
    final height = context.w(17.0);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    canvas.save();
    canvas.translate(-3, 1);
    canvas.rotate(-0.3);
    final rect1 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: width, height: height), const Radius.circular(2));
    canvas.drawRRect(rect1, paint);
    canvas.drawRRect(rect1, strokePaint);
    canvas.restore();

    canvas.save();
    canvas.translate(3, -1);
    canvas.rotate(0.2);
    final rect2 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: width, height: height), const Radius.circular(2));
    canvas.drawRRect(rect2, paint);
    canvas.drawRRect(rect2, strokePaint);
    canvas.restore();

    canvas.restore();
  }

  void _drawLabel(Canvas canvas, Offset seatOffset, Offset center, TextSpan textSpan, {bool isFolded = false}) {
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();
    final vec = seatOffset - center;
    final dist = vec.distance;
    final unitVec = dist > 0 ? vec / dist : const Offset(0, 1);
    final offsetDistance = isFolded ? context.w(12) : context.w(14);
    final labelOffset = seatOffset + unitVec * offsetDistance;
    textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TablePainter oldDelegate) {
    return oldDelegate.heroPosition != heroPosition ||
        oldDelegate.opponentPosition != opponentPosition ||
        oldDelegate.isDefenseMode != isDefenseMode ||
        oldDelegate.activePositions.length != activePositions.length ||
        oldDelegate.animationDone != animationDone;
  }
}
