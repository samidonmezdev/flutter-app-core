abstract class AdsService {
  Future<void> init();
  Future<void> showInterstitial();
  Future<void> showRewarded({void Function()? onRewarded});
  Future<void> showBanner();
  void dispose();
}
