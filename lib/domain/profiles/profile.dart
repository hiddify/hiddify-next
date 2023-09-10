import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:loggy/loggy.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

final _loggy = Loggy('Profile');

@freezed
class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required bool active,
    required String name,
    required String url,
    required DateTime lastUpdate,
    ProfileOptions? options,
    SubscriptionInfo? subInfo,
    ProfileExtra? extra,
  }) = _Profile;

  // TODO add content disposition parsing
  factory Profile.fromResponse(
    String url,
    Map<String, List<String>> headers,
  ) {
    _loggy.debug("Profile Headers: $headers");
    final titleHeader = headers['profile-title']?.single;
    var title = '';
    if (titleHeader != null) {
      if (titleHeader.startsWith("base64:")) {
        // TODO handle errors
        title =
            utf8.decode(base64.decode(titleHeader.replaceFirst("base64:", "")));
      } else {
        title = titleHeader;
      }
    }
    if (title.isEmpty) {
      final part = url.split("/").lastOrNull;
      if (part != null) {
        final pattern = RegExp(r"\.(yaml|yml|txt)[\s\S]*");
        title = part.replaceFirst(pattern, "");
      }
    }

    final updateIntervalHeader = headers['profile-update-interval']?.single;
    ProfileOptions? options;
    if (updateIntervalHeader != null) {
      final updateInterval = Duration(hours: int.parse(updateIntervalHeader));
      options = ProfileOptions(updateInterval: updateInterval);
    }

    final subscriptionInfoHeader = headers['subscription-userinfo']?.single;
    SubscriptionInfo? subInfo;
    if (subscriptionInfoHeader != null) {
      subInfo = SubscriptionInfo.fromResponseHeader(subscriptionInfoHeader);
    }

    final webPageUrlHeader = headers['profile-web-page-url']?.single;
    final supportUrlHeader = headers['support-url']?.single;
    ProfileExtra? extra;
    if (webPageUrlHeader != null || supportUrlHeader != null) {
      extra = ProfileExtra(
        webPageUrl: webPageUrlHeader,
        supportUrl: supportUrlHeader,
      );
    }

    return Profile(
      id: const Uuid().v4(),
      active: false,
      name: title.isBlank ? "Remote Profile" : title,
      url: url,
      lastUpdate: DateTime.now(),
      options: options,
      subInfo: subInfo,
      extra: extra,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

@freezed
class ProfileOptions with _$ProfileOptions {
  const factory ProfileOptions({
    required Duration updateInterval,
  }) = _ProfileOptions;

  factory ProfileOptions.fromJson(Map<String, dynamic> json) =>
      _$ProfileOptionsFromJson(json);
}

@freezed
class ProfileExtra with _$ProfileExtra {
  const factory ProfileExtra({
    String? webPageUrl,
    String? supportUrl,
  }) = _ProfileExtra;

  factory ProfileExtra.fromJson(Map<String, dynamic> json) =>
      _$ProfileExtraFromJson(json);
}

@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const SubscriptionInfo._();

  const factory SubscriptionInfo({
    required int upload,
    required int download,
    required int total,
    @JsonKey(fromJson: _dateTimeFromSecondsSinceEpoch) required DateTime expire,
  }) = _SubscriptionInfo;

  bool get isExpired => expire <= DateTime.now();

  int get consumption => upload + download;

  double get ratio => (consumption / total).clamp(0, 1);

  Duration get remaining => expire.difference(DateTime.now());

  factory SubscriptionInfo.fromResponseHeader(String header) {
    final values = header.split(';');
    final map = {
      for (final v in values)
        v.split('=').first.trim(): int.tryParse(v.split('=').second.trim()),
    };
    _loggy.debug("Subscription Info: $map");
    return SubscriptionInfo.fromJson(map);
  }

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);
}

DateTime _dateTimeFromSecondsSinceEpoch(dynamic expire) =>
    DateTime.fromMillisecondsSinceEpoch((expire as int) * 1000);
