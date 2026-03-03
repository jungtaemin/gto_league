import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../home/widgets/gto/stitch_colors.dart';

class _ActionStep {
  final String position;
  final String action;
  const _ActionStep(this.position, this.action);
}

/// Full-screen poker table with player avatars arranged around it.
///
/// Renders a background table image and positions 9 seats
/// (with AI robot avatars for bots) around the table edges.
class FullScreenTableView extends StatefulWidget {
  final String heroPosition;
  final String actionHistory;

  const FullScreenTableView({
    super.key,
    required this.heroPosition,
    this.actionHistory = '',
  });

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

  static String _normalizePos(String pos) {
    switch (pos.toUpperCase()) {
      case 'BTN': return 'BU';
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      default: return pos.toUpperCase();
    }
  }

  @override
  State<FullScreenTableView> createState() => _FullScreenTableViewState();
}

class _FullScreenTableViewState extends State<FullScreenTableView> {
  late List<_ActionStep> _steps;
  int _currentStep = -1;
  Timer? _timer;
  bool _animationDone = false;

  static const _stepDuration = Duration(milliseconds: 150);

  static const List<String> seats = [
    'UTG', 'UTG+1', 'UTG+2', 'LJ', 'HJ', 'CO', 'BU', 'SB', 'BB'
  ];

  @override
  void initState() {
    super.initState();
    _steps = FullScreenTableView.parseActionSequence(widget.actionHistory);
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant FullScreenTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionHistory != widget.actionHistory ||
        oldWidget.heroPosition != widget.heroPosition) {
      _timer?.cancel();
      _steps = FullScreenTableView.parseActionSequence(widget.actionHistory);
      _currentStep = -1;
      _animationDone = false;
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (_steps.isEmpty) {
      setState(() => _animationDone = true);
      return;
    }
    setState(() {
      _currentStep = max(-1, _steps.length - 2);
    });

    _timer = Timer.periodic(_stepDuration, (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _currentStep++;
        if (_currentStep >= _steps.length - 1) {
          timer.cancel();
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
    super.dispose();
  }

  String _getBotAvatar(int index) {
    int avatarIdx = (index % 4) + 1;
    return 'assets/images/bot_avatar_$avatarIdx.webp';
  }

  @override
  Widget build(BuildContext context) {
    final activePositions = <String, String>{};
    final ghostedPositions = <String>{};

    if (_currentStep >= 0) {
      for (int i = 0; i <= _currentStep && i < _steps.length; i++) {
        final step = _steps[i];
        activePositions[step.position] = step.action;
        if (i < _steps.length - 1) {
          ghostedPositions.add(step.position);
        } else {
          ghostedPositions.remove(step.position);
        }
      }
    }

    final heroNorm = FullScreenTableView._normalizePos(widget.heroPosition);
    int heroIndex = seats.indexOf(heroNorm);
    if (heroIndex == -1) heroIndex = 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Avatar size
        final avatarSize = context.w(44).clamp(36.0, 54.0);

        // Seat positions around the screen (relative: fractions of w, h)
        // Hero is always bottom center. We rotate positions based on heroIndex.
        // These are 9 fixed screen positions (clockwise from bottom-center).
        final List<Offset> screenPositions = [
          Offset(w * 0.50, h * 0.88), // 0: Bottom Center (Hero)
          Offset(w * 0.85, h * 0.78), // 1: Bottom Right
          Offset(w * 0.92, h * 0.55), // 2: Right
          Offset(w * 0.85, h * 0.32), // 3: Top Right
          Offset(w * 0.65, h * 0.13), // 4: Top Center-Right
          Offset(w * 0.35, h * 0.13), // 5: Top Center-Left
          Offset(w * 0.15, h * 0.32), // 6: Top Left
          Offset(w * 0.08, h * 0.55), // 7: Left
          Offset(w * 0.15, h * 0.78), // 8: Bottom Left
        ];

        // Build seat widgets
        final seatWidgets = <Widget>[];

        for (int i = 0; i < 9; i++) {
          // Which seat index maps to screen position i?
          // Screen position 0 = heroIndex in seats array
          final seatIdx = (heroIndex + i) % 9;
          final posName = seats[seatIdx];
          final isHero = posName == heroNorm;
          final pos = screenPositions[i];
          final activeAction = activePositions[posName];
          final isGhosted = ghostedPositions.contains(posName);
          bool isFolded = activeAction == 'fold';

          // Seats before hero with no action are folded
          if (!isHero && activeAction == null) {
            // Check if position is before hero in action order
            final posIdx = seats.indexOf(posName);
            if (posIdx < heroIndex) {
              isFolded = true;
            }
          }

          // Don't fold hero
          if (isHero) isFolded = false;

          // Determine colors
          Color borderColor;
          List<BoxShadow>? glow;
          if (isHero) {
            borderColor = StitchColors.accentCyan;
            if (_animationDone) {
              glow = [BoxShadow(color: StitchColors.accentCyan.withValues(alpha: 0.7), blurRadius: 14, spreadRadius: 2)];
            }
          } else if (isFolded) {
            borderColor = Colors.grey.withValues(alpha: 0.4);
          } else if (activeAction == 'push' || activeAction == 'raise' || activeAction == '3bet') {
            borderColor = Colors.redAccent;
            glow = [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)];
          } else if (activeAction == 'call') {
            borderColor = Colors.blue;
            glow = [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 8)];
          } else {
            borderColor = Colors.white24;
          }

          // Action badge
          Widget? actionBadge;
          if (activeAction != null) {
            Color badgeColor;
            switch (activeAction) {
              case 'fold': badgeColor = Colors.grey.shade700; break;
              case 'push': badgeColor = const Color(0xFFDC2626); break;
              case 'raise': badgeColor = const Color(0xFFF97316); break;
              case '3bet': badgeColor = const Color(0xFFEF4444); break;
              case 'call': badgeColor = const Color(0xFF2563EB); break;
              default: badgeColor = Colors.grey;
            }
            actionBadge = Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.h(2)),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(context.r(6)),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Text(
                activeAction.toUpperCase(),
                style: TextStyle(
                  color: activeAction == 'fold' ? Colors.white54 : Colors.white,
                  fontSize: context.sp(9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            );
          }

          seatWidgets.add(
            Positioned(
              left: pos.dx - avatarSize / 2,
              top: pos.dy - avatarSize / 2,
              child: SizedBox(
                width: avatarSize + context.w(30), // extra for label
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar circle
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: isHero ? 2.5 : 1.5),
                        boxShadow: glow,
                      ),
                      child: ClipOval(
                        child: isHero
                            ? Image.asset(
                                'assets/images/characters/char_robot.webp',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.blueGrey,
                                  child: Icon(Icons.person, color: Colors.white, size: avatarSize * 0.6),
                                ),
                              )
                            : Opacity(
                                opacity: isFolded ? 0.35 : 1.0,
                                child: Image.asset(
                                  _getBotAvatar(seatIdx),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade800,
                                    child: Icon(Icons.smart_toy, color: Colors.white54, size: avatarSize * 0.6),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: context.h(2)),
                    // Position name
                    Text(
                      posName,
                      style: TextStyle(
                        color: isHero ? StitchColors.accentCyan : (isFolded ? Colors.white30 : Colors.white70),
                        fontSize: context.sp(9),
                        fontWeight: isHero ? FontWeight.bold : FontWeight.normal,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    // Action badge
                    if (actionBadge != null)
                      Padding(
                        padding: EdgeInsets.only(top: context.h(2)),
                        child: actionBadge,
                      ),
                    // Hero turn indicator
                    if (isHero && _animationDone)
                      Padding(
                        padding: EdgeInsets.only(top: context.h(2)),
                        child: Text('YOUR TURN',
                          style: TextStyle(
                            color: StitchColors.accentCyan,
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 4),
                              Shadow(color: StitchColors.accentCyan.withValues(alpha: 0.6), blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            // Table Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/poker_table_bg.webp',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A0E1A)),
              ),
            ),
            // Seats
            ...seatWidgets,
          ],
        );
      },
    );
  }
}
