import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/failures.dart';

part 'connection_failure.freezed.dart';

@freezed
sealed class ConnectionFailure with _$ConnectionFailure, Failure {
  const ConnectionFailure._();

  @With<UnexpectedFailure>()
  const factory ConnectionFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = UnexpectedConnectionFailure;

  @With<ExpectedMeasuredFailure>()
  const factory ConnectionFailure.missingVpnPermission([String? message]) =
      MissingVpnPermission;

  @With<ExpectedMeasuredFailure>()
  const factory ConnectionFailure.missingNotificationPermission([
    String? message,
  ]) = MissingNotificationPermission;

  const factory ConnectionFailure.core(CoreServiceFailure failure) =
      CoreConnectionFailure;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      UnexpectedConnectionFailure() => (
          type: t.failure.connectivity.unexpected,
          message: null,
        ),
      MissingVpnPermission(:final message) => (
          type: t.failure.connectivity.missingVpnPermission,
          message: message
        ),
      MissingNotificationPermission(:final message) => (
          type: t.failure.connectivity.missingNotificationPermission,
          message: message
        ),
      CoreConnectionFailure(:final failure) => failure.present(t),
    };
  }
}
