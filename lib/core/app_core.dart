import 'app_config.dart';
import 'event_bus.dart';
import '../services/ads/ads_service.dart';
import '../services/iap/iap_service.dart';
import '../services/analytics/analytics_service.dart';
import '../services/push/push_service.dart';
import '../services/version/version_service.dart';
import '../services/rate/rate_service.dart';
import '../services/support/support_service.dart';
import '../services/remote_config/remote_config_service.dart';
import '../services/deep_link/deep_link_service.dart';

class AppCore {
  AppCore._();

  static AppConfig? _config;
  static bool _initialized = false;

  static AppConfig get config {
    assert(_initialized, 'AppCore.bootstrap() must be called first.');
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

  static RemoteConfigService get remoteConfig {
    assert(config.remoteConfig != null, 'RemoteConfigService not provided in AppConfig');
    return config.remoteConfig!;
  }

  static DeepLinkService get deepLink {
    assert(config.deepLink != null, 'DeepLinkService not provided in AppConfig');
    return config.deepLink!;
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
      if (config.remoteConfig != null) config.remoteConfig!.init(),
      if (config.deepLink != null) config.deepLink!.init(),
    ]);

    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}
