import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/services/connectivity/connectivity_service.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class DesktopConnectivityService
    with InfraLogger
    implements ConnectivityService {
  DesktopConnectivityService(this._singboxService);

  final SingboxService _singboxService;

  late final BehaviorSubject<ConnectionStatus> _connectionStatus;

  @override
  Future<void> init() async {
    loggy.debug("initializing");
    _connectionStatus =
        BehaviorSubject.seeded(const ConnectionStatus.disconnected());
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() => _connectionStatus;

  @override
  Future<void> connect() async {
    loggy.debug('connecting');
    _connectionStatus.value = const ConnectionStatus.connecting();
    await _singboxService.start().getOrElse(
      (l) {
        _connectionStatus.value = const ConnectionStatus.disconnected();
        throw l;
      },
    ).run();
    _connectionStatus.value = const ConnectionStatus.connected();
  }

  @override
  Future<void> disconnect() async {
    loggy.debug("disconnecting");
    _connectionStatus.value = const ConnectionStatus.disconnecting();
    await _singboxService.stop().getOrElse((l) {
      _connectionStatus.value = const ConnectionStatus.connected();
      throw l;
    }).run();
    _connectionStatus.value = const ConnectionStatus.disconnected();
  }
}
