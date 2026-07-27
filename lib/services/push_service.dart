import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushService {
  PushService({this.onMessageReceived});

  final void Function(RemoteMessage message)? onMessageReceived;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      debugPrint('FCM token: $token');
    }

    FirebaseMessaging.onMessage.listen((message) {
      onMessageReceived?.call(message);
    });
  }

  Future<String?> getToken() async => _messaging.getToken();
}
