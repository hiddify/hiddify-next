import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/singbox/model/singbox_proxy_type.dart';

part 'singbox_outbound.freezed.dart';
part 'singbox_outbound.g.dart';

@freezed
class SingboxOutboundGroup with _$SingboxOutboundGroup {
  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory SingboxOutboundGroup({
    required String tag,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    required String selected,
    @Default([]) List<SingboxOutboundGroupItem> items,
  }) = _SingboxOutboundGroup;

  factory SingboxOutboundGroup.fromJson(Map<String, dynamic> json) =>
      _$SingboxOutboundGroupFromJson(json);
}

@freezed
class SingboxOutboundGroupItem with _$SingboxOutboundGroupItem {
  const SingboxOutboundGroupItem._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory SingboxOutboundGroupItem({
    required String tag,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    required int urlTestDelay,
  }) = _SingboxOutboundGroupItem;

  factory SingboxOutboundGroupItem.fromJson(Map<String, dynamic> json) =>
      _$SingboxOutboundGroupItemFromJson(json);
}

ProxyType _typeFromJson(dynamic type) =>
    ProxyType.values
        .firstOrNullWhere((e) => e.key == (type as String?)?.toLowerCase()) ??
    ProxyType.unknown;
