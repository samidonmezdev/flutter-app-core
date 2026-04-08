import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/push/push_service.dart';

class FCMPushService implements PushService {
  late final FirebaseMessaging _messaging;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  /// Arka planda gelen mesajları işlemek için top-level bir handler gerekir.
  /// Uygulamanda main() içinde şunu çağır:
  /// FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  @override
  Future<void> init() async {
    _messaging = FirebaseMessaging.instance;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground mesajları
    FirebaseMessaging.onMessage.listen((message) {
      _messageController.add({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      });
    });
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<void> subscribe(String topic) =>
      _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribe(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  @override
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
}
