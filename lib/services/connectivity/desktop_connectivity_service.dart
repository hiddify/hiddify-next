import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/core_service_failure.dart';
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
    await _singboxService.start().match(
      (err) {
        _connectionStatus.value = ConnectionStatus.disconnected(
          CoreConnectionFailure(
            CoreServiceStartFailure(err),
          ),
        );
      },
      (_) => _connectionStatus.value = const ConnectionStatus.connected(),
    ).run();
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
