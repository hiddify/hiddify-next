import 'package:drift/drift.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/domain/profiles/profiles.dart';

extension ProfileMapper on Profile {
  ProfileEntriesCompanion toCompanion() {
    return switch (this) {
      RemoteProfile(:final url, :final options, :final subInfo) =>
        ProfileEntriesCompanion.insert(
          id: id,
          type: ProfileType.remote,
          active: active,
          name: name,
          url: Value(url),
          lastUpdate: lastUpdate,
          updateInterval: Value(options?.updateInterval),
          upload: Value(subInfo?.upload),
          download: Value(subInfo?.download),
          total: Value(subInfo?.total),
          expire: Value(subInfo?.expire),
          webPageUrl: Value(subInfo?.webPageUrl),
          supportUrl: Value(subInfo?.supportUrl),
        ),
      LocalProfile() => ProfileEntriesCompanion.insert(
          id: id,
          type: ProfileType.local,
          active: active,
          name: name,
          lastUpdate: lastUpdate,
        ),
    };
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
        webPageUrl: e.webPageUrl,
        supportUrl: e.supportUrl,
      );
    }

    return switch (e.type) {
      ProfileType.remote => RemoteProfile(
          id: e.id,
          active: e.active,
          name: e.name,
          url: e.url!,
          lastUpdate: e.lastUpdate,
          options: options,
          subInfo: subInfo,
        ),
      ProfileType.local => LocalProfile(
          id: e.id,
          active: e.active,
          name: e.name,
          lastUpdate: e.lastUpdate,
        ),
    };
  }
}
