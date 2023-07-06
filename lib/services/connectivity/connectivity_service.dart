import 'package:hiddify/services/connectivity/desktop_connectivity_service.dart';
import 'package:hiddify/services/connectivity/mobile_connectivity_service.dart';
import 'package:hiddify/services/notification/notification.dart';
import 'package:hiddify/utils/utils.dart';

abstract class ConnectivityService {
  factory ConnectivityService(NotificationService notification) {
    if (PlatformUtils.isDesktop) return DesktopConnectivityService();
    return MobileConnectivityService(notification);
  }

  Future<void> init();

  // TODO: use declarative states
  Stream<bool> watchConnectionStatus();

  // TODO: remove
  Future<bool> grantVpnPermission();

  Future<void> connect({
    required int httpPort,
    required int socksPort,
    bool systemProxy = true,
  });

  Future<void> disconnect();
}
