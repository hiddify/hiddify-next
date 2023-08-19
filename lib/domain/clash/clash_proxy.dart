import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash_enums.dart';

part 'clash_proxy.freezed.dart';
part 'clash_proxy.g.dart';

// TODO: test and improve
@Freezed(fromJson: true)
sealed class ClashProxy with _$ClashProxy {
  const ClashProxy._();

  const factory ClashProxy.group({
    required String name,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    required List<String> all,
    required String now,
    @Default(false) bool udp,
    List<ClashHistory>? history,
    @JsonKey(includeFromJson: false, includeToJson: false) int? delay,
  }) = ClashProxyGroup;

  const factory ClashProxy.item({
    required String name,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    @Default(false) bool udp,
    List<ClashHistory>? history,
    @JsonKey(includeFromJson: false, includeToJson: false) int? delay,
  }) = ClashProxyItem;

  factory ClashProxy.fromJson(Map<String, dynamic> json) {
    final isGroup = json.containsKey('all') ||
        json.containsKey('now') ||
        ProxyType.groupValues.any(
          (e) => e.label == json.getOrElse('type', () => null),
        );
    if (isGroup) {
      return ClashProxyGroup.fromJson(json);
    } else {
      return ClashProxyItem.fromJson(json);
    }
  }
}

ProxyType _typeFromJson(dynamic type) =>
    ProxyType.values
        .firstOrNullWhere((e) => e.key == (type as String?)?.toLowerCase()) ??
    ProxyType.unknown;

@freezed
class ClashHistory with _$ClashHistory {
  const ClashHistory._();

  const factory ClashHistory({
    required String time,
    required int delay,
  }) = _ClashHistory;

  factory ClashHistory.fromJson(Map<String, dynamic> json) =>
      _$ClashHistoryFromJson(json);
}
