import 'package:dio/dio.dart';
import 'package:hiddify/core/utils/throttler.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/proxy/data/proxy_data_providers.dart';
import 'package:hiddify/features/proxy/model/ip_info_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_failure.dart';
import 'package:hiddify/utils/riverpod_utils.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_proxy_notifier.g.dart';

@riverpod
class IpInfoNotifier extends _$IpInfoNotifier with AppLogger {
  @override
  Future<IpInfo> build() async {
    ref.disposeDelay(const Duration(seconds: 20));
    final cancelToken = CancelToken();
    ref.onDispose(() {
      loggy.debug("disposing");
      cancelToken.cancel();
    });

    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (!serviceRunning) {
      throw const ServiceNotRunning();
    }

    return ref
        .watch(proxyRepositoryProvider)
        .getCurrentIpInfo(cancelToken)
        .getOrElse(
      (err) {
        loggy.error("error getting proxy ip info", err);
        throw err;
      },
    ).run();
  }

  Future<void> refresh() async {
    loggy.debug("refreshing");
    ref.invalidateSelf();
  }
}

@riverpod
class ActiveProxyNotifier extends _$ActiveProxyNotifier with AppLogger {
  @override
  Stream<ProxyItemEntity> build() async* {
    ref.disposeDelay(const Duration(seconds: 20));

    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (!serviceRunning) {
      throw const ServiceNotRunning();
    }

    yield* ref
        .watch(proxyRepositoryProvider)
        .watchActiveProxies()
        .map((event) => event.getOrElse((l) => throw l))
        .map((event) => event.firstOrNull!.items.first);
  }

  final _urlTestThrottler = Throttler(const Duration(seconds: 2));

  Future<void> urlTest(String groupTag) async {
    _urlTestThrottler(
      () async {
        loggy.debug("testing group: [$groupTag]");
        if (state case AsyncData()) {
          await ref
              .read(proxyRepositoryProvider)
              .urlTest(groupTag)
              .getOrElse((err) {
            loggy.error("error testing group", err);
            throw err;
          }).run();
        }
      },
    );
  }
}
