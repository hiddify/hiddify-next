import 'package:drift/drift.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/domain/profiles/profiles.dart';

extension ProfileMapper on Profile {
  ProfileEntriesCompanion toCompanion() {
    return ProfileEntriesCompanion.insert(
      id: id,
      active: active,
      name: name,
      url: url,
      lastUpdate: lastUpdate,
      updateInterval: Value(options?.updateInterval),
      upload: Value(subInfo?.upload),
      download: Value(subInfo?.download),
      total: Value(subInfo?.total),
      expire: Value(subInfo?.expire),
      webPageUrl: Value(extra?.webPageUrl),
      supportUrl: Value(extra?.supportUrl),
    );
  }

  static Profile fromEntry(ProfileEntry e) {
    ProfileOptions? options;
    if (e.updateInterval != null) {
      options = ProfileOptions(updateInterval: e.updateInterval!);
    }

    SubscriptionInfo? subInfo;
    if (e.upload != null &&
        e.download != null &&
        e.total != null &&
        e.expire != null) {
      subInfo = SubscriptionInfo(
        upload: e.upload!,
        download: e.download!,
        total: e.total!,
        expire: e.expire!,
      );
    }

    ProfileExtra? extra;
    if (e.webPageUrl != null || e.supportUrl != null) {
      extra = ProfileExtra(
        webPageUrl: e.webPageUrl,
        supportUrl: e.supportUrl,
      );
    }

    return Profile(
      id: e.id,
      active: e.active,
      name: e.name,
      url: e.url,
      lastUpdate: e.lastUpdate,
      options: options,
      subInfo: subInfo,
      extra: extra,
    );
  }
}
