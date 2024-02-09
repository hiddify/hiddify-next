import 'package:dio/dio.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/proxy/data/proxy_data_providers.dart';
import 'package:hiddify/features/proxy/model/ip_info_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_failure.dart';
import 'package:hiddify/utils/riverpod_utils.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_proxy_notifier.g.dart';

typedef ActiveProxyInfo = ({
  ProxyItemEntity proxy,
  AsyncValue<IpInfo?> ipInfo,
});

@riverpod
Stream<ProxyItemEntity?> activeProxyGroup(ActiveProxyGroupRef ref) async* {
  final serviceRunning = await ref.watch(serviceRunningProvider.future);
  if (!serviceRunning) {
    throw const ServiceNotRunning();
  }
  yield* ref
      .watch(proxyRepositoryProvider)
      .watchActiveProxies()
      .map((event) => event.getOrElse((l) => throw l))
      .map((event) => event.firstOrNull?.items.firstOrNull);
}

@riverpod
Future<IpInfo?> proxyIpInfo(ProxyIpInfoRef ref) async {
  final serviceRunning = await ref.watch(serviceRunningProvider.future);
  if (!serviceRunning) {
    return null;
  }
  final cancelToken = CancelToken();
  ref.onDispose(() {
    Loggy("ProxyIpInfo").debug("canceling");
    cancelToken.cancel();
  });
  return ref
      .watch(proxyRepositoryProvider)
      .getCurrentIpInfo(cancelToken)
      .getOrElse(
    (err) {
      Loggy("ProxyIpInfo").error("error getting proxy ip info", err);
      throw err;
    },
  ).run();
}

@riverpod
class ActiveProxyNotifier extends _$ActiveProxyNotifier with AppLogger {
  @override
  AsyncValue<ActiveProxyInfo> build() {
    ref.disposeDelay(const Duration(seconds: 20));
    final ipInfo = ref.watch(proxyIpInfoProvider);
    final activeProxies = ref.watch(activeProxyGroupProvider);
    return switch (activeProxies) {
      AsyncData(value: final activeGroup?) =>
        AsyncData((proxy: activeGroup, ipInfo: ipInfo)),
      AsyncError(:final error, :final stackTrace) =>
        AsyncError(error, stackTrace),
      _ => const AsyncLoading(),
    };
  }

  Future<void> refreshIpInfo() async {
    if (state case AsyncData(:final value) when !value.ipInfo.isLoading) {
      ref.invalidate(proxyIpInfoProvider);
    }
  }
}
