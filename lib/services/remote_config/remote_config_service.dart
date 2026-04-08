abstract class RemoteConfigService {
  Future<void> init();
  Future<void> fetch();
  String getString(String key, {String defaultValue = ''});
  bool getBool(String key, {bool defaultValue = false});
  int getInt(String key, {int defaultValue = 0});
  double getDouble(String key, {double defaultValue = 0.0});
  Map<String, dynamic> getAll();
}
