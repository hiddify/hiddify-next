import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';
import 'package:hiddify/utils/pref_notifier.dart';

export 'package:hiddify/gen/translations.g.dart';

final localeProvider = AlwaysAlivePrefNotifier.provider(
  "locale",
  AppLocale.deviceLocale(),
  mapFrom: AppLocale.values.byName,
  mapTo: (value) => value.name,
);

enum AppLocale {
  en,
  fa;

  Locale get locale {
    return Locale(name);
  }

  static List<Locale> get locales =>
      AppLocale.values.map((e) => e.locale).toList();

  static AppLocale fromString(String e) {
    return AppLocale.values.firstOrNullWhere((element) => element.name == e) ??
        AppLocale.en;
  }

  static AppLocale deviceLocale() {
    return AppLocale.fromString(
      AppLocaleUtils.findDeviceLocale().languageCode,
    );
  }

  TranslationsEn translations() {
    final appLocale = AppLocaleUtils.parse(name);
    return appLocale.build();
  }

  String get preferredFontFamily => this == fa ? FontFamily.shabnam : "";
}
