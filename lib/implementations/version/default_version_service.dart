import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/version/version_service.dart';

class DefaultVersionService implements VersionService {
  final String androidPackageId;
  final String iosAppId;

  /// Uygulama bu sürümün altındaysa force update göster.
  final String? minimumVersion;

  String? _currentVersion;

  DefaultVersionService({
    required this.androidPackageId,
    required this.iosAppId,
    this.minimumVersion,
  });

  @override
  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
  }

  @override
  Future<bool> isUpdateRequired() async {
    if (minimumVersion == null || _currentVersion == null) return false;
    return _compareVersions(_currentVersion!, minimumVersion!) < 0;
  }

  @override
  Future<bool> isUpdateAvailable() async {
    // Store'dan güncel versiyon çekmek için HTTP isteği gerekir.
    // Basit tutmak için false döndürüyoruz; upgrader paketi ile genişletilebilir.
    return false;
  }

  @override
  String? getStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$androidPackageId';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id$iosAppId';
    }
    return null;
  }

  @override
  Future<void> openStore() async {
    final url = getStoreUrl();
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  int _compareVersions(String v1, String v2) {
    final a = v1.split('.').map(int.parse).toList();
    final b = v2.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      final diff = (a.elementAtOrNull(i) ?? 0) - (b.elementAtOrNull(i) ?? 0);
      if (diff != 0) return diff;
    }
    return 0;
  }
}
