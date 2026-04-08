import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/rate/rate_service.dart';

class DefaultRateService implements RateService {
  final int minLaunchCount;
  final int minDaysSinceInstall;

  static const _kLaunchCountKey = 'app_core_launch_count';
  static const _kFirstLaunchKey = 'app_core_first_launch_ms';
  static const _kRatedKey = 'app_core_rated';

  DefaultRateService({
    this.minLaunchCount = 3,
    this.minDaysSinceInstall = 3,
  });

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // İlk açılış tarihini kaydet
    if (!prefs.containsKey(_kFirstLaunchKey)) {
      await prefs.setInt(
        _kFirstLaunchKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  @override
  Future<void> showRateDialog() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRatedKey, true);
    } else {
      await inAppReview.openStoreListing();
    }
  }

  @override
  Future<bool> shouldShowRateDialog() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_kRatedKey) == true) return false;

    final launchCount = prefs.getInt(_kLaunchCountKey) ?? 0;
    if (launchCount < minLaunchCount) return false;

    final firstLaunchMs = prefs.getInt(_kFirstLaunchKey) ?? 0;
    final daysSince = DateTime.now()
        .difference(
          DateTime.fromMillisecondsSinceEpoch(firstLaunchMs),
        )
        .inDays;

    return daysSince >= minDaysSinceInstall;
  }

  @override
  void incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kLaunchCountKey) ?? 0;
    await prefs.setInt(_kLaunchCountKey, current + 1);
  }
}
