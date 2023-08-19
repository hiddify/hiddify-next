import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/core_facade.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_controller.g.dart';

@Riverpod(keepAlive: true)
class ConnectivityController extends _$ConnectivityController with AppLogger {
  @override
  Stream<ConnectionStatus> build() {
    ref.listen(
      activeProfileProvider.select((value) => value.asData?.value),
      (previous, next) async {
        if (previous == null) return;
        final shouldReconnect = previous != next;
        if (shouldReconnect) {
          loggy.debug("active profile modified, reconnect");
          await reconnect();
        }
      },
    );
    return _connectivity.watchConnectionStatus();
  }

  CoreFacade get _connectivity => ref.watch(coreFacadeProvider);

  Future<void> toggleConnection() async {
    if (state case AsyncError()) {
      await _connect();
    } else if (state case AsyncData(:final value)) {
      switch (value) {
        case Disconnected():
          await _connect();
        case Connected():
          await _disconnect();
        default:
          loggy.warning("switching status, debounce");
      }
    }
  }

  Future<void> reconnect() async {
    if (state case AsyncData(:final value)) {
      if (value case Connected()) {
        loggy.debug("reconnecting");
        await _disconnect();
        await _connect();
      }
    }
  }

  Future<void> abortConnection() async {
    if (state case AsyncData(:final value)) {
      switch (value) {
        case Connected() || Connecting():
          loggy.debug("aborting connection");
          await _disconnect();
        default:
      }
    }
  }

  Future<void> _connect() async {
    final activeProfile = await ref.read(activeProfileProvider.future);
    await _connectivity
        .changeConfig(activeProfile!.id)
        .andThen(_connectivity.connect)
        .mapLeft((l) {
      loggy.warning("error connecting: $l");
      state = AsyncError(l, StackTrace.current);
    }).run();
  }

  Future<void> _disconnect() async {
    await _connectivity.disconnect().mapLeft((l) {
      loggy.warning("error disconnecting: $l");
      state = AsyncError(l, StackTrace.current);
    }).run();
  }
}

@Riverpod(keepAlive: true)
Future<bool> serviceRunning(ServiceRunningRef ref) => ref
    .watch(
      connectivityControllerProvider.selectAsync((data) => data.isConnected),
    )
    .onError((error, stackTrace) => false);
