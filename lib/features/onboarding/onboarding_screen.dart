import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/widgets/neon_text.dart';
import '../../core/widgets/neo_brutalist_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.deepBlack,
                    AppColors.midnightBlue.withOpacity(0.5),
                    AppColors.deepBlack,
                  ],
                ),
              ),
            ),
          ),

          // PageView
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
            ],
          ),

          // Skip Button (Top Right)
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: _onFinish,
              child: Text(
                "건너뛰기",
                style: AppTextStyles.bodySmall(color: AppColors.darkGray)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),

          // Bottom Controls (Dots + Button)
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isActive ? 24 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.acidYellow : AppColors.darkGray,
                        border: Border.all(
                          color: AppColors.pureBlack,
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.acidYellow.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: _currentPage == 2
                      ? NeoBrutalistButton(
                          onPressed: _onFinish,
                          label: "시작하기!",
                          color: AppColors.neonPink,
                          textColor: AppColors.pureWhite,
                          isPrimary: true,
                        )
                      : NeoBrutalistButton(
                          onPressed: _onNext,
                          label: "다음",
                          color: AppColors.acidYellow,
                          textColor: AppColors.pureBlack,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Anchor
          const Text(
            "👋",
            style: TextStyle(fontSize: 80),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut)
              .moveY(begin: 20, end: 0, duration: 400.ms),
          
          const SizedBox(height: 40),

          // Title
          const NeonText(
            "스와이프 조작법",
            fontSize: 32,
            color: AppColors.neonCyan,
            glowIntensity: 1.2,
            animated: true,
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border.all(color: AppColors.pureBlack, width: 4),
              boxShadow: AppShadows.hardShadow,
            ),
            child: Column(
              children: [
                Text(
                  "← FOLD  |  ALL-IN →",
                  style: AppTextStyles.headingSmall(color: AppColors.acidYellow),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "포커 핸드를 보고 스와이프!",
                  style: AppTextStyles.body(color: AppColors.pureWhite),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .scale(delay: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Anchor
          const Text(
            "🧠",
            style: TextStyle(fontSize: 80),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut)
              .moveY(begin: 20, end: 0, duration: 400.ms),

          const SizedBox(height: 40),

          // Title
          const NeonText(
            "GTO란?",
            fontSize: 32,
            color: AppColors.neonPurple,
            glowIntensity: 1.2,
            animated: true,
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border.all(color: AppColors.pureBlack, width: 4),
              boxShadow: AppShadows.neonHardShadow(AppColors.neonPurple),
            ),
            child: Column(
              children: [
                Text(
                  "Game Theory Optimal\n= 수학적 최적해",
                  style: AppTextStyles.headingSmall(color: AppColors.pureWhite),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "정답률이 높을수록 티어 UP! 🚀",
                  style: AppTextStyles.body(color: AppColors.acidGreen),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .scale(delay: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Anchor
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "❤️",
                style: TextStyle(fontSize: 64),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
              const SizedBox(width: 20),
              const Text(
                "🔥",
                style: TextStyle(fontSize: 64),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .shimmer(duration: 1500.ms, color: AppColors.acidYellow),
            ],
          ),

          const SizedBox(height: 40),

          // Title
          const NeonText(
            "하트 & 콤보",
            fontSize: 32,
            color: AppColors.laserRed,
            glowIntensity: 1.2,
            animated: true,
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border.all(color: AppColors.pureBlack, width: 4),
              boxShadow: AppShadows.neonHardShadow(AppColors.laserRed),
            ),
            child: Column(
              children: [
                Text(
                  "❤️ = 목숨 (틀리면 -1)",
                  style: AppTextStyles.body(color: AppColors.pureWhite),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "🔥 콤보 = 연속 정답 보너스",
                  style: AppTextStyles.body(color: AppColors.acidYellow),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .scale(delay: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
