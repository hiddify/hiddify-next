import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
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
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      ProfileUnexpectedFailure(:final error) => (
          type: t.failure.profiles.unexpected,
          message: t.mayPrintError(error),
        ),
      ProfileNotFoundFailure() => (
          type: t.failure.profiles.notFound,
          message: null
        ),
      ProfileInvalidConfigFailure(:final message) => (
          type: t.failure.profiles.invalidConfig,
          message: message
        ),
    };
  }
}
