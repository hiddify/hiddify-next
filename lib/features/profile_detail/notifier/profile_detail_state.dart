import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/utils/utils.dart';

part 'profile_detail_state.freezed.dart';

@freezed
class ProfileDetailState with _$ProfileDetailState {
  const ProfileDetailState._();

  const factory ProfileDetailState({
    required Profile profile,
    @Default(false) bool isEditing,
    @Default(false) bool showErrorMessages,
    @Default(MutationState.initial()) MutationState<ProfileFailure> save,
    @Default(MutationState.initial()) MutationState<ProfileFailure> update,
    @Default(MutationState.initial()) MutationState<ProfileFailure> delete,
  }) = _ProfileDetailState;

  bool get isBusy =>
      save.isInProgress || delete.isInProgress || update.isInProgress;
}
