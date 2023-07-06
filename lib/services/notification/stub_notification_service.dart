import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hiddify/services/notification/notification_service.dart';

class StubNotificationService implements NotificationService {
  @override
  Future<void> init() async {
    return;
  }

  @override
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {}

  @override
  Future<void> removeNotification(int id) async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  }) async {}

  @override
  Future<bool> grantPermission() async {
    return true;
  }
}
