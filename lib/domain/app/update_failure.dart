import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/domain/failures.dart';

part 'update_failure.freezed.dart';

@freezed
sealed class UpdateFailure with _$UpdateFailure, Failure {
  const UpdateFailure._();

  const factory UpdateFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = UpdateUnexpectedFailure;

  @override
  String present(TranslationsEn t) {
    return switch (this) {
      UpdateUnexpectedFailure() => t.failure.unexpected,
    };
  }
}
