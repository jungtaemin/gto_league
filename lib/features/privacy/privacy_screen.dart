import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/neon_text.dart';
import '../../core/widgets/neo_brutalist_button.dart';
import '../../core/theme/app_shadows.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: NeonText(
                      '🔒 개인정보 처리방침',
                      fontSize: 24,
                      color: AppColors.acidYellow,
                      glowIntensity: 0.8,
                      animated: true,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      context,
                      icon: '📋',
                      title: '수집하는 정보',
                      content: '본 앱은 최소한의 정보만 수집합니다: 기기 식별자(UUID), 게임 점수, 닉네임',
                      accentColor: AppColors.neonPink,
                      delay: 100,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      icon: '🎯',
                      title: '정보 이용 목적',
                      content: '리그 순위 표시, 게임 진행 상태 저장, 서비스 품질 개선',
                      accentColor: AppColors.neonCyan,
                      delay: 200,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      icon: '🔐',
                      title: '정보 보관 및 보호',
                      content: '모든 데이터는 Supabase 클라우드에 암호화되어 저장됩니다. 개인을 특정할 수 있는 정보는 수집하지 않습니다.',
                      accentColor: AppColors.acidGreen,
                      delay: 300,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      icon: '🗑️',
                      title: '정보 삭제',
                      content: '앱 삭제 시 기기 내 모든 데이터가 삭제됩니다. 클라우드 데이터 삭제를 원하시면 앱 내 문의를 이용해주세요.',
                      accentColor: AppColors.laserRed,
                      delay: 400,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      icon: '📧',
                      title: '문의',
                      content: 'antigravity.dev@gmail.com',
                      accentColor: AppColors.electricBlue,
                      delay: 500,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: NeoBrutalistButton(
                onPressed: () => Navigator.of(context).pop(),
                label: '돌아가기',
                color: AppColors.pureWhite,
                textColor: AppColors.pureBlack,
                isPrimary: false,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 1.0, end: 0.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    required String content,
    required Color accentColor,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.pureBlack, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.neonHardShadow(accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonText(
                  title,
                  fontSize: 18,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  glowIntensity: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body(color: AppColors.pureWhite.withOpacity(0.9)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOutBack);
  }
}
