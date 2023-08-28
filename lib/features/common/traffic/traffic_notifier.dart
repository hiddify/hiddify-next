import 'package:dartx/dartx.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'traffic_notifier.g.dart';

// TODO: improve
@riverpod
class TrafficNotifier extends _$TrafficNotifier with AppLogger {
  int get _steps => 100;

  @override
  Stream<List<Traffic>> build() async* {
    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (serviceRunning) {
      // TODO: temporary!
      yield* ref.watch(coreFacadeProvider).watchCoreStatus().map((event) {
        return event.map(
          (a) => ClashTraffic(upload: a.uplink, download: a.downlink),
        );
      }).map(
        (event) => _mapToState(
          event.getOrElse((_) => const ClashTraffic(upload: 0, download: 0)),
        ),
      );
    } else {
      yield* Stream.periodic(const Duration(seconds: 1)).asyncMap(
        (_) async {
          return const ClashTraffic(upload: 0, download: 0);
        },
      ).map(_mapToState);
    }
  }

  List<Traffic> _mapToState(ClashTraffic event) {
    final previous = state.valueOrNull ??
        List.generate(
          _steps,
          (index) => const Traffic(upload: 0, download: 0),
        );
    while (previous.length < _steps) {
      loggy.debug("previous short, adding");
      previous.insert(0, const Traffic(upload: 0, download: 0));
    }
    return [
      ...previous.takeLast(_steps - 1),
      Traffic(upload: event.upload, download: event.download),
    ];
  }
}
