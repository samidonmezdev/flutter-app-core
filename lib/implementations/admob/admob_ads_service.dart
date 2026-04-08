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
    await _loadInterstitial();
    await _loadRewarded();
  }

  Future<void> _loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> _loadRewarded() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  @override
  Future<void> showInterstitial() async {
    if (_interstitialAd == null) {
      await _loadInterstitial();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
      },
    );
    await _interstitialAd!.show();
  }

  @override
  Future<void> showRewarded({void Function()? onRewarded}) async {
    if (_rewardedAd == null) {
      await _loadRewarded();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
      },
    );
    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) => onRewarded?.call(),
    );
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
