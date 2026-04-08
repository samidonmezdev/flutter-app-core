import 'app_config.dart';
import 'event_bus.dart';
import '../services/ads/ads_service.dart';
import '../services/iap/iap_service.dart';
import '../services/analytics/analytics_service.dart';
import '../services/push/push_service.dart';
import '../services/version/version_service.dart';
import '../services/rate/rate_service.dart';
import '../services/support/support_service.dart';

class AppCore {
  AppCore._();

  static AppConfig? _config;
  static bool _initialized = false;

  static AppConfig get config {
    assert(_initialized, 'AppCore.bootstrap() must be called before accessing config');
    return _config!;
  }

  static AdsService get ads {
    assert(config.ads != null, 'AdsService not provided in AppConfig');
    return config.ads!;
  }

  static IAPService get iap {
    assert(config.iap != null, 'IAPService not provided in AppConfig');
    return config.iap!;
  }

  static AnalyticsService get analytics {
    assert(config.analytics != null, 'AnalyticsService not provided in AppConfig');
    return config.analytics!;
  }

  static PushService get push {
    assert(config.push != null, 'PushService not provided in AppConfig');
    return config.push!;
  }

  static VersionService get version {
    assert(config.version != null, 'VersionService not provided in AppConfig');
    return config.version!;
  }

  static RateService get rate {
    assert(config.rate != null, 'RateService not provided in AppConfig');
    return config.rate!;
  }

  static SupportService get support {
    assert(config.support != null, 'SupportService not provided in AppConfig');
    return config.support!;
  }

  static AppEventBus get events => AppEventBus.instance;

  static Future<void> bootstrap(AppConfig config) async {
    _config = config;

    await Future.wait([
      if (config.ads != null) config.ads!.init(),
      if (config.iap != null) config.iap!.init(),
      if (config.analytics != null) config.analytics!.init(),
      if (config.push != null) config.push!.init(),
      if (config.version != null) config.version!.init(),
      if (config.rate != null) config.rate!.init(),
    ]);

    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}
