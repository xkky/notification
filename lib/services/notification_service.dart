import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../desktop/linux_notification.dart';
import '../desktop/macos_notification.dart';
import '../desktop/windows_notification.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const macosSettings = DarwinInitializationSettings();
    const windowsSettings = WindowsInitializationSettings(
        appName: 'notification', appUserModelId: '', guid: '');
    const linuxSettings = LinuxInitializationSettings(defaultActionName: '通知');
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
      windows: windowsSettings,
      linux: linuxSettings,
    );

    await _localNotifications.initialize(settings);
    _initialized = true;
  }

  static Future<void> show({
    required String title,
    required String body,
    String sound = 'default',
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        await showWindowsToast(title, body);
        break;
      case TargetPlatform.macOS:
        await showMacOSNotification(title, body, sound: sound);
        break;
      case TargetPlatform.linux:
        await showLinuxNotification(title, body, sound: sound);
        break;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        await showLocalNotification(title: title, body: body, sound: sound);
        break;
      default:
        break;
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String sound = 'default',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'notification_project',
      'Notification Project',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound,
    );

    final macOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macOSDetails,
    );

    final id = Random().nextInt(100000);
    await _localNotifications.show(
      id,
      title,
      body,
      details,
    );
  }
}
