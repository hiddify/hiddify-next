import 'package:hiddify/core/locale/locale.dart';

// TODO: rewrite
mixin Failure {
  ({String type, String? message}) present(TranslationsEn t);
}

extension ErrorPresenter on TranslationsEn {
  String printError(Object error) {
    if (error case Failure()) {
      final err = error.present(this);
      return err.type + (err.message == null ? "" : ": ${err.message}");
    }
    return failure.unexpected;
  }

  ({String type, String? message}) presentError(Object error) {
    if (error case Failure()) return error.present(this);
    return (type: failure.unexpected, message: null);
  }
}
