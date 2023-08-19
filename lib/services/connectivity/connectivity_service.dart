import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/services/connectivity/desktop_connectivity_service.dart';
import 'package:hiddify/services/connectivity/mobile_connectivity_service.dart';
import 'package:hiddify/services/notification/notification.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';

abstract class ConnectivityService {
  factory ConnectivityService(
    SingboxService singboxService,
    NotificationService notificationService,
  ) {
    if (PlatformUtils.isDesktop) {
      return DesktopConnectivityService(singboxService);
    }
    return MobileConnectivityService(singboxService, notificationService);
  }

  Future<void> init();

  Stream<ConnectionStatus> watchConnectionStatus();

  Future<void> connect();

  Future<void> disconnect();
}
