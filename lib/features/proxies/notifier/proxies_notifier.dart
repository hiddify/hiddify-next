import 'dart:async';

import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'proxies_notifier.g.dart';

@Riverpod(keepAlive: true)
class ProxiesNotifier extends _$ProxiesNotifier with AppLogger {
  @override
  Stream<List<OutboundGroup>> build() async* {
    loggy.debug("building");
    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (!serviceRunning) {
      throw const CoreServiceNotRunning();
    }
    yield* ref.watch(coreFacadeProvider).watchOutbounds().map(
          (event) => event.getOrElse(
            (f) {
              loggy.warning("error receiving proxies", f);
              throw f;
            },
          ),
        );
  }

  Future<void> changeProxy(String groupTag, String outboundTag) async {
    loggy.debug(
      "changing proxy, group: [$groupTag] - outbound: [$outboundTag]",
    );
    if (state case AsyncData(value: final outbounds)) {
      await ref
          .read(coreFacadeProvider)
          .selectOutbound(groupTag, outboundTag)
          .getOrElse((l) {
        loggy.warning("error selecting outbound", l);
        throw l;
      }).run();
      state = AsyncData(
        [
          ...outbounds.map(
            (e) => e.tag == groupTag ? e.copyWith(selected: outboundTag) : e,
          ),
        ],
      ).copyWithPrevious(state);
    }
  }

  Future<void> urlTest(String groupTag) async {
    loggy.debug("testing group: [$groupTag]");
    if (state case AsyncData()) {
      await ref.read(coreFacadeProvider).urlTest(groupTag).getOrElse((l) {
        loggy.warning("error testing group", l);
        throw l;
      }).run();
    }
  }
}
