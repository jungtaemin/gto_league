import 'package:flutter/material.dart';
import 'widgets/gto/gto_background.dart';
import 'widgets/gto/gto_bottom_nav.dart';
import 'widgets/gto/gto_lobby_body.dart';
import 'widgets/gto/gto_league_body.dart';
import 'widgets/gto/gto_train_body.dart';
import '../decorate/decorate_page.dart';
import '../../core/utils/music_manager.dart';
import '../../data/services/league_service.dart';
import '../../data/models/tier.dart';
import 'widgets/gto/league/league_result_dialog.dart';

/// GTO League Home Screen – Stitch V1 layout
class GtoHomeScreen extends StatefulWidget {
  const GtoHomeScreen({super.key});

  @override
  State<GtoHomeScreen> createState() => _GtoHomeScreenState();
}

class _GtoHomeScreenState extends State<GtoHomeScreen> {
  int _navIndex = 2; // default to battle tab (Lobby)

  @override
  void initState() {
    super.initState();
    MusicManager.play(MusicType.lobby);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSeasonResult();
    });
  }

  Future<void> _checkSeasonResult() async {
    final result = await LeagueService().checkUnreadSeasonResult();
    if (result != null && mounted) {
      final seasonId = result['season_id'] as String;
      final tierName = result['tier'] as String;
      final settleResult = result['settle_result'] as String;
      final reward = result['settle_reward'] as int;

      LeagueResultType type;
      final currentTier = Tier.fromName(tierName);
      Tier previousTier = currentTier;

      if (settleResult == 'promotion') {
        type = LeagueResultType.promotion;
        previousTier = _getPreviousTier(currentTier, isPromotion: true);
      } else if (settleResult == 'demotion') {
        type = LeagueResultType.demotion;
        previousTier = _getPreviousTier(currentTier, isPromotion: false);
      } else {
        type = LeagueResultType.retention;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => LeagueResultDialog(
          type: type,
          previousTier: previousTier,
          currentTier: currentTier,
          rewardChips: reward,
          onClaim: () {
            LeagueService().markSeasonResultAsRead(seasonId);
          },
        ),
      );
    }
  }

  Tier _getPreviousTier(Tier current, {required bool isPromotion}) {
    final tiers = Tier.values;
    final currentIndex = tiers.indexOf(current);
    if (isPromotion) {
      if (currentIndex > 0) return tiers[currentIndex - 1];
    } else {
      if (currentIndex < tiers.length - 1) return tiers[currentIndex + 1];
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 0: Full-screen background (Persistent)
          const Positioned.fill(child: GtoBackground()),

          // Layer 1: Body Content (Switchable)
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _navIndex,
                children: const [
                  Center(child: Text("Shop (Wait)", style: TextStyle(color: Colors.white))), // 0
                  DecoratePage(), // 1: Decorate
                  GtoLobbyBody(), // 2: Home
                  GtoLeagueBody(), // 3: Ranking
                  GtoTrainBody(), // 4: Training (Deep Run)
                ],
              ),
            ),
          ),

          // Layer 2: Bottom Navigation Bar (Persistent)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GtoBottomNav(
              selectedIndex: _navIndex,
              onTap: (index) {
                setState(() { _navIndex = index; });
                // If special handling needs to push route instead of tab switch?
                // User requirement: "below menu layout maintain... touch and scroll comfortably"
                // Tab switching is best for this.
                // However, Play Button in LobbyBody still pushes '/game'.
              },
            ),
          ),
        ],
      ),
    );
  }
}
