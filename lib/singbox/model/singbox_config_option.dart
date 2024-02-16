import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';

part 'singbox_config_option.mapper.dart';

@MappableClass(
  caseStyle: CaseStyle.paramCase,
  includeCustomMappers: [
    OptionalRangeJsonMapper(),
    IntervalMapper(),
  ],
)
class SingboxConfigOption with SingboxConfigOptionMappable {
  const SingboxConfigOption({
    required this.executeConfigAsIs,
    required this.logLevel,
    required this.resolveDestination,
    required this.ipv6Mode,
    required this.remoteDnsAddress,
    required this.remoteDnsDomainStrategy,
    required this.directDnsAddress,
    required this.directDnsDomainStrategy,
    required this.mixedPort,
    required this.localDnsPort,
    required this.tunImplementation,
    required this.mtu,
    required this.strictRoute,
    required this.connectionTestUrl,
    required this.urlTestInterval,
    required this.enableClashApi,
    required this.clashApiPort,
    required this.enableTun,
    required this.enableTunService,
    required this.setSystemProxy,
    required this.bypassLan,
    required this.allowConnectionFromLan,
    required this.enableFakeDns,
    required this.enableDnsRouting,
    required this.independentDnsCache,
    required this.enableTlsFragment,
    required this.tlsFragmentSize,
    required this.tlsFragmentSleep,
    required this.enableTlsMixedSniCase,
    required this.enableTlsPadding,
    required this.tlsPaddingSize,
    required this.enableMux,
    required this.muxPadding,
    required this.muxMaxStreams,
    required this.muxProtocol,
    required this.enableWarp,
    required this.warpDetourMode,
    required this.warpLicenseKey,
    required this.warpCleanIp,
    required this.warpPort,
    required this.warpNoise,
    required this.geoipPath,
    required this.geositePath,
    required this.rules,
  });

  final bool executeConfigAsIs;
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
  final bool enableTun;
  final bool enableTunService;
  final bool setSystemProxy;
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
  final String geoipPath;
  final String geositePath;
  final List<SingboxRule> rules;

  String format() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }
}

class IntervalMapper extends SimpleMapper<Duration> {
  const IntervalMapper();

  @override
  Duration decode(dynamic value) =>
      Duration(minutes: int.parse((value as String).replaceAll("m", "")));

  @override
  String encode(Duration self) => "${self.inMinutes}m";
}
