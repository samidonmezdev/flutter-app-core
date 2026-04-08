import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/iap/iap_service.dart';

class RevenueCatIAPService implements IAPService {
  final String apiKey;

  /// Kontrol edilecek entitlement ID (RevenueCat dashboard'dan)
  final String entitlementId;

  RevenueCatIAPService({
    required this.apiKey,
    this.entitlementId = 'premium',
  });

  final _premiumController = StreamController<bool>.broadcast();
  bool _isPremium = false;

  @override
  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener((info) {
      _isPremium = info.entitlements.active.containsKey(entitlementId);
      _premiumController.add(_isPremium);
    });

    await _refreshPremiumStatus();
  }

  Future<void> _refreshPremiumStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _isPremium = info.entitlements.active.containsKey(entitlementId);
      _premiumController.add(_isPremium);
    } catch (_) {}
  }

  @override
  Future<void> purchase(String productId) async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return;

    final package = current.availablePackages.firstWhere(
      (p) => p.storeProduct.identifier == productId,
      orElse: () => current.availablePackages.first,
    );

    await Purchases.purchasePackage(package);
    await _refreshPremiumStatus();
  }

  @override
  Future<void> restore() async {
    await Purchases.restorePurchases();
    await _refreshPremiumStatus();
  }

  @override
  bool isPremium() => _isPremium;

  @override
  Stream<bool> get premiumStream => _premiumController.stream;
}
