import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

Future<void> showMacOSNotification(String title, String body,
    {String sound = 'default'}) async {
  debugPrint('macOS Notification Center: $title - $body');
  await NotificationService.showLocalNotification(
    title: title,
    body: body,
    sound: sound,
  );
}
