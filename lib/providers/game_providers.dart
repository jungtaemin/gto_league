import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/ad_service.dart';
import '../data/services/league_service.dart';
import '../data/services/ranking_service.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

/// Global AdService provider.
final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Global RankingService provider (기존 로컬 고스트 리그 — 호환 유지).
final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});

/// Global LeagueService provider (Supabase JIT 매칭 리그).
///
/// 사용:
/// ```dart
/// final league = ref.read(leagueServiceProvider);
/// await league.joinOrCreateLeague(score);
/// ```
final leagueServiceProvider = Provider<LeagueService>((ref) {
  return LeagueService();
});
