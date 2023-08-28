import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_status.freezed.dart';
part 'core_status.g.dart';

@freezed
class CoreStatus with _$CoreStatus {
  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory CoreStatus({
    required int connectionsIn,
    required int connectionsOut,
    required int uplink,
    required int downlink,
    required int uplinkTotal,
    required int downlinkTotal,
  }) = _CoreStatus;

  factory CoreStatus.fromJson(Map<String, dynamic> json) =>
      _$CoreStatusFromJson(json);
}
