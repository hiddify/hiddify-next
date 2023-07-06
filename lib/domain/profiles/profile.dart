import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/profiles/profiles.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required bool active,
    required String name,
    required String url,
    SubscriptionInfo? subInfo,
    Duration? updateInterval,
    required DateTime lastUpdate,
  }) = _Profile;

  bool get hasSubscriptionInfo => subInfo?.isValid ?? false;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
