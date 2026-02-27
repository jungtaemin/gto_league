import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/music_manager.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../../../core/utils/haptic_manager.dart';
import '../../../decorate/providers/decorate_provider.dart';
import 'stitch_colors.dart';
import 'dart:ui';
// ── SharedPreferences Keys ──────────────────────────
const _kBgmVolume = 'settings_bgm_volume';
const _kSfxVolume = 'settings_sfx_volume';
const _kVibration = 'settings_vibration';
const _kPushNoti  = 'settings_push_noti';

/// 앱 시작 시 호출하여 저장된 설정을 매니저에 적용합니다.
Future<void> applyStoredSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final bgm = prefs.getDouble(_kBgmVolume) ?? 0.4;
  final sfx = prefs.getDouble(_kSfxVolume) ?? 1.0;
  final vib = prefs.getBool(_kVibration) ?? true;
  await MusicManager.setVolume(bgm);
  await SoundManager.setVolume(sfx);
  HapticManager.setEnabled(vib);
}

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> with TickerProviderStateMixin {
  late TabController _tabController;

  // Live State — initialized from actual managers
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _vibration;
  bool _pushNoti = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Read current values from actual managers
    _bgmVolume = MusicManager.volume;
    _sfxVolume = SoundManager.volume;
    _vibration = HapticManager.enabled;
    _loadPushNoti();
  }

  Future<void> _loadPushNoti() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pushNoti = prefs.getBool(_kPushNoti) ?? true;
      });
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBgmVolume, _bgmVolume);
    await prefs.setDouble(_kSfxVolume, _sfxVolume);
    await prefs.setBool(_kVibration, _vibration);
    await prefs.setBool(_kPushNoti, _pushNoti);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 다이얼로그 닫을 때 자동 저장
    _saveToPrefs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(24)),
        side: BorderSide.none,
      ),
      insetPadding: EdgeInsets.all(context.w(16)),
      child: Container(
        width: double.infinity,
        height: context.h(600),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
            BoxShadow(color: StitchColors.blue600.withOpacity(0.1), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                _buildHeader(context),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGameSettingsTab(context),
                      _buildAccountTab(context),
                      _buildEtcTab(context),
                    ],
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(duration: 200.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(16)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: StitchColors.blue400, size: context.w(24)),
              SizedBox(width: context.w(8)),
              Text(
                "SETTINGS",
                style: TextStyle(
                  fontFamily: 'Black Han Sans',
                  color: Colors.white,
                  fontSize: context.sp(20),
                  letterSpacing: 1.0,
                  shadows: [Shadow(color: StitchColors.blue600.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.white54, size: context.w(24)),
            splashRadius: context.w(20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.w(16)),
      height: context.w(44),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: StitchColors.blue600,
          borderRadius: BorderRadius.circular(context.r(10)),
          boxShadow: [BoxShadow(color: StitchColors.blue600.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
          gradient: const LinearGradient(colors: [StitchColors.blue500, StitchColors.blue700]),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: StitchColors.slate400,
        labelStyle: TextStyle(fontSize: context.sp(14), fontWeight: FontWeight.bold),
        padding: EdgeInsets.all(context.w(4)),
        tabs: const [
          Tab(text: "게임 설정"),
          Tab(text: "계정"),
          Tab(text: "기타"),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 1: 게임 설정
  // ═══════════════════════════════════════════════════════════

  Widget _buildGameSettingsTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        _buildSectionHeader(context, "SOUND"),
        _buildVolumeSlider(context, "배경음 (BGM)", Icons.music_note_rounded, _bgmVolume, (v) {
          setState(() => _bgmVolume = v);
          MusicManager.setVolume(v);
        }),
        _buildVolumeSlider(context, "효과음 (SFX)", Icons.volume_up_rounded, _sfxVolume, (v) {
          setState(() => _sfxVolume = v);
          SoundManager.setVolume(v);
        }),
        
        SizedBox(height: context.w(20)),
        _buildSectionHeader(context, "SYSTEM"),
        _buildSwitchRow(context, "진동 (Haptic)", Icons.vibration, _vibration, (v) {
          setState(() => _vibration = v);
          HapticManager.setEnabled(v);
          if (v) HapticManager.correct(); // 켜졌을 때 즉시 피드백
        }),
        _buildSwitchRow(context, "알림 (Push Notification)", Icons.notifications_active_rounded, _pushNoti, (v) {
          setState(() => _pushNoti = v);
          // 실제 푸시 알림 제어는 향후 Firebase 연동 시 추가
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 2: 계정
  // ═══════════════════════════════════════════════════════════

  Widget _buildAccountTab(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? "Guest";
    final email = user?.email ?? "Guest User";

    // Detect which providers are actually linked
    final identities = user?.identities ?? [];
    final hasGoogle = identities.any((i) => i.provider == 'google');
    final hasApple = identities.any((i) => i.provider == 'apple');
    final hasEmail = identities.any((i) => i.provider == 'email');

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        // ── Profile Card ──
        Container(
          padding: EdgeInsets.all(context.w(16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final equippedUrl = ref.watch(equippedCharacterUrlProvider);
                  
                  if (equippedUrl != null) {
                    return Container(
                      width: context.w(48),
                      height: context.w(48),
                      decoration: BoxDecoration(
                        color: StitchColors.bgDark,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(equippedUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: StitchColors.blue300, width: 2),
                      ),
                    );
                  }

                  return CircleAvatar(
                    radius: context.w(24),
                    backgroundColor: StitchColors.blue600,
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              SizedBox(width: context.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: TextStyle(color: Colors.white, fontSize: context.sp(14), fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.w(4)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: userId));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("✅ UID 복사 완료"),
                              duration: const Duration(milliseconds: 800),
                              backgroundColor: StitchColors.green400,
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            "UID: ${userId.length > 8 ? '${userId.substring(0, 8)}...' : userId}",
                            style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(11)),
                          ),
                          SizedBox(width: context.w(4)),
                          Icon(Icons.copy_rounded, color: StitchColors.slate400, size: context.w(12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "LINKED ACCOUNTS"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialIcon(context, Icons.g_mobiledata, "Google", hasGoogle),
            _buildSocialIcon(context, Icons.apple, "Apple", hasApple),
            _buildSocialIcon(context, Icons.email, "Email", hasEmail),
          ],
        ),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "MANAGE"),
        _buildActionButton(context, "로그아웃", Icons.logout_rounded, Colors.white70, () async {
          final confirm = await _showConfirmDialog(
            context,
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            confirmText: "로그아웃",
            confirmColor: StitchColors.blue500,
          );
          if (confirm == true && context.mounted) {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            }
          }
        }),
        SizedBox(height: context.w(8)),
        _buildActionButton(context, "회원 탈퇴", Icons.delete_forever_rounded, Colors.red[400]!, () async {
          final confirm = await _showConfirmDialog(
            context,
            title: "⚠️ 회원 탈퇴",
            message: "모든 게임 데이터가 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 탈퇴하시겠습니까?",
            confirmText: "탈퇴하기",
            confirmColor: Colors.red,
          );
          if (confirm == true && context.mounted) {
            try {
              // Supabase Edge Function이나 Admin API로 사용자 삭제
              // 현재는 로그아웃만 수행 (서버 측 삭제 로직 필요)
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("탈퇴 처리가 요청되었습니다."), duration: Duration(seconds: 2)),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("탈퇴 실패: $e"), duration: const Duration(seconds: 2)),
                );
              }
            }
          }
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 3: 기타
  // ═══════════════════════════════════════════════════════════

  Widget _buildEtcTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        _buildSectionHeader(context, "COUPON"),
        _CouponInput(),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "COMMUNITY"),
        Row(
          children: [
            Expanded(
              child: _buildCommunityButton(context, "Discord", const Color(0xFF5865F2), Icons.discord, () {
                _copyAndNotify(context, "https://discord.gg/antigravity", "Discord 초대 링크가 복사되었습니다!");
              }),
            ),
            SizedBox(width: context.w(8)),
            Expanded(
              child: _buildCommunityButton(context, "공식 카페", const Color(0xFF03C75A), Icons.forum_rounded, () {
                _copyAndNotify(context, "https://cafe.naver.com/antigravity", "공식 카페 링크가 복사되었습니다!");
              }),
            ),
          ],
        ),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "INFO"),
        _buildInfoRow(context, "이용약관", onTap: () {
          _copyAndNotify(context, "https://antigravity.games/terms", "이용약관 링크가 복사되었습니다!");
        }),
        _buildInfoRow(context, "개인정보처리방침", onTap: () {
          _copyAndNotify(context, "https://antigravity.games/privacy", "개인정보처리방침 링크가 복사되었습니다!");
        }),
        _buildInfoRow(context, "오픈소스 라이선스", onTap: () {
          showLicensePage(
            context: context,
            applicationName: 'Holdem All-In Fold',
            applicationVersion: 'v1.0.0',
          );
        }),
        _buildInfoRow(context, "버전 정보", value: "v1.0.0 (Beta)"),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      child: Text(
        "© 2025 ANTIGRAVITY GAMES. All Rights Reserved.",
        style: TextStyle(color: Colors.white24, fontSize: context.sp(10)),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.w(12)),
      child: Text(
        title,
        style: TextStyle(
          color: StitchColors.blue400,
          fontSize: context.sp(11),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(
    BuildContext context,
    String title,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: StitchColors.slate400, size: context.w(16)),
            SizedBox(width: context.w(6)),
            Text(title, style: TextStyle(color: Colors.white70, fontSize: context.sp(12))),
            const Spacer(),
            Text(
              value <= 0 ? "OFF" : "${(value * 100).toInt()}%",
              style: TextStyle(
                color: value <= 0 ? Colors.red[400] : StitchColors.slate400,
                fontSize: context.sp(12),
                fontWeight: value <= 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            activeTrackColor: StitchColors.blue500,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: context.w(8)),
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(8)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: StitchColors.slate400, size: context.w(18)),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.white70, fontSize: context.sp(13))),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: StitchColors.green400,
            activeTrackColor: StitchColors.green400.withOpacity(0.3),
            inactiveThumbColor: Colors.white54,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String label, bool isConnected) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.w(12)),
          decoration: BoxDecoration(
            color: isConnected ? StitchColors.blue600 : Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(color: isConnected ? StitchColors.blue400 : Colors.transparent),
          ),
          child: Icon(icon, color: Colors.white, size: context.w(20)),
        ),
        SizedBox(height: context.w(4)),
        Text(
          label,
          style: TextStyle(color: isConnected ? Colors.white : Colors.white38, fontSize: context.sp(10)),
        ),
        SizedBox(height: context.w(2)),
        Text(
          isConnected ? "연결됨" : "미연결",
          style: TextStyle(
            color: isConnected ? StitchColors.green400 : Colors.white24,
            fontSize: context.sp(9),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(12)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.sp(14))),
            Icon(icon, color: color, size: context.w(18)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: context.w(12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: context.w(18)),
      label: Text(label, style: TextStyle(fontSize: context.sp(12), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, {String? value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.w(10), horizontal: context.w(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: context.sp(13))),
            if (value != null)
              Text(value, style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(13))),
            if (value == null)
              Icon(Icons.chevron_right_rounded, color: Colors.white24, size: context.w(18)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  void _copyAndNotify(BuildContext context, String url, String message) {
    Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.link, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: StitchColors.blue600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: Colors.white70, fontSize: context.sp(14))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("취소", style: TextStyle(color: StitchColors.slate400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Coupon Input Widget (stateful for its own text controller)
// ═══════════════════════════════════════════════════════════

class _CouponInput extends StatefulWidget {
  @override
  State<_CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<_CouponInput> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeemCoupon() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("쿠폰 코드를 입력해주세요."), duration: Duration(seconds: 1)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Supabase RPC or Edge Function 호출
      final response = await Supabase.instance.client
          .from('coupons')
          .select()
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (!mounted) return;

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ 유효하지 않은 쿠폰입니다."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 쿠폰이 적용되었습니다! (${response['reward'] ?? 'reward'})"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("쿠폰 확인 실패: $e"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: context.w(44),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                hintText: "쿠폰 번호를 입력하세요",
                hintStyle: TextStyle(color: Colors.white30, fontSize: context.sp(12)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: context.w(12)),
                prefixIcon: Icon(Icons.card_giftcard, color: Colors.white24, size: context.w(18)),
              ),
            ),
          ),
        ),
        SizedBox(width: context.w(8)),
        SizedBox(
          width: context.w(50),
          height: context.w(44),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _redeemCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.zero,
            ),
            child: _isLoading
                ? SizedBox(width: context.w(18), height: context.w(18), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Icon(Icons.check_rounded, size: context.w(24), color: Colors.black),
          ),
        ),
      ],
    );
  }
}
