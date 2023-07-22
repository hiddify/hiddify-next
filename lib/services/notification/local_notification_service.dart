import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hiddify/services/notification/constants.dart';
import 'package:hiddify/services/notification/notification_service.dart';
import 'package:hiddify/utils/utils.dart';

// TODO: rewrite

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // TODO: handle action
}

// ignore: unreachable_from_main
class LocalNotificationService with InfraLogger implements NotificationService {
  LocalNotificationService(this.flutterLocalNotificationsPlugin);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? payload;

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
      linux: LinuxInitializationSettings(defaultActionName: "open"),
    );

    await _initDetails();
    await _initChannels();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _initDetails() async {
    if (kIsWeb || Platform.isLinux) return;
    final initialDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (initialDetails?.didNotificationLaunchApp ?? false) {
      payload = initialDetails!.notificationResponse?.payload;
      loggy.debug('app launched from notification, payload: $payload');
      // TODO: use payload
    }
  }

  Future<void> _initChannels() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mainChannel);
  }

  @override
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // TODO: complete
    loggy.debug('received notification response, $notificationResponse');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  }) async {
    loggy.debug('showing notification');
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details ??
          NotificationDetails(
            android: AndroidNotificationDetails(
              mainChannel.id,
              mainChannel.name,
            ),
          ),
      payload: payload,
    );
  }

  @override
  Future<void> removeNotification(int id) async {
    loggy.debug('removing notification');
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<bool> grantPermission() async {
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    return result ?? false;
  }
}
