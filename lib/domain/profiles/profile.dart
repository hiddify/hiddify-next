import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:uuid/uuid.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

final _loggy = Loggy('Profile');

enum ProfileType { remote, local }

@freezed
sealed class Profile with _$Profile {
  const Profile._();

  const factory Profile.remote({
    required String id,
    required bool active,
    required String name,
    required String url,
    required DateTime lastUpdate,
    ProfileOptions? options,
    SubscriptionInfo? subInfo,
  }) = RemoteProfile;

  const factory Profile.local({
    required String id,
    required bool active,
    required String name,
    required DateTime lastUpdate,
  }) = LocalProfile;

  // ignore: prefer_constructors_over_static_methods
  static RemoteProfile fromResponse(
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
      final contentDisposition = headers['content-disposition']?.single;
      if (contentDisposition != null) {
        final RegExp regExp = RegExp('filename="([^"]*)"');
        final match = regExp.firstMatch(contentDisposition);
        if (match != null && match.groupCount >= 1) {
          title = match.group(1) ?? '';
        }
      }
    }
    if (title.isEmpty) {
      final part = url.split("#").lastOrNull;
      if (part != null) {
        title = part;
      }
    }
    if (title.isEmpty) {
      final part = url.split("/").lastOrNull;
      if (part != null) {
        final pattern = RegExp(r"\.(json|yaml|yml|txt)[\s\S]*");
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
    if (subInfo != null) {
      subInfo = subInfo.copyWith(
        webPageUrl: isUrl(webPageUrlHeader ?? "") ? webPageUrlHeader : null,
        supportUrl: isUrl(supportUrlHeader ?? "") ? supportUrlHeader : null,
      );
    }

    return RemoteProfile(
      id: const Uuid().v4(),
      active: false,
      name: title.isBlank ? "Remote Profile" : title,
      url: url,
      lastUpdate: DateTime.now(),
      options: options,
      subInfo: subInfo,
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
class SubscriptionInfo with _$SubscriptionInfo {
  const SubscriptionInfo._();

  const factory SubscriptionInfo({
    required int upload,
    required int download,
    @JsonKey(fromJson: _fromJsonTotal, defaultValue: 9223372036854775807)
    required int total,
    @JsonKey(fromJson: _dateTimeFromSecondsSinceEpoch) required DateTime expire,
    String? webPageUrl,
    String? supportUrl,
  }) = _SubscriptionInfo;

  bool get isExpired => expire <= DateTime.now();

  int get consumption => upload + download;

  double get ratio => (consumption / total).clamp(0, 1);

  Duration get remaining => expire.difference(DateTime.now());

  factory SubscriptionInfo.fromResponseHeader(String header) {
    final values = header.split(';');
    final map = {
      for (final v in values)
        v.split('=').first.trim():
            num.tryParse(v.split('=').second.trim())?.toInt(),
    };
    _loggy.debug("Subscription Info: $map");
    return SubscriptionInfo.fromJson(map);
  }

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);
}

int _fromJsonTotal(dynamic total) {
  final totalInt = total as int? ?? -1;
  return totalInt > 0 ? totalInt : 9223372036854775807;
}

DateTime _dateTimeFromSecondsSinceEpoch(dynamic expire) {
  final expireInt = expire as int? ?? -1;
  return DateTime.fromMillisecondsSinceEpoch(
    (expireInt > 0 ? expireInt : 92233720368) * 1000,
  );
}
