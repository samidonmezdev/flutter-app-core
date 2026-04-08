import '../services/ads/ads_service.dart';
import '../services/iap/iap_service.dart';
import '../services/analytics/analytics_service.dart';
import '../services/push/push_service.dart';
import '../services/version/version_service.dart';
import '../services/rate/rate_service.dart';
import '../services/support/support_service.dart';

class AppConfig {
  final String privacyUrl;
  final String? termsUrl;
  final String supportEmail;
  final AdsService? ads;
  final IAPService? iap;
  final AnalyticsService? analytics;
  final PushService? push;
  final VersionService? version;
  final RateService? rate;
  final SupportService? support;

  const AppConfig({
    required this.privacyUrl,
    required this.supportEmail,
    this.termsUrl,
    this.ads,
    this.iap,
    this.analytics,
    this.push,
    this.version,
    this.rate,
    this.support,
  });
}
