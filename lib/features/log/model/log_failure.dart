import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/locale_prefs.dart';
import 'package:hiddify/domain/failures.dart';

part 'log_failure.freezed.dart';

@freezed
sealed class LogFailure with _$LogFailure, Failure {
  const LogFailure._();

  const factory LogFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = LogUnexpectedFailure;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      LogUnexpectedFailure() => (
          type: "unexpected",
          message: null,
        ),
    };
  }
}
