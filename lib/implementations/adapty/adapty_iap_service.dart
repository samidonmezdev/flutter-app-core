import 'dart:async';
import 'package:adapty_flutter/adapty_flutter.dart';
import '../../services/iap/iap_service.dart';

class AdaptyIAPService implements IAPService {
  final String adaptyApiKey;

  AdaptyIAPService({required this.adaptyApiKey});

  final _premiumController = StreamController<bool>.broadcast();
  bool _isPremium = false;

  @override
  Future<void> init() async {
    await Adapty().activate(
      configuration: AdaptyConfiguration(apiKey: adaptyApiKey),
    );
    await _refreshPremiumStatus();
  }

  Future<void> _refreshPremiumStatus() async {
    try {
      final profile = await Adapty().getProfile();
      _isPremium = profile.accessLevels['premium']?.isActive ?? false;
      _premiumController.add(_isPremium);
    } catch (_) {}
  }

  @override
  Future<void> purchase(String productId) async {
    final paywalls = await Adapty().getPaywall(placementId: productId);
    final products = await Adapty().getPaywallProducts(paywall: paywalls);
    if (products.isEmpty) return;

    await Adapty().makePurchase(product: products.first);
    await _refreshPremiumStatus();
  }

  @override
  Future<void> restore() async {
    await Adapty().restorePurchases();
    await _refreshPremiumStatus();
  }

  @override
  bool isPremium() => _isPremium;

  @override
  Stream<bool> get premiumStream => _premiumController.stream;
}
