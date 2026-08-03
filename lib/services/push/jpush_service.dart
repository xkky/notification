import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

import '../push_service.dart';

/// 极光推送实现(国内 Android/iOS,自动集成厂商通道)
///
/// 使用前需配置:
/// - pubspec.yaml 中 `jpush_android` 节点配置各厂商参数
/// - Android: `build.gradle` 中 manifestPlaceholders 配置 JPUSH_APPKEY
/// - iOS: 在极光后台配置 APNs 证书
class JPushService implements PushService {
  JPushService({
    required this.appKey,
    this.channel = 'developer-default',
    this.production = false,
    this.debug = true,
  });

  /// 极光后台 AppKey
  final String appKey;

  /// 渠道名
  final String channel;

  /// iOS 是否生产环境
  final bool production;

  /// 是否开启 debug 日志
  final bool debug;

  final JPushFlutterInterface _jpush = JPush.newJPush();
  void Function(PushMessage message)? _callback;

  @override
  Future<void> initialize() async {
    _jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        _handleMessage(message, isNotification: true);
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        _handleMessage(message, isNotification: true, isOpened: true);
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        _handleMessage(message, isNotification: false);
      },
      onReceiveNotificationAuthorization:
          (Map<String, dynamic> message) async {
        // 通知授权状态变化
      },
    );

    _jpush.setup(
      appKey: appKey,
      channel: channel,
      production: production,
      debug: debug,
    );

    // iOS 申请通知权限
    _jpush.applyPushAuthority(
      const NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true,
      ),
    );
  }

  void _handleMessage(
    Map<String, dynamic> message, {
    required bool isNotification,
    bool isOpened = false,
  }) {
    String title;
    String body;

    if (isNotification) {
      title = (message['title'] as String?) ??
          message['alert'] as String? ??
          '收到推送';
      body = (message['alert'] as String?) ??
          message['content'] as String? ??
          message.toString();
    } else {
      title = '收到自定义消息';
      body = message['message'] as String? ?? message.toString();
    }

    _callback?.call(PushMessage(
      title: title,
      body: body,
      data: message,
    ));
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _jpush.getRegistrationID();
    } catch (_) {
      return null;
    }
  }

  @override
  void onMessageReceived(void Function(PushMessage message) callback) {
    _callback = callback;
  }

  @override
  void dispose() {
    _callback = null;
  }
}
