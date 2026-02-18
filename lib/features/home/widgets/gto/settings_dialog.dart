import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/responsive.dart';
import 'stitch_colors.dart';
import 'dart:ui';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock State
  double _bgmVolume = 0.8;
  double _sfxVolume = 1.0;
  bool _vibration = true;
  bool _pushNoti = true;
  int _graphicQuality = 1; // 0: Low, 1: Medium, 2: High
  String _couponCode = "";
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("DEBUG: SettingsDialog V3 (Yellow Fix)");
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
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
        height: context.h(600), // 고정 높이 할당
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95), // Slate 900
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
            BoxShadow(color: StitchColors.blue600.withOpacity(0.1), blurRadius: 30, spreadRadius: 2), // Blue Glow
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
                  fontFamily: 'Black Han Sans', // or system font
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

  // --- TABS ---

  Widget _buildGameSettingsTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        _buildSectionHeader(context, "SOUND"),
        _buildVolumeSlider(context, "배경음 (BGM)", _bgmVolume, (v) => setState(() => _bgmVolume = v)),
        _buildVolumeSlider(context, "효과음 (SFX)", _sfxVolume, (v) => setState(() => _sfxVolume = v)),
        
        SizedBox(height: context.w(20)),
        _buildSectionHeader(context, "GRAPHICS"),
        _buildQualitySelector(context),
        
        SizedBox(height: context.w(20)),
        _buildSectionHeader(context, "SYSTEM"),
        _buildSwitchRow(context, "진동 (Haptic)", _vibration, (v) => setState(() => _vibration = v)),
        _buildSwitchRow(context, "알림 (Push Notification)", _pushNoti, (v) => setState(() => _pushNoti = v)),
      ],
    );
  }

  Widget _buildAccountTab(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? "Guest";
    final email = user?.email ?? "Guest User";

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        // Profile Card
        Container(
          padding: EdgeInsets.all(context.w(16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: context.w(24),
                backgroundColor: StitchColors.blue600,
                child: Text(email[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: context.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: TextStyle(color: Colors.white, fontSize: context.sp(14), fontWeight: FontWeight.bold)),
                    SizedBox(height: context.w(4)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: userId));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UID 복사 완료"), duration: Duration(milliseconds: 800)));
                      },
                      child: Row(
                        children: [
                          Text("UID: ${userId.substring(0, 8)}...", style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(11))),
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
            _buildSocialIcon(context, Icons.g_mobiledata, "Google", true), // Mock connected
            _buildSocialIcon(context, Icons.apple, "Apple", false),
            _buildSocialIcon(context, Icons.email, "Email", true),
          ],
        ),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "MANAGE"),
        _buildActionButton(context, "로그아웃", Icons.logout_rounded, Colors.white70, () async {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        }),
        SizedBox(height: context.w(8)),
        _buildActionButton(context, "회원 탈퇴", Icons.delete_forever_rounded, Colors.red[400]!, () {}),
      ],
    );
  }

  Widget _buildEtcTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      children: [
        _buildSectionHeader(context, "COUPON"),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: context.w(44),
                child: TextField(
                  controller: _couponController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    hintText: "쿠폰 번호를 입력하세요",
                    hintStyle: TextStyle(color: Colors.white30, fontSize: context.sp(12)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: context.w(12)),
                  ),
                ),
              ),
            ),
            SizedBox(width: context.w(8)),
            ElevatedButton(
              onPressed: () {
                // TODO: 쿠폰 입력 로직
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("쿠폰 기능은 준비 중입니다."), duration: Duration(seconds: 1)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.primary,
                foregroundColor: Colors.black,
                fixedSize: Size(context.w(50), context.w(44)), // Width reduced, height kept
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Icon(Icons.check_rounded, size: context.w(24), color: Colors.black),
            ),
          ],
        ),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "COMMUNITY"),
        Row(
          children: [
            Expanded(child: _buildCommunityButton(context, "Discord", const Color(0xFF5865F2), Icons.discord)),
            SizedBox(width: context.w(8)),
            Expanded(child: _buildCommunityButton(context, "Official Cafe", const Color(0xFF03C75A), Icons.forum_rounded)),
          ],
        ),

        SizedBox(height: context.w(24)),
        _buildSectionHeader(context, "INFO"),
        _buildInfoRow(context, "이용약관"),
        _buildInfoRow(context, "개인정보처리방침"),
        _buildInfoRow(context, "버전 정보", value: "v1.0.0 (Beta)"),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      child: Text(
        "© 2024 ANTIGRAVITY GAMES. All Rights Reserved.",
        style: TextStyle(color: Colors.white24, fontSize: context.sp(10)),
        textAlign: TextAlign.center,
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.w(12)),
      child: Text(title, style: TextStyle(color: StitchColors.blue400, fontSize: context.sp(11), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildVolumeSlider(BuildContext context, String title, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(color: Colors.white70, fontSize: context.sp(12))),
            const Spacer(),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(12))),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: StitchColors.blue500,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(BuildContext context, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: context.w(8)),
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(8)),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: context.sp(13))),
          Switch(
            value: value, onChanged: onChanged,
            activeColor: StitchColors.green400,
            activeTrackColor: StitchColors.green400.withOpacity(0.3),
            inactiveThumbColor: Colors.white54,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector(BuildContext context) {
    return Container(
      height: context.w(40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: ["Low", "Medium", "High"].asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final isSelected = _graphicQuality == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _graphicQuality = idx),
              child: AnimatedContainer(
                duration: 200.ms,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? StitchColors.blue600 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: context.sp(12),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
        Text(label, style: TextStyle(color: isConnected ? Colors.white : Colors.white38, fontSize: context.sp(10))),
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

  Widget _buildCommunityButton(BuildContext context, String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
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

  Widget _buildInfoRow(BuildContext context, String label, {String? value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.w(8), horizontal: context.w(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: context.sp(13))),
          if (value != null) Text(value, style: TextStyle(color: StitchColors.slate400, fontSize: context.sp(13))),
          if (value == null) Icon(Icons.chevron_right_rounded, color: Colors.white24, size: context.w(18)),
        ],
      ),
    );
  }
}
