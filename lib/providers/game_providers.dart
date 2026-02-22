import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/ad_service.dart';
import '../data/services/league_service.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

/// Global AdService provider.
final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(() => service.dispose());
  return service;
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
