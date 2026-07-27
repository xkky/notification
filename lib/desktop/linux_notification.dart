import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

Future<void> showLinuxNotification(String title, String body,
    {String sound = 'default'}) async {
  debugPrint('Linux Desktop Notification: $title - $body');
  await NotificationService.showLocalNotification(
    title: title,
    body: body,
    sound: sound,
  );
}
