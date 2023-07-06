import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_info.freezed.dart';
part 'subscription_info.g.dart';

// TODO: test and improve
@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const SubscriptionInfo._();

  const factory SubscriptionInfo({
    int? upload,
    int? download,
    int? total,
    @JsonKey(fromJson: _dateTimeFromSecondsSinceEpoch) DateTime? expire,
  }) = _SubscriptionInfo;

  bool get isValid =>
      total != null && download != null && upload != null && expire != null;

  bool get isExpired => expire! <= DateTime.now();

  int get consumption => upload! + download!;

  double get ratio => consumption / total!;

  Duration get remaining => expire!.difference(DateTime.now());

  factory SubscriptionInfo.fromResponseHeader(String header) {
    final values = header.split(';');
    final map = {
      for (final v in values)
        v.split('=').first: int.tryParse(v.split('=').second)
    };
    return SubscriptionInfo.fromJson(map);
  }

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);
}

DateTime? _dateTimeFromSecondsSinceEpoch(dynamic expire) =>
    DateTime.fromMillisecondsSinceEpoch((expire as int) * 1000);
