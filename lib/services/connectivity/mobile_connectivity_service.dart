import 'package:flutter/services.dart';
import 'package:hiddify/domain/connectivity/connectivity_failure.dart';
import 'package:hiddify/services/connectivity/connectivity_service.dart';
import 'package:hiddify/services/notification/notification.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

// TODO: rewrite
class MobileConnectivityService
    with InfraLogger
    implements ConnectivityService {
  MobileConnectivityService(this._notificationService);

  final NotificationService _notificationService;

  static const _methodChannel = MethodChannel("Hiddify/VpnService");
  static const _eventChannel = EventChannel("Hiddify/VpnServiceEvents");

  final _connectionStatus = ValueConnectableStream(
    _eventChannel.receiveBroadcastStream().map((event) => event as bool),
  ).autoConnect();

  @override
  Future<void> init() async {
    loggy.debug("initializing");
    final initialStatus = _connectionStatus.first;
    await _methodChannel.invokeMethod("refresh_status");
    await initialStatus;
  }

  @override
  Stream<bool> watchConnectionStatus() {
    return _connectionStatus;
  }

  @override
  Future<bool> grantVpnPermission() async {
    loggy.debug('requesting vpn permission');
    final result = await _methodChannel.invokeMethod<bool>("grant_permission");
    if (!(result ?? false)) {
      loggy.info("vpn permission denied");
    }
    return result ?? false;
  }

  @override
  Future<void> connect({
    required int httpPort,
    required int socksPort,
    bool systemProxy = true,
  }) async {
    loggy.debug("connecting");
    await setPrefs(httpPort, socksPort, systemProxy);
    final hasNotificationPermission =
        await _notificationService.grantPermission();
    if (!hasNotificationPermission) {
      loggy.warning("notification permission denied");
      throw const ConnectivityFailure.unexpected();
    }
    await _methodChannel.invokeMethod<bool>("start");
  }

  @override
  Future<void> disconnect() async {
    loggy.debug("disconnecting");
    await _methodChannel.invokeMethod<bool>("stop");
  }

  Future<void> setPrefs(int port, int socksPort, bool systemProxy) async {
    loggy.debug(
      'setting connection prefs: httpPort: $port, socksPort: $socksPort, systemProxy: $systemProxy',
    );
    final result = await _methodChannel.invokeMethod<bool>(
      "set_prefs",
      {
        "port": port,
        "socks-port": socksPort,
        "system-proxy": systemProxy,
      },
    );
    if (!(result ?? false)) {
      loggy.error("failed to set connection prefs");
      // TODO: throw
    }
  }
}
