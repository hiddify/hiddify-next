import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/domain/failures.dart';

part 'core_service_failure.freezed.dart';

@freezed
sealed class CoreServiceFailure with _$CoreServiceFailure, Failure {
  const CoreServiceFailure._();

  const factory CoreServiceFailure.unexpected(
    Object error,
    StackTrace stackTrace,
  ) = UnexpectedCoreServiceFailure;

  const factory CoreServiceFailure.serviceNotRunning([String? message]) =
      CoreServiceNotRunning;

  const factory CoreServiceFailure.invalidConfig([
    String? message,
  ]) = InvalidConfig;

  const factory CoreServiceFailure.create([
    String? message,
  ]) = CoreServiceCreateFailure;

  const factory CoreServiceFailure.start([
    String? message,
  ]) = CoreServiceStartFailure;

  const factory CoreServiceFailure.other([
    String? message,
  ]) = CoreServiceOtherFailure;

  String? get msg => switch (this) {
        UnexpectedCoreServiceFailure() => null,
        CoreServiceNotRunning(:final message) => message,
        InvalidConfig(:final message) => message,
        CoreServiceCreateFailure(:final message) => message,
        CoreServiceStartFailure(:final message) => message,
        CoreServiceOtherFailure(:final message) => message,
      };

  @override
  String present(TranslationsEn t) {
    return switch (this) {
      UnexpectedCoreServiceFailure() => t.failure.singbox.unexpected,
      CoreServiceNotRunning(:final message) =>
        t.failure.singbox.serviceNotRunning +
            (message == null ? "" : ": $message"),
      InvalidConfig(:final message) =>
        t.failure.singbox.invalidConfig + (message == null ? "" : ": $message"),
      CoreServiceCreateFailure(:final message) =>
        t.failure.singbox.create + (message == null ? "" : ": $message"),
      CoreServiceStartFailure(:final message) =>
        t.failure.singbox.start + (message == null ? "" : ": $message"),
      CoreServiceOtherFailure(:final message) => message ?? "",
    };
  }
}
