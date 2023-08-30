import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_status.freezed.dart';
part 'core_status.g.dart';

@freezed
class CoreStatus with _$CoreStatus {
  const CoreStatus._();

  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory CoreStatus({
    required int connectionsIn,
    required int connectionsOut,
    required int uplink,
    required int downlink,
    required int uplinkTotal,
    required int downlinkTotal,
  }) = _CoreStatus;

  factory CoreStatus.empty() => const CoreStatus(
        connectionsIn: 0,
        connectionsOut: 0,
        uplink: 0,
        downlink: 0,
        uplinkTotal: 0,
        downlinkTotal: 0,
      );

  factory CoreStatus.fromJson(Map<String, dynamic> json) =>
      _$CoreStatusFromJson(json);
}
