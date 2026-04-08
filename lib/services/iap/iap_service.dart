abstract class IAPService {
  Future<void> init();
  Future<void> purchase(String productId);
  Future<void> restore();
  bool isPremium();
  Stream<bool> get premiumStream;
}
