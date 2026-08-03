class AppConfig {
  const AppConfig({
    required this.websocketUrl,
    required this.defaultTopic,
    required this.soundAsset,
    required this.jpushAppKey,
    required this.jpushChannel,
  });

  final String websocketUrl;
  final String defaultTopic;
  final String soundAsset;

  /// 极光推送 AppKey(国内 Android/iOS)
  final String jpushAppKey;

  /// 极光推送渠道名
  final String jpushChannel;

  static const AppConfig production = AppConfig(
    // websocketUrl: 'wss://example.com/ws',
    websocketUrl: 'wss://localhost:8443',
    defaultTopic: 'notification_project',
    soundAsset: 'assets/sounds/ai_done.wav',
    // 替换为你在极光后台申请的 AppKey
    jpushAppKey: '981da4b7b85d8189fa01a9ad',
    jpushChannel: 'd90c91542563776b316a12d2',
  );
}
