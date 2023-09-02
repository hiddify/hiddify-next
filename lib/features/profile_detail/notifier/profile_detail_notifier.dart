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
        profile: Profile(
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
      (l) {
        loggy.warning('failed to load profile, $l');
        throw l;
      },
      (profile) {
        if (profile == null) {
          loggy.warning('profile with id: [$id] does not exist');
          throw const ProfileNotFoundFailure();
        }
        return ProfileDetailState(profile: profile, isEditing: true);
      },
    );
  }

  ProfilesRepository get _profilesRepo => ref.read(profilesRepositoryProvider);

  void setField({String? name, String? url}) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(
        value.copyWith(
          profile: value.profile.copyWith(
            name: name ?? value.profile.name,
            url: url ?? value.profile.url,
          ),
        ),
      ).copyWithPrevious(state);
    }
  }

  Future<void> save() async {
    if (state case AsyncData(:final value)) {
      if (value.save.isInProgress) return;
      final profile = value.profile;
      loggy.debug(
        'saving profile, url: [${profile.url}], name: [${profile.name}]',
      );
      state = AsyncData(value.copyWith(save: const MutationInProgress()))
          .copyWithPrevious(state);
      Either<ProfileFailure, Unit>? failureOrSuccess;
      if (profile.name.isBlank || profile.url.isBlank) {
        loggy.debug('profile save: invalid arguments');
      } else if (value.isEditing) {
        loggy.debug('updating profile');
        failureOrSuccess = await _profilesRepo.update(profile).run();
      } else {
        loggy.debug('adding profile, url: [${profile.url}]');
        failureOrSuccess = await _profilesRepo.add(profile).run();
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
      ).copyWithPrevious(state);
    }
  }

  Future<void> delete() async {
    if (state case AsyncData(:final value)) {
      if (value.delete.isInProgress) return;
      final profile = value.profile;
      loggy.debug('deleting profile');
      state = AsyncData(
        value.copyWith(delete: const MutationState.inProgress()),
      ).copyWithPrevious(state);
      final result = await _profilesRepo.delete(profile.id).run();
      state = AsyncData(
        value.copyWith(
          delete: result.match(
            (l) => MutationFailure(l),
            (_) => const MutationSuccess(),
          ),
        ),
      ).copyWithPrevious(state);
    }
  }
}
