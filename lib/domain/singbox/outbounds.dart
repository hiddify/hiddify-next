import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/singbox/proxy_type.dart';

part 'outbounds.freezed.dart';
part 'outbounds.g.dart';

@freezed
class OutboundGroup with _$OutboundGroup {
  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory OutboundGroup({
    required String tag,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    required String selected,
    @Default([]) List<OutboundGroupItem> items,
  }) = _OutboundGroup;

  factory OutboundGroup.fromJson(Map<String, dynamic> json) =>
      _$OutboundGroupFromJson(json);
}

@freezed
class OutboundGroupItem with _$OutboundGroupItem {
  const OutboundGroupItem._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory OutboundGroupItem({
    required String tag,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    required int urlTestDelay,
    String? selectedTag,
  }) = _OutboundGroupItem;

  factory OutboundGroupItem.fromJson(Map<String, dynamic> json) =>
      _$OutboundGroupItemFromJson(json);
}

ProxyType _typeFromJson(dynamic type) =>
    ProxyType.values
        .firstOrNullWhere((e) => e.key == (type as String?)?.toLowerCase()) ??
    ProxyType.unknown;

String sanitizedTag(String tag) =>
    tag.replaceFirst(RegExp(r"\§[^]*"), "").trimRight();
