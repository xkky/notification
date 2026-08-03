/// 推送消息抽象类,跨实现统一
class PushMessage {
  PushMessage({
    required this.title,
    required this.body,
    this.data = const {},
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
}

/// 推送服务抽象接口
///
/// 不同实现:
/// - [JPushService]:国内 Android/iOS,基于极光推送 + 厂商通道
///   (海外如需 FCM,可启用 pubspec.yaml 中的 firebase_* 依赖并实现 FcmPushService)
abstract class PushService {
  /// 初始化推送服务
  Future<void> initialize();

  /// 获取推送唯一标识(registration id / token)
  Future<String?> getToken();

  /// 注册消息回调
  void onMessageReceived(void Function(PushMessage message) callback);

  /// 释放资源
  void dispose();
}
