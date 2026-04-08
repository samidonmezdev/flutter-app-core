import 'package:firebase_analytics/firebase_analytics.dart';
import '../../services/analytics/analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  late final FirebaseAnalytics _analytics;

  @override
  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
  }

  @override
  void logEvent(String name, {Map<String, dynamic>? params}) {
    _analytics.logEvent(
      name: name,
      parameters: params?.map((k, v) => MapEntry(k, v as Object)),
    );
  }

  @override
  void setUserId(String userId) {
    _analytics.setUserId(id: userId);
  }

  @override
  void setUserProperty(String name, String value) {
    _analytics.setUserProperty(name: name, value: value);
  }

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}
