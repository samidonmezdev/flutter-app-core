abstract class VersionService {
  Future<void> init();
  Future<bool> isUpdateRequired();
  Future<bool> isUpdateAvailable();
  String? getStoreUrl();
  Future<void> openStore();
}
