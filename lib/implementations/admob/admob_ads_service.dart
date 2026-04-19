import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ads_service.dart';

class AdMobAdsService implements AdsService {
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final String bannerAdUnitId;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;

  AdMobAdsService({
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.bannerAdUnitId,
  });

  @override
  Future<void> init() async {
    await MobileAds.instance.initialize();
    // Preload in background — don't block startup
    _loadInterstitial();
    _loadRewarded();
  }

  Future<void> _loadInterstitial() async {
    final completer = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    await completer.future;
  }

  Future<void> _loadRewarded() async {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    await completer.future;
  }

  @override
  Future<void> showInterstitial() async {
    // Ad henüz yüklenmemişse bekle (max 8sn)
    if (_interstitialAd == null) {
      await _loadInterstitial().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    }

    if (_interstitialAd == null) return;

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial(); // preload next
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
      },
    );

    await ad.show();
  }

  @override
  Future<void> showRewarded({void Function()? onRewarded}) async {
    // Ad henüz yüklenmemişse bekle (max 10sn)
    if (_rewardedAd == null) {
      await _loadRewarded().timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );
    }

    if (_rewardedAd == null) return;

    final ad = _rewardedAd!;
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadRewarded(); // preload next
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadRewarded();
      },
    );

    await ad.show(onUserEarnedReward: (_, __) => onRewarded?.call());
  }

  @override
  Future<void> showBanner() async {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    await _bannerAd!.load();
  }

  BannerAd? get bannerAd => _bannerAd;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
  }
}
