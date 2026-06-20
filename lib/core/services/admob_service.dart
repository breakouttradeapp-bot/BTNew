import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdMobService {
  // Test AdMob unit IDs (Google provided test IDs)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _interstitialLoading = false;
  static bool _rewardedLoading = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitial();
    loadRewardedAd();
  }

  static void loadInterstitial() {
    if (_interstitialAd != null || _interstitialLoading) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
          _interstitialAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (err) {
          _interstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  static Future<void> showInterstitial(BuildContext context) async {
    if (_interstitialAd == null) {
      loadInterstitial();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );
    _interstitialAd!.show();
  }

  static void loadRewardedAd() {
    if (_rewardedAd != null || _rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (err) {
          _rewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  static Future<void> showRewardedAd({required VoidCallback onUserEarnedReward}) async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onUserEarnedReward();
    });
  }

  // Helper to create BannerAd for widgets
  static BannerAd createBannerAd({AdSize size = AdSize.banner}) {
    return BannerAd(
      size: size,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
      request: const AdRequest(),
    );
  }
}
