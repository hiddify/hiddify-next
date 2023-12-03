import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/utils/json_converters.dart';
import 'package:hiddify/features/config_option/model/config_option_patch.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';

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
    @Default("tcp://8.8.8.8") String remoteDnsAddress,
    @Default(DomainStrategy.auto) DomainStrategy remoteDnsDomainStrategy,
    @Default("8.8.8.8") String directDnsAddress,
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
    @Default(false) bool enableFakeDns,
    @Default(true) bool independentDnsCache,
  }) = _ConfigOptionEntity;

  static ConfigOptionEntity initial = ConfigOptionEntity(
    serviceMode: ServiceMode.defaultMode,
  );

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
      enableFakeDns: patch.enableFakeDns ?? enableFakeDns,
      independentDnsCache: patch.independentDnsCache ?? independentDnsCache,
    );
  }

  factory ConfigOptionEntity.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionEntityFromJson(json);
}
