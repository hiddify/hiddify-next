import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/domain/failures.dart';

part 'clash_failures.freezed.dart';

// TODO: rewrite
@freezed
sealed class ClashFailure with _$ClashFailure, Failure {
  const ClashFailure._();

  const factory ClashFailure.unexpected(
    Object error,
    StackTrace stackTrace,
  ) = ClashUnexpectedFailure;

  const factory ClashFailure.core([String? error]) = ClashCoreFailure;

  @override
  String present(TranslationsEn t) {
    return switch (this) {
      ClashUnexpectedFailure() => t.failure.clash.unexpected,
      ClashCoreFailure(:final error) =>
        t.failure.clash.core(reason: error ?? ""),
    };
  }
}
