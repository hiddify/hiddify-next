import 'package:dio/dio.dart';
import 'package:hiddify/core/prefs/prefs.dart';

mixin Failure {
  ({String type, String? message}) present(TranslationsEn t);
}

/// failures ignored by analytics service etc.
mixin ExpectedException {}

extension ErrorPresenter on TranslationsEn {
  String? _errorToMessage(Object error) {
    switch (error) {
      case Failure():
        final err = error.present(this);
        return err.type + (err.message == null ? "" : ": ${err.message}");
      case DioException():
        return error.present(this);
      default:
        return null;
    }
  }

  String printError(Object error) =>
      _errorToMessage(error) ?? failure.unexpected;

  String? mayPrintError(Object? error) =>
      error != null ? _errorToMessage(error) : null;

  ({String type, String? message}) presentError(
    Object error, {
    String? action,
  }) {
    final ({String type, String? message}) presentable;
    if (error case Failure()) {
      presentable = error.present(this);
    } else {
      presentable = (type: failure.unexpected, message: null);
    }
    return (
      type: action == null ? presentable.type : "$action: ${presentable.type}",
      message: presentable.message,
    );
  }
}

extension DioExceptionPresenter on DioException {
  String presentType(TranslationsEn t) => switch (type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          t.failure.connection.timeout,
        DioExceptionType.badCertificate => t.failure.connection.badCertificate,
        DioExceptionType.badResponse => t.failure.connection.badResponse,
        DioExceptionType.connectionError =>
          t.failure.connection.connectionError,
        _ => t.failure.unexpected,
      };

  String present(TranslationsEn t) {
    return presentType(t) + (message == null ? "" : "\n$message");
  }
}
