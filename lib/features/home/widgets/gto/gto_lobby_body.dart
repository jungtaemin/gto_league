import 'package:flutter/material.dart';
import '../../../../core/utils/music_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../providers/user_stats_provider.dart';
import 'gto_bottom_nav.dart';
import 'gto_top_bar.dart';
import 'gto_hero_stage.dart';
import 'stitch_colors.dart';
import 'settings_dialog.dart'; // 추가됨
import '../../../../data/models/league_player.dart';
import '../../../../data/models/tier.dart';
import '../../../../data/services/league_service.dart';
import '../../../../data/services/supabase_service.dart';
/// Stitch V2 Lobby Body
/// 반응형: 모든 크기를 context.w() 기반으로 통일
class GtoLobbyBody extends ConsumerWidget {
  const GtoLobbyBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 배틀 버튼이 네비바에 가리지 않도록 충분한 간격 확보
    final navBottomPadding = context.w(GtoBottomNav.designHeight) + context.bottomSafePadding + context.w(20);

    return Column(
      children: [
        // 1. Top Bar
        Padding(
          padding: EdgeInsets.only(top: context.w(2)),
          child: const GtoTopBar(),
        ),

        SizedBox(height: context.w(2)),

        // 2. Logo (화면 전체 너비 기준 중앙) + Side Menu (우측 오버레이)
        _buildLogoWithSideMenu(context),

        // 3. Hero Stage (Robot) → 남은 공간 자동 차지
        const Expanded(
          child: GtoHeroStage(),
        ),

        // 4. Battle Button
        Padding(
          padding: EdgeInsets.only(left: context.w(24), right: context.w(24), bottom: navBottomPadding),
          child: _buildBattleButton(context, ref),
        ),
      ],
    );
  }

  /// 로고는 화면 전체 너비 기준 정중앙, 사이드 메뉴는 우측에 오버레이
  Widget _buildLogoWithSideMenu(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 로고: 전체 너비 사용, 중앙 정렬
        _buildLogoSection(context),
        // 사이드 메뉴: 우측 상단에 오버레이
        Positioned(
          right: context.w(2),
          top: context.w(6),
          child: _buildRightSideMenu(context),
        ),
      ],
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GTO 텍스트 - Column으로 배치하여 LEAGUE와 절대 겹치지 않음
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              stops: [0.2, 1.0],
            ).createShader(bounds),
            child: Text("GTO", style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: context.w(64),
              color: Colors.white,
              letterSpacing: 2.0,
              height: 1.0,
              shadows: [
                const Shadow(color: Color(0xFF1E3A8A), offset: Offset(0, 3), blurRadius: 0),
                Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(0, 6), blurRadius: 10),
              ],
            )),
          ),

          // LEAGUE 텍스트 - GTO 바로 아래에 자연스럽게 배치
          Transform.translate(
            offset: Offset(0, -context.w(8)), // 살짝 위로 당겨서 로고처럼 밀착
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFDE047), Color(0xFFF97316)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text("LEAGUE", style: TextStyle(
                fontFamily: 'Black Han Sans',
                fontSize: context.w(36),
                color: Colors.white,
                letterSpacing: 1.0,
                height: 1.0,
                shadows: [
                  const Shadow(color: Color(0xFF7C2D12), offset: Offset(0, 2), blurRadius: 0),
                  const Shadow(color: Color(0xFF7C2D12), offset: Offset(2, 2), blurRadius: 0),
                  const Shadow(color: Color(0xFF7C2D12), offset: Offset(-2, 2), blurRadius: 0),
                  Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(0, 5), blurRadius: 8),
                ],
              )),
            ),
          ),

          // Chip Tag
          Transform.translate(
            offset: Offset(0, -context.w(4)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.w(4)),
              decoration: BoxDecoration(
                color: const Color(0xFF172554).withOpacity(0.8),
                borderRadius: BorderRadius.circular(context.r(20)),
                border: Border.all(color: StitchColors.blue500.withOpacity(0.5), width: 1),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Text("홀덤 푸시폴드 배틀", style: TextStyle(
                color: StitchColors.blue200, fontSize: context.sp(11), fontWeight: FontWeight.normal, letterSpacing: 0.5
              )),
            ),
          ),
          
          SizedBox(height: context.w(12)),
          
          // League Rank Brief Panel
          const _LeagueBriefPanel(),
        ],
      ),
    );
  }

  Widget _buildBattleButton(BuildContext context, WidgetRef ref) {
    final buttonHeight = context.w(70).clamp(55.0, 90.0);
    final fontSize = context.sp(24);
    final iconSize = context.w(34);
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Floating cost indicator
        Positioned(
          top: -context.w(20),
          child: const FloatingEnergyCost(),
        ),
        GestureDetector(
      onTap: () async {
        final notifier = ref.read(userStatsProvider.notifier);
        final success = await notifier.consumeEnergy();
        
        if (!success) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text('에너지 부족!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                '에너지가 부족합니다!\n상점에서 충전할까요?',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('나중에', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // TODO: 상점 화면으로 이동
                  },
                  child: const Text('충전하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          return;
        }
        if (context.mounted) {
          Navigator.pushNamed(context, '/league').then((_) {
            MusicManager.ensurePlaying(MusicType.lobby);
          });
        }
      },
      child: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(28)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [StitchColors.buttonGoldStart, StitchColors.buttonGoldMid, StitchColors.buttonGoldEnd],
                ),
                boxShadow: [
                  const BoxShadow(color: StitchColors.shadowGold, offset: Offset(0, 5), blurRadius: 0),
                  BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 12), blurRadius: 16),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(28)),
                child: Stack(
                  children: [
                    Positioned(top: 0, left: 0, right: 0, height: 1, child: Container(color: StitchColors.yellow200)),
                    
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: -12 * 3.14159 / 180,
                                child: Icon(Icons.sports_mma, size: iconSize, color: const Color(0xFF6D4C41)),
                              ),
                              SizedBox(width: context.w(10)),
                              Text("리그 참가", style: TextStyle(
                                fontFamily: 'Black Han Sans', fontSize: fontSize, 
                                color: const Color(0xFF5D4037), letterSpacing: 1.0,
                                height: 1.2,
                                shadows: const [Shadow(color: Colors.white24, offset: Offset(0, 1), blurRadius: 0)],
                              )),
                              SizedBox(width: context.w(6)),
                              Icon(Icons.navigate_next_rounded, size: iconSize * 0.83, color: const Color(0xFF8D6E63)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      top: 0, left: 0, right: 0, height: buttonHeight * 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
      ],
    );
  }

  Widget _buildRightSideMenu(BuildContext context) {
    return Column(
      children: [
        _buildSideButton(context, Icons.settings_rounded, "설정", StitchColors.slate400, onTap: () {
          showDialog(context: context, builder: (context) => const SettingsDialog());
        }),
        SizedBox(height: context.w(10)),
        _buildSideButton(context, Icons.emoji_events_rounded, "업적", StitchColors.blue400),
        SizedBox(height: context.w(10)),
        _buildSideButton(context, Icons.mail_rounded, "우편함", StitchColors.cyan400),
      ],
    );
  }

  Widget _buildSideButton(BuildContext context, IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(42), height: context.w(42),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(context.r(12))),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: color),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: StitchColors.blue300, size: context.w(14)),
                  Text(label, style: TextStyle(
                    color: StitchColors.blue300, fontSize: context.sp(6), fontWeight: FontWeight.bold,
                    height: 1.2,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 1, end: 0, curve: Curves.easeOutBack);
  }
}

class FloatingEnergyCost extends ConsumerWidget {
  const FloatingEnergyCost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final tier = stats.tier;
    
    // 임시 티어별 입장료 산정 (기획)
    int chipCost = 0;
    if (tier.minScore >= Tier.shark.minScore) {
      chipCost = 1000;
    } else if (tier.minScore >= Tier.pubReg.minScore) {
      chipCost = 100;
    }

    return Animate(
      key: const ValueKey('FloatingEnergyCost_Anim'),
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        MoveEffect(begin: const Offset(0, 0), end: const Offset(0, -5), duration: 1200.ms, curve: Curves.easeInOut),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(4)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StitchColors.yellow400.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: StitchColors.yellow400, size: context.w(14)),
            SizedBox(width: context.w(2)),
            Text(
              "-1",
              style: TextStyle(color: StitchColors.yellow400, fontSize: context.sp(12), fontWeight: FontWeight.bold),
            ),
            if (chipCost > 0) ...[
              SizedBox(width: context.w(8)),
              Icon(Icons.diamond, color: Colors.amber, size: context.w(12)),
              SizedBox(width: context.w(2)),
              Text(
                "-$chipCost",
                style: TextStyle(color: Colors.amber, fontSize: context.sp(12), fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// 메인 화면 랭킹 브리핑 패널
class _LeagueBriefPanel extends StatefulWidget {
  const _LeagueBriefPanel();

  @override
  State<_LeagueBriefPanel> createState() => _LeagueBriefPanelState();
}

class _LeagueBriefPanelState extends State<_LeagueBriefPanel> {
  bool _isLoading = true;
  int? _myRank;
  Tier? _myTier;
  int? _totalCount;
  bool _isAssigned = false;

  @override
  void initState() {
    super.initState();
    _loadMyRank();
  }

  Future<void> _loadMyRank() async {
    if (!SupabaseService.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final groupId = await LeagueService().getCurrentGroupId();
      if (groupId != null) {
        final players = await LeagueService().fetchLeagueRanking(groupId);
        final me = players.firstWhere(
          (p) => p.id == SupabaseService.currentUser!.id,
          orElse: () => const LeaguePlayer(id: '', nickname: '', score: 0, tier: Tier.fish, rank: 0, type: PlayerType.real),
        );
        if (me.id.isNotEmpty && me.rank > 0) {
          _myRank = me.rank;
          _myTier = me.tier;
          _totalCount = players.length;
          _isAssigned = true;
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink(); // 로딩중엔 숨김

    String message = "첫 게임을 플레이하고 리그에 배치되세요!";
    Color bgColor = Colors.black.withOpacity(0.3);
    Color textColor = Colors.white70;

    if (_isAssigned && _myRank != null && _myTier != null && _totalCount != null) {
      message = "현재 ${_myTier!.displayName} 리그 ${_myRank}위 / ${_totalCount}명";
      if (LeagueService.isPromotion(_myRank!)) {
        message += " 🔥승급권";
        bgColor = const Color(0xFFD97706).withOpacity(0.8);
        textColor = Colors.white;
      } else if (LeagueService.isDemotion(_myRank!)) {
        message += " 🥶강등권";
        bgColor = const Color(0xFFB91C1C).withOpacity(0.8);
        textColor = Colors.white;
      } else {
        message += " (잔류)";
        bgColor = const Color(0xFF2563EB).withOpacity(0.8);
        textColor = Colors.white;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(8)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_rounded, color: textColor, size: context.w(14)),
          SizedBox(width: context.w(6)),
          Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).moveY(begin: context.w(10), end: 0, duration: 500.ms);
  }
}
