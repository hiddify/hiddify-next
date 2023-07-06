import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const mainChannel = AndroidNotificationChannel(
  "com.hiddify.hiddify",
  "Hiddify",
  importance: Importance.high,
  enableVibration: false,
  playSound: false,
);
