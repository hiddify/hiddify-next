import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/failures.dart';

part 'app_failure.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure, Failure {
  const AppFailure._();

  @With<UnexpectedFailure>()
  const factory AppFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = UpdateUnexpectedFailure;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      UpdateUnexpectedFailure() => (type: t.failure.unexpected, message: null),
    };
  }
}
