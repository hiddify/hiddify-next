// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'package:flutter/foundation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_options_store.g.dart';

bool _debugConfigBuilder = false;
final _default = ConfigOptions.initial;

@Riverpod(keepAlive: true)
class ServiceModeStore extends _$ServiceModeStore {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
    "service-mode",
    ServiceMode.defaultMode,
    mapFrom: ServiceMode.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  ServiceMode build() => _pref.getValue();

  Future<void> update(ServiceMode value) {
    state = value;
    return _pref.update(value);
  }
}

final logLevelStore = PrefNotifier.provider(
  "log-level",
  _default.logLevel,
  mapFrom: LogLevel.values.byName,
  mapTo: (value) => value.name,
);
final resolveDestinationStore =
    PrefNotifier.provider("resolve-destination", _default.resolveDestination);
final ipv6ModeStore = PrefNotifier.provider(
  "ipv6-mode",
  _default.ipv6Mode,
  mapFrom: IPv6Mode.values.byName,
  mapTo: (value) => value.name,
);
final remoteDnsAddressStore =
    PrefNotifier.provider("remote-dns-address", _default.remoteDnsAddress);
final remoteDnsDomainStrategyStore = PrefNotifier.provider(
  "remote-domain-dns-strategy",
  _default.remoteDnsDomainStrategy,
  mapFrom: DomainStrategy.values.byName,
  mapTo: (value) => value.name,
);
final directDnsAddressStore =
    PrefNotifier.provider("direct-dns-address", _default.directDnsAddress);
final directDnsDomainStrategyStore = PrefNotifier.provider(
  "direct-domain-dns-strategy",
  _default.directDnsDomainStrategy,
  mapFrom: DomainStrategy.values.byName,
  mapTo: (value) => value.name,
);
final mixedPortStore = PrefNotifier.provider("mixed-port", _default.mixedPort);
final localDnsPortStore =
    PrefNotifier.provider("localDns-port", _default.localDnsPort);
final tunImplementationStore = PrefNotifier.provider(
  "tun-implementation",
  _default.tunImplementation,
  mapFrom: TunImplementation.values.byName,
  mapTo: (value) => value.name,
);
final mtuStore = PrefNotifier.provider("mtu", _default.mtu);
final connectionTestUrlStore =
    PrefNotifier.provider("connection-test-url", _default.connectionTestUrl);
final urlTestIntervalStore = PrefNotifier.provider<Duration, int>(
  "url-test-interval",
  _default.urlTestInterval,
  mapFrom: (value) => Duration(seconds: value),
  mapTo: (value) => value.inSeconds,
);
final enableClashApiStore =
    PrefNotifier.provider("enable-clash-api", _default.enableClashApi);
final clashApiPortStore =
    PrefNotifier.provider("clash-api-port", _default.clashApiPort);
// final enableTunStore = PrefNotifier.provider("enable-tun", _default.enableTun);
// final setSystemProxyStore =
//     PrefNotifier.provider("set-system-proxy", _default.setSystemProxy);
final strictRouteStore =
    PrefNotifier.provider("strict-route", _default.strictRoute);
final bypassLanStore = PrefNotifier.provider("bypass-lan", _default.bypassLan);
final enableFakeDnsStore =
    PrefNotifier.provider("enable-fake-dns", _default.enableFakeDns);

// HACK temporary
@riverpod
List<Rule> rules(RulesRef ref) => switch (ref.watch(regionNotifierProvider)) {
      Region.ir => [
          const Rule(
            id: "id",
            name: "name",
            enabled: true,
            domains: "domain:.ir",
            ip: "geoip:ir",
            outbound: RuleOutbound.bypass,
          ),
        ],
      Region.cn => [
          const Rule(
            id: "id",
            name: "name",
            enabled: true,
            domains: "domain:.cn,geosite:cn",
            ip: "geoip:cn",
            outbound: RuleOutbound.bypass,
          ),
        ],
      Region.ru => [
          const Rule(
            id: "id",
            name: "name",
            enabled: true,
            domains: "domain:.ru",
            ip: "geoip:ru",
            outbound: RuleOutbound.bypass,
          ),
        ],
      _ => [],
    };

@riverpod
ConfigOptions configPreferences(ConfigPreferencesRef ref) {
  return ConfigOptions(
    executeConfigAsIs: kDebugMode && _debugConfigBuilder,
    logLevel: ref.watch(logLevelStore),
    resolveDestination: ref.watch(resolveDestinationStore),
    ipv6Mode: ref.watch(ipv6ModeStore),
    remoteDnsAddress: ref.watch(remoteDnsAddressStore),
    remoteDnsDomainStrategy: ref.watch(remoteDnsDomainStrategyStore),
    directDnsAddress: ref.watch(directDnsAddressStore),
    directDnsDomainStrategy: ref.watch(directDnsDomainStrategyStore),
    mixedPort: ref.watch(mixedPortStore),
    localDnsPort: ref.watch(localDnsPortStore),
    tunImplementation: ref.watch(tunImplementationStore),
    mtu: ref.watch(mtuStore),
    strictRoute: ref.watch(strictRouteStore),
    connectionTestUrl: ref.watch(connectionTestUrlStore),
    urlTestInterval: ref.watch(urlTestIntervalStore),
    enableClashApi: ref.watch(enableClashApiStore),
    clashApiPort: ref.watch(clashApiPortStore),
    // enableTun: ref.watch(enableTunStore),
    // setSystemProxy: ref.watch(setSystemProxyStore),
    bypassLan: ref.watch(bypassLanStore),
    enableFakeDns: ref.watch(enableFakeDnsStore),
    rules: ref.watch(rulesProvider),
  );
}

@riverpod
ConfigOptions configOptions(ConfigOptionsRef ref) {
  final serviceMode = ref.watch(serviceModeStoreProvider);
  return ref.watch(configPreferencesProvider).copyWith(
        enableTun: serviceMode == ServiceMode.tun,
        setSystemProxy: serviceMode == ServiceMode.systemProxy,
      );
}
