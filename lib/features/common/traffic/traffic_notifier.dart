import 'package:dartx/dartx.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'traffic_notifier.g.dart';

// TODO: improve
@riverpod
class TrafficNotifier extends _$TrafficNotifier with AppLogger {
  int get _steps => 100;

  @override
  Stream<List<Traffic>> build() {
    return Stream.periodic(const Duration(seconds: 1)).asyncMap(
      (_) async {
        return ref.read(clashFacadeProvider).getTraffic().match(
          (f) {
            loggy.warning('failed to watch clash traffic: $f');
            return const ClashTraffic(upload: 0, download: 0);
          },
          (traffic) => traffic,
        ).run();
      },
    ).map(
      (event) => switch (state) {
        AsyncData(:final value) => [
            ...value.takeLast(_steps - 1),
            Traffic(upload: event.upload, download: event.download),
          ],
        _ => List.generate(
            _steps,
            (index) => const Traffic(upload: 0, download: 0),
          )
      },
    );
  }
}
