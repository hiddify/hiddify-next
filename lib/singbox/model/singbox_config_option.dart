import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/range.dart';
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
    @IntervalConverter() required Duration urlTestInterval,
    required bool enableClashApi,
    required int clashApiPort,
    required bool enableTun,
    required bool setSystemProxy,
    required bool bypassLan,
    required bool allowConnectionFromLan,
    required bool enableFakeDns,
    required bool enableDnsRouting,
    required bool independentDnsCache,
    required bool enableTlsFragment,
    @RangeWithOptionalCeilJsonConverter()
    required RangeWithOptionalCeil tlsFragmentSize,
    @RangeWithOptionalCeilJsonConverter()
    required RangeWithOptionalCeil tlsFragmentSleep,
    required bool enableTlsMixedSniCase,
    required bool enableTlsPadding,
    @RangeWithOptionalCeilJsonConverter()
    required RangeWithOptionalCeil tlsPaddingSize,
    required bool enableMux,
    required bool muxPadding,
    required int muxMaxStreams,
    required MuxProtocol muxProtocol,
    required bool enableWarp,
    required WarpDetourMode warpDetourMode,
    required String warpLicenseKey,
    required String warpCleanIp,
    required int warpPort,
    @RangeWithOptionalCeilJsonConverter()
    required RangeWithOptionalCeil warpNoise,
    required String geoipPath,
    required String geositePath,
    required List<SingboxRule> rules,
  }) = _SingboxConfigOption;

  String format() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory SingboxConfigOption.fromJson(Map<String, dynamic> json) =>
      _$SingboxConfigOptionFromJson(json);
}

class IntervalConverter implements JsonConverter<Duration, String> {
  const IntervalConverter();

  @override
  Duration fromJson(String json) =>
      Duration(minutes: int.parse(json.replaceAll("m", "")));

  @override
  String toJson(Duration object) => "${object.inMinutes}m";
}
