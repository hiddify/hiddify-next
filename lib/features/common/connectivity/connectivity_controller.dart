import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/services/connectivity/connectivity.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_controller.g.dart';

// TODO: test and improve
// TODO: abort connection on clash error
@Riverpod(keepAlive: true)
class ConnectivityController extends _$ConnectivityController with AppLogger {
  @override
  ConnectionStatus build() {
    state = const Disconnected();
    final connection = _connectivity
        .watchConnectionStatus()
        .map(ConnectionStatus.fromBool)
        .listen((event) => state = event);

    // currently changes wont take effect while connected
    ref.listen(
      prefsControllerProvider.select((value) => value.network),
      (_, next) => _networkPrefs = next,
      fireImmediately: true,
    );
    ref.listen(
      prefsControllerProvider
          .select((value) => (value.clash.httpPort!, value.clash.socksPort!)),
      (_, next) => _ports = (http: next.$1, socks: next.$2),
      fireImmediately: true,
    );

    ref.onDispose(connection.cancel);
    return state;
  }

  ConnectivityService get _connectivity =>
      ref.watch(connectivityServiceProvider);

  late ({int http, int socks}) _ports;
  // ignore: unused_field
  late NetworkPrefs _networkPrefs;

  Future<void> toggleConnection() async {
    switch (state) {
      case Disconnected():
        if (!await _connectivity.grantVpnPermission()) {
          state = const Disconnected(ConnectivityFailure.unexpected());
          return;
        }
        await _connectivity.connect(
          httpPort: _ports.http,
          socksPort: _ports.socks,
        );
      case Connected():
        await _connectivity.disconnect();
      default:
    }
  }
}
