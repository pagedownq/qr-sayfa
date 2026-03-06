import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedInterstitialLoading = false;

  int _interstitialAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  Future<void> init() async {
    if (kIsWeb) return;
    _loadInterstitialAd();
    _loadRewardedInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (kIsWeb || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded.');
          _interstitialAd = ad;
          _interstitialAttempts = 0;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAttempts++;
          _interstitialAd = null;
          _isInterstitialLoading = false;
          if (_interstitialAttempts < maxFailedLoadAttempts) {
            _loadInterstitialAd();
          }
        },
      ),
    );
  }

  void _loadRewardedInterstitialAd() {
    if (kIsWeb || _isRewardedInterstitialLoading) return;
    _isRewardedInterstitialLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5354046379', // Test ID
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedInterstitialAd loaded.');
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd failed: $error');
          _rewardedInterstitialAd = null;
          _isRewardedInterstitialLoading = false;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      onAdDismissed?.call();
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('Ad showed fullscreen.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Ad dismissed fullscreen.');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // Reload for next time
        if (onAdDismissed != null) onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        if (onAdDismissed != null) onAdDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void showRewardedInterstitialAd({VoidCallback? onRewardEarned, VoidCallback? onAdDismissed}) {
    if (_rewardedInterstitialAd == null) {
      debugPrint('Warning: attempt to show rewarded interstitial before loaded.');
      if (onAdDismissed != null) onAdDismissed();
      _loadRewardedInterstitialAd();
      return;
    }

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd(); // Reload for next time
        if (onAdDismissed != null) onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd();
        if (onAdDismissed != null) onAdDismissed();
      },
    );

    _rewardedInterstitialAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      if (onRewardEarned != null) onRewardEarned();
    });
    _rewardedInterstitialAd = null;
  }
}
