abstract class RateService {
  Future<void> init();
  Future<void> showRateDialog();
  Future<bool> shouldShowRateDialog();
  void incrementLaunchCount();
}
