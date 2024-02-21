import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/core/utils/json_converters.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';

part 'singbox_config_option.freezed.dart';
part 'singbox_config_option.g.dart';

@freezed
class SingboxConfigOption with _$SingboxConfigOption {
  const SingboxConfigOption._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory SingboxConfigOption({
    required bool executeConfigAsIs,
    required LogLevel logLevel,
    required bool resolveDestination,
    required IPv6Mode ipv6Mode,
    required String remoteDnsAddress,
    required DomainStrategy remoteDnsDomainStrategy,
    required String directDnsAddress,
    required DomainStrategy directDnsDomainStrategy,
    required int mixedPort,
    required int localDnsPort,
    required TunImplementation tunImplementation,
    required int mtu,
    required bool strictRoute,
    required String connectionTestUrl,
    @IntervalInSecondsConverter() required Duration urlTestInterval,
    required bool enableClashApi,
    required int clashApiPort,
    required bool enableTun,
    required bool enableTunService,
    required bool setSystemProxy,
    required bool bypassLan,
    required bool allowConnectionFromLan,
    required bool enableFakeDns,
    required bool enableDnsRouting,
    required bool independentDnsCache,
    required bool enableTlsFragment,
    @OptionalRangeJsonConverter() required OptionalRange tlsFragmentSize,
    @OptionalRangeJsonConverter() required OptionalRange tlsFragmentSleep,
    required bool enableTlsMixedSniCase,
    required bool enableTlsPadding,
    @OptionalRangeJsonConverter() required OptionalRange tlsPaddingSize,
    required bool enableMux,
    required bool muxPadding,
    required int muxMaxStreams,
    required MuxProtocol muxProtocol,
    required String geoipPath,
    required String geositePath,
    required List<SingboxRule> rules,
    required SingboxWarpOption warp,
  }) = _SingboxConfigOption;

  String format() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory SingboxConfigOption.fromJson(Map<String, dynamic> json) =>
      _$SingboxConfigOptionFromJson(json);
}

@freezed
class SingboxWarpOption with _$SingboxWarpOption {
  const factory SingboxWarpOption({
    required bool enable,
    required WarpDetourMode mode,
    required String wireguardConfig,
    required String licenseKey,
    required String accountId,
    required String accessToken,
    required String cleanIp,
    required int cleanPort,
    @OptionalRangeJsonConverter() required OptionalRange warpNoise,
    @OptionalRangeJsonConverter() required OptionalRange warpNoiseDelay,
  }) = _SingboxWarpOption;

  factory SingboxWarpOption.fromJson(Map<String, dynamic> json) =>
      _$SingboxWarpOptionFromJson(json);
}
