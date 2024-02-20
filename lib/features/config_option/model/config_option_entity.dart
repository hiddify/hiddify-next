import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/core/utils/json_converters.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';
import 'package:hiddify/utils/platform_utils.dart';

part 'config_option_entity.freezed.dart';
part 'config_option_entity.g.dart';

@freezed
class ConfigOptionEntity with _$ConfigOptionEntity {
  const ConfigOptionEntity._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory ConfigOptionEntity({
    required ServiceMode serviceMode,
    @Default(LogLevel.warn) LogLevel logLevel,
    @Default(false) bool resolveDestination,
    @Default(IPv6Mode.disable) IPv6Mode ipv6Mode,
    @Default("udp://1.1.1.1") String remoteDnsAddress,
    @Default(DomainStrategy.auto) DomainStrategy remoteDnsDomainStrategy,
    @Default("1.1.1.1") String directDnsAddress,
    @Default(DomainStrategy.auto) DomainStrategy directDnsDomainStrategy,
    @Default(2334) int mixedPort,
    @Default(6450) int localDnsPort,
    @Default(TunImplementation.mixed) TunImplementation tunImplementation,
    @Default(9000) int mtu,
    @Default(true) bool strictRoute,
    @Default("http://cp.cloudflare.com/") String connectionTestUrl,
    @IntervalInSecondsConverter()
    @Default(Duration(minutes: 10))
    Duration urlTestInterval,
    @Default(true) bool enableClashApi,
    @Default(6756) int clashApiPort,
    @Default(false) bool bypassLan,
    @Default(false) bool allowConnectionFromLan,
    @Default(false) bool enableFakeDns,
    @Default(true) bool enableDnsRouting,
    @Default(true) bool independentDnsCache,
    @Default(false) bool enableTlsFragment,
    @OptionalRangeJsonConverter()
    @Default(OptionalRange(min: 1, max: 500))
    OptionalRange tlsFragmentSize,
    @OptionalRangeJsonConverter()
    @Default(OptionalRange(min: 0, max: 500))
    OptionalRange tlsFragmentSleep,
    @Default(false) bool enableTlsMixedSniCase,
    @Default(false) bool enableTlsPadding,
    @OptionalRangeJsonConverter()
    @Default(OptionalRange(min: 1, max: 1500))
    OptionalRange tlsPaddingSize,
    @Default(false) bool enableMux,
    @Default(false) bool muxPadding,
    @Default(8) int muxMaxStreams,
    @Default(MuxProtocol.h2mux) MuxProtocol muxProtocol,
    @Default(false) bool enableWarp,
    @Default(WarpDetourMode.outbound) WarpDetourMode warpDetourMode,
    @Default("") String warpLicenseKey,
    @Default("") String warpAccountId,
    @Default("") String warpAccessToken,
    @Default("auto") String warpCleanIp,
    @Default(0) int warpPort,
    @OptionalRangeJsonConverter()
    @Default(OptionalRange())
    OptionalRange warpNoise,
    @Default("") String warpWireguardConfig,
  }) = _ConfigOptionEntity;

  factory ConfigOptionEntity.initial() => ConfigOptionEntity(
        serviceMode: ServiceMode.defaultMode,
      );

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
    return encoder.convert(toJson());
  }

  ConfigOptionEntity patch(ConfigOptionPatch patch) {
    return copyWith(
      serviceMode: patch.serviceMode ?? serviceMode,
      logLevel: patch.logLevel ?? logLevel,
      resolveDestination: patch.resolveDestination ?? resolveDestination,
      ipv6Mode: patch.ipv6Mode ?? ipv6Mode,
      remoteDnsAddress: patch.remoteDnsAddress ?? remoteDnsAddress,
      remoteDnsDomainStrategy:
          patch.remoteDnsDomainStrategy ?? remoteDnsDomainStrategy,
      directDnsAddress: patch.directDnsAddress ?? directDnsAddress,
      directDnsDomainStrategy:
          patch.directDnsDomainStrategy ?? directDnsDomainStrategy,
      mixedPort: patch.mixedPort ?? mixedPort,
      localDnsPort: patch.localDnsPort ?? localDnsPort,
      tunImplementation: patch.tunImplementation ?? tunImplementation,
      mtu: patch.mtu ?? mtu,
      strictRoute: patch.strictRoute ?? strictRoute,
      connectionTestUrl: patch.connectionTestUrl ?? connectionTestUrl,
      urlTestInterval: patch.urlTestInterval ?? urlTestInterval,
      enableClashApi: patch.enableClashApi ?? enableClashApi,
      clashApiPort: patch.clashApiPort ?? clashApiPort,
      bypassLan: patch.bypassLan ?? bypassLan,
      allowConnectionFromLan:
          patch.allowConnectionFromLan ?? allowConnectionFromLan,
      enableFakeDns: patch.enableFakeDns ?? enableFakeDns,
      enableDnsRouting: patch.enableDnsRouting ?? enableDnsRouting,
      independentDnsCache: patch.independentDnsCache ?? independentDnsCache,
      enableTlsFragment: patch.enableTlsFragment ?? enableTlsFragment,
      tlsFragmentSize: patch.tlsFragmentSize ?? tlsFragmentSize,
      tlsFragmentSleep: patch.tlsFragmentSleep ?? tlsFragmentSleep,
      enableTlsMixedSniCase:
          patch.enableTlsMixedSniCase ?? enableTlsMixedSniCase,
      enableTlsPadding: patch.enableTlsPadding ?? enableTlsPadding,
      tlsPaddingSize: patch.tlsPaddingSize ?? tlsPaddingSize,
      enableMux: patch.enableMux ?? enableMux,
      muxPadding: patch.muxPadding ?? muxPadding,
      muxMaxStreams: patch.muxMaxStreams ?? muxMaxStreams,
      muxProtocol: patch.muxProtocol ?? muxProtocol,
      enableWarp: patch.enableWarp ?? enableWarp,
      warpDetourMode: patch.warpDetourMode ?? warpDetourMode,
      warpLicenseKey: patch.warpLicenseKey ?? warpLicenseKey,
      warpAccountId: patch.warpAccountId ?? warpAccountId,
      warpAccessToken: patch.warpAccessToken ?? warpAccessToken,
      warpCleanIp: patch.warpCleanIp ?? warpCleanIp,
      warpPort: patch.warpPort ?? warpPort,
      warpNoise: patch.warpNoise ?? warpNoise,
      warpWireguardConfig: patch.warpWireguardConfig ?? warpWireguardConfig,
    );
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
      geoipPath: geoipPath,
      geositePath: geositePath,
      rules: rules,
      warp: SingboxWarpOption(
        enable: enableWarp,
        mode: warpDetourMode,
        licenseKey: warpLicenseKey,
        accountId: warpAccountId,
        accessToken: warpAccessToken,
        cleanIp: warpCleanIp,
        cleanPort: warpPort,
        warpNoise: warpNoise,
        wireguardConfig: warpWireguardConfig,
      ),
    );
  }

  factory ConfigOptionEntity.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionEntityFromJson(json);
}

@freezed
class ConfigOptionPatch with _$ConfigOptionPatch {
  const ConfigOptionPatch._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory ConfigOptionPatch({
    ServiceMode? serviceMode,
    LogLevel? logLevel,
    bool? resolveDestination,
    IPv6Mode? ipv6Mode,
    String? remoteDnsAddress,
    DomainStrategy? remoteDnsDomainStrategy,
    String? directDnsAddress,
    DomainStrategy? directDnsDomainStrategy,
    int? mixedPort,
    int? localDnsPort,
    TunImplementation? tunImplementation,
    int? mtu,
    bool? strictRoute,
    String? connectionTestUrl,
    @IntervalInSecondsConverter() Duration? urlTestInterval,
    bool? enableClashApi,
    int? clashApiPort,
    bool? bypassLan,
    bool? allowConnectionFromLan,
    bool? enableFakeDns,
    bool? enableDnsRouting,
    bool? independentDnsCache,
    bool? enableTlsFragment,
    @OptionalRangeJsonConverter() OptionalRange? tlsFragmentSize,
    @OptionalRangeJsonConverter() OptionalRange? tlsFragmentSleep,
    bool? enableTlsMixedSniCase,
    bool? enableTlsPadding,
    @OptionalRangeJsonConverter() OptionalRange? tlsPaddingSize,
    bool? enableMux,
    bool? muxPadding,
    int? muxMaxStreams,
    MuxProtocol? muxProtocol,
    bool? enableWarp,
    WarpDetourMode? warpDetourMode,
    String? warpLicenseKey,
    String? warpAccountId,
    String? warpAccessToken,
    String? warpCleanIp,
    int? warpPort,
    @OptionalRangeJsonConverter() OptionalRange? warpNoise,
    String? warpWireguardConfig,
  }) = _ConfigOptionPatch;

  factory ConfigOptionPatch.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionPatchFromJson(json);
}
