import 'package:dio/dio.dart';
import 'package:hiddify/core/prefs/prefs.dart';

mixin Failure {
  ({String type, String? message}) present(TranslationsEn t);
}

extension ErrorPresenter on TranslationsEn {
  String? _errorToMessage(Object error) {
    switch (error) {
      case Failure():
        final err = error.present(this);
        return err.type + (err.message == null ? "" : ": ${err.message}");
      case DioException():
        return error.toString();
      default:
        return null;
    }
  }

  String printError(Object error) =>
      _errorToMessage(error) ?? failure.unexpected;

  String? mayPrintError(Object? error) =>
      error != null ? _errorToMessage(error) : null;

  ({String type, String? message}) presentError(Object error) {
    if (error case Failure()) return error.present(this);
    return (type: failure.unexpected, message: null);
  }
}
