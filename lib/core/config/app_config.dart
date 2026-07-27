class AppConfig {
  const AppConfig({
    required this.websocketUrl,
    required this.defaultTopic,
    required this.soundAsset,
  });

  final String websocketUrl;
  final String defaultTopic;
  final String soundAsset;

  static const AppConfig production = AppConfig(
    websocketUrl: 'wss://example.com/ws',
    defaultTopic: 'notification_project',
    soundAsset: 'assets/sounds/ai_done.wav',
  );
}
