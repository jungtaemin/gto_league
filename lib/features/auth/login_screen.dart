import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/services/supabase_service.dart';
import '../home/widgets/gto/stitch_colors.dart';

/// Stitch 스타일 로그인 화면
/// 
/// Google 로그인 + 게스트 모드 지원
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${e.toString()}'),
            backgroundColor: StitchColors.glowRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _playAsGuest() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0B2E), // Deep navy
              Color(0xFF0F1035), // bgDark
              Color(0xFF1A1B4B), // bgLight
              Color(0xFF0A0B2E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // ─── 로고 영역 ──────────────────────────
              _buildLogo()
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 12),
              
              // 서브타이틀
              const Text(
                'GTO를 마스터하고 랭킹에 도전하세요',
                style: TextStyle(
                  color: StitchColors.slate400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
              
              const Spacer(flex: 2),
              
              // ─── 버튼 영역 ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Google 로그인 버튼
                    _buildGoogleButton()
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 16),
                    
                    // 게스트 모드 버튼
                    _buildGuestButton()
                        .animate(delay: 800.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // ─── 하단 안내 ──────────────────────────
              const Text(
                '로그인하면 글로벌 랭킹에 참여할 수 있습니다',
                style: TextStyle(
                  color: StitchColors.slate500,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 로고 위젯 ──────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 포커 아이콘
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE066), // Gold start
                Color(0xFFFFB800), // Gold mid
                Color(0xFFE68A00), // Gold end
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '♠',
              style: TextStyle(
                fontSize: 48,
                color: Color(0xFF0F1035),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 타이틀
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFE066),
              Color(0xFFFFB800),
              Color(0xFFE68A00),
            ],
          ).createShader(bounds),
          child: const Text(
            'GTO LEAGUE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3.0,
              height: 1.2,
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        const Text(
          'ALL-IN OR FOLD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: StitchColors.slate300,
            letterSpacing: 6.0,
          ),
        ),
      ],
    );
  }

  // ─── Google 로그인 버튼 ──────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" 아이콘
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'G',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Color(0xFF4285F4), // Google Blue
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google로 로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── 게스트 모드 버튼 ──────────────────────────────
  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _playAsGuest,
        style: OutlinedButton.styleFrom(
          foregroundColor: StitchColors.slate300,
          side: const BorderSide(color: StitchColors.slate600, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: StitchColors.slate400,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              '게스트로 플레이',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: StitchColors.slate300,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
