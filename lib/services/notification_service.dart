import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const initializationSettings = InitializationSettings(
      linux: LinuxInitializationSettings(defaultActionName: 'OK'),
      macOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const notificationDetails = NotificationDetails(
      linux: LinuxNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'zenbreak_channel',
        'ZenBreak Reminders',
        channelDescription: 'Reminders for eye care, posture, water, and workout',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
