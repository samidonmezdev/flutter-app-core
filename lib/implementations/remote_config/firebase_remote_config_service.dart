import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../services/remote_config/remote_config_service.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  late final FirebaseRemoteConfig _remoteConfig;

  /// Fetch aralığı — production'da 1 saat önerilen minimum
  final Duration fetchInterval;

  /// Başlangıç default değerleri
  final Map<String, dynamic> defaults;

  FirebaseRemoteConfigService({
    this.fetchInterval = const Duration(hours: 1),
    this.defaults = const {},
  });

  @override
  Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: fetchInterval,
      ),
    );

    if (defaults.isNotEmpty) {
      await _remoteConfig.setDefaults(
        defaults.map((k, v) => MapEntry(k, v)),
      );
    }

    await _remoteConfig.fetchAndActivate();
  }

  @override
  Future<void> fetch() async {
    await _remoteConfig.fetchAndActivate();
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final val = _remoteConfig.getString(key);
    return val.isEmpty ? defaultValue : val;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  Map<String, dynamic> getAll() {
    return _remoteConfig.getAll().map(
      (k, v) => MapEntry(k, v.asString()),
    );
  }
}
