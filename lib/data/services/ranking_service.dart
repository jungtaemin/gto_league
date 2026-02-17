import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/league_player.dart';
import '../models/tier.dart';

// ---------------------------------------------------------------------------
// Ghost Name Pool (Korean poker nicknames)
// ---------------------------------------------------------------------------

const _ghostNicknames = [
  '올인맨', '폴드왕', '블러퍼', '콜링머신', '리버래트',
  '샤크킹', '피쉬사냥꾼', '팟컨트롤러', '넛츠헌터', '밸류벳왕',
  '체크레이즈', '쓰리벳러', '포벳마스터', '프리플랍신', '턴벳왕',
  '리버킬러', '스택빌더', '칩리더', 'ICM머신', '버블보이',
  '파이널이스트', '딜러킬러', '바운티헌터', '레이트렉', '얼리렉',
  'GTO초보', '착한피쉬', '동키브레인', '펍레전드', '그라인더맨',
  '핸드리딩왕', '레인지맨', '블록벳러', '오버벳러', '씬밸류왕',
  '미니멀렉', '빅블선생', '스몰블꿈', 'UTG전사', 'BB수비대',
];

// ---------------------------------------------------------------------------
// Ranking Service
// ---------------------------------------------------------------------------

/// Manages the 9-Max daily league with ghost player generation.
///
/// ## Ghost Sync Design (Server cost = $0)
///
/// Instead of real-time multiplayer, we simulate a competitive league:
/// 1. Generate 8 ghost players with score distributions matching the
///    player's current tier (±1 tier)
/// 2. Ghost scores drift slightly each session to feel "alive"
/// 3. Player's best daily score is stored locally + synced to Supabase
/// 4. Daily reset at midnight KST
///
/// ## Supabase Integration (Future)
/// - Anonymous auth on first launch
/// - Upload: {userId, score, tier, date}
/// - Download: top 100 scores for ghost pool enrichment
/// - Cost: ~0 under free tier (< 500 MAU, < 500MB DB)
class RankingService {
  static const int _leagueSize = 9; // 9-Max like a poker table
  static const String _bestScoreKey = 'daily_best_score';
  static const String _bestScoreDateKey = 'daily_best_date';
  static const String _playerIdKey = 'player_uuid';
  static const String _playerNicknameKey = 'player_nickname';

  final Random _random;
  final Uuid _uuid;

  RankingService({Random? random})
      : _random = random ?? Random(),
        _uuid = const Uuid();

  // -------------------------------------------------------------------------
  // Player Identity
  // -------------------------------------------------------------------------

  /// Get or create a persistent player UUID.
  Future<String> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_playerIdKey);
    if (id == null) {
      id = _uuid.v4();
      await prefs.setString(_playerIdKey, id);
    }
    return id;
  }

  /// Get or set player nickname.
  Future<String> getPlayerNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNicknameKey) ?? '나';
  }

  Future<void> setPlayerNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNicknameKey, nickname);
  }

  // -------------------------------------------------------------------------
  // Daily Best Score
  // -------------------------------------------------------------------------

  /// Get today's best score (resets daily at midnight).
  Future<int> getDailyBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_bestScoreDateKey);
    final today = _todayString();

    if (savedDate != today) {
      // New day — reset
      await prefs.setInt(_bestScoreKey, 0);
      await prefs.setString(_bestScoreDateKey, today);
      return 0;
    }

    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  /// Submit a score. Only updates if it beats today's best.
  /// Returns true if it's a new daily high score.
  Future<bool> submitScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();

    // Ensure date is current
    final savedDate = prefs.getString(_bestScoreDateKey);
    if (savedDate != today) {
      await prefs.setString(_bestScoreDateKey, today);
      await prefs.setInt(_bestScoreKey, 0);
    }

    final currentBest = prefs.getInt(_bestScoreKey) ?? 0;
    if (score > currentBest) {
      await prefs.setInt(_bestScoreKey, score);
      debugPrint('[RankingService] New daily best: $score (was $currentBest)');
      return true;
    }
    return false;
  }

  // -------------------------------------------------------------------------
  // 9-Max League Generation
  // -------------------------------------------------------------------------

  /// Generate a full 9-Max league with the player + 8 ghosts.
  ///
  /// Ghost scores cluster around the player's [playerScore] for tension:
  /// - 3 ghosts slightly above (challenge)
  /// - 3 ghosts slightly below (competition)
  /// - 2 ghosts at wider range (outliers)
  Future<List<LeaguePlayer>> generateLeague(int playerScore) async {
    final playerId = await getPlayerId();
    final nickname = await getPlayerNickname();
    final playerTier = Tier.fromScore(playerScore);

    final players = <LeaguePlayer>[];

    // Add the real player
    players.add(LeaguePlayer(
      id: playerId,
      nickname: nickname,
      score: playerScore,
      tier: playerTier,
      rank: 0, // Will be calculated
      isGhost: false,
    ));

    // Generate 8 ghosts
    const ghostCount = _leagueSize - 1;
    final usedNames = <String>{nickname};

    for (var i = 0; i < ghostCount; i++) {
      final ghostScore = _generateGhostScore(playerScore, i);
      final ghostTier = Tier.fromScore(ghostScore);
      final ghostName = _pickUniqueName(usedNames);

      players.add(LeaguePlayer(
        id: _uuid.v4(),
        nickname: ghostName,
        score: ghostScore,
        tier: ghostTier,
        rank: 0,
        isGhost: true,
      ));
    }

    // Sort by score descending and assign ranks
    players.sort((a, b) => b.score.compareTo(a.score));
    final ranked = <LeaguePlayer>[];
    for (var i = 0; i < players.length; i++) {
      ranked.add(players[i].copyWith(rank: i + 1));
    }

    return ranked;
  }

  // -------------------------------------------------------------------------
  // Supabase Sync (Scaffold — enable when credentials available)
  // -------------------------------------------------------------------------

  /// Upload score to Supabase. No-op until Supabase is configured.
  ///
  /// Future implementation:
  /// ```dart
  /// final supabase = Supabase.instance.client;
  /// await supabase.from('scores').upsert({
  ///   'user_id': playerId,
  ///   'score': score,
  ///   'tier': tier.name,
  ///   'date': todayString,
  /// });
  /// ```
  Future<void> syncScoreToCloud(int score) async {
    // TODO: Enable when Supabase project is created
    debugPrint('[RankingService] Cloud sync placeholder — score: $score');
  }

  /// Download ghost pool from Supabase for enriched matchmaking.
  /// Returns empty list until Supabase is configured.
  Future<List<LeaguePlayer>> fetchCloudGhosts() async {
    // TODO: Enable when Supabase project is created
    debugPrint('[RankingService] Cloud ghost fetch placeholder');
    return [];
  }

  // -------------------------------------------------------------------------
  // Private Helpers
  // -------------------------------------------------------------------------

  int _generateGhostScore(int playerScore, int index) {
    // Distribution: 3 above, 3 below, 2 outliers
    final baseVariance = max(50, (playerScore * 0.15).round());

    if (index < 3) {
      // Slightly above player
      return playerScore + _random.nextInt(baseVariance) + 10;
    } else if (index < 6) {
      // Slightly below player
      return max(0, playerScore - _random.nextInt(baseVariance) - 10);
    } else {
      // Wider range outliers
      final wideVariance = baseVariance * 2;
      final offset = _random.nextInt(wideVariance) - (wideVariance ~/ 2);
      return max(0, playerScore + offset);
    }
  }

  String _pickUniqueName(Set<String> usedNames) {
    final available =
        _ghostNicknames.where((n) => !usedNames.contains(n)).toList();
    if (available.isEmpty) {
      // Fallback: append number
      final name = '고스트${usedNames.length}';
      usedNames.add(name);
      return name;
    }
    final name = available[_random.nextInt(available.length)];
    usedNames.add(name);
    return name;
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
