import '../services/notification_service.dart';

class LocalNotificationService {
  static Future<void> show({
    required String title,
    required String body,
    String sound = 'default',
  }) async {
    await NotificationService.showLocalNotification(
      title: title,
      body: body,
      sound: sound,
    );
  }
}
