import 'package:hiddify/core/locale/locale.dart';

// TODO: rewrite
mixin Failure {
  String present(TranslationsEn t);
}

extension ErrorPresenter on TranslationsEn {
  String presentError(Object error) {
    if (error case Failure()) return error.present(this);
    return failure.unexpected;
  }
}
