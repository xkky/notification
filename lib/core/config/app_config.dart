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
    // websocketUrl: 'wss://example.com/ws',
    websocketUrl: 'wss://localhost:8443',
    defaultTopic: 'notification_project',
    soundAsset: 'assets/sounds/ai_done.wav',
  );
}
