import 'dart:io';

import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/services/connectivity/connectivity_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:proxy_manager/proxy_manager.dart';
import 'package:rxdart/rxdart.dart';

// TODO: rewrite
class DesktopConnectivityService
    with InfraLogger
    implements ConnectivityService {
  // TODO: possibly replace
  final _proxyManager = ProxyManager();

  final _connectionStatus = BehaviorSubject.seeded(false);

  @override
  Future<void> init() async {}

  @override
  Stream<bool> watchConnectionStatus() {
    return _connectionStatus;
  }

  @override
  Future<bool> grantVpnPermission() async => true;

  @override
  Future<void> connect({
    required int httpPort,
    required int socksPort,
    bool systemProxy = true,
  }) async {
    loggy.debug('connecting');
    await Future.wait([
      _proxyManager.setAsSystemProxy(
        ProxyTypes.http,
        Constants.localHost,
        httpPort,
      ),
      _proxyManager.setAsSystemProxy(
        ProxyTypes.https,
        Constants.localHost,
        httpPort,
      )
    ]);
    if (!Platform.isWindows) {
      await _proxyManager.setAsSystemProxy(
        ProxyTypes.socks,
        Constants.localHost,
        socksPort,
      );
    }
    _connectionStatus.value = true;
  }

  @override
  Future<void> disconnect() async {
    loggy.debug("disconnecting");
    await _proxyManager.cleanSystemProxy();
    _connectionStatus.value = false;
  }
}
