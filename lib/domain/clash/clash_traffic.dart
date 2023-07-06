import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_traffic.freezed.dart';
part 'clash_traffic.g.dart';

@freezed
class ClashTraffic with _$ClashTraffic {
  const ClashTraffic._();

  const factory ClashTraffic({
    @JsonKey(name: 'up') required int upload,
    @JsonKey(name: 'down') required int download,
  }) = _ClashTraffic;

  factory ClashTraffic.fromJson(Map<String, dynamic> json) =>
      _$ClashTrafficFromJson(json);
}
