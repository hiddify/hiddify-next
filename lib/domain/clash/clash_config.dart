import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash_enums.dart';

part 'clash_config.freezed.dart';
part 'clash_config.g.dart';

@freezed
class ClashConfig with _$ClashConfig {
  const ClashConfig._();

  @JsonSerializable(includeIfNull: false, fieldRename: FieldRename.kebab)
  const factory ClashConfig({
    @JsonKey(name: 'port') int? httpPort,
    int? socksPort,
    int? redirPort,
    int? tproxyPort,
    int? mixedPort,
    List<String>? authentication,
    bool? allowLan,
    String? bindAddress,
    TunnelMode? mode,
    LogLevel? logLevel,
    bool? ipv6,
  }) = _ClashConfig;

  ClashConfig patch(ClashConfigPatch patch) {
    return copyWith(
      httpPort: (patch.httpPort ?? optionOf(httpPort)).toNullable(),
      socksPort: (patch.socksPort ?? optionOf(socksPort)).toNullable(),
      redirPort: (patch.redirPort ?? optionOf(redirPort)).toNullable(),
      tproxyPort: (patch.tproxyPort ?? optionOf(tproxyPort)).toNullable(),
      mixedPort: (patch.mixedPort ?? optionOf(mixedPort)).toNullable(),
      authentication:
          (patch.authentication ?? optionOf(authentication)).toNullable(),
      allowLan: (patch.allowLan ?? optionOf(allowLan)).toNullable(),
      bindAddress: (patch.bindAddress ?? optionOf(bindAddress)).toNullable(),
      mode: (patch.mode ?? optionOf(mode)).toNullable(),
      logLevel: (patch.logLevel ?? optionOf(logLevel)).toNullable(),
      ipv6: (patch.ipv6 ?? optionOf(ipv6)).toNullable(),
    );
  }

  factory ClashConfig.fromJson(Map<String, dynamic> json) =>
      _$ClashConfigFromJson(json);
}

@freezed
class ClashConfigPatch with _$ClashConfigPatch {
  const ClashConfigPatch._();

  @JsonSerializable(includeIfNull: false)
  const factory ClashConfigPatch({
    Option<int>? httpPort,
    Option<int>? socksPort,
    Option<int>? redirPort,
    Option<int>? tproxyPort,
    Option<int>? mixedPort,
    Option<List<String>>? authentication,
    Option<bool>? allowLan,
    Option<String>? bindAddress,
    Option<TunnelMode>? mode,
    Option<LogLevel>? logLevel,
    Option<bool>? ipv6,
  }) = _ClashConfigPatch;
}
