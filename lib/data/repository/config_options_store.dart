import 'package:hiddify/domain/singbox/config_options.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_options_store.g.dart';

final _default = ConfigOptions.initial;

final executeConfigAsIs =
    PrefNotifier.provider("execute-config-as-is", _default.executeConfigAsIs);

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
final mtuStore = PrefNotifier.provider("mtu", _default.mtu);
final connectionTestUrlStore =
    PrefNotifier.provider("connection-test-url", _default.connectionTestUrl);
final urlTestIntervalStore =
    PrefNotifier.provider("url-test-interval", _default.urlTestInterval);
final enableClashApiStore =
    PrefNotifier.provider("enable-clash-api", _default.enableClashApi);
final clashApiPortStore =
    PrefNotifier.provider("clash-api-port", _default.clashApiPort);
final enableTunStore = PrefNotifier.provider("enable-tun", _default.enableTun);
final setSystemProxyStore =
    PrefNotifier.provider("set-system-proxy", _default.setSystemProxy);

@riverpod
ConfigOptions configOptions(ConfigOptionsRef ref) => ConfigOptions(
      executeConfigAsIs: ref.watch(executeConfigAsIs),
      logLevel: ref.watch(logLevelStore),
      resolveDestination: ref.watch(resolveDestinationStore),
      ipv6Mode: ref.watch(ipv6ModeStore),
      remoteDnsAddress: ref.watch(remoteDnsAddressStore),
      remoteDnsDomainStrategy: ref.watch(remoteDnsDomainStrategyStore),
      directDnsAddress: ref.watch(directDnsAddressStore),
      directDnsDomainStrategy: ref.watch(directDnsDomainStrategyStore),
      mixedPort: ref.watch(mixedPortStore),
      localDnsPort: ref.watch(localDnsPortStore),
      mtu: ref.watch(mtuStore),
      connectionTestUrl: ref.watch(connectionTestUrlStore),
      urlTestInterval: ref.watch(urlTestIntervalStore),
      enableClashApi: ref.watch(enableClashApiStore),
      clashApiPort: ref.watch(clashApiPortStore),
      enableTun: ref.watch(enableTunStore),
      setSystemProxy: ref.watch(setSystemProxyStore),
    );
