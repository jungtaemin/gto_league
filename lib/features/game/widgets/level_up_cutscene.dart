import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_manager.dart';

/// Fullscreen level-up cutscene overlay for Deep Run mode.
/// E-sports final table pressure feeling with camera shake + haptic crescendo.
///
/// Shows "STAGE UP!" with bounce-in, then "BLINDS UP! (XXbb)" with slide-up.
/// Auto-dismisses after ~2.5 seconds and calls [onComplete].
class LevelUpCutscene extends StatefulWidget {
  /// New level number (2-5).
  final int newLevel;

  /// New BB level for display (12, 10, 7, or 5).
  final int newBbLevel;

  /// Called when the cutscene finishes (~2.5s).
  final VoidCallback onComplete;

  /// Whether this is the initial game start sequence.
  final bool isGameStart;

  const LevelUpCutscene({
    super.key,
    required this.newLevel,
    required this.newBbLevel,
    required this.onComplete,
    this.isGameStart = false,
  });

  @override
  State<LevelUpCutscene> createState() => _LevelUpCutsceneState();
}

class _LevelUpCutsceneState extends State<LevelUpCutscene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _masterController;
  late final Animation<double> _dimFadeIn;
  late final Animation<double> _stageScaleIn;
  late final Animation<double> _blindsFadeIn;
  late final Animation<Offset> _blindsSlideUp;
  late final Animation<double> _allFadeOut;

  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // (0-200ms) Screen dims
    _dimFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.08, curve: Curves.easeIn),
      ),
    );

    // (200-600ms) "STAGE UP!" scale bounce — 0.3→1.0 with elasticOut
    _stageScaleIn = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.08, 0.24, curve: Curves.elasticOut),
      ),
    );

    // (800-1400ms) "BLINDS UP!" fade + slide
    _blindsFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.32, 0.56, curve: Curves.easeOut),
      ),
    );

    _blindsSlideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.32, 0.56, curve: Curves.easeOut),
      ),
    );

    // (2000-2500ms) Everything fades out
    _allFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );

    _masterController.addListener(_checkHapticTrigger);
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _masterController.forward();
  }

  void _checkHapticTrigger() {
    // Fire haptic at step 2 start (~200ms = 0.08 progress)
    if (!_hapticFired && _masterController.value >= 0.08) {
      _hapticFired = true;
      HapticManager.levelUp();
    }
  }

  @override
  void dispose() {
    _masterController.removeListener(_checkHapticTrigger);
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppColors.getLevelTheme(widget.newLevel);

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: AnimatedBuilder(
          animation: _masterController,
          builder: (context, child) {
            final overallOpacity = _allFadeOut.value.clamp(0.0, 1.0);

            return Opacity(
              opacity: overallOpacity,
              child: Stack(
                children: [
                  // Dark overlay with radial gradient
                  Positioned.fill(
                    child: Opacity(
                      opacity: _dimFadeIn.value.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              theme.primary.withOpacity(0.3),
                              AppColors.pureBlack.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.7],
                            radius: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center content with camera shake
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "🚨 STAGE UP!" or "🚨 GAME START!" with scale bounce + shake
                        Transform.scale(
                          scale: _stageScaleIn.value.clamp(0.0, 1.2),
                          child: Text(
                            widget.isGameStart ? '🚨 GAME START!' : '🚨 STAGE UP!',
                            style: AppTextStyles.display(
                              color: theme.accent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                            .animate(
                              autoPlay: true,
                              delay: 200.ms,
                            )
                            .shake(
                              duration: 300.ms,
                              offset: const Offset(3, 3),
                            ),

                        const SizedBox(height: 32),

                        // The animated Poker Chip used for all stages
                        _buildChip(theme),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(LevelTheme theme) {
    return Transform.scale(
      scale: _stageScaleIn.value.clamp(0.0, 1.2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow Component
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withOpacity(0.4),
                  blurRadius: 100,
                  spreadRadius: 30,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms),

          // Main Chip Body
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [theme.background, AppColors.deepBlack],
                radius: 0.8,
              ),
              border: Border.all(
                color: theme.accent,
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accent.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.accent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.newBbLevel}',
                        style: TextStyle(
                          fontFamily: 'Black Han Sans',
                          fontSize: 72,
                          height: 1.0,
                          color: AppColors.pureWhite,
                          shadows: [
                            Shadow(
                              color: theme.accent,
                              blurRadius: 20,
                            ),
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'BB',
                        style: TextStyle(
                          fontFamily: 'Black Han Sans',
                          fontSize: 28,
                          height: 1.0,
                          color: theme.accent,
                          letterSpacing: 2.0,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Shimmer Sweep
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
          ).animate(delay: 500.ms)
           .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5), angle: 1.0, blendMode: BlendMode.screen),
        ],
      ),
    )
    .animate(
      autoPlay: true,
      delay: 100.ms,
    )
    // Entry animation: pop and slight rotation
    .scale(
      begin: const Offset(0.1, 0.1),
      end: const Offset(1.0, 1.0),
      duration: 800.ms,
      curve: Curves.elasticOut,
    )
    .rotate(
      begin: -0.15,
      end: 0.0,
      duration: 800.ms,
      curve: Curves.easeOutBack,
    )
    // Impact shake
    .shake(
      duration: 400.ms,
      hz: 4,
      offset: const Offset(4, 4),
    );
  }
}
