import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/widgets/neon_text.dart';
import '../../core/widgets/neo_brutalist_button.dart';
import '../../data/models/league_player.dart';
import '../../providers/game_providers.dart';
import '../../providers/game_state_notifier.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  List<LeaguePlayer> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeague();
  }

  Future<void> _loadLeague() async {
    setState(() => _isLoading = true);
    final rankingService = ref.read(rankingServiceProvider);
    final playerScore = ref.read(gameStateNotifierProvider).score;
    final league = await rankingService.generateLeague(playerScore);
    if (mounted) {
      setState(() {
        _players = league;
        _isLoading = false;
      });
    }
  }

  void _refreshLeague() {
    setState(() {
      _players = [];
      _isLoading = true;
    });
    _loadLeague();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title
            const Center(
              child: NeonText(
                "🏆 오늘의 리그",
                color: AppColors.acidYellow,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                strokeWidth: 2.5,
                glowIntensity: 0.8,
                animated: true,
              ),
            ).animate().fadeIn(duration: 600.ms).scale(curve: Curves.easeOutBack),
            
            const SizedBox(height: 20),

            // League Table
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.acidYellow))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: _players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return _buildPlayerRow(player)
                            .animate(delay: (index * 50).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutBack);
                      },
                    ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  NeoBrutalistButton(
                    label: "새로고침",
                    isPrimary: true,
                    color: AppColors.electricBlue,
                    textColor: AppColors.pureWhite,
                    onPressed: _refreshLeague,
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalistButton(
                    label: "나가기",
                    isPrimary: false,
                    color: AppColors.darkGray,
                    textColor: AppColors.pureWhite,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(LeaguePlayer player) {
    final isMe = !player.isGhost;
    final rank = player.rank;
    
    // Rank styling
    Color rankColor;
    double rankGlow;
    
    if (rank == 1) {
      rankColor = AppColors.acidYellow;
      rankGlow = 0.8;
    } else if (rank == 2) {
      rankColor = AppColors.neonCyan;
      rankGlow = 0.6;
    } else if (rank == 3) {
      rankColor = AppColors.neonPink;
      rankGlow = 0.6;
    } else {
      rankColor = AppColors.pureWhite.withOpacity(0.7);
      rankGlow = 0.0;
    }

    // Container styling
    final borderColor = isMe ? AppColors.acidYellow : AppColors.pureWhite.withOpacity(0.1);
    final List<BoxShadow> shadows = isMe 
        ? AppShadows.innerGlow(AppColors.acidYellow) 
        : [];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 40,
            child: NeonText(
              "#$rank",
              color: rankColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              glowIntensity: rankGlow,
              animated: false,
            ),
          ),
          
          // Player Info
          Expanded(
            child: Row(
              children: [
                Text(
                  player.tier.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.nickname,
                        style: AppTextStyles.body(
                          color: isMe ? AppColors.acidYellow : AppColors.pureWhite
                        ).copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (player.isGhost)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "👻",
                      style: TextStyle(
                        fontSize: 16, 
                        color: AppColors.pureWhite.withOpacity(0.5)
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Score
          NeonText(
            "${player.score}",
            color: AppColors.pureWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            glowIntensity: 0.3,
            animated: false,
          ),
        ],
      ),
    );
  }
}
