import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/domain/failures.dart';

part 'profiles_failure.freezed.dart';

@freezed
sealed class ProfileFailure with _$ProfileFailure, Failure {
  const ProfileFailure._();

  const factory ProfileFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = ProfileUnexpectedFailure;

  const factory ProfileFailure.notFound() = ProfileNotFoundFailure;

  const factory ProfileFailure.invalidConfig([String? message]) =
      ProfileInvalidConfigFailure;

  @override
  String present(TranslationsEn t) {
    return switch (this) {
      ProfileUnexpectedFailure() => t.failure.profiles.unexpected,
      ProfileNotFoundFailure() => t.failure.profiles.notFound,
      ProfileInvalidConfigFailure(:final message) =>
        t.failure.profiles.invalidConfig +
            (message == null ? "" : ": $message"),
    };
  }
}
