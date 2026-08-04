import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../desktop/linux_notification.dart';
import '../desktop/macos_notification.dart';
import '../desktop/windows_notification.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 闹钟流音频上下文,使声音在静音/震动模式下也能播放
  static final _alarmAudioContext = AudioContext(
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.alarm,
      contentType: AndroidContentType.sonification,
    ),
  );
  static final AudioPlayer _alarmPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

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

    await _localNotifications.initialize(settings: settings);

    // Android 13+ 需运行时申请通知权限
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

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
    // Android: 关闭通知通道声音,改用闹钟流播放(绕过静音/震动模式)
    // App 被杀时走 OPPO 厂商通道,声音遵循系统铃声模式
    const androidDetails = AndroidNotificationDetails(
      'notification_project_alarm',
      'Notification Project',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
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
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );

    // Android 用闹钟流播放声音,静音/震动模式下也能响
    if (defaultTargetPlatform == TargetPlatform.android) {
      await playAlarmSound();
    }
  }

  /// 通过闹钟音频流(ALARM stream)播放声音,绕过静音/震动模式
  static Future<void> playAlarmSound() async {
    try {
      await _alarmPlayer.play(
        AssetSource('sounds/ai_done.wav'),
        ctx: _alarmAudioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // 播放失败时忽略,不影响通知展示
    }
  }
}
