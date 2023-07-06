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
      upload: Value(subInfo?.upload),
      download: Value(subInfo?.download),
      total: Value(subInfo?.total),
      expire: Value(subInfo?.expire),
      updateInterval: Value(updateInterval),
    );
  }

  static Profile fromEntry(ProfileEntry entry) {
    return Profile(
      id: entry.id,
      active: entry.active,
      name: entry.name,
      url: entry.url,
      lastUpdate: entry.lastUpdate,
      updateInterval: entry.updateInterval,
      subInfo: SubscriptionInfo(
        upload: entry.upload,
        download: entry.download,
        total: entry.total,
        expire: entry.expire,
      ),
    );
  }
}
