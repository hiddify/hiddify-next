import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash_enums.dart';

part 'clash_log.freezed.dart';
part 'clash_log.g.dart';

@freezed
class ClashLog with _$ClashLog {
  const ClashLog._();

  const factory ClashLog({
    @JsonKey(name: 'type') required LogLevel level,
    @JsonKey(name: 'payload') required String message,
    @JsonKey(defaultValue: DateTime.now) required DateTime time,
  }) = _ClashLog;

  String get timeStamp =>
      "${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}";

  factory ClashLog.fromJson(Map<String, dynamic> json) =>
      _$ClashLogFromJson(json);
}
