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

  const LevelUpCutscene({
    super.key,
    required this.newLevel,
    required this.newBbLevel,
    required this.onComplete,
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
                        // "🚨 STAGE UP!" with scale bounce + shake
                        Transform.scale(
                          scale: _stageScaleIn.value.clamp(0.0, 1.2),
                          child: Text(
                            '🚨 STAGE UP!',
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

                        const SizedBox(height: 24),

                        // "BLINDS UP! (XXbb)" with slide-up + fade
                        SlideTransition(
                          position: _blindsSlideUp,
                          child: Opacity(
                            opacity: _blindsFadeIn.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: AppColors.neonGlow(
                                  theme.accent,
                                  intensity: 0.4,
                                ),
                              ),
                              child: Text(
                                'BLINDS UP! (${widget.newBbLevel}BB)',
                                style: AppTextStyles.heading(
                                  color: theme.accent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
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
}
