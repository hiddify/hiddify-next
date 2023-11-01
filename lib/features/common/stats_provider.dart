import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_provider.g.dart';

@riverpod
class Stats extends _$Stats with AppLogger {
  @override
  Stream<CoreStatus> build() async* {
    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (serviceRunning) {
      yield* ref
          .watch(coreFacadeProvider)
          .watchCoreStatus()
          .map((event) => event.getOrElse((_) => CoreStatus.empty()));
    } else {
      yield* Stream.value(CoreStatus.empty());
    }
  }
}
