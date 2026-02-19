import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/league_player.dart';
import '../../../../data/models/tier.dart';
import '../../../../data/services/league_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../providers/game_providers.dart';
import '../../../../providers/game_state_notifier.dart';

/// GTO 리그 화면 — 실제 Supabase 데이터 연동
/// 
/// 듀오링고 스타일: 20명 그룹, 상위 5명 승급, 하위 5명 강등
class GtoLeagueBody extends ConsumerStatefulWidget {
  const GtoLeagueBody({super.key});

  @override
  ConsumerState<GtoLeagueBody> createState() => _GtoLeagueBodyState();
}

class _GtoLeagueBodyState extends ConsumerState<GtoLeagueBody> {
  List<LeaguePlayer> _players = [];
  bool _isLoading = true;
  String? _groupId;
  String? _myUserId;

  // ─── Colors ─────────────────────────────────────────
  static const _bgDark = Color(0xFF0F0C29);
  static const _gold = Color(0xFFFBBF24);
  static const _goldDark = Color(0xFFD97706);
  static const _cyan = Color(0xFF22D3EE);
  static const _red = Color(0xFFF87171);

  @override
  void initState() {
    super.initState();
    _myUserId = SupabaseService.currentUser?.id;
    _loadLeague();
  }

  Future<void> _loadLeague() async {
    setState(() => _isLoading = true);
    
    final leagueService = ref.read(leagueServiceProvider);
    
    if (SupabaseService.isLoggedIn) {
      // 1. 현재 주차 그룹 ID 조회
      _groupId = await leagueService.getCurrentGroupId();
      
      if (_groupId != null) {
        // 2. 실제 랭킹 데이터 로드
        final players = await leagueService.fetchLeagueRanking(_groupId!);
        if (mounted) {
          setState(() {
            _players = players;
            _isLoading = false;
          });
        }
        return;
      } else {
        // 로그인 상태지만 미배정 → 미배치 뷰 표시 (로컬 리그 생성 안 함)
        if (mounted) {
          setState(() {
            _players = [];
            _isLoading = false;
          });
        }
        return;
      }
    }
    
    // 비로그인 → 로컬 고스트 리그 (체험판)
    final score = ref.read(gameStateProvider).score;
    final players = await leagueService.generateLocalLeague(score);
    if (mounted) {
      setState(() {
        _players = players;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final leagueService = ref.read(leagueServiceProvider);
    final weekNumber = leagueService.getWeekNumber();
    final weekYear = weekNumber ~/ 100;
    final weekNum = weekNumber % 100;
    final myTier = _getCurrentTierFromPlayers();

    return RefreshIndicator(
      onRefresh: _loadLeague,
      color: _gold,
      backgroundColor: _bgDark,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFBBF24)))
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 미배치 상태 (로그인 상태이나 그룹 없음)
                if (SupabaseService.isLoggedIn && _groupId == null && _players.isEmpty)
                  SliverFillRemaining(
                    child: _buildUnassignedView(context),
                  )
                else ...[
                  // ── Header Section ──
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.w(12)),
                      
                      // Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                                  ).createShader(bounds),
                                  child: Text('9-Max 리그', style: TextStyle(fontSize: context.sp(24), fontWeight: FontWeight.w900, color: Colors.white)),
                                ),
                                SizedBox(height: context.w(2)),
                                Text(
                                  // 20년차 개발자 관점: 단순 날짜 대신 '시즌 종료 임박' 느낌 강조
                                  'Weekly Season ${weekNumber % 100} · ${_getSeasonEndTime()}',
                                  style: TextStyle(fontSize: context.sp(11), color: const Color(0xFF22D3EE), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            // 참여 인원 / 새로고침
                            GestureDetector(
                              onTap: _loadLeague,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.w(5)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(context.r(20)),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white54, size: context.w(14)),
                                    SizedBox(width: context.w(4)),
                                    Text(
                                      '${_players.where((p) => !p.isGhost).length}명 참여중',
                                      style: TextStyle(color: Colors.white, fontSize: context.sp(11), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: context.w(12)),

                      // Tier Icons Row
                      SizedBox(
                        height: context.w(80),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          children: Tier.values.map((t) {
                            final isMe = t == myTier;
                            return _buildTierIcon(context, t.emoji, t.displayName, _tierColor(t), isMe);
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: context.w(8)),
                      
                      // 비로그인 / 미배정 안내
                      if (!SupabaseService.isLoggedIn)
                        _buildInfoBanner(context, '로그인하면 리그에 참여됩니다!', Icons.cloud_off_rounded, Colors.orange)
                      else if (_groupId == null)
                        _buildInfoBanner(context, '첫 게임을 완료하면 리그에 배치됩니다!', Icons.info_outline, _cyan),
                    ],
                  ),
                ),
                
                // ── Promotion Zone Header ──
                SliverToBoxAdapter(
                  child: _buildZoneDivider(context, '승급 존 (TOP 5)', _gold, Icons.arrow_upward),
                ),
                
                // ── Player List ──
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _players.length) return null;
                        
                        final player = _players[index];
                        final rank = player.rank;
                        
                        // 승급/강등 라인 구분자 삽입
                        Widget? divider;
                        if (rank == LeagueService.promotionCount + 1) {
                          divider = _buildZoneDivider(context, '안전 구간', Colors.grey, Icons.shield);
                        } else if (rank == LeagueService.leagueSize - LeagueService.demotionCount + 1) {
                          divider = _buildZoneDivider(context, '강등 라인', _red, Icons.arrow_downward);
                        }
                        
                        final isMe = player.id == _myUserId && !player.isGhost;
                        
                        return Column(
                          children: [
                            if (divider != null) divider,
                            Padding(
                              padding: EdgeInsets.only(bottom: context.w(8)),
                              child: isMe
                                  ? _buildMeCard(context, player)
                                  : LeagueService.isPromotion(rank)
                                      ? _buildPromotionCard(context, player)
                                      : LeagueService.isDemotion(rank)
                                          ? _buildDemotionCard(context, player)
                                          : player.isEmptySlot
                                              ? _buildEmptySlotCard(context, player)
                                              : _buildNormalCard(context, player),
                            ),
                          ],
                        ).animate(delay: (index * 40).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
                      },
                      childCount: _players.length,
                    ),
                  ),
                ),
                
                // ── Footer ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: context.w(16), bottom: context.w(120)),
                    child: Center(
                      child: Text(
                        '매주 월요일 리그가 초기화됩니다',
                        style: TextStyle(color: Colors.white24, fontSize: context.sp(10)),
                      ),
                    ),
                  ),
                ),
                ], // else ...[] 닫기
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════

  Tier _getCurrentTierFromPlayers() {
    if (_players.isEmpty) return Tier.fish;
    final me = _players.where((p) => p.id == _myUserId && !p.isGhost);
    if (me.isNotEmpty) return me.first.tier;
    return _players.first.tier;
  }

  Color _tierColor(Tier t) {
    return switch (t) {
      Tier.fish => const Color(0xFF60A5FA),
      Tier.donkey => const Color(0xFFA3E635),
      Tier.callingStation => const Color(0xFFF472B6),
      Tier.pubReg => const Color(0xFFFCD34D),
      Tier.grinder => const Color(0xFF94A3B8),
      Tier.shark => const Color(0xFF22D3EE),
      Tier.gtoMachine => const Color(0xFFC084FC),
    };
  }

  // ═══════════════════════════════════════════════════
  // CARD WIDGETS
  // ═══════════════════════════════════════════════════

  Widget _buildMeCard(BuildContext context, LeaguePlayer player) {
    final zoneLabel = LeagueService.getZoneLabel(player.rank);
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.w(4)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: _cyan, width: 2),
        boxShadow: [
          BoxShadow(color: _cyan.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
          BoxShadow(color: _cyan.withOpacity(0.15), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: context.w(32),
            child: Text('${player.rank}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(22), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _cyan,
                shadows: [Shadow(color: _cyan.withOpacity(0.8), blurRadius: 5)],
              ),
            ),
          ),
          SizedBox(width: context.w(8)),
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: context.w(44), height: context.w(44),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(child: Text(player.nickname.isNotEmpty ? player.nickname[0] : '?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.sp(16)))),
              ),
              Positioned(top: -4, left: -4, child: Container(
                width: context.w(18), height: context.w(18),
                decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle),
                child: Center(child: Text('나', style: TextStyle(color: Colors.white, fontSize: context.sp(7), fontWeight: FontWeight.bold))),
              )),
            ],
          ),
          SizedBox(width: context.w(12)),
          // Name + Zone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(player.nickname, style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                    Row(children: [
                      Icon(Icons.arrow_upward, color: _cyan.withOpacity(0.8), size: context.w(12)),
                      SizedBox(width: context.w(2)),
                      Text('${player.score}p', style: TextStyle(color: _cyan.withOpacity(0.9), fontSize: context.sp(16), fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
                SizedBox(height: context.w(4)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (zoneLabel != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.w(2)),
                        decoration: BoxDecoration(
                          color: (LeagueService.isPromotion(player.rank) ? _gold : _red).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(context.r(6)),
                        ),
                        child: Text(zoneLabel, style: TextStyle(color: LeagueService.isPromotion(player.rank) ? _gold : _red, fontSize: context.sp(9), fontWeight: FontWeight.bold)),
                      )
                    else
                      Text('안전권', style: TextStyle(color: _gold.withOpacity(0.7), fontSize: context.sp(10), fontWeight: FontWeight.bold)),
                    Text('${player.tier.emoji} ${player.tier.displayName}', style: TextStyle(fontSize: context.sp(10), color: Colors.white38)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, LeaguePlayer player) {
    final isKing = player.rank == 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFFACC15).withOpacity(0.15), const Color(0xFFFACC15).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: _gold.withOpacity(isKing ? 0.3 : 0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.w(32),
            child: Text('${player.rank}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(isKing ? 20 : 16), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                color: player.rank <= 3 ? _gold : Colors.white54)),
          ),
          SizedBox(width: context.w(8)),
          _buildAvatar(context, player, isKing ? context.w(40) : context.w(36), player.rank <= 3 ? _gold : _goldDark),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(player.nickname, style: TextStyle(color: Colors.white, fontSize: context.sp(14), fontWeight: isKing ? FontWeight.bold : FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      if (isKing) ...[
                        SizedBox(width: context.w(6)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.w(1)),
                          decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(context.r(6))),
                          child: Text('왕', style: TextStyle(color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.bold)),
                        ),
                      ],
                      if (player.isGhost) ...[
                        SizedBox(width: context.w(4)),
                        Text('👻', style: TextStyle(fontSize: context.sp(12))),
                      ],
                    ],
                  ),
                ),
                Text('${player.score}p', style: TextStyle(color: player.rank <= 3 ? _gold : const Color(0xFFFDE68A).withOpacity(0.8), fontSize: context.sp(14), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalCard(BuildContext context, LeaguePlayer player) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.w(32),
            child: Text('${player.rank}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold, color: Colors.white38)),
          ),
          SizedBox(width: context.w(8)),
          _buildAvatar(context, player, context.w(32), Colors.grey.shade700),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(player.nickname, style: TextStyle(color: Colors.white38, fontSize: context.sp(14)), overflow: TextOverflow.ellipsis)),
                      if (player.isGhost) ...[SizedBox(width: context.w(4)), Text('👻', style: TextStyle(fontSize: context.sp(10)))],
                    ],
                  ),
                ),
                Text('${player.score}p', style: TextStyle(color: Colors.white30, fontSize: context.sp(12), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemotionCard(BuildContext context, LeaguePlayer player) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_red.withOpacity(0.05), _red.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.w(32),
            child: Text('${player.rank}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold, color: Colors.red.shade300.withOpacity(0.8))),
          ),
          SizedBox(width: context.w(8)),
          _buildAvatar(context, player, context.w(32), Colors.red.shade900.withOpacity(0.4)),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(player.nickname, style: TextStyle(color: Colors.white60, fontSize: context.sp(14)), overflow: TextOverflow.ellipsis)),
                      if (player.isGhost) ...[SizedBox(width: context.w(4)), Text('👻', style: TextStyle(fontSize: context.sp(10)))],
                      SizedBox(width: context.w(6)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.w(1)),
                        decoration: BoxDecoration(color: _red.withOpacity(0.2), borderRadius: BorderRadius.circular(context.r(6))),
                        child: Text('강등', style: TextStyle(color: _red, fontSize: context.sp(8), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Text('${player.score}p', style: TextStyle(color: Colors.red.shade300, fontSize: context.sp(12), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // COMMON WIDGETS
  // ═══════════════════════════════════════════════════

  Widget _buildAvatar(BuildContext context, LeaguePlayer player, double size, Color bgColor) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: bgColor,
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Center(child: Text(
        player.nickname.isNotEmpty ? player.nickname[0] : '?',
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: size * 0.35),
      )),
    );
  }

  Widget _buildTierIcon(BuildContext context, String emoji, String label, Color color, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(right: context.w(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isActive ? context.w(56) : context.w(48),
            height: isActive ? context.w(56) : context.w(48),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.8), color.withOpacity(0.4)]),
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(color: isActive ? _gold : Colors.white.withOpacity(0.2), width: isActive ? 2 : 1),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Text(emoji, style: TextStyle(fontSize: isActive ? context.sp(28) : context.sp(22)))),
                if (isActive)
                  Positioned(top: -8, left: 0, right: 0, child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(6), vertical: context.w(2)),
                      decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(8)),
                      child: Text('나', style: TextStyle(color: Colors.black, fontSize: context.sp(8), fontWeight: FontWeight.w900)),
                    ),
                  )),
              ],
            ),
          ),
          SizedBox(height: context.w(4)),
          Text(label, style: TextStyle(
            fontSize: isActive ? context.sp(11) : context.sp(10),
            color: isActive ? _gold : Colors.white38,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildZoneDivider(BuildContext context, String label, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.w(8)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, color, Colors.transparent]))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(4)),
            decoration: BoxDecoration(
              color: _bgDark,
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: context.w(14)),
                SizedBox(width: context.w(4)),
                Text(label, style: TextStyle(color: color, fontSize: context.sp(10), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context, String text, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.w(8)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.w(16)),
            SizedBox(width: context.w(8)),
            Expanded(child: Text(text, style: TextStyle(color: color, fontSize: context.sp(12), fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // UNASSIGNED VIEW & EMPTY SLOT
  // ═══════════════════════════════════════════════════

  Widget _buildUnassignedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: context.w(80), color: Colors.white24),
          SizedBox(height: context.w(20)),
          Text(
            '아직 소속된 리그가 없습니다!',
            style: TextStyle(fontSize: context.sp(20), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: context.w(8)),
          Text(
            '첫 게임을 완료하면 리그에 배치됩니다.',
            style: TextStyle(fontSize: context.sp(14), color: Colors.white54),
          ),
          SizedBox(height: context.w(32)),
          // 게임 시작 버튼 (로비로 이동하거나 바로 게임 시작)
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: context.w(32), vertical: context.w(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
            ),
            child: Text('배치고사 보러가기', style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard(BuildContext context, LeaguePlayer player) {
    // 빈 슬롯은 투명하게 처리하여 유저가 채워질 공간임을 암시
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.w(10)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.w(32),
            child: Text('${player.rank}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold, color: Colors.white12)),
          ),
          SizedBox(width: context.w(8)),
            Container(
              width: context.w(32), height: context.w(32),
              decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
              child: Icon(Icons.person_outline, color: Colors.white24, size: context.w(16)),
            ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('매칭 중...', style: TextStyle(color: Colors.white24, fontSize: context.sp(14), fontStyle: FontStyle.italic)),
                Text('-', style: TextStyle(color: Colors.white12, fontSize: context.sp(12), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSeasonEndTime() {
    final now = DateTime.now();
    // 다음 주 월요일 00:00 (KST 기준이라 가정하고 로컬 타임 사용)
    // 실제 서비스에서는 UTC 고려 필요하나, 모바일 게임 특성상 로컬 시간 기준 D-Day가 직관적일 수 있음.
    // 여기서는 단순히 다음 월요일까지 남은 시간을 계산.
    var nextMonday = DateTime(now.year, now.month, now.day);
    while (nextMonday.weekday != DateTime.monday) {
      nextMonday = nextMonday.add(const Duration(days: 1));
    }
    if (nextMonday.isBefore(now)) {
      nextMonday = nextMonday.add(const Duration(days: 7));
    }
    
    final diff = nextMonday.difference(now);
    if (diff.inDays > 0) {
      return '종료까지 ${diff.inDays}일 남음 🔥';
    } else {
      final hours = diff.inHours;
      if (hours > 0) return '종료까지 $hours시간 남음 ⏰';
      return '곧 시즌 종료 ⏳';
    }
  }
}
