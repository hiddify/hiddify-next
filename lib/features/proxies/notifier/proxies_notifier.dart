import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/features/common/clash/clash_mode.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/features/proxies/model/model.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'proxies_notifier.g.dart';

@Riverpod(keepAlive: true)
class ProxiesNotifier extends _$ProxiesNotifier with AppLogger {
  @override
  Future<List<GroupWithProxies>> build() async {
    loggy.debug('building');
    if (!await ref.watch(serviceRunningProvider.future)) {
      throw const CoreServiceNotRunning();
    }
    final mode = await ref.watch(clashModeProvider.future);
    return _clash.getProxies().flatMap(
      (proxies) {
        return TaskEither(
          () async => right(await GroupWithProxies.fromProxies(proxies, mode)),
        );
      },
    ).getOrElse((l) {
      loggy.warning("failed receiving proxies: $l");
      throw l;
    }).run();
  }

  ClashFacade get _clash => ref.read(coreFacadeProvider);

  Future<void> changeProxy(String selectorName, String proxyName) async {
    loggy.debug("changing proxy, selector: $selectorName - proxy: $proxyName ");
    await _clash
        .changeProxy(selectorName, proxyName)
        .getOrElse((l) => throw l)
        .run();
    ref.invalidateSelf();
  }
}
