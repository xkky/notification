import 'package:flutter/foundation.dart';

enum NotificationPlatform {
  windows,
  macOS,
  linux,
  android,
  iOS,
  web,
  unknown,
}

class AppPlatformInfo {
  const AppPlatformInfo._({required this.platform});

  final NotificationPlatform platform;

  static AppPlatformInfo detect() {
    if (kIsWeb) {
      return const AppPlatformInfo._(platform: NotificationPlatform.web);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return const AppPlatformInfo._(platform: NotificationPlatform.windows);
      case TargetPlatform.macOS:
        return const AppPlatformInfo._(platform: NotificationPlatform.macOS);
      case TargetPlatform.linux:
        return const AppPlatformInfo._(platform: NotificationPlatform.linux);
      case TargetPlatform.android:
        return const AppPlatformInfo._(platform: NotificationPlatform.android);
      case TargetPlatform.iOS:
        return const AppPlatformInfo._(platform: NotificationPlatform.iOS);
      default:
        return const AppPlatformInfo._(platform: NotificationPlatform.unknown);
    }
  }

  bool get isDesktop =>
      platform == NotificationPlatform.windows ||
      platform == NotificationPlatform.macOS ||
      platform == NotificationPlatform.linux;

  bool get isMobile =>
      platform == NotificationPlatform.android ||
      platform == NotificationPlatform.iOS;
}
