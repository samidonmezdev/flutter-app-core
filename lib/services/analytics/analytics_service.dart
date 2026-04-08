abstract class AnalyticsService {
  Future<void> init();
  void logEvent(String name, {Map<String, dynamic>? params});
  void setUserId(String userId);
  void setUserProperty(String name, String value);
}
