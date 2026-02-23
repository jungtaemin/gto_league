import 'package:flutter/material.dart';
import '../../../../core/utils/music_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/league_player.dart';
import '../../../../data/models/tier.dart';
import '../../../../data/services/league_service.dart';
import '../../../../data/services/season_helper.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../providers/game_providers.dart';
import '../../../../providers/game_state_notifier.dart';
import 'league/league_header.dart';
import 'league/league_player_card.dart';
import 'league/rival_badge.dart';
import 'league/zone_divider.dart';
/// GTO 리그 화면 -- thin orchestrator delegating to league/ widgets.
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
  DateTime? _lastFetchTime;
  List<LeaguePlayer>? _cachedPlayers;
  String? _cachedGroupId;
  @override
  void initState() {
    super.initState();
    _myUserId = SupabaseService.currentUser?.id;
    _loadLeague();
  }

  Future<void> _loadLeague({bool force = false}) async {
    // Cache check: skip fetch if data is fresh (< 60s) and same group
    if (!force && _lastFetchTime != null && _cachedPlayers != null) {
      final elapsed = DateTime.now().difference(_lastFetchTime!);
      if (elapsed.inSeconds < 60 && _cachedGroupId == _groupId) {
        setState(() { _players = _cachedPlayers!; _isLoading = false; });
        return;
      }
    }
    setState(() => _isLoading = true);
    final leagueService = ref.read(leagueServiceProvider);
    if (SupabaseService.isLoggedIn) {
      _groupId = await leagueService.getCurrentGroupId();
      if (_groupId != null) {
        final players = await leagueService.fetchLeagueRanking(_groupId!);
        if (mounted) {
          _cachedPlayers = players;
          _cachedGroupId = _groupId;
          _lastFetchTime = DateTime.now();
          setState(() { _players = players; _isLoading = false; });
        }
        return;
      } else {
        if (mounted) setState(() { _players = []; _isLoading = false; });
        return;
      }
    }
    final score = ref.read(gameStateProvider).score;
    final players = await leagueService.generateLocalLeague(score);
    if (mounted) {
      _cachedPlayers = players;
      _cachedGroupId = _groupId;
      _lastFetchTime = DateTime.now();
      setState(() { _players = players; _isLoading = false; });
    }
  }
  Tier _getMyTier() {
    if (_players.isEmpty) return Tier.fish;
    final me = _players.where((p) => p.id == _myUserId && p.isReal).firstOrNull;
    return me?.tier ?? _players.first.tier;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = SeasonHelper.getRemainingDuration(DateTime.now());
    final isFeverTime = remaining.inHours < 12;
    final seasonId = SeasonHelper.getSeasonId(DateTime.now());
    final realCount = _players.where((p) => p.isReal).length;
    final myTier = _getMyTier();
    // Rival logic
    final me = _players.where((p) => p.id == _myUserId && p.isReal).firstOrNull;
    final myRank = me?.rank;
    LeaguePlayer? rival;
    int? rivalGap;
    if (myRank != null && myRank > 1) {
      rival = _players.where((p) => p.rank == myRank - 1).firstOrNull;
      if (rival != null && me != null && rival.score > me.score) {
        rivalGap = rival.score - me.score;
      }
    }
    return RefreshIndicator(
      onRefresh: () => _loadLeague(force: true),
      color: AppColors.leaguePromotionGold,
      backgroundColor: AppColors.leagueBgDark,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.leaguePromotionGold))
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                if (SupabaseService.isLoggedIn && _groupId == null && _players.isEmpty)
                  SliverFillRemaining(child: _buildUnassignedView(context))
                else ...[
                   SliverToBoxAdapter(
                     child: LeagueHeader(
                       seasonId: seasonId,
                       remainingDuration: remaining,
                       isFeverTime: isFeverTime,
                       myTier: myTier,
                       realPlayerCount: realCount,
                       isLoggedIn: SupabaseService.isLoggedIn,
                       isAssigned: _groupId != null,
                       onRefresh: _loadLeague,
                     ),
                   ),
                  SliverToBoxAdapter(
                    child: ZoneDivider(
                      label: '승급 존 (TOP 3)',
                      color: AppColors.leaguePromotionGold,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _players.length) return null;
                          final player = _players[index];
                          final rank = player.rank;
                          final isMe = player.id == _myUserId && player.isReal;
                          Widget? divider;
                          if (rank == LeagueService.promotionCount + 1) {
                            divider = ZoneDivider(label: '안전 구간', color: Colors.grey, icon: Icons.shield);
                          } else if (rank == LeagueService.leagueSize - LeagueService.demotionCount + 1) {
                            divider = ZoneDivider(label: '강등 라인', color: AppColors.leagueDemotionRed, icon: Icons.arrow_downward);
                          }
                          Widget? badge;
                          if (rival != null && player.rank == rival.rank && rivalGap != null) {
                            badge = RivalBadge(pointGap: rivalGap);
                          }

                          return Column(
                            children: [
                              if (divider != null) divider,
                              Padding(
                                padding: EdgeInsets.only(bottom: context.w(8)),
                                child: LeaguePlayerCard(
                                  player: player,
                                  isMe: isMe,
                                  trailingBadge: badge,
                                ),
                              ),
                            ],
                          ).animate(delay: (index * 40).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
                        },
                        childCount: _players.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: context.w(16), bottom: context.w(120)),
                      child: Center(
                        child: Text(
                          '시즌 종료 시 리그가 초기화됩니다',
                          style: TextStyle(color: Colors.white24, fontSize: context.sp(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
  Widget _buildUnassignedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: context.w(80), color: Colors.white24),
          SizedBox(height: context.w(20)),
          Text('아직 소속된 리그가 없습니다!',
              style: TextStyle(fontSize: context.sp(20), fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: context.w(8)),
          Text('첫 게임을 완료하면 리그에 배치됩니다.',
              style: TextStyle(fontSize: context.sp(14), color: Colors.white54)),
          SizedBox(height: context.w(32)),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/league').then((_) {
              MusicManager.ensurePlaying(MusicType.lobby);
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.leaguePromotionGold,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: context.w(32), vertical: context.w(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
            ),
            child: Text('배치고사 보러가기',
                style: TextStyle(fontSize: context.sp(16), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
