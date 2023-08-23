import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hiddify/services/notification/local_notification_service.dart';
import 'package:hiddify/services/notification/stub_notification_service.dart';

abstract class NotificationService {
  factory NotificationService() {
    // HACK temporarily return stub for linux and mac as well
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return StubNotificationService();
    }
    return LocalNotificationService(FlutterLocalNotificationsPlugin());
  }

  Future<void> init();

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  );

  Future<bool> grantPermission();

  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  });

  Future<void> removeNotification(int id);
}
