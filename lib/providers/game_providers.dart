import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/ad_service.dart';
import '../data/services/ranking_service.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

/// Global AdService provider.
///
/// Usage:
/// ```dart
/// final adService = ref.read(adServiceProvider);
/// adService.showRewardedAd(...);
/// ```
final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Global RankingService provider.
///
/// Usage:
/// ```dart
/// final ranking = ref.read(rankingServiceProvider);
/// final league = await ranking.generateLeague(playerScore);
/// ```
final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});
