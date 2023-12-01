import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/failures.dart';

part 'mutation_state.freezed.dart';

// TODO: remove
@freezed
class MutationState<F extends Failure> with _$MutationState<F> {
  const MutationState._();

  const factory MutationState.initial() = MutationInitial<F>;
  const factory MutationState.inProgress() = MutationInProgress<F>;
  const factory MutationState.failure(Failure failure) = MutationFailure<F>;
  const factory MutationState.success() = MutationSuccess<F>;

  bool get isInProgress => this is MutationInProgress;
}
