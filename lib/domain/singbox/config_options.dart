import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/singbox/box_log.dart';
import 'package:hiddify/domain/singbox/rules.dart';

part 'config_options.freezed.dart';
part 'config_options.g.dart';

@freezed
class ConfigOptions with _$ConfigOptions {
  const ConfigOptions._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory ConfigOptions({
    @Default(false) bool executeConfigAsIs,
    @Default(LogLevel.warn) LogLevel logLevel,
    @Default(false) bool resolveDestination,
    @Default(IPv6Mode.disable) IPv6Mode ipv6Mode,
    @Default("tcp://8.8.8.8") String remoteDnsAddress,
    @Default(DomainStrategy.auto) DomainStrategy remoteDnsDomainStrategy,
    @Default("local") String directDnsAddress,
    @Default(DomainStrategy.auto) DomainStrategy directDnsDomainStrategy,
    @Default(2334) int mixedPort,
    @Default(6450) int localDnsPort,
    @Default(TunImplementation.mixed) TunImplementation tunImplementation,
    @Default(9000) int mtu,
    @Default(true) bool strictRoute,
    @Default("http://cp.cloudflare.com/") String connectionTestUrl,
    @IntervalConverter()
    @Default(Duration(minutes: 10))
    Duration urlTestInterval,
    @Default(true) bool enableClashApi,
    @Default(6756) int clashApiPort,
    @Default(false) bool enableTun,
    @Default(false) bool setSystemProxy,
    @Default(false) bool bypassLan,
    @Default(false) bool enableFakeDns,
    @Default(true) bool independentDnsCache,
    List<Rule>? rules,
  }) = _ConfigOptions;

  static ConfigOptions initial = const ConfigOptions();

  String format() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory ConfigOptions.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionsFromJson(json);
}

@JsonEnum(valueField: 'key')
enum IPv6Mode {
  disable("ipv4_only"),
  enable("prefer_ipv4"),
  prefer("prefer_ipv6"),
  only("ipv6_only");

  const IPv6Mode(this.key);

  final String key;

  String present(TranslationsEn t) => switch (this) {
        disable => t.settings.config.ipv6Modes.disable,
        enable => t.settings.config.ipv6Modes.enable,
        prefer => t.settings.config.ipv6Modes.prefer,
        only => t.settings.config.ipv6Modes.only,
      };
}

@JsonEnum(valueField: 'key')
enum DomainStrategy {
  auto(""),
  preferIpv6("prefer_ipv6"),
  preferIpv4("prefer_ipv4"),
  ipv4Only("ipv4_only"),
  ipv6Only("ipv6_only");

  const DomainStrategy(this.key);

  final String key;

  String get displayName => switch (this) {
        auto => "auto",
        _ => key,
      };
}

enum TunImplementation {
  mixed,
  system,
  gVisor;
}

class IntervalConverter implements JsonConverter<Duration, String> {
  const IntervalConverter();

  @override
  Duration fromJson(String json) =>
      Duration(minutes: int.parse(json.replaceAll("m", "")));

  @override
  String toJson(Duration object) => "${object.inMinutes}m";
}
