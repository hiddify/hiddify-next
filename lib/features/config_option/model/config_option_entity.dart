import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/core/utils/json_converters.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';
import 'package:hiddify/utils/platform_utils.dart';

part 'config_option_entity.mapper.dart';

@MappableClass(
  caseStyle: CaseStyle.paramCase,
  includeCustomMappers: [
    OptionalRangeJsonMapper(),
    IntervalInSecondsMapper(),
  ],
)
class ConfigOptionEntity with ConfigOptionEntityMappable {
  const ConfigOptionEntity({
    required this.serviceMode,
    this.logLevel = LogLevel.warn,
    this.resolveDestination = false,
    this.ipv6Mode = IPv6Mode.disable,
    this.remoteDnsAddress = "udp://1.1.1.1",
    this.remoteDnsDomainStrategy = DomainStrategy.auto,
    this.directDnsAddress = "1.1.1.1",
    this.directDnsDomainStrategy = DomainStrategy.auto,
    this.mixedPort = 2334,
    this.localDnsPort = 6450,
    this.tunImplementation = TunImplementation.mixed,
    this.mtu = 9000,
    this.strictRoute = true,
    this.connectionTestUrl = "http://cp.cloudflare.com/",
    this.urlTestInterval = const Duration(minutes: 10),
    this.enableClashApi = true,
    this.clashApiPort = 6756,
    this.bypassLan = false,
    this.allowConnectionFromLan = false,
    this.enableFakeDns = false,
    this.enableDnsRouting = true,
    this.independentDnsCache = true,
    this.enableTlsFragment = false,
    this.tlsFragmentSize = const OptionalRange(min: 1, max: 500),
    this.tlsFragmentSleep = const OptionalRange(min: 0, max: 500),
    this.enableTlsMixedSniCase = false,
    this.enableTlsPadding = false,
    this.tlsPaddingSize = const OptionalRange(min: 1, max: 1500),
    this.enableMux = false,
    this.muxPadding = false,
    this.muxMaxStreams = 8,
    this.muxProtocol = MuxProtocol.h2mux,
    this.enableWarp = false,
    this.warpDetourMode = WarpDetourMode.outbound,
    this.warpLicenseKey = "",
    this.warpCleanIp = "auto",
    this.warpPort = 0,
    this.warpNoise = const OptionalRange(),
  });

  final ServiceMode serviceMode;
  final LogLevel logLevel;
  final bool resolveDestination;
  @MappableField(key: "ipv6-mode")
  final IPv6Mode ipv6Mode;
  final String remoteDnsAddress;
  final DomainStrategy remoteDnsDomainStrategy;
  final String directDnsAddress;
  final DomainStrategy directDnsDomainStrategy;
  final int mixedPort;
  final int localDnsPort;
  final TunImplementation tunImplementation;
  final int mtu;
  final bool strictRoute;
  final String connectionTestUrl;
  final Duration urlTestInterval;
  final bool enableClashApi;
  final int clashApiPort;
  final bool bypassLan;
  final bool allowConnectionFromLan;
  final bool enableFakeDns;
  final bool enableDnsRouting;
  final bool independentDnsCache;
  final bool enableTlsFragment;
  final OptionalRange tlsFragmentSize;
  final OptionalRange tlsFragmentSleep;
  final bool enableTlsMixedSniCase;
  final bool enableTlsPadding;
  final OptionalRange tlsPaddingSize;
  final bool enableMux;
  final bool muxPadding;
  final int muxMaxStreams;
  final MuxProtocol muxProtocol;
  final bool enableWarp;
  final WarpDetourMode warpDetourMode;
  final String warpLicenseKey;
  final String warpCleanIp;
  final int warpPort;
  final OptionalRange warpNoise;

  factory ConfigOptionEntity.initial() =>
      ConfigOptionEntity(serviceMode: ServiceMode.defaultMode);

  bool hasExperimentalOptions() {
    if (PlatformUtils.isDesktop && serviceMode == ServiceMode.tun) {
      return true;
    }
    if (enableTlsFragment ||
        enableTlsMixedSniCase ||
        enableTlsPadding ||
        enableMux ||
        enableWarp) {
      return true;
    }

    return false;
  }

  String format() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }

  ConfigOptionEntity patch(ConfigOptionPatch patch) {
    return copyWith.$delta(patch.delta());
  }

  SingboxConfigOption toSingbox({
    required String geoipPath,
    required String geositePath,
    required List<SingboxRule> rules,
  }) {
    return SingboxConfigOption(
      executeConfigAsIs: false,
      logLevel: logLevel,
      resolveDestination: resolveDestination,
      ipv6Mode: ipv6Mode,
      remoteDnsAddress: remoteDnsAddress,
      remoteDnsDomainStrategy: remoteDnsDomainStrategy,
      directDnsAddress: directDnsAddress,
      directDnsDomainStrategy: directDnsDomainStrategy,
      mixedPort: mixedPort,
      localDnsPort: localDnsPort,
      tunImplementation: tunImplementation,
      mtu: mtu,
      strictRoute: strictRoute,
      connectionTestUrl: connectionTestUrl,
      urlTestInterval: urlTestInterval,
      enableClashApi: enableClashApi,
      clashApiPort: clashApiPort,
      enableTun: serviceMode == ServiceMode.tun,
      enableTunService: serviceMode == ServiceMode.tunService,
      setSystemProxy: serviceMode == ServiceMode.systemProxy,
      bypassLan: bypassLan,
      allowConnectionFromLan: allowConnectionFromLan,
      enableFakeDns: enableFakeDns,
      enableDnsRouting: enableDnsRouting,
      independentDnsCache: independentDnsCache,
      enableTlsFragment: enableTlsFragment,
      tlsFragmentSize: tlsFragmentSize,
      tlsFragmentSleep: tlsFragmentSleep,
      enableTlsMixedSniCase: enableTlsMixedSniCase,
      enableTlsPadding: enableTlsPadding,
      tlsPaddingSize: tlsPaddingSize,
      enableMux: enableMux,
      muxPadding: muxPadding,
      muxMaxStreams: muxMaxStreams,
      muxProtocol: muxProtocol,
      enableWarp: enableWarp,
      warpDetourMode: warpDetourMode,
      warpLicenseKey: warpLicenseKey,
      warpCleanIp: warpCleanIp,
      warpPort: warpPort,
      warpNoise: warpNoise,
      geoipPath: geoipPath,
      geositePath: geositePath,
      rules: rules,
    );
  }
}

@MappableClass(
  caseStyle: CaseStyle.paramCase,
  ignoreNull: true,
  includeCustomMappers: [
    OptionalRangeJsonMapper(),
    IntervalInSecondsMapper(),
  ],
)
class ConfigOptionPatch with ConfigOptionPatchMappable {
  const ConfigOptionPatch({
    this.serviceMode,
    this.logLevel,
    this.resolveDestination,
    this.ipv6Mode,
    this.remoteDnsAddress,
    this.remoteDnsDomainStrategy,
    this.directDnsAddress,
    this.directDnsDomainStrategy,
    this.mixedPort,
    this.localDnsPort,
    this.tunImplementation,
    this.mtu,
    this.strictRoute,
    this.connectionTestUrl,
    this.urlTestInterval,
    this.enableClashApi,
    this.clashApiPort,
    this.bypassLan,
    this.allowConnectionFromLan,
    this.enableFakeDns,
    this.enableDnsRouting,
    this.independentDnsCache,
    this.enableTlsFragment,
    this.tlsFragmentSize,
    this.tlsFragmentSleep,
    this.enableTlsMixedSniCase,
    this.enableTlsPadding,
    this.tlsPaddingSize,
    this.enableMux,
    this.muxPadding,
    this.muxMaxStreams,
    this.muxProtocol,
    this.enableWarp,
    this.warpDetourMode,
    this.warpLicenseKey,
    this.warpCleanIp,
    this.warpPort,
    this.warpNoise,
  });

  final ServiceMode? serviceMode;
  final LogLevel? logLevel;
  final bool? resolveDestination;
  @MappableField(key: "ipv6-mode")
  final IPv6Mode? ipv6Mode;
  final String? remoteDnsAddress;
  final DomainStrategy? remoteDnsDomainStrategy;
  final String? directDnsAddress;
  final DomainStrategy? directDnsDomainStrategy;
  final int? mixedPort;
  final int? localDnsPort;
  final TunImplementation? tunImplementation;
  final int? mtu;
  final bool? strictRoute;
  final String? connectionTestUrl;
  final Duration? urlTestInterval;
  final bool? enableClashApi;
  final int? clashApiPort;
  final bool? bypassLan;
  final bool? allowConnectionFromLan;
  final bool? enableFakeDns;
  final bool? enableDnsRouting;
  final bool? independentDnsCache;
  final bool? enableTlsFragment;
  final OptionalRange? tlsFragmentSize;
  final OptionalRange? tlsFragmentSleep;
  final bool? enableTlsMixedSniCase;
  final bool? enableTlsPadding;
  final OptionalRange? tlsPaddingSize;
  final bool? enableMux;
  final bool? muxPadding;
  final int? muxMaxStreams;
  final MuxProtocol? muxProtocol;
  final bool? enableWarp;
  final WarpDetourMode? warpDetourMode;
  final String? warpLicenseKey;
  final String? warpCleanIp;
  final int? warpPort;
  final OptionalRange? warpNoise;

  Map<String, dynamic> delta() =>
      toMap()..removeWhere((key, value) => value == null);
}
