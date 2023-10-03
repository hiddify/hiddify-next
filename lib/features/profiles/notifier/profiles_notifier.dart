import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
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
    if (LinkParser.parse(rawInput) case (final link)?) {
      loggy.debug("adding profile, url: [${link.url}]");
      return ref
          .read(profilesRepositoryProvider)
          .addByUrl(link.url, markAsActive: markAsActive)
          .getOrElse((err) {
        loggy.warning("failed to add profile", err);
        throw err;
      }).run();
    } else if (LinkParser.protocol(rawInput) case (final parsed)?) {
      loggy.debug("adding profile, content");
      return ref
          .read(profilesRepositoryProvider)
          .addByContent(
            parsed.content,
            name: parsed.name,
            markAsActive: markAsActive,
          )
          .getOrElse((err) {
        loggy.warning("failed to add profile", err);
        throw err;
      }).run();
    } else {
      loggy.debug("invalid content");
      throw const ProfileInvalidUrlFailure();
    }
  }

  Future<Unit?> updateProfile(RemoteProfile profile) async {
    loggy.debug("updating profile");
    return ref
        .read(profilesRepositoryProvider)
        .update(profile)
        .getOrElse((l) => throw l)
        .run();
  }

  Future<void> deleteProfile(Profile profile) async {
    loggy.debug('deleting profile: ${profile.name}');
    await _profilesRepo.delete(profile.id).mapLeft(
      (err) {
        loggy.warning('failed to delete profile', err);
        throw err;
      },
    ).run();
  }
}
