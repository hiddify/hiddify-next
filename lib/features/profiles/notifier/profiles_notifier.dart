import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profiles_notifier.g.dart';

@riverpod
class ProfilesSortNotifier extends _$ProfilesSortNotifier with AppLogger {
  @override
  ({ProfilesSort by, SortMode mode}) build() {
    return (by: ProfilesSort.lastUpdate, mode: SortMode.descending);
  }

  void changeSort(ProfilesSort sortBy) =>
      state = (by: sortBy, mode: state.mode);

  void toggleMode() => state = (
        by: state.by,
        mode: state.mode == SortMode.ascending
            ? SortMode.descending
            : SortMode.ascending
      );
}

@riverpod
class ProfilesNotifier extends _$ProfilesNotifier with AppLogger {
  @override
  Stream<List<Profile>> build() {
    final sort = ref.watch(profilesSortNotifierProvider);
    return _profilesRepo
        .watchAll(sort: sort.by, mode: sort.mode)
        .map((event) => event.getOrElse((l) => throw l));
  }

  ProfilesRepository get _profilesRepo => ref.read(profilesRepositoryProvider);

  Future<Unit> selectActiveProfile(String id) async {
    loggy.debug('changing active profile to: [$id]');
    return _profilesRepo.setAsActive(id).getOrElse((err) {
      loggy.warning('failed to set [$id] as active profile', err);
      throw err;
    }).run();
  }

  Future<Unit> addProfile(String rawInput) async {
    final activeProfile = await ref.read(activeProfileProvider.future);
    final markAsActive =
        activeProfile == null || ref.read(markNewProfileActiveProvider);
    final TaskEither<ProfileFailure, Unit> task;
    if (LinkParser.parse(rawInput) case (final link)?) {
      loggy.debug("adding profile, url: [${link.url}]");
      task = ref
          .read(profilesRepositoryProvider)
          .addByUrl(link.url, markAsActive: markAsActive);
    } else if (LinkParser.protocol(rawInput) case (final parsed)?) {
      loggy.debug("adding profile, content");
      task = ref.read(profilesRepositoryProvider).addByContent(
            parsed.content,
            name: parsed.name,
            markAsActive: markAsActive,
          );
    } else {
      loggy.debug("invalid content");
      throw const ProfileInvalidUrlFailure();
    }
    return task.match(
      (err) {
        loggy.warning("failed to add profile", err);
        throw err;
      },
      (_) {
        loggy.info(
          "successfully added profile, mark as active? [$markAsActive]",
        );
        return unit;
      },
    ).run();
  }

  Future<Unit?> updateProfile(RemoteProfile profile) async {
    loggy.debug("updating profile");
    return await ref.read(profilesRepositoryProvider).update(profile).match(
      (err) {
        loggy.warning("failed to update profile", err);
        throw err;
      },
      (_) async {
        loggy.info(
          'successfully updated profile, was active? [${profile.active}]',
        );

        await ref.read(activeProfileProvider.future).then((active) async {
          if (active != null && active.id == profile.id) {
            await ref
                .read(connectivityControllerProvider.notifier)
                .reconnect(profile.id);
          }
        });
        return unit;
      },
    ).run();
  }

  Future<void> deleteProfile(Profile profile) async {
    loggy.debug('deleting profile: ${profile.name}');
    await _profilesRepo.delete(profile.id).match(
      (err) {
        loggy.warning('failed to delete profile', err);
        throw err;
      },
      (_) {
        loggy.info(
          'successfully deleted profile, was active? [${profile.active}]',
        );
        return unit;
      },
    ).run();
  }

  Future<void> exportConfigToClipboard(Profile profile) async {
    await ref.read(coreFacadeProvider).generateConfig(profile.id).match(
      (err) {
        loggy.warning('error generating config', err);
        throw err;
      },
      (configJson) async {
        await Clipboard.setData(ClipboardData(text: configJson));
      },
    ).run();
  }
}
