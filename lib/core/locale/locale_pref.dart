import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:hiddify/gen/translations.g.dart';

export 'package:hiddify/gen/translations.g.dart';

enum LocalePref {
  en;

  Locale get locale {
    return Locale(name);
  }

  static List<Locale> get locales =>
      LocalePref.values.map((e) => e.locale).toList();

  static LocalePref fromString(String e) {
    return LocalePref.values.firstOrNullWhere((element) => element.name == e) ??
        LocalePref.en;
  }

  static LocalePref deviceLocale() {
    return LocalePref.fromString(
      AppLocaleUtils.findDeviceLocale().languageCode,
    );
  }

  TranslationsEn translations() {
    final appLocale = AppLocaleUtils.parse(name);
    return appLocale.build();
  }
}
