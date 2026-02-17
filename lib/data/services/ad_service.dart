import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ---------------------------------------------------------------------------
// Ad Unit IDs (Test IDs — replace with real ones before release)
// ---------------------------------------------------------------------------

class _AdUnitIds {
  // Android test ad unit IDs from Google
  static const String rewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  // iOS test ad unit IDs from Google
  static const String rewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  static String get rewarded {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return rewardedAndroid;
    }
    return rewardedIos;
  }
}

// ---------------------------------------------------------------------------
// Reward Type
// ---------------------------------------------------------------------------

/// Types of rewards the player can earn from watching ads.
enum AdRewardType {
  /// Refill hearts to maximum (5).
  heartRefill,

  /// Add 3 time-bank charges.
  timeBankRefill,

  /// Reveal the GTO chart for the current position (future feature).
  chartReveal,
}

// ---------------------------------------------------------------------------
// Ad Service
// ---------------------------------------------------------------------------

/// Manages Google AdMob rewarded ads for monetization.
///
/// ## Usage:
/// ```dart
/// final adService = AdService();
/// await adService.initialize();
///
/// // Preload an ad
/// adService.loadRewardedAd();
///
/// // Show when ready
/// adService.showRewardedAd(
///   rewardType: AdRewardType.heartRefill,
///   onRewardEarned: () => ref.read(gameStateProvider.notifier).refillHearts(),
///   onAdDismissed: () => adService.loadRewardedAd(), // Preload next
/// );
/// ```
class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Whether a rewarded ad is loaded and ready to show.
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Whether an ad is currently being loaded.
  bool get isLoading => _isLoading;

  // -------------------------------------------------------------------------
  // Initialize
  // -------------------------------------------------------------------------

  /// Initialize the Mobile Ads SDK. Call once at app startup.
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // Preload first rewarded ad
    loadRewardedAd();
  }

  // -------------------------------------------------------------------------
  // Rewarded Ad
  // -------------------------------------------------------------------------

  /// Load a rewarded ad into memory.
  ///
  /// No-op if an ad is already loaded or currently loading.
  void loadRewardedAd() {
    if (_rewardedAd != null || _isLoading) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: _AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('[AdService] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
          debugPrint('[AdService] Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show the loaded rewarded ad.
  ///
  /// - [rewardType]: Which reward to grant (for analytics/logging).
  /// - [onRewardEarned]: Called when the user earns the reward (watched enough).
  /// - [onAdDismissed]: Called when the ad is fully closed (good time to preload next).
  /// - [onAdNotReady]: Called if no ad is loaded. Defaults to silent no-op.
  void showRewardedAd({
    required AdRewardType rewardType,
    required VoidCallback onRewardEarned,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdNotReady,
  }) {
    if (_rewardedAd == null) {
      debugPrint('[AdService] No rewarded ad ready for $rewardType');
      onAdNotReady?.call();
      // Try to load one for next time
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Failed to show ad: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        // Preload next
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] Reward earned: ${reward.amount} ${reward.type} for $rewardType');
        onRewardEarned();
      },
    );
  }

  // -------------------------------------------------------------------------
  // Disposal
  // -------------------------------------------------------------------------

  /// Dispose of any loaded ad. Call when the service is no longer needed.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
