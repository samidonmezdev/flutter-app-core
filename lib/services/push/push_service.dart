abstract class PushService {
  Future<void> init();
  Future<String?> getToken();
  Future<void> subscribe(String topic);
  Future<void> unsubscribe(String topic);
  Stream<Map<String, dynamic>> get onMessage;
}
