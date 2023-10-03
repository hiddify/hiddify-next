import 'package:dartx/dartx.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/profile_detail/notifier/profile_detail_state.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'profile_detail_notifier.g.dart';

@riverpod
class ProfileDetailNotifier extends _$ProfileDetailNotifier with AppLogger {
  @override
  Future<ProfileDetailState> build(
    String id, {
    String? url,
    String? profileName,
  }) async {
    if (id == 'new') {
      return ProfileDetailState(
        profile: RemoteProfile(
          id: const Uuid().v4(),
          active: true,
          name: profileName ?? "",
          url: url ?? "",
          lastUpdate: DateTime.now(),
        ),
      );
    }
    final failureOrProfile = await _profilesRepo.get(id).run();
    return failureOrProfile.match(
      (err) {
        loggy.warning('failed to load profile', err);
        throw err;
      },
      (profile) {
        if (profile == null) {
          loggy.warning('profile with id: [$id] does not exist');
          throw const ProfileNotFoundFailure();
        }
        _originalProfile = profile;
        return ProfileDetailState(profile: profile, isEditing: true);
      },
    );
  }

  ProfilesRepository get _profilesRepo => ref.read(profilesRepositoryProvider);
  Profile? _originalProfile;

  void setField({String? name, String? url, Option<int>? updateInterval}) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(
        value.copyWith(
          profile: value.profile.map(
            remote: (rp) => rp.copyWith(
              name: name ?? rp.name,
              url: url ?? rp.url,
              options: updateInterval == null
                  ? rp.options
                  : updateInterval.fold(
                      () => null,
                      (t) => ProfileOptions(
                        updateInterval: Duration(hours: t),
                      ),
                    ),
            ),
            local: (lp) => lp.copyWith(name: name ?? lp.name),
          ),
        ),
      );
    }
  }

  Future<void> save() async {
    if (state case AsyncData(:final value)) {
      if (value.save.isInProgress) return;
      final profile = value.profile;
      Either<ProfileFailure, Unit>? failureOrSuccess;
      state = AsyncData(value.copyWith(save: const MutationInProgress()));
      switch (profile) {
        case RemoteProfile():
          loggy.debug(
            'saving profile, url: [${profile.url}], name: [${profile.name}]',
          );
          if (profile.name.isBlank || profile.url.isBlank) {
            loggy.debug('profile save: invalid arguments');
          } else if (value.isEditing) {
            if (_originalProfile case RemoteProfile(:final url)
                when url == profile.url) {
              loggy.debug('editing profile');
              failureOrSuccess = await _profilesRepo.edit(profile).run();
            } else {
              loggy.debug('updating profile');
              failureOrSuccess = await _profilesRepo.update(profile).run();
            }
          } else {
            loggy.debug('adding profile, url: [${profile.url}]');
            failureOrSuccess = await _profilesRepo.add(profile).run();
          }
        case LocalProfile() when value.isEditing:
          loggy.debug('editing profile');
          failureOrSuccess = await _profilesRepo.edit(profile).run();
        default:
          loggy.warning("local profile can't be added manually");
      }
      state = AsyncData(
        value.copyWith(
          save: failureOrSuccess?.fold(
                (l) => MutationFailure(l),
                (_) => const MutationSuccess(),
              ) ??
              value.save,
          showErrorMessages: true,
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    if (state case AsyncData(:final value)) {
      loggy.debug('updating profile');
      if (value.profile case LocalProfile()) {
        loggy.warning("local profile can't be updated");
        return;
      }
      if (value.update.isInProgress || !value.isEditing) return;
      final profile = value.profile;
      loggy.debug('updating profile');
      state = AsyncData(value.copyWith(update: const MutationInProgress()));
      final failureOrUpdatedProfile = await _profilesRepo
          .update(profile as RemoteProfile)
          .flatMap((_) => _profilesRepo.get(id))
          .run();
      state = AsyncData(
        value.copyWith(
          update: failureOrUpdatedProfile.match(
            (l) => MutationFailure(l),
            (_) => const MutationSuccess(),
          ),
          profile: failureOrUpdatedProfile.match(
            (_) => profile,
            (updatedProfile) => updatedProfile ?? profile,
          ),
        ),
      );
    }
  }

  Future<void> delete() async {
    if (state case AsyncData(:final value)) {
      if (value.delete.isInProgress) return;
      final profile = value.profile;
      loggy.debug('deleting profile');
      state = AsyncData(value.copyWith(delete: const MutationInProgress()));
      final result = await _profilesRepo.delete(profile.id).run();
      state = AsyncData(
        value.copyWith(
          delete: result.match(
            (l) => MutationFailure(l),
            (_) => const MutationSuccess(),
          ),
        ),
      );
    }
  }
}
